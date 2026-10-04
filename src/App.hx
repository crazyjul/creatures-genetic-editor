import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;
import creatures.gene.LobeGene;
import creatures.gene.TractGene;
import components.GeneView;

class App extends VComponent<AppData, NoneT> {

    public function new() {
        super();
        Webpack.require("./App.css");
    }

    override public function Components() {
        return [
            "file-select" => new components.FileSelect(),
            "gene-view" => new GeneView(),
            "brain-map" => new components.BrainMap(),
            "compare-view" => new components.CompareView()
        ];
    }

    override public function Data() :  AppData {
        return {
            file : null, gnoFile : null, genome : null, selectedGenes : [], genomeNotes : null,
            view : "genes", compare : false, theme : "light",
            grouped : false, collapsed : [],
            search : "", kindFilter : -1, ageFilter : "",
            ages : [
                { value : "Embryo", label : "Embryo" },
                { value : "Child", label : "Child" },
                { value : "Adolescent", label : "Adolescent" },
                { value : "Youth", label : "Youth" },
                { value : "Adult", label : "Adult" },
                { value : "Old", label : "Old" },
                { value : "Senile", label : "Senile" }
            ],
            kinds : [
                { type : -1, label : "All" },
                { type : 0, label : "Brain" },
                { type : 1, label : "Biochemistry" },
                { type : 2, label : "Creature" },
                { type : 3, label : "Organ" }
            ]
        };
    }

    override public function Template() {
        return Webpack.require('./App.html');
    }

    static inline var ThemeStorageKey = "gene-editor-theme";

    /** Starts from the saved choice, otherwise from the system setting. */
    override function Created() : Void {
        var stored : String = null;

        try {
            stored = js.Browser.getLocalStorage().getItem(ThemeStorageKey);
        } catch(e : Dynamic) {
            // Storage can be blocked (private windows); the theme then simply is not remembered.
        }

        if(stored == "dark" || stored == "light") {
            theme = stored;
        } else {
            theme = js.Browser.window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
        }

        applyTheme();
    }

    function applyTheme() {
        js.Browser.document.documentElement.setAttribute("data-theme", theme);
    }

    function toggleTheme() {
        theme = theme == "dark" ? "light" : "dark";
        applyTheme();

        try {
            js.Browser.getLocalStorage().setItem(ThemeStorageKey, theme);
        } catch(e : Dynamic) {
        }
    }

    override function El():String {
        return "#app";
    }

    var isValid(get, never):Bool;

    function get_isValid(): Bool {
        return genome != null &&  genome.isValid();
    }

    var genes(get, never):Array<Gene>;

    function get_genes() : Array<Gene> {
        if(genome == null) {
            return [];
        }

        return genome.genes;
    }

    var lobeGenes(get, never):Array<LobeGene>;
    var tractGenes(get, never):Array<TractGene>;

    function get_lobeGenes() : Array<LobeGene> {
        return [for(gene in genes) if(Std.isOfType(gene, LobeGene)) cast gene];
    }

    function get_tractGenes() : Array<TractGene> {
        return [for(gene in genes) if(Std.isOfType(gene, TractGene)) cast gene];
    }

    var rows(get, never):Array<GeneRow>;

    function get_rows() : Array<GeneRow> {
        var result = [];
        var needle = search.toLowerCase();

        for(i in 0...genes.length) {
            var gene = genes[i];

            if(!matchesKindAndSearch(gene, i, needle)) {
                continue;
            }

            if(ageFilter != "" && ageOf(gene) != ageFilter) {
                continue;
            }

            result.push({ index : i, gene : gene });
        }

        return result;
    }

    function matchesKindAndSearch(gene : Gene, index : Int, needle : String) : Bool {
        if(kindFilter != -1 && gene.type != kindFilter) {
            return false;
        }

        return needle == "" || matches(gene, index, needle);
    }

    function ageOf(gene : Gene) : String {
        return cast gene.age;
    }

    /** Genes switching on at the given life stage, among those passing the kind and search filters. */
    function ageCount(age : String) : Int {
        var needle = search.toLowerCase();
        var count = 0;

        for(i in 0...genes.length) {
            if(ageOf(genes[i]) == age && matchesKindAndSearch(genes[i], i, needle)) {
                ++count;
            }
        }

        return count;
    }

    /** Height of a life stage's bar, as a percentage of the busiest stage. */
    function ageShare(age : String) : Float {
        var most = 0;

        for(stage in ages) {
            most = Std.int(Math.max(most, ageCount(stage.value)));
        }

        return most == 0 ? 0 : ageCount(age) * 100.0 / most;
    }

    static var CreatureKinds = [
        "Stimuli", "Species", "Appearance", "Poses", "Gaits", "Instincts", "Pigments", "Pigment bleeds", "Expressions"
    ];

    /**
     * Every gene belongs to one group. Receptors, emitters and reactions belong to the organ gene that
     * precedes them; the other genes are grouped by kind. Groups are listed in order of first appearance.
     */
    function buildGroups() : Array<GeneGroup> {
        var groups = new Array<GeneGroup>();
        var byKey = new Map<String, GeneGroup>();
        var currentOrgan : GeneGroup = null;

        function group(key : String, label : String) : GeneGroup {
            var found = byKey[key];

            if(found == null) {
                found = { key : key, label : label, members : [] };
                byKey[key] = found;
                groups.push(found);
            }

            return found;
        }

        for(i in 0...genes.length) {
            var gene = genes[i];
            var target : GeneGroup;

            if(gene.type == 3) {
                currentOrgan = group("organ-" + i, describe(gene));
                target = currentOrgan;
            } else if(gene.type == 1 && gene.subtype <= 2) {
                target = currentOrgan != null ? currentOrgan : group("biochemistry", "Biochemistry");
            } else if(gene.type == 1) {
                target = group("biochemistry-global", "Biochemistry: half lives, concentrations, neuro emitters");
            } else if(gene.type == 0) {
                target = group("brain", "Brain");
            } else if(gene.type == 2) {
                var kind = gene.subtype < CreatureKinds.length ? CreatureKinds[gene.subtype] : "Other";
                target = group("creature-" + gene.subtype, "Creature: " + kind);
            } else {
                target = group("other", "Other");
            }

            target.members.push({ index : i, gene : gene });
        }

        return groups;
    }

    var items(get, never):Array<ListItem>;

    function get_items() : Array<ListItem> {
        var matching = new Map<Int, Bool>();

        for(row in rows) {
            matching[row.index] = true;
        }

        if(!grouped) {
            return [for(row in rows) { key : "g" + row.index, isGroup : false, groupKey : "", label : "", count : 0, open : true, index : row.index, gene : row.gene }];
        }

        var result = [];
        var searching = search != "";

        for(group in buildGroups()) {
            var visible = group.members.filter(function(m) return matching.exists(m.index));

            if(visible.length == 0) {
                continue;
            }

            var open = searching || collapsed.indexOf(group.key) == -1;
            result.push({ key : "h-" + group.key, isGroup : true, groupKey : group.key, label : group.label, count : visible.length, open : open, index : -1, gene : null });

            if(open) {
                for(m in visible) {
                    result.push({ key : "g" + m.index, isGroup : false, groupKey : group.key, label : "", count : 0, open : true, index : m.index, gene : m.gene });
                }
            }
        }

        return result;
    }

    function toggleGroup(key : String) {
        if(collapsed.indexOf(key) == -1) {
            collapsed.push(key);
        } else {
            collapsed.remove(key);
        }
    }

    function collapseAll() {
        collapsed = [for(group in buildGroups()) group.key];
    }

    function expandAll() {
        collapsed = [];
    }

    function matches(gene : Gene, index : Int, needle : String) : Bool {
        return describe(gene).toLowerCase().indexOf(needle) != -1
            || Std.string(gene.id) == needle
            || Std.string(index) == needle;
    }

    function describe(gene : Gene) : String {
        if(genomeNotes != null) {
            var note = genomeNotes.getDescription(gene.type, gene.subtype, gene.id);

            if(note != "") {
                return note;
            }
        }

        return untyped gene.getName();
    }

    function kindCount(type : Int) : Int {
        if(type == -1) {
            return genes.length;
        }

        var count = 0;

        for(gene in genes) {
            if(gene.type == type) {
                ++count;
            }
        }

        return count;
    }

    function clearSelection() {
        selectedGenes = [];
    }

    var selectedLabels(get, never):Array<String>;

    function get_selectedLabels() : Array<String> {
        return [for(gene in selectedGenes) describe(gene)];
    }

    function toggleGeneSelection(selected : Gene) {
        var gene_index = selectedGenes.indexOf(selected);

        if(gene_index == -1) {
            selectedGenes.push(selected);
        } else {
            selectedGenes.remove(selected);
        }
    }

    function isSelected(item : Gene) : Bool {
        return selectedGenes.indexOf(item) != -1;
    }

    @:watch(file) function fileChanged(newValue:js.html.File, oldValue:js.html.File):Void {
        if(file == null) {
            return;
        }

        var reader = new js.html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onload =  function(event) {
            var buffer : js.html.ArrayBuffer = event.target.result;
            var bytes =  haxe.io.Bytes.ofData(buffer);
            selectedGenes = [];
            search = "";
            kindFilter = -1;
            ageFilter = "";
            collapsed = [];
            view = "genes";
            genome = new creatures.Genome(bytes);
            components.GenomeContext.update(genome, genomeNotes);
        }
        reader.onerror = function(event) {
            trace(event);
        };
    }

    @:watch(gnoFile) function gnoFileChanged(newValue:js.html.File, oldValue:js.html.File):Void {
        if(gnoFile == null) {
            return;
        }

        var reader = new js.html.FileReader();
        reader.readAsArrayBuffer(gnoFile);
        reader.onload =  function(event) {
            var buffer : js.html.ArrayBuffer = event.target.result;
            var bytes =  haxe.io.Bytes.ofData(buffer);
            genomeNotes = new creatures.gene.notes.GenomeNotes();
            genomeNotes.load(bytes);
            components.GenomeContext.update(genome, genomeNotes);
        }
        reader.onerror = function(event) {
            trace(event);
        };
    }
}

typedef AppData = {
    var file: js.html.File;
    var gnoFile: js.html.File;
    var genome: creatures.Genome;
    var genomeNotes: creatures.gene.notes.GenomeNotes;
    var selectedGenes: Array<creatures.gene.Gene>;
    var view: String;
    var compare: Bool;
    var theme: String;
    var grouped: Bool;
    var collapsed: Array<String>;
    var search: String;
    var kindFilter: Int;
    var ageFilter: String;
    var ages: Array<Dynamic>;
    var kinds: Array<Dynamic>;
}

typedef GeneRow = {
    var index: Int;
    var gene: Gene;
}

typedef GeneGroup = {
    var key: String;
    var label: String;
    var members: Array<GeneRow>;
}

/** A table line: either a gene or, when the list is grouped, a group header. */
typedef ListItem = {
    var key: String;
    var isGroup: Bool;
    var groupKey: String;
    var label: String;
    var count: Int;
    var open: Bool;
    var index: Int;
    var gene: Gene;
}

