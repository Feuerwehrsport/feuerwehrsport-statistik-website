$ () ->

  addAppointment = (places, events, values = {}) ->
    placeOptions = [ value: 'NULL', display: '----' ]
    for place in places
      placeOptions.push value: place.id, display: place.name

    eventOptions = [ value: 'NULL', display: '----' ]
    for event in events
      eventOptions.push value: event.id, display: event.name

    defaultValues = 
      date: ""
      name: ""
      placeId: 'NULL'
      eventId: 'NULL'
      description: ""
      fs: false
      hb: false
      hl: false
      gs: false
      la: false
    values = $.extend(defaultValues, values)

    w = FssWindow.build('Termin hinzufügen')

    w.add((new FssFormRowDescription(values.message)).addClass("text-warning")) if values.message?

    w.add(new FssFormRowDate('date', 'Datum', values.date))
    .add(new FssFormRowText('name', 'Name', values.name))
    .add(new FssFormRowSelect('placeId', 'Ort', values.placeId, placeOptions))
    .add(new FssFormRowSelect('eventId', 'Typ', values.eventId, eventOptions))
    .add(new FssFormRowTextarea('description', 'Beschreibung', values.description))

    for key, disciplineName of Fss.disciplines
      w.add(new FssFormRowCheckbox(key, disciplineName, values[key]))

    w.on('submit', (data) ->
      if data.name is '' or data.description is ''
        data.message = "Name und Beschreibung müssen gesetzt sein."
        return addAppointment(places, events, data)

      disciplines = []
      for key of Fss.disciplines
        disciplines.push(key) if data[key]
      appointmentData =
        dated_at: data.date
        name: data.name
        description: data.description
        disciplines: disciplines.join(",")
  
      appointmentData.place_id = data.placeId if data.placeId isnt "NULL"
      appointmentData.event_id = data.eventId if data.eventId isnt "NULL"
      Fss.post 'appointments', appointment: appointmentData, (result) ->
        location.reload()
    )
    .open()

  $('#add-appointment').click () ->
    Fss.checkLogin () ->
      Fss.getPlaces (places) ->
        Fss.getEvents (events) ->
          addAppointment(places, events)