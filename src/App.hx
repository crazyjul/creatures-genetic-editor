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
        return { file : null, gnoFile : null, genome : null, selectedGenes : [], genomeNotes : null };
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
        var reader = new js.html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onload =  function(event) {
            var buffer : js.html.ArrayBuffer = event.target.result;
            var bytes =  haxe.io.Bytes.ofData(buffer);
            genome = new creatures.Genome(bytes);
        }
        reader.onerror = function(event) {
            trace(event);
        };
    }

    @:watch(gnoFile) function gnoFileChanged(newValue:js.html.File, oldValue:js.html.File):Void {
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
}

