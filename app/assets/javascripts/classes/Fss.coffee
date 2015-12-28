#= require classes/AlertFssWindow
#= require classes/FssFormRow
#= require classes/FssWindow
#= require classes/WarningFssWindow

class @Fss
  @wks: 
    gs: [
      "B-Schlauch",
      "Verteiler",
      "C-Schlauch",
      "Knoten",
      "D-Schlauch",
      "Läufer"
    ]
    la: [
      "Maschinist",
      "A-Länge",
      "Saugkorb",
      "B-Schlauch",
      "Strahlrohr links",
      "Verteiler",
      "Strahlrohr rechts"
    ]
    fs:
      female: [
        "Leiterwand",
        "Hürde",
        "Balken",
        "Feuer"
      ]
      male: [
        "Haus",
        "Wand",
        "Balken",
        "Feuer"
      ]

  @disciplines:
    la: "Löschangriff"
    fs: "Feuerwehrstafette"
    gs: "Gruppenstafette"
    hl: "Hakenleitersteigen"
    hb: "Hindernisbahn"

  @sexes:
    male: "männlich"
    female: "weiblich"
  
  @captchaQuestion: () ->
    questions = [
      ['plus', (a, b) -> a + b ],
      ['minus', (a, b) -> a - b ],
      ['mal', (a, b) -> a * b ]
    ]

    i = Math.round(Math.random() * 2)
    a = Math.round(Math.random() * 10)
    b = Math.round(Math.random() * 9)

    question = "#{a} #{questions[i][0]} #{b}"
    answer = questions[i][1](a, b)
    if answer < 0 || answer > 50
      [question, answer] = Fss.captchaQuestion()
    [question, answer]

  @login: (callback, values = {}) ->
    [question, answer] = Fss.captchaQuestion()

    defaultValues =
      name: ""
      email_address: ""
      save: false
    values = $.extend(defaultValues, values)

    w = FssWindow.build("Anmelden")

    w.add((new FssFormRowDescription(values.message)).addClass("text-warning")) if values.message?

    w
      .add(new FssFormRowText("test", question))
      .add(new FssFormRowDescription("Bitte lösen Sie die Gleichung."))
      .add(new FssFormRowText("name", "Name", values.name))
      .add(new FssFormRowDescription("Dieser Name ist nur für Rückfragen bei Problemen gedacht."))
      .add(new FssFormRowText("email_address", "E-Mail-Adresse", values.email_address))
      .add(new FssFormRowDescription("Diese Angabe ist freiwillig."))
      .add(new FssFormRowCheckbox("save", "Angaben in Cookie speichern", values.save))
      .on("submit", (data) ->
        if parseInt(data.test, 10) isnt answer
          data.message = "Die Antwort ist nicht korrekt."
          return Fss.login(callback, data)

        handler = (retData) ->
          if retData.login
            if data.save
              Cookies.set('name', data.name, expires: 365, path: '')
              Cookies.set('email_address', data.email_address, expires: 365, path: '')
            else
              Cookies.remove('name', path: '')
              Cookies.remove('email_address', path: '')
            callback()
          else
            data.message = retData.message
            Fss.login(callback, data)
        Fss.post 'users/', user: data, handler, handler 

      )
      .open()

  @checkLogin: (callback) ->
    Fss.post "users/status", {}, (data) ->
      if data.login
        callback()
      else
        input = {}
        if Cookies.get('name')
          input.name = Cookies.get('name')
          input.save = true;
          if Cookies.get('email_address')
            input.email_address = Cookies.get('email_address')
        Fss.login(callback, input)

  @getResource: (type, id, callbackSuccess) ->
    Fss.get "#{type}/#{id}", {}, (data) ->
      callbackSuccess(data[data.resource_name])

  @getResources: (type, callbackSuccess) ->
    Fss.get "#{type}", {}, (data) ->
      callbackSuccess(data[type])

  @get: (url, data, callbackSuccess, callbackFailed=false) ->
    Fss.ajaxRequest("GET", url, data, callbackSuccess, callbackFailed=false)
  
  @post: (url, data, callbackSuccess, callbackFailed=false) ->
    Fss.ajaxRequest("POST", url, data, callbackSuccess, callbackFailed=false)

  @put: (url, data, callbackSuccess, callbackFailed=false) ->
    Fss.ajaxRequest("PUT", url, data, callbackSuccess, callbackFailed=false)

  @ajaxRequest: (type, url, data, callbackSuccess, callbackFailed=false) ->
    url = "/api/#{url}"
    wait = new WaitFssWindow()

    params =
      type: type
      url: url
      data: data
      dataType: 'json'
      success: (data) ->
        wait.close()
        if data.success
          callbackSuccess(data)
        else if callbackFailed
          callbackFailed(data)
        else
          message = if data.message? then data.message else JSON.stringify(data)
          new WarningFssWindow(message)
    
    if data instanceof FormData
      params.processData = false
      params.contentType = false
    $.ajax(params)

  @postReload: (type, data) ->
    Fss.post type, data, (result) ->
      if result.success
        location.reload()
      else
        new WarningFssWindow(data.message)

  @teamMates: (scoreId) ->
    Fss.checkLogin () ->
      Fss.getResource 'group_scores', scoreId, (score) ->
        wks = Fss.wks[score.discipline]
        wks = wks[score.gender] if score.discipline is 'fs'

        buildWindow = (withGender) ->
          options = {}
          options = { gender: score.gender } if withGender
          Fss.get 'people', options, (data) ->
            people = data.people
            fssWindow = FssWindow.build("Wettkämpfer zuordnen")
            .add(new FssFormRowDescription("Sie ordnen Personen diesen #{score.translated_discipline_name}-Läufen zu."))
            try
              fssWindow.add(new FssFormRowScores('scores', people, score.similar_scores, wks))
            catch
              buildWindow(false)
              return

            if score.gender == 'male' && withGender
              div = $('<div/>').css(marginTop: '12px', marginBottom: '10px')
              .append($('<span/>').text('Auch Frauen zur Auswahl stellen (für gemischte Mannschaften): '))
              .append($('<button/>').text('Auswahl erweitern').on('click', (e) =>
                e.preventDefault()
                fssWindow.close()
                buildWindow(false)
              ))
              fssWindow.add(new FssFormRow(div))
            fssWindow.on("submit", (data) ->
              Fss.reloadOnArrayReady data.scores, (score, success) ->
                Fss.put("group_scores/#{score.id}/person_participation", group_score: score, success)
            )
            .open()
        buildWindow(true)

  @tdScoreHandle = (selector, buttonCallback) ->
    button = null
    $(document).on 'mouseenter', selector, () ->
      td = $(this)
      tr = td.closest('tr')
      score = tr.data('id')
      table = tr.closest('table')
      button = $('<span/>').addClass('bt').appendTo(td)
      buttonCallback(button, score, table, td)
    $(document).on 'mouseleave', selector, () ->
      if button
        button.remove()
        button = null

  @reloadOnArrayReady = (array, dataCallback) ->
    ready = 0
    elementReady = () ->
      ready++
      location.reload() if ready > array.length
    
    for element in array
      dataCallback(element, elementReady)
    elementReady()

  @changeRequest = (key, data, files=[]) ->
    postData = new FormData()
    postData.append("change_request[files][]", file) for file, i in files

    appendData = (keyName, obj) ->
      if typeof obj is "object"
        appendData("#{keyName}[#{subKeyName}]", value) for subKeyName, value of obj
      else
        postData.append("#{keyName}", obj)
    appendData("change_request", 
      content:
        key: key
        data: data
    )
    
    Fss.post 'change_requests', postData, (result) ->
      new AlertFssWindow(
        'Gespeichert',
        'Der Fehlerbericht wurde gespeichert und ein Administrator informiert. In ein paar Tagen wird das Problem behoben sein.'
      )