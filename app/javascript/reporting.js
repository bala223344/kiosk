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

const authenticity_token = document.querySelector("meta[name=csrf-token]").content
axios.defaults.headers.common['X-CSRF-Token'] = authenticity_token


import Loading from 'vue-loading-overlay';
// Import stylesheet
import 'vue-loading-overlay/dist/vue-loading.css';


new Vue({
  el: '#app',
  data: {

    total_count: 0,
    showModal: false,
    rows: [],
    detail: null,
    kiosk_title: '',
    page: 1,
    total_pages: 1,
    s: '',
    sort_field: '',
    sort_order: '',
    refund_status: [],
    isLoading: true,
    receipt_status: [],
    ctype : null,
    tx_status : null
  },
  components: { BModal,  Loading },

  mounted() {

    this.getIndex()



  },


  computed: {

  },


  methods: {

    ctype_filter: function(str) {
      this.page = 1
      this.tx_status = null
      this.ctype = str
      this.getIndex()
    },
    tx_status_filter: function(str) {
      this.page = 1
      this.ctype = null
      this.tx_status = str
      this.getIndex()
    },
    reset: function() {
      this.tx_status = null
      this.ctype = null
      this.page = 1
      this.getIndex()
    },

    nextp: function () {
      this.page = parseInt(this.page) + 1
      this.getIndex()

    },
    prevp: function () {
      this.page = parseInt(this.page) - 1
      this.getIndex()
    },

    getclass: function (field) {
      //nothing clicked yet..return empty
      if (!this.sort_field) return '';
      if (this.sort_field == field)
        return (this.sort_order == 'asc') ? 'desc' : 'asc'
    },

    sort: function (field) {

      //clicking on the same field
      if (this.sort_field == field) {
        this.sort_order = (this.sort_order == 'asc') ? 'desc' : 'asc'
      } else {
        this.sort_field = field
        this.sort_order = 'asc'
      }
      this.getIndex()
    },



    search: function () {
      this.page = 1
      this.getIndex()
    },

    getIndex: function () {

      this.isLoading = true
      var params = {
        page: this.page
      }

      if (this.s) {
        params.q = this.s
      }

      if (this.sort_field) {
        params.sort_field = this.sort_field
        params.sort_order = this.sort_order
      }

      if (this.ctype) {
        params.ctype = this.ctype
      }
      if (this.tx_status) {
        params.tx_status = this.tx_status
      }


      var self = this
      axios.get(config.REPORTING_URL, {
        params: params

      })
        .then(function (response) {
          self.rows = response.data.donations
          self.total_count = response.data.total_count
          self.total_pages = Math.ceil(response.data.total_count / 20)
          self.kiosk_title = response.data.kiosk_title
        })
        .catch(function (error) {
          // handle error
          console.log(error);
        })
        .then(function () {
          // always executed
          self.isLoading = false;

        });
    },

    refund: function (id) {
      var params = {
        kiosk: { id: id },
      }
      var self = this
      this.isLoading = true
      axios.post(config.REFUND_URL,
        params

      )
        .then(function (response) {
          self.$set(self.refund_status, id, "Processed")
        })
        .catch(function (error) {
          self.$set(self.refund_status, id, error)

        }).then(function () {
          // always executed
          self.isLoading = false;

        });


    },

    sendreceipt: function (id) {
      var params = {
        kiosk: { id: id },
      }
      var self = this
      this.isLoading = true
      axios.post(config.RECEIPT_URL,
        params

      )
        .then(function (response) {
          self.$set(self.receipt_status, id, "Sent")
        })
        .catch(function (error) {
          self.$set(self.receipt_status, id, error)

        }).then(function () {
          // always executed
          self.isLoading = false;

        });


    },

    getDetails: function (id) {

      var params = {
        id: id
      }
      this.isLoading = true
      var self = this

      axios.get(config.REPORTING_DETAIL_URL, {
        params: params

      })
        .then(function (response) {

          self.detail = response.data.donation

          self.$refs['my-modal'].show()
        }).catch(function (error) {

        }).then(function () {
          // always executed
          self.isLoading = false;

        });




    }
  }


})