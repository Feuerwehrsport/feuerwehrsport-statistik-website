#= require classes/Fss
#= require classes/SortTable

Fss.ready 'appointment', ->
  new SortTable({ selector: '.datatable-appointments', direction: 'asc' })

  editAppointment = (headline, places, events, values, submitCallback) ->
    eventOptions = [ { value: 'NULL', display: '----' } ]
    for event in events
      eventOptions.push({ value: event.id, display: event.name })

    defaultValues = {
      dated_at: ''
      name: ''
      place: ''
      event_id: 'NULL'
      disciplines: ''
      description: ''
    }
    values = $.extend(defaultValues, values)
    for key of Fss.disciplines
      values[key] = key in values.disciplines.split(',')

    w = FssWindow.build(headline)

    w.add((new FssFormRowDescription(values.message)).addClass('text-warning')) if values.message?

    w.add(new FssFormRowDate('dated_at', 'Datum', values.dated_at))
    .add(new FssFormRowText('name', 'Name', values.name))
    .add(new FssFormRowText('place', 'Ort', values.place, places.map((place) -> place.name)))
    .add(new FssFormRowSelect('event_id', 'Typ', values.event_id, eventOptions))
    .add(new FssFormRowTextarea('description', 'Beschreibung', values.description))

    for key, disciplineName of Fss.disciplines
      w.add(new FssFormRowCheckbox(key, disciplineName, values[key]))

    w.on('submit', (data) ->
      if data.name is '' or data.description is ''
        data.message = 'Name und Beschreibung müssen gesetzt sein.'
        return editAppointment(headline, places, events, data, submitCallback)

      disciplines = []
      for key of Fss.disciplines
        disciplines.push(key) if data[key]
      appointmentData = {
        dated_at: data.dated_at
        name: data.name
        place: data.place
        description: data.description
        disciplines: disciplines.join(',')
      }
      appointmentData.event_id = if data.event_id isnt 'NULL' then data.event_id else null
      submitCallback(appointmentData)
    )
    .open()

  $('#add-appointment').click ->
    Fss.checkLogin ->
      Fss.getResources 'places', (places) ->
        Fss.getResources 'events', (events) ->
          editAppointment 'Termin hinzufügen',  places, events, {}, (appointmentData) ->
            Fss.ajaxReload('POST', 'appointments', { appointment: appointmentData })

  $('#edit-appointment').click ->
    appointmentId = $(this).data('appointment-id')
    Fss.checkLogin ->
      Fss.getResources 'places', (places) ->
        Fss.getResources 'events', (events) ->
          Fss.getResource 'appointments', appointmentId, (appointment) ->
            editAppointment 'Termin bearbeiten', places, events, appointment, (appointmentData) ->
              if appointment.updateable
                Fss.ajaxReload('PUT', "appointments/#{appointmentId}", { appointment: appointmentData })
              else
                Fss.changeRequest('appointment-edit', { appointment_id: appointmentId, appointment: appointmentData })
