import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.core.VxComponent;
import store.AppStore;

class App extends VxComponent<AppStore, NoneT, NoneT> {
	public function new() {
		super();
	}

	override public function Components() {
		return [];
	}

	override public function Template() {
		return Webpack.require('./App.html');
	}
}
