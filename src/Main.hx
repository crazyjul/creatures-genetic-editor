import haxevx.vuex.core.VxBoot;
import haxevx.vuex.native.Vue;

class Main {
    public function new() {
        var vue = Reflect.field(Webpack.require("vue"), "default");
        js.Lib.global.Vue = vue;
        js.Lib.global.Vuex = Webpack.require("vuex");
        //var boot:VxBoot = new VxBoot();
        //boot.startStore(new store.AppStore());
        //boot.startVueWithRootComponent("#app", new App());
        //Do not use vuex at the moment
        Vue.filter('to_string', function(a) {
            return Std.string(a);
        });

        new Vue(new App());
    }

    static function main() {
        new Main();
    }
}
