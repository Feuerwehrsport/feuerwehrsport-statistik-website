#= require bootstrap-datetimepicker

hasNativeSupportForDate = true
hasNativeSupportForTime = true

M3.ready ->
  $.fn.datetimepicker.defaults.locale = moment.locale()

  $('.form-control.string[data-constraint=time]').each ->
    $(@).attr('type', 'time').removeClass('string').addClass('time')
    $(@).addClass('with-picker').datetimepicker({ format: 'LT' }) unless hasNativeSupportForTime

  $('.form-control.string[data-constraint=date], .filters-filter input[data-constraint=date]').each ->
    if hasNativeSupportForTime and moment($(@).val(), moment.localeData().longDateFormat('L')).isValid()
      $(@).val(moment($(@).val(), moment.localeData().longDateFormat('L')).format('YYYY-MM-DD'))
    else if !hasNativeSupportForTime and moment($(@).val()).isValid()
      $(@).val(moment($(@).val()).format('L'))
    $(@).attr('type', 'date').removeClass('string').addClass('date')
    $(@).addClass('with-picker').datetimepicker({ format: 'L' }) unless hasNativeSupportForTime

  $('.form-group.date, .form-group.time, .form-group.datetime').each ->
    year = month = day = hour = minute = -1
    hiddenYear = hiddenMonth = hiddenDay = hiddenHour = hiddenMinute = inputDate = inputTime = null
    hasDateInput = $(@).is('.date, .datetime')
    hasTimeInput = $(@).is('.time, .datetime')

    $(@).find('select').each ->
      select = $(@)
      id = select.attr('id')
      name = select.attr('name')
      position = parseInt(name.match(/\((\d)i\)/)[1])
      value = select.val()

      hidden = $('<input type="hidden" />').attr('id', id).attr('name', name).val(value)
      select.replaceWith(hidden)

      switch position
        when 1
          year = parseInt(value, 10) if value
          hiddenYear = hidden
        when 2
          month = parseInt(value, 10) - 1 if value
          hiddenMonth = hidden
        when 3
          day = parseInt(value, 10) if value
          hiddenDay = hidden
        when 4
          hour = parseInt(value, 10) if value
          hiddenHour = hidden
        when 5
          minute = parseInt(value, 10) if value
          hiddenMinute = hidden

    if hasDateInput
      if year > 0 and month >= 0 and day > 0
        date = moment({ year: year, month: month, day: day })
        dateFormatted = if hasNativeSupportForDate then date.format('YYYY-MM-DD') else date.format('L')
      inputDate = $('<input type="date" class="form-control date" />').val(dateFormatted).insertAfter(hiddenYear)
      inputDate.on 'dp.change change keyup paste mouseup', ->
        if hasNativeSupportForDate
          date = moment(inputDate.val())
        else
          date = moment(inputDate.val(), 'L')
        if date.isValid()
          hiddenYear.val(date.year())
          hiddenMonth.val(date.month() + 1)
          hiddenDay.val(date.date())
        else
          hiddenYear.val('')
          hiddenMonth.val('')
          hiddenDay.val('')
      inputDate.addClass('with-picker').datetimepicker({ format: 'L' }) unless hasNativeSupportForDate

    if hasTimeInput
      if hour >= 0 and minute >= 0
        time = moment({ hour: hour, minute: minute })
        timeFormatted = if hasNativeSupportForTime then time.format('HH:mm') else time.format('LT')
      inputTime = $('<input type="time" class="form-control time" />').val(timeFormatted).insertAfter(hiddenHour)
      inputTime.on 'dp.change change keyup paste mouseup', ->
        value = inputTime.val().trim()
        if hasNativeSupportForTime
          date = moment("#{moment().format('YYYY-MM-DD')}T#{value}")
        else
          date = moment("#{moment().format('L')} #{value}", 'L LT')
        if value and date.isValid()
          hiddenHour.val(date.hours())
          hiddenMinute.val(date.minutes())
        else
          hiddenHour.val('')
          hiddenMinute.val('')
      inputTime.addClass('with-picker').datetimepicker({ format: 'LT' }) unless hasNativeSupportForTime

    label = $(@).find('label')
    id = "#{label.attr('for')}_picker"
    label.attr('for', id)
    if hasDateInput
      inputDate.attr('id', id)
      inputDate.parent().contents().filter(-> @nodeType == 3).remove()
    else
      inputTime.attr('id', id)
      inputTime.parent().contents().filter(-> @nodeType == 3).remove()
