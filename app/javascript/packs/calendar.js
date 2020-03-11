import Vue from 'vue'
import Calendar from '../calendar.vue'

$(function () {
  window.vueCalendar = new Vue({
    render: h => h(Calendar)
  }).$mount('#calendar-placeholder')
})
