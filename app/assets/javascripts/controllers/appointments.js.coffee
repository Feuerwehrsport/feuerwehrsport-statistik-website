$ () ->
  new SortTable(selector: ".datatable-appointments", direction: 'asc')

  editAppointment = (headline, places, events, values, submitCallback) ->
    placeOptions = [ value: 'NULL', display: '----' ]
    for place in places
      placeOptions.push value: place.id, display: place.name

    eventOptions = [ value: 'NULL', display: '----' ]
    for event in events
      eventOptions.push value: event.id, display: event.name

    defaultValues = 
      dated_at: ""
      name: ""
      place_id: 'NULL'
      event_id: 'NULL'
      disciplines: ""
      description: ""
    values = $.extend(defaultValues, values)
    for key of Fss.disciplines
      values[key] = key in values.disciplines.split(",")

    w = FssWindow.build(headline)

    w.add((new FssFormRowDescription(values.message)).addClass("text-warning")) if values.message?

    w.add(new FssFormRowDate('dated_at', 'Datum', values.dated_at))
    .add(new FssFormRowText('name', 'Name', values.name))
    .add(new FssFormRowSelect('place_id', 'Ort', values.place_id, placeOptions))
    .add(new FssFormRowSelect('event_id', 'Typ', values.event_id, eventOptions))
    .add(new FssFormRowTextarea('description', 'Beschreibung', values.description))

    for key, disciplineName of Fss.disciplines
      w.add(new FssFormRowCheckbox(key, disciplineName, values[key]))

    w.on('submit', (data) ->
      if data.name is '' or data.description is ''
        data.message = "Name und Beschreibung müssen gesetzt sein."
        return editAppointment(headline, places, events, data, submitCallback)

      disciplines = []
      for key of Fss.disciplines
        disciplines.push(key) if data[key]
      appointmentData =
        dated_at: data.dated_at
        name: data.name
        description: data.description
        disciplines: disciplines.join(",")
  
      appointmentData.place_id = data.place_id if data.place_id isnt "NULL"
      appointmentData.event_id = data.event_id if data.event_id isnt "NULL"
      submitCallback(appointmentData)
    )
    .open()

  $('#add-appointment').click () ->
    Fss.checkLogin () ->
      Fss.getResources "places", (places) ->
        Fss.getResources "events", (events) ->
          editAppointment "Termin hinzufügen",  places, events, {}, (appointmentData) ->
            Fss.ajaxReload 'POST', 'appointments', appointment: appointmentData, log_action: "add-appointment"

  $('#edit-appointment').click () ->
    appointmentId = $(this).data('appointment-id')
    Fss.checkLogin () ->
      Fss.getResources "places", (places) ->
        Fss.getResources "events", (events) ->
          Fss.getResource "appointments", appointmentId, (date) ->
            editAppointment "Termin bearbeiten", places, events, date, (appointmentData) ->
              Fss.changeRequest 'appointment-edit', appointment_id: appointmentId, appointment: appointmentData