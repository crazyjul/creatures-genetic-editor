package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.PoseGene;

class PosePanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./PosePanel.html');
    }
}

private typedef Props = {
    var value: PoseGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
