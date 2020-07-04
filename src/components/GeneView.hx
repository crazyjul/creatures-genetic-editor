package components;

import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

import creatures.gene.Gene;

class GeneView extends VComponent<NoneT, Props> {
    public function new() {
        super();
        Webpack.require("./GeneView.css");
    }

    override public function Components() {
        return ["gene-header" => new GeneHeader(),
        "Organ-panel" => new components.genes.OrganPanel(),
        "Receptor-panel" => new components.genes.ReceptorPanel(),
        "Appearance-panel" => new components.genes.AppearancePanel(),
        "HalfLife-panel" => new components.genes.HalfLifePanel(),
        "Reaction-panel" => new components.genes.ReactionPanel(),
        "Emitter-panel" => new components.genes.EmitterPanel(),
        "Inject-panel" => new components.genes.InjectPanel(),
        "Expression-panel" => new components.genes.ExpressionPanel(),
        "Stimulus-panel" => new components.genes.StimulusPanel(),
        "Genus-panel" => new components.genes.GenusPanel()];
    }

    override public function Template() {
        return Webpack.require('./GeneView.html');
    }

}

private typedef Props = {
    var value: Array<Gene>;
    var notes : creatures.gene.notes.GenomeNotes;
};

