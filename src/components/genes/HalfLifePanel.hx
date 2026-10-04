package components.genes;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.HalfLifeGene;

typedef HalfLifeBar = {
    var chemical : Int;
    var x : Float;
    var height : Float;
    var instant : Bool;
    var title : String;
}

class HalfLifePanel extends VComponent<NoneT, Props> {
    static inline var ChartHeight = 100.0;
    // Decay rates run from 0 to 32, the exponent of the half life.
    static inline var MaxRate = 32.0;

    public function new() {
        super();
    }

    override public function Components() {
        return [ "gene-header" => new components.GeneHeader() ];
    }

    override public function Template() {
        return Webpack.require('./HalfLifePanel.html');
    }

    var bars(get, never):Array<HalfLifeBar>;

    function get_bars() : Array<HalfLifeBar> {
        var rates = value.decayRates;
        var halfLives = value.halfLives;

        return [for(i in 0...rates.length) {
            chemical : i,
            x : i * 2.0,
            height : Math.max(1.0, rates[i] / MaxRate * ChartHeight),
            instant : rates[i] == 0,
            title : creatures.Chemicals.label(i) + ": " + (rates[i] == 0 ? "vanishes at once" : "half life " + ticks(halfLives[i]) + " ticks")
        }];
    }

    var instantCount(get, never):Int;

    function get_instantCount() : Int {
        return value.decayRates.filter(function(rate) return rate == 0).length;
    }

    var slowest(get, never):Int;

    /** The chemical that lasts the longest. */
    function get_slowest() : Int {
        var best = 0;
        var rates = value.decayRates;

        for(i in 0...rates.length) {
            if(rates[i] > rates[best]) {
                best = i;
            }
        }

        return best;
    }

    function ticks(halfLife : Float) : String {
        if(halfLife >= 1e6) {
            return untyped halfLife.toExponential(2);
        }

        return Std.string(Math.round(halfLife * 10) / 10);
    }
}

private typedef Props = {
    var value: HalfLifeGene;
    var notes : creatures.gene.notes.GenomeNotes;
};
