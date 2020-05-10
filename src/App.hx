import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.core.VxComponent;
import store.AppStore;

class App extends VxComponent<AppStore, AppData, NoneT> {
    public function new() {
        super();
    }

    override public function Components() {
        return ["file-select"=> new components.FileSelect()];
    }

    override public function Data() :  AppData {
        return { file : null };
    }

    override public function Template() {
        return Webpack.require('./App.html');
    }

    var isValid(get, never):Bool;

    function get_isValid(): Bool {
        return store.genome.isValid;
    }

    @:watch(file) function fileChanged(newValue:js.html.File, oldValue:js.html.File):Void {
        var reader = new js.html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onload =  function(event) {
            var buffer : js.html.ArrayBuffer = event.target.result;
            var bytes =  haxe.io.Bytes.ofData(buffer);
            var genome = new creatures.Genome(bytes);
            trace(genome.isValid());
        }
        reader.onerror = function(event) {
            trace(event);
        };
    }
}

typedef AppData = {
    var file: js.html.File;
}

