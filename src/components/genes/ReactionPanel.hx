package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.ReactionGene;

class ReactionPanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./ReactionPanel.html');
    }

    /** Half lives span many orders of magnitude, so large ones are written in scientific notation. */
    function ticks(value : Float) : String {
        if(value >= 1e6) {
            return untyped value.toExponential(2);
        }

        return Std.string(Math.round(value * 10) / 10);
    }
}

private typedef Props = {
    var value: ReactionGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
