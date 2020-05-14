package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

class GeneView extends VComponent<NoneT, Props> {
    public function new() {
        super();
        Webpack.require("./GeneView.css");
    }

    override public function Components() {
        return [];
    }

    override public function Template() {
        return Webpack.require('./GeneView.html');
    }

}

private typedef Props = {
    var value: Gene;
};

