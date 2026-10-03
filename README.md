# gene-editor

Browser-based viewer/editor for Creatures genome files. The UI is written in
[Haxe](https://haxe.org) (compiled to JS) on top of Vue 2, and built with Vue CLI / webpack.

## Prerequisites

- Node.js and npm
- [Haxe](https://haxe.org/download/) 4.2.5 or 4.3.7 (both build successfully) and `haxelib` on your `PATH`
- Haxe libraries (see `build.hxml`):

```
haxelib install haxevx
haxelib install jsprop
haxelib install haxe-loader
haxelib git creatures-genetics-toolbox https://github.com/crazyjul/creatures-genetics-toolbox
```

`haxevx` from haxelib (0.7.2) does not compile on Haxe 4.1+. Use the fixed fork
(branch with the Haxe 4 fixes) cloned next to this repository instead:

```
haxelib dev haxevx ../haxevx
```

`creatures-genetics-toolbox` provides `Genome`, `Gene`, `GenomeNotes`, etc. It is not on haxelib.
To work on it alongside the editor, clone it next to this repository and point haxelib at the clone:

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

### Compiles and minifies for production
```
npm run build
```

`haxe-loader` runs the Haxe compiler on `build.hxml` as part of the webpack build, so Haxe errors
show up as webpack errors. To check the Haxe code alone, run the same command as `build.hxml`
(for example `haxe build.hxml`).

## Layout

- `src/Main.hx` – entry point, mounts the root Vue component
- `src/App.hx` – root component: loads genome (`.gen*`) and notes (`.gno`) files
- `src/components/` – `FileSelect`, `GeneView`, `GeneHeader`
- `src/components/genes/` – one panel per gene type; each `.hx` class has a matching `.html` template

## Known issues

- `haxevx` on haxelib is too old for Haxe 4.1+; see the setup above.
- The Vue CLI plugins are kept at `~5.0.8` to match `@vue/cli-service`.
- Webpack warns about the ~800 KiB vendor bundle (Element UI); the build still succeeds.
