package components;

import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

typedef CompareRow = {
    var name : String;
    var label : String;
    var values : Array<String>;
    var differs : Bool;
}

typedef CompareData = {
    var onlyDifferences : Bool;
}

/**
 * The selected genes side by side: one column per gene, one row per field. Fields are discovered from the
 * genes themselves, so every gene kind is covered; a gene without a field shows a dash.
 */
class CompareView extends VComponent<CompareData, Props> {
    // Shown first, in this order.
    static var HeaderFields = ["id", "generation", "age", "sex", "mutability", "variant"];

    // Not worth a table row: duplicated elsewhere or too long.
    static var Skipped = ["typename", "type", "subtype", "flags", "initRule", "updateRule", "parts"];

    public function new() {
        super();
        Webpack.require("./CompareView.css");
    }

    override public function Components() {
        return [];
    }

    override public function Data() : CompareData {
        return { onlyDifferences : false };
    }

    override public function Template() {
        return Webpack.require('./CompareView.html');
    }

    var rows(get, never):Array<CompareRow>;

    function get_rows() : Array<CompareRow> {
        var names = [];

        for(gene in genes) {
            for(name in propertyNames(gene)) {
                if(Skipped.indexOf(name) == -1 && names.indexOf(name) == -1) {
                    names.push(name);
                }
            }
        }

        // Header fields first, then the rest in the order they were found.
        names = HeaderFields.filter(function(n) return names.indexOf(n) != -1)
            .concat(names.filter(function(n) return HeaderFields.indexOf(n) == -1));

        var result = [];

        for(name in names) {
            var values = [for(gene in genes) cell(gene, name)];
            var differs = values.filter(function(v) return v != values[0]).length > 0;

            if(onlyDifferences && !differs) {
                continue;
            }

            result.push({ name : name, label : humanise(name), values : values, differs : differs });
        }

        return result;
    }

    /**
     * Names of the readable properties of a gene. They are defined on each instance (and wrapped by Vue),
     * so the instance's own properties are read; private fields start with an underscore.
     */
    static function propertyNames(gene : Gene) : Array<String> {
        return js.Syntax.code("(function(g) {
            return Object.getOwnPropertyNames(g).filter(function(n) {
                return n.charAt(0) !== '_' && typeof g[n] !== 'function';
            });
        })({0})", gene);
    }

    static function cell(gene : Gene, name : String) : String {
        return js.Syntax.code("(function(g, n) {
            if (!(n in g)) return '-';
            var v = g[n];
            if (typeof v === 'number') return String(Math.round(v * 1000) / 1000);
            if (typeof v === 'boolean') return v ? 'Yes' : 'No';
            if (v === null || v === undefined) return '-';
            if (typeof v === 'object') return JSON.stringify(v);
            return String(v);
        })({0}, {1})", gene, name);
    }

    /** "bioTickRate" becomes "Bio tick rate". */
    static function humanise(name : String) : String {
        var spaced = ~/([A-Z])/g.replace(name, " $1").toLowerCase();

        return spaced.charAt(0).toUpperCase() + spaced.substr(1);
    }
}

private typedef Props = {
    var genes : Array<Gene>;
    var labels : Array<String>;
};
