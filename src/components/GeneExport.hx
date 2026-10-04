package components;

import creatures.gene.Gene;

/** Turns genes into JSON text and hands that text to the browser as a download or to the clipboard. */
class GeneExport {
    /**
     * Every readable field of every gene, plus its description and kind. Fields are defined on each gene
     * instance (and wrapped by Vue), so the instance's own properties are read; private ones start with "_".
     */
    public static function toJson(genes : Array<Gene>, descriptions : Array<String>) : String {
        return js.Syntax.code("(function(genes, descriptions) {
            return JSON.stringify(genes.map(function(g, i) {
                var o = { description: descriptions[i], kind: g.typename || null };
                Object.getOwnPropertyNames(g).forEach(function(n) {
                    if (n.charAt(0) === '_' || typeof g[n] === 'function' || n === 'typename') return;
                    o[n] = g[n];
                });
                return o;
            }), null, 2);
        })({0}, {1})", genes, descriptions);
    }

    /** Saves the text as a file through the browser's download. */
    public static function download(fileName : String, text : String) : Void {
        js.Syntax.code("(function(name, text) {
            var url = URL.createObjectURL(new Blob([text], { type: 'application/json' }));
            var link = document.createElement('a');
            link.href = url;
            link.download = name;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            setTimeout(function() { URL.revokeObjectURL(url); }, 0);
        })({0}, {1})", fileName, text);
    }

    /** Saves binary data (a genome file) through the browser's download. */
    public static function downloadBytes(fileName : String, bytes : haxe.io.Bytes) : Void {
        js.Syntax.code("(function(name, data) {
            var url = URL.createObjectURL(new Blob([data], { type: 'application/octet-stream' }));
            var link = document.createElement('a');
            link.href = url;
            link.download = name;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            setTimeout(function() { URL.revokeObjectURL(url); }, 0);
        })({0}, {1})", fileName, bytes.getData());
    }

    /** Copies the text to the clipboard; false when the browser refuses. */
    public static function copy(text : String, done : Bool -> Void) : Void {
        js.Syntax.code("(function(text, done) {
            if (!navigator.clipboard) { done(false); return; }
            navigator.clipboard.writeText(text).then(function() { done(true); }, function() { done(false); });
        })({0}, {1})", text, done);
    }
}
