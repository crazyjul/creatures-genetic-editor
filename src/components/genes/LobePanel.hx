package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.LobeGene;

class LobePanel extends VComponent<NoneT, Props> {
    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./LobePanel.html');
    }

    /** A rectangle with the lobe's aspect ratio and colour, split into one cell per neuron when that is readable. */
    var previewStyle(get, never):String;

    function get_previewStyle() : String {
        var colour = value.colour;
        var style = "background-color:rgb(" + colour[0] + "," + colour[1] + "," + colour[2] + ");"
            + "aspect-ratio:" + value.width + "/" + value.height + ";";

        if(value.width <= 64 && value.height <= 64) {
            style += "background-size:calc(100% / " + value.width + ") calc(100% / " + value.height + ");";
        } else {
            style += "background-image:none;";
        }

        return style;
    }
}

private typedef Props = {
    var value: LobeGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
