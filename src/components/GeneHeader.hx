package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Age;
import creatures.gene.Gene;
import creatures.gene.GeneFlag;

class GeneHeader extends VComponent<Data, Props> {
    public function new() {
        super();
        Webpack.require("./GeneHeader.css");
    }

    override public function Components() {
        return [ "gene-editor" => new GeneEditor() ];
    }

    override public function Template() {
        return Webpack.require('./GeneHeader.html');
    }

    override public function Data() : Data {
        return  {
            ageOptions : [
            {value: Age.Embryo, label : "Embryo"},
            {value: Age.Child, label : "Child"},
            {value: Age.Adolescent, label : "Adolescent"},
            {value: Age.Youth, label : "Youth"},
            {value: Age.Adult, label : "Adult"},
            {value: Age.Old, label : "Old"},
            {value: Age.Senile, label : "Senile"},
            ]
        };
    }

    // Every control below is a computed value with a setter, so that v-model works and each change is an
    // edit the app can undo. The gene is replaced after an edit, so `value` is read when the edit happens.

    var ageChoice(get, set):String;
    var sexChoice(get, set):String;
    var mutabilityValue(get, set):Int;
    var duplicate(get, set):Bool;
    var mutate(get, set):Bool;
    var cut(get, set):Bool;
    var ignored(get, set):Bool;
    var annotation(get, never) : String;
    var modified(get, never) : Bool;

    /** A key that is the same for quick successive edits of the same value, and only then. */
    function editKey(what : String) : String {
        return value.type + "." + value.subtype + "." + value.id + ":" + what;
    }

    function get_ageChoice() : String {
        return cast value.age;
    }

    function set_ageChoice(choice : String) : String {
        GenomeContext.edit(value, function() {
            value.age = cast choice;
        }, editKey("age"));

        return choice;
    }

    function get_sexChoice() : String {
        return cast value.sex;
    }

    function set_sexChoice(choice : String) : String {
        GenomeContext.edit(value, function() {
            value.sex = cast choice;
        }, editKey("sex"));

        return choice;
    }

    function get_mutabilityValue() : Int {
        return value.mutability;
    }

    function set_mutabilityValue(amount : Int) : Int {
        // A cleared number box reports null.
        if(untyped amount == null) {
            return value.mutability;
        }

        GenomeContext.edit(value, function() {
            value.mutability = amount;
        }, editKey("mutability"));

        return amount;
    }

    function setFlag(flag : GeneFlag, on : Bool, name : String) : Void {
        GenomeContext.edit(value, function() {
            if(on) {
                value.addFlag(flag);
            } else {
                value.removeFlag(flag);
            }
        }, editKey(name));
    }

    function get_duplicate() : Bool {
        return value.hasFlag(CanBeDuplicated);
    }

    function set_duplicate(on : Bool) : Bool {
        setFlag(CanBeDuplicated, on, "duplicate");

        return on;
    }

    function get_mutate() : Bool {
        return value.hasFlag(CanBeMutated);
    }

    function set_mutate(on : Bool) : Bool {
        setFlag(CanBeMutated, on, "mutate");

        return on;
    }

    function get_cut() : Bool {
        return value.hasFlag(CanBeCut);
    }

    function set_cut(on : Bool) : Bool {
        setFlag(CanBeCut, on, "cut");

        return on;
    }

    function get_ignored() : Bool {
        return value.hasFlag(Ignored);
    }

    function set_ignored(on : Bool) : Bool {
        setFlag(Ignored, on, "ignored");

        return on;
    }

    function get_annotation() : String {
        if(notes == null ) return "";
        return notes.getDescription(value.type, value.subtype, value.id);
    }

    function get_modified() : Bool {
        return GenomeContext.isModified(value);
    }

    function revert() : Void {
        GenomeContext.revert(value);
    }
}

private typedef Data = {
    var ageOptions : Array<Dynamic>;
}

private typedef Props = {
    var value: Gene;
    var name : String;
    var notes : creatures.gene.notes.GenomeNotes;
};

