# gene-editor

Browser-based viewer and editor for Creatures 3 / Docking Station genome files. The UI is written in
[Haxe](https://haxe.org) (compiled to JS) on top of Vue 2, and built with Vue CLI / webpack.

Open a genome (`.gen`) and, optionally, its genome notes (`.gno`), which give the genes their descriptions.

## Features

- **Gene list** with search, filters by kind and by life stage (an age timeline), grouping by organ, and keyboard
  navigation (arrows, Enter, `/`, Esc).
- **Gene cards** for every kind of gene: lobes, tracts, instincts, reactions, receptors, emitters, half lives,
  poses, pigments and so on, with visuals where they help (reaction equations, a half-life chart, a pose figure,
  highlighted SV rules). Chemicals and lobes are named.
- **Brain map**: the lobes and tracts drawn like the original Vat Kit.
- **Chemicals**: every chemical and the genes that use it.
- **Compare** the selected genes side by side, and **export** them as JSON.
- **Editing**: change the age, sex, mutability and flags of a gene, every one of its values (a form built from the
  gene's fields, and a raw bytes grid), then **save** the genome. Undo and redo (Ctrl+Z, Ctrl+Y), revert one gene
  or all of them; modified genes are marked in the list. Ctrl+S saves.
- Light and dark themes, and a layout for phones.

## Prerequisites

- Node.js and npm
- [Haxe](https://haxe.org/download/) 4.2.5 or 4.3.7 (both build successfully) and `haxelib` on your `PATH`
- Haxe libraries (see `build.hxml`):

```
haxelib install jsprop
haxelib install haxe-loader
haxelib install haxevx
haxelib git creatures-genetics-toolbox https://github.com/crazyjul/creatures-genetics-toolbox
```

`haxevx` from haxelib (0.7.2) does not compile on Haxe 4.1+. Use the version with the Haxe 4 fixes
(<https://github.com/firefalcom/haxevx>, branch `master`) cloned next to this repository instead:

```
git clone https://github.com/firefalcom/haxevx ../haxevx
haxelib dev haxevx ../haxevx
```

`creatures-genetics-toolbox` reads and writes the genomes: it provides `Genome`, `Gene`, `GenomeNotes`, etc. It is
not on haxelib. To work on it alongside the editor, clone it next to this repository and point haxelib at the clone:

```
haxelib dev creatures-genetics-toolbox ../creatures-genetics-toolbox
```

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

The Haxe sources of this project reload by themselves, but changes to the toolbox do not: restart the server after
changing it.

### Compiles and minifies for production
```
npm run build
```

`haxe-loader` runs the Haxe compiler on `build.hxml` as part of the webpack build, so Haxe errors
show up as webpack errors. To check the Haxe code alone, run the same command as `build.hxml`
(for example `haxe build.hxml`).

## Publishing on GitHub Pages

`.github/workflows/pages.yml` builds the app and deploys `dist` on every push to `master`. Once, in the repository
settings, set **Pages > Source** to **GitHub Actions**. The workflow installs Haxe 4.3.7 and the Haxe libraries
(`haxevx` and `creatures-genetics-toolbox` from their GitHub repositories, so push toolbox changes first). The build
uses relative asset paths, so the site works under `https://<user>.github.io/<repository>/`.

## Layout

- `src/Main.hx` – entry point, mounts the root Vue component and registers the template filters
- `src/App.hx` – root component: files, selection, filters, editing (undo, save) and keyboard shortcuts
- `src/components/` – `FileSelect`, `GeneView`, `GeneHeader` (the card), `GeneEditor` (edit form and raw bytes),
  `BrainMap`, `CompareView`, and the helpers `GenomeContext` (names, edit hook) and `GeneExport`
- `src/components/genes/` – one panel per gene kind; each `.hx` class has a matching `.html` template

## How editing works

A gene reads and writes its bytes in the genome. When a card changes a value it calls `GenomeContext.edit`, and
the app makes the change, records the undo step if the bytes really changed, rebuilds the gene from the bytes and
puts it in the lists in place of the old one. A new gene object is what makes Vue refresh everything that shows it
(list, cards, brain map, compare, chemicals).

The notes and the genome's byte buffers are frozen so that Vue does not wrap them: they are large and read on every
render. Anything that depends on them must therefore refresh by replacing gene objects, as above.

## Known issues

- The Creatures 4 genes (pattern, color, belly, eyes, special) are not decoded.
- The Vue CLI plugins are kept at `~5.0.8` to match `@vue/cli-service`.
- Webpack warns about the ~800 KiB vendor bundle (Element UI); the build still succeeds.
