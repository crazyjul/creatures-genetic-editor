package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

class ExpressionPanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./ExpressionPanel.html');
    }

}

private typedef Props = {
    var value: Gene;
    var notes : creatures.gene.notes.GenomeNotes;
};

