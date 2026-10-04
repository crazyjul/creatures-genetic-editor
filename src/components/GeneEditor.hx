package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.Chemicals;
import creatures.gene.Gene;
import creatures.gene.GeneField;

typedef ChemicalOption = {
    var value : Int;
    var label : String;
}

/**
 * Edits any gene: a form built from the gene's own list of fields, and its raw bytes for the values
 * that have no field of their own. Every change goes through GenomeContext.edit, so it is undoable.
 */
class GeneEditor extends VComponent<NoneT, Props> {
    static var chemicalOptions : Array<ChemicalOption>;

    public function new() {
        super();
        Webpack.require("./GeneEditor.css");
    }

    override public function Components() {
        return [];
    }

    override public function Template() {
        return Webpack.require('./GeneEditor.html');
    }

    var fields(get, never):Array<GeneField>;

    function get_fields() : Array<GeneField> {
        return gene.fields();
    }

    var bodyBytes(get, never):Array<Int>;

    function get_bodyBytes() : Array<Int> {
        return gene.bodyBytes();
    }

    /** Every chemical, named where the game names it. Built once: there are 256 of them. */
    var chemicals(get, never):Array<ChemicalOption>;

    function get_chemicals() : Array<ChemicalOption> {
        if(chemicalOptions == null) {
            chemicalOptions = [{ value : 0, label : "none (0)" }];

            for(id in 1...256) {
                chemicalOptions.push({ value : id, label : Chemicals.isKnown(id) ? Chemicals.label(id) : "Chemical " + id });
            }
        }

        return chemicalOptions;
    }

    function current(field : GeneField) : Dynamic {
        return gene.getFieldValue(field);
    }

    /** A key that is the same for quick successive edits of the same value, and only then. */
    function editKey(what : String) : String {
        return gene.type + "." + gene.subtype + "." + gene.id + ":" + what;
    }

    function commit(field : GeneField, value : Dynamic) : Void {
        // An emptied number box reports null; there is nothing to write then.
        if(value == null) {
            return;
        }

        GenomeContext.edit(gene, function() {
            gene.setFieldValue(field, value);
        }, editKey(field.name));
    }

    function commitByte(position : Int, text : String) : Void {
        var value = Std.parseInt(text);

        if(value == null) {
            return;
        }

        GenomeContext.edit(gene, function() {
            gene.setBodyByte(position, value);
        }, editKey("byte" + position));
    }
}

private typedef Props = {
    var gene : Gene;
};
