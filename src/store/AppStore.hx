package store;

import haxevx.vuex.core.VxStore;
import model.Genome;

class AppStore extends VxStore<AppState> {
    public function new() {
        strict = true;
    }

    @:module public var genome:Genome;
}

class AppState {
    // CAN'T BE HELPED. Need to explicitly declare matching module states within store state manually. Macro will check if state matches.
    @:module public var genome(default, never):Genome;

    public function new() {}
}
