module.exports = {
    chainWebpack: config => {
        // GraphQL Loader
        config.module
            .rule('haxe-loader')
            .test(/\.hxml$/)
            .use('haxe-loader')
            .loader('haxe-loader')
            .end()
        config.module
            .rule('html-loader')
            .test(/\.html$/)
            .use('html-loader')
            .loader('html-loader')
            .end()
    },
    runtimeCompiler : true
}