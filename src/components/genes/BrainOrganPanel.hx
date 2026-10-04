package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.BrainOrganGene;

class BrainOrganPanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./BrainOrganPanel.html');
    }
}

private typedef Props = {
    var value: BrainOrganGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
