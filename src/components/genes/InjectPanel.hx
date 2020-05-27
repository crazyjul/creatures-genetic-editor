package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

class InjectPanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./InjectPanel.html');
    }

}

private typedef Props = {
    var value: Gene;
};

