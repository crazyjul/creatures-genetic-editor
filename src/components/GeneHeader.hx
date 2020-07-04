package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Age;
import creatures.gene.Gene;

class GeneHeader extends VComponent<Data, Props> {
    public function new() {
        super();
        Webpack.require("./GeneHeader.css");
    }

    override public function Components() {
        return [];
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

    var duplicate(get, set):Bool;
    var mutate(get, set):Bool;
    var annotation(get, never) : String;

    function get_duplicate() : Bool {
        return value.hasFlag(CanBeDuplicated);
    }

    function set_duplicate(dup : Bool) : Bool {
        if(dup) {
            value.addFlag(CanBeDuplicated);
        } else {
            value.removeFlag(CanBeDuplicated);
        }

        return dup;
    }

    function get_mutate() : Bool {
        return value.hasFlag(CanBeMutated);
    }

    function set_mutate(mut : Bool) : Bool {
        if(mut) {
            value.addFlag(CanBeMutated);
        } else {
            value.removeFlag(CanBeMutated);
        }

        return mut;
    }

    function get_annotation() : String {
        if(notes == null ) return "";
        var note = notes.getDescription(value.type, value.subtype, value.id);
        return note != "" ? note : "<no annotation>";
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

