package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.VcPropSetting;

class FileSelect extends VComponent<NoneT, Props> {
    public function new() {
        super();
        Webpack.require("./FileSelect.css");
    }

    override public function Components() {
        return [];
    }

    override public function Template() {
        return Webpack.require('./FileSelect.html');
    }

    function handleFileChange(e) {
        // Whenever the file changes, emit the 'input' event with the file data.
        this._vEmit('input', e.target.files[0]);
    }

    override function GetDefaultPropSettings():Dynamic<VcPropSetting> {
        return {
            value:{type:js.html.File}
        };
    }
}

typedef Props = {
    var value: js.html.File;
};

