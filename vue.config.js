module.exports = {
    chainWebpack: config => {
        config.plugin('html').tap(args => {
            args[0].title = 'Creatures Gene Editor'
            return args
        })
        config.module
            .rule('haxe-loader')
            .test(/\.hxml$/)
            .use('haxe-loader')
            .loader('haxe-loader')
            .end()
        config.module
            .rule('html-loader')
            .test(/\.html$/)
            .exclude.add(require('path').resolve(__dirname, 'public')).end()
            .use('html-loader')
            .loader('html-loader')
            .end()
    },
    runtimeCompiler: true
}