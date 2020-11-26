/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)





import Vue from 'vue';
import { VuejsDatatableFactory } from 'vuejs-datatable';
Vue.use(VuejsDatatableFactory);

import axios from 'axios';
import REPORTING_URL from 'siteconfig';




var app = new Vue({
    el: '#app',
    data: {
      columns: [
          {label: 'id', field: 'id'},
          {label: 'First Name', field: 'name'},
          {label: 'Email', field: 'email'},
          
      ],
      rows: [
          //...
        
          //...
      ]
  },
  mounted() {

    
    var self = this
    axios.get(REPORTING_URL)
      .then(function (response) {
        self.rows = response.data.donations
      })
      .catch(function (error) {
        // handle error
        console.log(error);
      })
      .then(function () {
        // always executed
      });
      

  }
 
  })