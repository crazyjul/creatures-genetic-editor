package model;

import haxevx.vuex.core.IAction;
import haxevx.vuex.core.IModule;
import haxevx.vuex.core.IMutator;
import haxevx.vuex.core.IVxContext.IVxContext;
import haxevx.vuex.core.IVxStoreContext;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VModule;
import store.AppMutator;


class Genome extends VModule<GenomeState, NoneT> {
    public function new() {
        // Initial State
        state = {
            byteArray: null
        };
    }

    public var isValid(get,never):  Bool;

    static function Get_isValid(state:GenomeState):Bool {
        return state.byteArray != null;
    }

    @:action static var action:GenomeDispatcher;
    @:mutator static var mutator:GenomeMutator;
}

typedef GenomeState = {
    var byteArray : Dynamic;
}

class GenomeDispatcher implements IAction<Genome, NoneT> {
    @:mutator static var mutator:GenomeMutator;
}

class GenomeMutator extends AppMutator<GenomeState> implements IMutator<GenomeState> {

}
