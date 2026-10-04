package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.PoseGene;

typedef FigurePart = {
    var name : String;
    var x : Float;
    var y : Float;
    var width : Float;
    var height : Float;
    var code : String;
    /** "set" for a digit, "keep" for '?' and "none" for 'X'. */
    var state : String;
}

class PosePanel extends VComponent<NoneT, Props> {
    /** Where each body part sits on the figure: x, y, width, height. */
    static var Layout : Map<String, Array<Float>> = [
        "Head" => [62, 8, 36, 34],
        "Body" => [60, 46, 40, 62],
        "Left humerus" => [40, 48, 16, 30],
        "Left radius" => [40, 80, 16, 28],
        "Right humerus" => [104, 48, 16, 30],
        "Right radius" => [104, 80, 16, 28],
        "Left thigh" => [60, 112, 18, 32],
        "Left shin" => [60, 146, 18, 30],
        "Left foot" => [52, 178, 28, 11],
        "Right thigh" => [82, 112, 18, 32],
        "Right shin" => [82, 146, 18, 30],
        "Right foot" => [80, 178, 28, 11],
        "Tail root" => [102, 104, 26, 10],
        "Tail tip" => [130, 104, 26, 10]
    ];

    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./PosePanel.html');
    }

    var figure(get, never):Array<FigurePart>;

    function get_figure() : Array<FigurePart> {
        var result = [];

        for(part in value.parts) {
            var box = Layout[part.name];

            if(box == null) {
                continue;
            }

            result.push({
                name : part.name,
                x : box[0], y : box[1], width : box[2], height : box[3],
                code : part.code,
                state : part.code == "?" ? "keep" : (part.code == "X" ? "none" : "set")
            });
        }

        return result;
    }

    var direction(get, never):String;

    /** The first character of the pose string: which way the creature faces. */
    function get_direction() : String {
        return value.parts[0].code;
    }
}

private typedef Props = {
    var value: PoseGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
