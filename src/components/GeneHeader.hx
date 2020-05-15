package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

class GeneHeader extends VComponent<NoneT, Props> {
    public function new() {
        super();
        Webpack.require("./GeneHeader.css");
    }

    override public function Components() {
        return [];
    }

    override public function Template() {
        return Webpack.require('./GeneHeader.html');
    }

}

private typedef Props = {
    var value: Gene;
};

