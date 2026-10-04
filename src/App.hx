import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;
import components.GeneView;

class App extends VComponent<AppData, NoneT> {

    public function new() {
        super();
        Webpack.require("./App.css");
    }

    override public function Components() {
        return ["file-select"=> new components.FileSelect(), "gene-view" => new GeneView() ];
    }

    override public function Data() :  AppData {
        return {
            file : null, gnoFile : null, genome : null, selectedGenes : [], genomeNotes : null,
            search : "", kindFilter : -1,
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

    var rows(get, never):Array<GeneRow>;

    function get_rows() : Array<GeneRow> {
        var result = [];
        var needle = search.toLowerCase();

        for(i in 0...genes.length) {
            var gene = genes[i];

            if(kindFilter != -1 && gene.type != kindFilter) {
                continue;
            }

            if(needle != "" && !matches(gene, i, needle)) {
                continue;
            }

            result.push({ index : i, gene : gene });
        }

        return result;
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
            genome = new creatures.Genome(bytes);
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
    var search: String;
    var kindFilter: Int;
    var kinds: Array<Dynamic>;
}

typedef GeneRow = {
    var index: Int;
    var gene: Gene;
}

