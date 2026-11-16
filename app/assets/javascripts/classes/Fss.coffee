#= require classes/AlertFssWindow
#= require classes/FssFormRow
#= require classes/FssWindow
#= require classes/WarningFssWindow

class @Fss
  @disciplines: {
    la: 'Löschangriff'
    fs: 'Feuerwehrstafette'
    gs: 'Gruppenstafette'
    hl: 'Hakenleitersteigen'
    hb: 'Hindernisbahn'
  }
  @genders: {
    male: 'männlich'
    female: 'weiblich'
  }
  @loginStatus: false
  @loginUser: null


  @ready: (path, callback) ->
    M3.ready ->
      if typeof(path) is 'string' and window.location.pathname.indexOf("/#{path}") isnt -1
        callback()
      else if path instanceof RegExp and path.test(window.location.pathname)
        callback()

  @logoutWindow: ->
    new ConfirmFssWindow 'Benutzer abmelden?', 'Wollen Sie sich abmelden?', ->
      Fss.post 'api_users/logout', {}, ->
        new WaitFssWindow()
        location.reload()
  
  @login: (callback, values = {}) ->
    defaultValues = {
      name: ''
      email_address: ''
      save: false
    }
    values = $.extend(defaultValues, values)

    # the question is created on the server, the answer is checked there
    Fss.post 'api_users/challenge', {}, (challenge) ->
      w = FssWindow.build('Anmelden')

      w.add((new FssFormRowDescription(values.message)).addClass('text-warning')) if values.message?

      w
        .add(new FssFormRowText('captcha_answer', challenge.question))
        .add(new FssFormRowDescription('Bitte lösen Sie die Rechenaufgabe.'))
        .add(new FssFormRowText('name', 'Name', values.name))
        .add(new FssFormRowText('email_address', 'E-Mail-Adresse', values.email_address))
        .add(new FssFormRowDescription('Bitte geben Sie einen Namen und/oder eine E-Mail-Adresse an. ' +
          'Die Angaben sind nur für Rückfragen bei Problemen gedacht.'))
        .add((new FssFormRowText('website', 'Bitte leer lassen')).addClass('fss-form-row-hp'))
        .add(new FssFormRowCheckbox('save', 'Angaben in Cookie speichern', values.save))
        .on('submit', (data) ->
          handler = (retData) ->
            if retData.login
              if data.save
                Cookies.set('name', data.name, { expires: 365, path: '' })
                Cookies.set('email_address', data.email_address, { expires: 365, path: '' })
              else
                Cookies.remove('name', { path: '' })
                Cookies.remove('email_address', { path: '' })
              callback()
            else
              data.message = retData.message
              Fss.login(callback, data)
          params = {
            api_user: { name: data.name, email_address: data.email_address }
            captcha_answer: data.captcha_answer
            website: data.website
          }
          Fss.post('api_users/', params, handler, handler)
        )
        .open()

  @checkLogin: (callback) ->
    Fss.post 'api_users/status', {}, (data) ->
      if data.login
        callback()
      else
        input = {}
        if Cookies.get('name')
          input.name = Cookies.get('name')
          input.save = true
          if Cookies.get('email_address')
            input.email_address = Cookies.get('email_address')
        Fss.login(callback, input)

  @getResource: (type, id, dataOrCallback, callbackSuccess = null) ->
    if typeof dataOrCallback is 'function'
      callbackSuccess = dataOrCallback
      dataOrCallback = {}

    Fss.get "#{type}/#{id}", dataOrCallback, (data) ->
      callbackSuccess(data[data.resource_name])

  @getResources: (type, dataOrCallback, callbackSuccess = null) ->
    if typeof dataOrCallback is 'function'
      callbackSuccess = dataOrCallback
      dataOrCallback = {}
    Fss.get type, dataOrCallback, (data) ->
      callbackSuccess(data[type.replace(/\//, '_')])

  @get: (url, data, callbackSuccess, callbackFailed = false) ->
    Fss.ajaxRequest('GET', url, data, {}, callbackSuccess, callbackFailed)
  
  @post: (url, data, callbackSuccess, callbackFailed = false) ->
    Fss.ajaxRequest('POST', url, data, {}, callbackSuccess, callbackFailed)

  @put: (url, data, callbackSuccess, callbackFailed = false) ->
    Fss.ajaxRequest('PUT', url, data, {}, callbackSuccess, callbackFailed)

  @delete: (url, callbackSuccess, callbackFailed = false) ->
    Fss.ajaxRequest('DELETE', url, {}, {}, callbackSuccess, callbackFailed)

  @ajaxRequest: (type, url, data, options, callbackSuccess, callbackFailed = false) ->
    url = "/api/#{url}"
    wait = new WaitFssWindow()

    params = {
      type: type
      url: url
      data: data
      dataType: 'json'
      success: (data) ->
        wait.close()

        if data.login
          Fss.loginStatus = true
          Fss.loginUser = data.current_user
        else
          Fss.loginStatus = false
          Fss.loginUser = null

        if data.success
          callbackSuccess(data)
        else if callbackFailed
          callbackFailed(data)
        else
          message = if data.message? then data.message else JSON.stringify(data)
          new WarningFssWindow(message)
      error: (xhr, status) ->
        wait.close()
        if xhr.responseJSON?.message?
          new WarningFssWindow(xhr.responseJSON.message)
        else
          new WarningFssWindow("Die Hintergrundanfrage zur URL #{url} schlug fehl: #{status}")
    }
    if data instanceof FormData
      params.processData = false
      params.contentType = false
    if options.contentType is 'json'
      params.contentType = 'application/json'
      params.data = JSON.stringify(params.data)
    $.ajax(params)

  @ajaxReload: (ajaxType, url, data) ->
    Fss.ajaxRequest ajaxType, url, data, {}, (result) ->
      if result.success
        new WaitFssWindow()
        location.reload()
      else
        new WarningFssWindow(data.message)
