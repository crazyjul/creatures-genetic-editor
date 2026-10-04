package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;
import creatures.gene.LobeGene;
import creatures.gene.TractGene;

typedef LobeRect = {
    var gene : LobeGene;
    var x : Float;
    var y : Float;
    var w : Float;
    var h : Float;
    var fill : String;
    var textColour : String;
    var label : String;
    var title : String;
}

typedef TractLine = {
    var gene : TractGene;
    /** SVG path: a straight line, or a loop above the lobe when the tract starts and ends in the same lobe. */
    var path : String;
    var migrates : Bool;
    var title : String;
}

/**
 * Draws the brain like the original Vat Kit: lobes as coloured rectangles at their genome
 * coordinates (one unit per neuron) and tracts as arrows from their source to their destination lobe.
 */
class BrainMap extends VComponent<NoneT, Props> {
    static inline var Scale = 10.0;
    static inline var Padding = 36.0;
    static inline var MinThickness = 14.0;

    public function new() {
        super();
        Webpack.require("./BrainMap.css");
    }

    override public function Components() {
        return [];
    }

    override public function Template() {
        return Webpack.require('./BrainMap.html');
    }

    var lobeRects(get, never):Array<LobeRect>;
    var tractLines(get, never):Array<TractLine>;
    var viewBox(get, never):String;

    function get_lobeRects() : Array<LobeRect> {
        return [for(lobe in lobes) {
            var colour = lobe.colour;
            var luminance = 0.299 * colour[0] + 0.587 * colour[1] + 0.114 * colour[2];

            {
                gene : lobe,
                x : lobe.x * Scale,
                y : lobe.y * Scale,
                w : lobe.width * Scale,
                h : Math.max(MinThickness, lobe.height * Scale),
                fill : "rgb(" + colour[0] + "," + colour[1] + "," + colour[2] + ")",
                textColour : luminance > 150 ? "#1f2430" : "#ffffff",
                label : lobe.token,
                title : lobe.token + " - " + lobe.width + " x " + lobe.height + " neurons"
            }
        }];
    }

    function get_viewBox() : String {
        var rects = lobeRects;

        if(rects.length == 0) {
            return "0 0 100 100";
        }

        var minX = Math.POSITIVE_INFINITY;
        var minY = Math.POSITIVE_INFINITY;
        var maxX = Math.NEGATIVE_INFINITY;
        var maxY = Math.NEGATIVE_INFINITY;

        for(r in rects) {
            minX = Math.min(minX, r.x);
            minY = Math.min(minY, r.y);
            maxX = Math.max(maxX, r.x + r.w);
            maxY = Math.max(maxY, r.y + r.h);
        }

        return (minX - Padding) + " " + (minY - Padding) + " " + (maxX - minX + 2 * Padding) + " " + (maxY - minY + 2 * Padding);
    }

    function get_tractLines() : Array<TractLine> {
        var byToken = new Map<String, LobeRect>();

        for(r in lobeRects) {
            byToken[r.gene.token] = r;
        }

        var lines = [];

        for(tract in tracts) {
            var src = byToken[tract.srcLobe];
            var dst = byToken[tract.dstLobe];

            if(src == null || dst == null) {
                continue;
            }

            if(src == dst) {
                // Loop above the lobe, from a third of the way along to two thirds.
                var left = src.x + src.w * 0.35;
                var right = src.x + src.w * 0.65;
                var top = src.y;

                lines.push({
                    gene : tract,
                    path : "M" + left + "," + top + " C" + left + "," + (top - 32) + " " + right + "," + (top - 32) + " " + right + "," + top,
                    migrates : tract.migrates,
                    title : tract.srcLobe + " -> " + tract.dstLobe + " (loops back)"
                });
                continue;
            }

            var sx = src.x + src.w / 2;
            var sy = src.y + src.h / 2;
            var dx = dst.x + dst.w / 2;
            var dy = dst.y + dst.h / 2;

            // Start and end on the rectangle edges rather than at the centres.
            var from = edgePoint(src, dx - sx, dy - sy);
            var to = edgePoint(dst, sx - dx, sy - dy);

            lines.push({
                gene : tract,
                path : "M" + from[0] + "," + from[1] + " L" + to[0] + "," + to[1],
                migrates : tract.migrates,
                title : tract.srcLobe + " -> " + tract.dstLobe
            });
        }

        return lines;
    }

    /** Where a ray leaving the centre of the rectangle in the given direction crosses its border. */
    function edgePoint(rect : LobeRect, directionX : Float, directionY : Float) : Array<Float> {
        var cx = rect.x + rect.w / 2;
        var cy = rect.y + rect.h / 2;

        if(directionX == 0 && directionY == 0) {
            return [cx, cy];
        }

        var tx = directionX != 0 ? (rect.w / 2) / Math.abs(directionX) : Math.POSITIVE_INFINITY;
        var ty = directionY != 0 ? (rect.h / 2) / Math.abs(directionY) : Math.POSITIVE_INFINITY;
        var t = Math.min(tx, ty);

        return [cx + directionX * t, cy + directionY * t];
    }

    function isSelected(gene : Gene) : Bool {
        return selected.indexOf(gene) != -1;
    }

    function toggle(gene : Gene) {
        this._vEmit('toggle', gene);
    }
}

private typedef Props = {
    var lobes : Array<LobeGene>;
    var tracts : Array<TractGene>;
    var selected : Array<Gene>;
};
