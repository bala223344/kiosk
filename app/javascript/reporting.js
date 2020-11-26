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

import axios from 'axios';

var config = require('siteconfig');

import { BModal } from 'bootstrap-vue'



 new Vue({
    el: '#app',
    data: {
     
      total_count: 0,
      showModal: false,
      rows: [
      ],
      detail : null,
      page : 1,
      total_pages : 1
  },
  components: { BModal },

  mounted() {

    this.getIndex()
   
      

  },

  methods: {
    next: function () {
      this.page = this.page + 1
      this.getIndex()

    },
    prev: function () {
      this.page = this.page - 1
      this.getIndex()
    },

    getIndex: function () {

      var params =  {
        page: this.page
      }
      var self = this
      axios.get(config.REPORTING_URL, {
        params: params
       
      })
        .then(function (response) {
          self.rows = response.data.donations
          self.total_count = response.data.total_count
          self.total_pages = Math.ceil(response.data.total_count / 20 )
        })
        .catch(function (error) {
          // handle error
          console.log(error);
        })
        .then(function () {
          // always executed
        });
    },

    getDetails: function (id) {
     
      var self = this
    axios.get(config.REPORTING_DETAIL_URL)
      .then(function (response) {
       
        self.detail = response.data.donations
        console.log(self.detail);
        self.$refs['my-modal'].show()
      })
      .catch(function (error) {
        // handle error
        console.log(error);
      })
      .then(function () {
        // always executed
      });
      
      
    }
  }

 
  })