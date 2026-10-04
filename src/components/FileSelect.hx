package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.VcPropSetting;

class FileSelect extends VComponent<Data, Props> {
    public function new() {
        super();
        Webpack.require("./FileSelect.css");
    }

    override public function Components() {
        return [];
    }

    override public function Data() : Data {
        return { dragging : false };
    }

    override public function Template() {
        return Webpack.require('./FileSelect.html');
    }

    function handleFileChange(e) {
        // Whenever the file changes, emit the 'input' event with the file data.
        var file = e.target.files[0];

        if(file != null) {
            this._vEmit('input', file);
        }

        // Allow picking the same file again
        e.target.value = "";
    }

    function handleDrop(e) {
        dragging = false;
        var file = e.dataTransfer.files[0];

        if(file != null) {
            this._vEmit('input', file);
        }
    }

    override function GetDefaultPropSettings():Dynamic<VcPropSetting> {
        return {
            value:{type:js.html.File},
            label:{type:String, required:false},
            hint:{type:String, required:false},
            compact:{type:Bool, required:false}
        };
    }
}

typedef Props = {
    var value: js.html.File;
    var label: String;
    var hint: String;
    var compact: Bool;
};

typedef Data = {
    var dragging: Bool;
}

