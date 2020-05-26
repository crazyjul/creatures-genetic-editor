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
        return ["gene-header" => new GeneHeader(),
        "Organ-panel" => new components.genes.OrganPanel(),
        "Receptor-panel" => new components.genes.ReceptorPanel(),
        "Genus-panel" => new components.genes.GenusPanel()];
    }

    override public function Template() {
        return Webpack.require('./GeneView.html');
    }

}

private typedef Props = {
    var value: Array<Gene>;
};

