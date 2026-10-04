package components;

import creatures.Genome;
import creatures.gene.LobeGene;
import creatures.gene.PoseGene;
import creatures.gene.notes.GenomeNotes;

/**
 * Names of things that genes refer to by number (lobes by tissue id, poses by pose number).
 * A gene cannot see the rest of the genome, so the app rebuilds this whenever a genome or its notes load.
 */
class GenomeContext {
    static var lobes = new Map<Int, String>();
    static var poses = new Map<Int, String>();

    public static function update(genome : Genome, notes : GenomeNotes) : Void {
        lobes = new Map<Int, String>();
        poses = new Map<Int, String>();

        if(genome == null) {
            return;
        }

        for(gene in genome.genes) {
            var description = notes != null ? notes.getDescription(gene.type, gene.subtype, gene.id) : "";

            if(Std.isOfType(gene, LobeGene)) {
                var lobe : LobeGene = cast gene;

                // 255 means the lobe has no tissue, so nothing can refer to it.
                if(lobe.tissueId != 255 && !lobes.exists(lobe.tissueId)) {
                    lobes[lobe.tissueId] = description != "" ? lobe.token + " - " + description : lobe.token;
                }
            } else if(Std.isOfType(gene, PoseGene)) {
                var pose : PoseGene = cast gene;

                if(!poses.exists(pose.poseNumber)) {
                    poses[pose.poseNumber] = cleanPoseDescription(description);
                }
            }
        }
    }

    /** "013 appr1 (child) - Pose" becomes "appr1 (child)". */
    static function cleanPoseDescription(description : String) : String {
        var result = ~/^\d+\s+/.replace(description, "");
        result = ~/\s*-\s*Pose\s*$/.replace(result, "");

        return StringTools.trim(result);
    }

    public static function lobeLabel(tissue : Int) : String {
        var label = lobes[tissue];

        return label != null ? label : "lobe tissue " + tissue;
    }

    /** The name of a pose, or an empty string when unknown. */
    public static function poseLabel(number : Int) : String {
        var label = poses[number];

        return label != null ? label : "";
    }
}
