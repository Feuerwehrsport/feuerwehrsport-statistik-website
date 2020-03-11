<template>
  <div class='demo-app'>
    <FullCalendar
      class='demo-app-calendar'
      ref="fullCalendar"
      defaultView="dayGridMonth"
      :header="{
        left: 'prev,next today',
        center: 'title',
        right: 'listYear,listMonth,listWeek,dayGridMonth,dayGridWeek'
      }"
      :plugins="calendarPlugins"
      :weekends="calendarWeekends"
      :events="calendarEvents"
      locale="de"
      themeSystem="bootstrap"
      @dateClick="handleDateClick"
      />
  </div>
</template>

<script>
import FullCalendar from '@fullcalendar/vue'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'
import listPlugin from '@fullcalendar/list'
import bootstrapPlugin from '@fullcalendar/bootstrap'
export default {
  components: {
    FullCalendar // make the <FullCalendar> tag available
  },
  data: function() {
    return {
      calendarPlugins: [ // plugins must be defined in the JS
        dayGridPlugin,
        listPlugin,
        interactionPlugin, // needed for dateClick
        bootstrapPlugin
      ],
      calendarWeekends: true,
      calendarEvents: [],
    }
  },
  methods: {
    handleDateClick(arg) {
      if (confirm('Would you like to add an event to ' + arg.dateStr + ' ?')) {
        this.calendarEvents.push({ // add new event data
          title: 'New Event',
          start: arg.date,
          allDay: arg.allDay
        })
      }
    },
    updateEvents() {
      Fss.getResources('appointments', (appointments) => {
        this.calendarEvents = [];
        for (var i = appointments.length - 1; i >= 0; i--) {
          this.calendarEvents.push({ title: appointments[i].name, start: appointments[i].dated_at, id: appointments[i].id});
        }
      });
    }
  },
  created() {
    this.updateEvents();
  }
}
</script>

<style lang='scss'>
// you must include each plugins' css
// paths prefixed with ~ signify node_modules
@import '@fullcalendar/core/main.css';
@import '@fullcalendar/daygrid/main.css';
@import '@fullcalendar/list/main.css';
@import '@fullcalendar/bootstrap/main.css';
.demo-app {
  font-family: Arial, Helvetica Neue, Helvetica, sans-serif;
  font-size: 14px;
}
.demo-app-top {
  margin: 0 0 3em;
}
.demo-app-calendar {
  margin: 0 auto;
  max-width: 900px;
}
</style>