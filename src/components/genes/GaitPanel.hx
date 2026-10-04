package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.GaitGene;

class GaitPanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./GaitPanel.html');
    }

    function poseLabel(number : Int) : String {
        return GenomeContext.poseLabel(number);
    }
}

private typedef Props = {
    var value: GaitGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
