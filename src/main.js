// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import Vuex from 'vuex'
//import TreeView from 'vue-json-tree-view'


Vue.config.productionTip = false

/*
/* eslint-disable no-new * /
new Vue({
  el: '#app',
  components: { App },
  template: '<App/>'
})
*/

Vue.use(Vuex);
//Vue.use(TreeView);

//Vue.use(VueRouter);
require("../build.hxml");