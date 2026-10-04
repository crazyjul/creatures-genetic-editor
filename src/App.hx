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
            view : "genes", compare : false, theme : "light", cursorKey : "",
            editVersion : 0, lastEditKey : "", lastEditTime : 0.0, ignoreFileChange : false,
            chemical : -1, chemicalSearch : "", usedOnly : true, copied : "",
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

        components.GenomeContext.onEdit = applyEdit;
        components.GenomeContext.onRevert = revertGene;
    }

    override function Mounted() : Void {
        js.Browser.document.addEventListener("keydown", onKeyDown);

        // Closing the page would lose the edits, so the browser is asked to confirm.
        js.Browser.window.addEventListener("beforeunload", function(event : js.html.Event) {
            if(genome != null && genome.isModifiedAtAll()) {
                event.preventDefault();
                untyped event.returnValue = "";
            }
        });
    }

    // ---------- editing ----------

    /**
     * A gene is being changed through GenomeContext.edit. If the change alters the bytes, the state before it
     * is recorded for undo, then the gene is rebuilt from the genome's bytes and put in the lists in place of
     * the old one: a new object is what makes everything that shows the gene (list, cards, map, chemicals)
     * refresh. Quick edits with the same key (dragging a number) share one undo step.
     */
    function applyEdit(gene : Gene, change : Void -> Void, key : String) : Void {
        if(genome == null) {
            return;
        }

        var index = genes.indexOf(gene);

        if(index == -1) {
            return;
        }

        var before = genome.toBytes();
        freeze(before);

        change();

        // Controls can report a value they already had (a number box does so when it appears). Nothing
        // changed then, so there is nothing to undo and nothing to refresh.
        if(genome.toBytes().compare(before) == 0) {
            return;
        }

        var now = Date.now().getTime();

        if(key == null || key != lastEditKey || now - lastEditTime > 1500) {
            genome.recordUndo(before);
        }

        lastEditKey = key;
        lastEditTime = now;

        swapGene(index);
        afterEdit();
    }

    /** Rebuilds the gene at this position and puts it in place of the old object everywhere it is held. */
    function swapGene(index : Int) : Void {
        var old = genes[index];
        var fresh = genome.refresh(index);

        // splice, because Vue only notices changes made through the array's own methods
        replaceIn(genes, index, fresh);

        var selected = selectedGenes.indexOf(old);

        if(selected != -1) {
            replaceIn(selectedGenes, selected, fresh);
        }
    }

    static function replaceIn(list : Array<Gene>, position : Int, gene : Gene) : Void {
        js.Syntax.code("{0}.splice({1}, 1, {2})", list, position, gene);
    }

    function afterEdit() : Void {
        editVersion++;
        components.GenomeContext.update(genome, genomeNotes);
    }

    function undo() : Void {
        if(genome == null) {
            return;
        }

        for(index in genome.undo()) {
            swapGene(index);
        }

        lastEditKey = "";
        afterEdit();
    }

    function redo() : Void {
        if(genome == null) {
            return;
        }

        for(index in genome.redo()) {
            swapGene(index);
        }

        lastEditKey = "";
        afterEdit();
    }

    function revertGene(gene : Gene) : Void {
        var index = genes.indexOf(gene);

        if(genome == null || index == -1) {
            return;
        }

        for(changed in genome.revert(index)) {
            swapGene(changed);
        }

        lastEditKey = "";
        afterEdit();
    }

    function revertAll() : Void {
        if(genome == null || !js.Browser.window.confirm("Put every gene back to how it was loaded?")) {
            return;
        }

        for(changed in genome.revertAll()) {
            swapGene(changed);
        }

        lastEditKey = "";
        afterEdit();
    }

    /** The genome with the edits, as a file named after the one that was opened. */
    function saveGenome() : Void {
        if(genome == null) {
            return;
        }

        var name = file != null ? file.name : "genome.gen";
        var dot = name.lastIndexOf(".");
        var saved = dot > 0 ? name.substr(0, dot) + "-edited" + name.substr(dot) : name + "-edited";

        components.GeneExport.downloadBytes(saved, genome.toBytes());
    }

    var modifiedList(get, never):Array<Int>;

    /** Positions of the genes that differ from the loaded genome. */
    function get_modifiedList() : Array<Int> {
        // editVersion is read so that the list is worked out again after every edit
        return genome != null && editVersion >= 0 ? genome.modifiedGenes() : [];
    }

    var canUndo(get, never):Bool;

    function get_canUndo() : Bool {
        return genome != null && editVersion >= 0 && genome.canUndo();
    }

    var canRedo(get, never):Bool;

    function get_canRedo() : Bool {
        return genome != null && editVersion >= 0 && genome.canRedo();
    }

    function isModified(index : Int) : Bool {
        return modifiedList.indexOf(index) != -1;
    }

    /**
     * List shortcuts: arrows and Home/End move the cursor, Enter or Space selects, "/" searches and
     * Escape clears the search. Ignored while typing in a field, or with a modifier held.
     */
    function onKeyDown(event : js.html.KeyboardEvent) : Void {
        var target : js.html.Element = cast event.target;
        var tag = target != null ? target.tagName : "";
        var typing = tag == "INPUT" || tag == "TEXTAREA" || tag == "SELECT" || (target != null && target.isContentEditable);

        // Ctrl+Z undoes, Ctrl+Y or Ctrl+Shift+Z redoes, Ctrl+S saves. Inside a field the browser keeps its own undo.
        if(event.ctrlKey || event.metaKey) {
            var letter = event.key.toLowerCase();

            if(isValid && !typing) {
                if(letter == "z" && !event.shiftKey) {
                    event.preventDefault();
                    undo();
                } else if(letter == "y" || (letter == "z" && event.shiftKey)) {
                    event.preventDefault();
                    redo();
                }
            }

            if(isValid && letter == "s") {
                event.preventDefault();
                saveGenome();
            }

            return;
        }

        if(event.altKey) {
            return;
        }

        if(event.key == "Escape") {
            if(search != "") {
                search = "";
            }

            if(typing) {
                target.blur();
            }

            return;
        }

        if(!isValid || view != "genes" || typing) {
            return;
        }

        switch(event.key) {
            case "/":
                event.preventDefault();
                var box : js.html.InputElement = cast js.Browser.document.querySelector(".toolbar input");

                if(box != null) {
                    box.focus();
                }
            case "ArrowDown":
                event.preventDefault();
                moveCursor(1);
            case "ArrowUp":
                event.preventDefault();
                moveCursor(-1);
            case "Home":
                event.preventDefault();
                moveCursorTo(0);
            case "End":
                event.preventDefault();
                moveCursorTo(-1);
            case "Enter" | " ":
                // A focused button handles these itself.
                if(tag != "BUTTON") {
                    event.preventDefault();
                    toggleCursor();
                }
        }
    }

    function geneItems() : Array<ListItem> {
        return items.filter(function(item) return !item.isGroup);
    }

    function moveCursor(delta : Int) : Void {
        var list = geneItems();

        if(list.length == 0) {
            return;
        }

        var current = -1;

        for(i in 0...list.length) {
            if(list[i].key == cursorKey) {
                current = i;
                break;
            }
        }

        var next = current == -1 ? (delta > 0 ? 0 : list.length - 1) : current + delta;
        moveCursorTo(next < 0 ? 0 : (next >= list.length ? list.length - 1 : next));
    }

    /** Moves to the given position among the visible genes; -1 means the last one. */
    function moveCursorTo(position : Int) : Void {
        var list = geneItems();

        if(list.length == 0) {
            return;
        }

        cursorKey = list[position == -1 ? list.length - 1 : position].key;

        // Wait for the row to be marked before scrolling to it.
        js.Browser.window.setTimeout(function() {
            var row = js.Browser.document.querySelector("tr.cursor");

            if(row != null) {
                untyped row.scrollIntoView({ block : "nearest" });
            }
        }, 0);
    }

    function toggleCursor() : Void {
        for(item in geneItems()) {
            if(item.key == cursorKey) {
                toggleGeneSelection(item.gene);
                return;
            }
        }
    }

    /** A click both moves the cursor and toggles the gene, so keyboard use can continue from there. */
    function selectRow(item : ListItem) : Void {
        cursorKey = item.key;
        toggleGeneSelection(item.gene);
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

    var chemicalUsage(get, never):Map<Int, Array<creatures.ChemicalUsage.ChemicalUse>>;

    function get_chemicalUsage() : Map<Int, Array<creatures.ChemicalUsage.ChemicalUse>> {
        return creatures.ChemicalUsage.collect(genes);
    }

    /** One line per chemical that is named in the game's list or used by a gene. */
    var chemicalRows(get, never):Array<ChemicalRow>;

    function get_chemicalRows() : Array<ChemicalRow> {
        var usage = chemicalUsage;
        var needle = chemicalSearch.toLowerCase();
        var result = [];

        for(id in 1...256) {
            var uses = usage.exists(id) ? usage[id] : [];

            if(uses.length == 0 && (usedOnly || !creatures.Chemicals.isKnown(id))) {
                continue;
            }

            var name = creatures.Chemicals.name(id);

            if(needle != "" && name.toLowerCase().indexOf(needle) == -1 && Std.string(id) != needle) {
                continue;
            }

            result.push({ id : id, name : name, count : uses.length, summary : summariseUses(uses) });
        }

        return result;
    }

    /** "2 reactant, 1 receptor" */
    function summariseUses(uses : Array<creatures.ChemicalUsage.ChemicalUse>) : String {
        var counts = new Map<String, Int>();
        var order = [];

        for(use in uses) {
            if(!counts.exists(use.role)) {
                counts[use.role] = 0;
                order.push(use.role);
            }

            counts[use.role] += 1;
        }

        return order.map(function(role) return counts[role] + " " + role).join(", ");
    }

    /** The genes that use the chemical chosen in the Chemicals view. */
    var chemicalUses(get, never):Array<ChemicalUseRow>;

    function get_chemicalUses() : Array<ChemicalUseRow> {
        var usage = chemicalUsage;

        if(chemical < 1 || !usage.exists(chemical)) {
            return [];
        }

        return [for(use in usage[chemical]) {
            key : use.index + use.role,
            role : use.role,
            index : use.index,
            gene : use.gene,
            label : describe(use.gene)
        }];
    }

    function chemicalName(id : Int) : String {
        return creatures.Chemicals.label(id);
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

    // The counts below are computed properties, not methods called from the template: a template method
    // that loops over every gene registers a dependency for each read, and the timeline alone did that
    // about 70 times per render. A computed property is worked out once, when the genes or filters change.

    /**
     * The life stages with the number of genes switching on then (among those passing the kind and
     * search filters) and the height of each bar as a percentage of the busiest stage.
     */
    var ageStages(get, never):Array<AgeStage>;

    function get_ageStages() : Array<AgeStage> {
        var needle = search.toLowerCase();
        var counts = new Map<String, Int>();

        for(stage in ages) {
            counts[stage.value] = 0;
        }

        for(i in 0...genes.length) {
            var gene = genes[i];

            if(matchesKindAndSearch(gene, i, needle)) {
                var age = ageOf(gene);

                if(counts.exists(age)) {
                    counts[age] += 1;
                }
            }
        }

        var most = 0;

        for(stage in ages) {
            most = Std.int(Math.max(most, counts[stage.value]));
        }

        return [for(stage in ages) {
            value : stage.value,
            label : stage.label,
            count : counts[stage.value],
            share : most == 0 ? 0.0 : counts[stage.value] * 100.0 / most
        }];
    }

    /** The kind filter chips with the number of genes of each kind. */
    var kindChips(get, never):Array<KindChip>;

    function get_kindChips() : Array<KindChip> {
        var counts = new Map<Int, Int>();

        for(gene in genes) {
            counts[gene.type] = counts.exists(gene.type) ? counts[gene.type] + 1 : 1;
        }

        return [for(kind in kinds) {
            type : kind.type,
            label : kind.label,
            count : kind.type == -1 ? genes.length : (counts.exists(kind.type) ? counts[kind.type] : 0)
        }];
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

    function clearSelection() {
        selectedGenes = [];
    }

    function selectionJson() : String {
        return components.GeneExport.toJson(selectedGenes, selectedLabels);
    }

    /** The selected genes as a JSON file named after the genome. */
    function exportSelection() : Void {
        var base = "genome";

        if(file != null) {
            // Drop the last extension: "norn.gen" becomes "norn".
            var dot = file.name.lastIndexOf(".");
            base = dot > 0 ? file.name.substr(0, dot) : file.name;
        }

        components.GeneExport.download(base + "-selection.json", selectionJson());
    }

    function copySelection() : Void {
        components.GeneExport.copy(selectionJson(), function(ok : Bool) {
            copied = ok ? "Copied" : "Copy failed";
            js.Browser.window.setTimeout(function() { copied = ""; }, 1800);
        });
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

    /** Stops Vue from making the object reactive. Only the object itself is frozen, not what it refers to. */
    static function freeze(thing : Dynamic) : Void {
        js.Syntax.code("Object.freeze({0})", thing);
    }

    @:watch(file) function fileChanged(newValue:js.html.File, oldValue:js.html.File):Void {
        if(ignoreFileChange) {
            // This is the change made below to put the old file back.
            ignoreFileChange = false;
            return;
        }

        if(file == null) {
            return;
        }

        if(genome != null && genome.isModifiedAtAll()
            && !js.Browser.window.confirm("This genome has unsaved changes. Open another genome and lose them?")) {
            ignoreFileChange = true;
            file = oldValue;
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
            cursorKey = "";
            chemical = -1;
            collapsed = [];
            lastEditKey = "";
            editVersion++;
            view = "genes";

            // The bytes change, but not in a way Vue could follow (it only sees properties being assigned);
            // the app refreshes by replacing gene objects instead. Freezing keeps Vue from wrapping them.
            freeze(bytes);
            var loaded = new creatures.Genome(bytes);
            freeze(untyped loaded._original);
            genome = loaded;
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
            var loaded = new creatures.gene.notes.GenomeNotes();
            loaded.load(bytes);

            // Notes never change after loading, and lookups happen for every row of every render, so Vue
            // must not wrap the 1800 notes and the tree that indexes them.
            freeze(loaded);
            genomeNotes = loaded;
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
    var cursorKey: String;
    /** Goes up with every change to the genome, so that what depends on its bytes is worked out again. */
    var editVersion: Int;
    var lastEditKey: String;
    var lastEditTime: Float;
    var ignoreFileChange: Bool;
    var copied: String;
    var chemical: Int;
    var chemicalSearch: String;
    var usedOnly: Bool;
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

typedef AgeStage = {
    var value: String;
    var label: String;
    var count: Int;
    var share: Float;
}

typedef KindChip = {
    var type: Int;
    var label: String;
    var count: Int;
}

typedef ChemicalRow = {
    var id: Int;
    var name: String;
    var count: Int;
    var summary: String;
}

typedef ChemicalUseRow = {
    var key: String;
    var role: String;
    var index: Int;
    var gene: Gene;
    var label: String;
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

