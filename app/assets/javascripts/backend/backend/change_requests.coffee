#= require classes/Fss

reloadErrors = () ->
  Fss.getResources 'change_requests', (changeRequests) ->
    table = $('#change-requests')
    table.children().remove()
    for changeRequest in changeRequests
      continue if changeRequest.done_at
      error = new Error(changeRequest.id, changeRequest.content, changeRequest.created_at, changeRequest.files, changeRequest.user)
      table.append(error.getTr())

parseDateTime = (dateTime) ->
  new Date(dateTime)

class Error
  constructor: (@id, @content, @createdAt, @files, @user={}) ->
    @key = @content.key
    @data = @content.data
    @headline = @key
    @openTrs = null
    @openType = () =>
    @isOpen = false
    switch @key
      when "competition-change-name", "competition-add-hint" then @handleCompetition()
      when "person-correction", "person-merge", "person-other", "person-change-nation" then @handlePerson()
      when "team-other", "team-correction", "team-merge", "team-logo" then @handleTeam()
      when "appointment-edit" then @handleDate()
      when "report-link" then @handleLink()


  getTr: () =>
    creatorTd = $('<td/>').text(@user.name).addClass('small')
    if @user.named_email_address
      creatorTd.append(" (")
      creatorTd.append($('<a/>').attr("href", "mailto:#{@user.named_email_address}").text(@user.named_email_address))
      creatorTd.append(")")
    @tr = $('<tr/>')
      .append($('<th/>').text(parseDateTime(@createdAt).toLocaleString()))
      .append(creatorTd)
      .append($('<th/>').text(@headline))
      .append($('<th/>')
      .append($('<button/>').append($('<span/>').addClass("glyphicon glyphicon-chevron-down"))
      .on('click', @click)
      .css('cursor', 'pointer')
      ))
    
  click: () =>
    if @isOpen
      @openTrs.hide()
      @tr.removeClass('active').find('span').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
      @isOpen = false
    else
      @isOpen = true
      @tr.addClass('active').find('span').toggleClass('glyphicon-chevron-down glyphicon-chevron-up')
      unless @openTrs
        code = $('<tr/>').append($('<td/>').attr('colspan', 4).append($('<pre/>').text(JSON.stringify(@content, null, 2))))
        div = $('<div/>').addClass("row")
        @openType(div)
        @openTrs = code.add($('<tr/>').append($('<td/>').attr('colspan', 4).append(div)))
        @tr.after(@openTrs)
      else
        @openTrs.show()

  box: (cols, appendTo = null) =>
    div = $('<div/>').addClass("col-md-#{cols}")
    div.appendTo(appendTo) if appendTo
    div

  getActionBox: (div, callback = null, cols = 3) =>
    box = @box(cols, div).append($('<div/>').addClass('btn btn-default').text('Erledigt').click( () => @confirmDone("Ohne Aktion - ") ))
    if callback
      box.append('<br/>').append($('<div/>').addClass('btn btn-success').text('Beheben').click( () => @confirmAction(callback) ))
    box

  confirmAction: (callback, text = "") ->
    new ConfirmFssWindow("Fehler wirklich beheben?", "Diese Aktion verändert die Daten! #{text}", () -> callback())    

  confirmDone: (text = "") =>
    new ConfirmFssWindow(text + 'Fehler erledigt', text + 'Wirklich als erledigt markieren?', () =>
      Fss.put "change_requests/#{@id}", change_request: { done: 1 }, () -> reloadErrors()
    )

  handleCompetition: () =>
    getCompetitionBox = (appendTo, headline = "Wettkampf", id = @data.competition_id) =>
      box = @box(3, appendTo).append($('<h4/>').text(headline))
      Fss.getResource "competitions", id, (competition) ->
        box.append(
          $('<a/>')
          .attr('href', "/competitions/#{id}")
          .text("#{competition.date} (#{competition.name})")
        )
        .append("<br/>ID: #{id}")
        .append("<br/>Ort: #{competition.place}")
        .append("<br/>Typ: #{competition.event}")
    @headline = "Wettkampf"
    switch @key
      when "competition-change-name"
        @headline += " - Name"
        @openType = (div) =>
          getCompetitionBox(div)
          @box(4, div)
            .append($('<h4/>').text("Korrektur"))
            .append("Name: #{@data.name}")
          @getActionBox(div)
          .append('<br/>')
          .append $('<div/>').addClass('btn btn-success').text('Neuen Namen setzen').click () =>
            FssWindow.build('Namen eintragen')
            .add(new FssFormRowText('name', 'Name', @data.name))
            .on('submit', (data) =>
              @confirmAction () =>
                Fss.put "competitions/#{@data.competition_id}", competition: data, log_action: "update-name", () => @confirmDone()
            )
            .open()
      when "competition-add-hint"
        @headline += " - Hinweis"
        @openType = (div) =>
          getCompetitionBox(div)
          @box(3, div)
          .append($('<h4/>').text("Neuer Hinweis"))
          .append($('<pre/>').text(@data.hint))
          .append($('<a/>').attr('href', "/backend/competitions/#{@data.competition_id}/edit").text("Wettkampf bearbeiten"))
          hintsBox = @box(3, div)
          @getActionBox(div)
      else
        @openType = (div) =>
          @getActionBox(div)

  handlePerson: () =>
    getPersonBox = (appendTo, callback = null, headline = "Person", id = @data.person_id) =>
      box = @box(3, appendTo).append($('<h4/>').text(headline))
      Fss.getResource "people", id, (person) ->
        box.append(
          $('<a/>')
          .attr('href', "/page/person-#{person.id}.html")
          .text("#{person.first_name} #{person.last_name} (#{person.gender_translated})")
        ).append("<br/>ID: #{id}")
        callback(person, box)
    @headline = "Person"
    switch @key
      when "person-correction"
        @headline += " - Korrektur"
        @openType = (div) =>
          getPersonBox(div)
          @box(4, div)
            .append($('<h4/>').text("Korrektur"))
            .append("Vorname: #{@data.person.first_name}<br/>Nachname: #{@data.person.last_name}")
          @getActionBox div, () =>
            Fss.put "people/#{@data.person_id}", person: @data.person, log_action: "update-name", () => @confirmDone()

      when "person-merge"
        @headline += " - Zusammenführen"
        @openType = (div) =>
          action = (params = {}) =>
            params.correct_person_id = @data.correct_person_id
            params.log_action = "merge"
            Fss.post "people/#{@data.person_id}/merge", params, (data) => @confirmDone()
          getPersonBox(div)
          getPersonBox(div, null, "Richtige Person", @data.correct_person_id)
          @getActionBox(div, () => action() )
          .append($('<div/>').addClass("btn btn-info").text('Immer beheben').click( () => 
            @confirmAction(
              () -> action( always: true ),
              "Beim Import wird in Zukunft immer automatisch der Name ersetzt."
            )
          ))

      when "person-other"
        @headline += " - Freitext"
        @openType = (div) =>
          getPersonBox(div)
          @box(5, div).append($('<pre/>').text(@data.description))
          @getActionBox(div)

      when "person-change-nation"
        @headline += " - Nation ändern"
        @openType = (div) =>
          getPersonBox div, (person, box) ->
            Fss.getResource "nations", person.nation_id, (nation) ->
              box.append($('<div/>').text("Nation: #{nation.name}"))
          inner = @box(4, div)
          Fss.getResource "nations", @data.nation_id, (nation) ->
            inner
            .append($('<h4/>').text("neue Nation"))
            .append(nation.name)
          @getActionBox div, () =>
            Fss.put "people/#{@data.person_id}", person: { nation_id: @data.nation_id }, log_action: "update-nation", () => @confirmDone()
      else
        @openType = (div) =>
          @getActionBox(div)

  handleTeam: () =>
    getTeamBox = (appendTo, callback = null, headline = "Mannschaft", id = @data.team_id) =>
      box = @box(3, appendTo).append($('<h4/>').text(headline))
      Fss.getResource "teams", id, (team) ->
        box.append(
          $('<a/>')
          .attr('href', "/teams/#{team.id}")
          .text("#{team.name} (#{team.state})")
          .attr('title', "#{team.shortcut} (#{team.status})")
        ).append("<br/>ID: #{id}")
        callback(team, box) if callback
    @headline = "Mannschaft"
    switch @key
      when "team-correction"
        @headline += " - Korrektur"
        @openType = (div) =>
          getTeamBox(div)
          @box(4, div)
            .append($('<h4/>').text("Korrektur"))
            .append("Name: #{@data.team.name}<br/>Kurz: #{@data.team.shortcut}<br/>Typ: #{@data.team.status}")
          @getActionBox div, () =>
            Fss.put "teams/#{@data.team_id}", team: @data.team, log_action: "update-name", () => @confirmDone()

      when "team-merge"
        @headline += " - Zusammenführen"
        @openType = (div) =>
          action = (params = {}) =>
            params.correct_team_id = @data.correct_team_id
            params.log_action = "merge"
            Fss.post "teams/#{@data.team_id}/merge", params, (data) => @confirmDone()
          getTeamBox(div)
          getTeamBox(div, null, "Richtige Mannschaft", @data.correct_team_id)
          @getActionBox(div, () -> action() )
          .append($('<div/>').addClass('btn btn-info').text('Immer beheben').click( () => 
            @confirmAction(
              () -> action( always: true ),
              "Beim Import wird in Zukunft immer automatisch der Name ersetzt."
            )
          ))

      when "team-logo"
        @headline += " - Logo"
        @openType = (div) =>
          getTeamBox div, (team, box) ->
            box.append($('<div/>').append($('<img/>').attr('src', team.tile_path))) if team.tile_path
          $.each @files, (i, file) =>
            showButton = $('<div/>').addClass('btn btn-info').text('Anzeigen').click () =>
              showButton.remove()
              Fss.getResource "change_requests/#{@id}/files", i, (file) =>
                $('<img/>').attr('src', "data:#{file.content_type};base64,#{file.binary}").css('width', "200px").appendTo(imageBox)
                selectButton.show()
            selectButton = $('<div/>').hide().addClass("btn btn-success").text('Auswählen').click () => 
              @confirmAction () =>
                Fss.put "teams/#{@data.team_id}", team: { image_change_request: "#{@id}-#{i}" }, log_action: "update-logo", () => @confirmDone()
            imageBox = $("<div/>")
            .append(file.filename)
            .append('<br/>')
            .append(file.content_type)
            .append('<br/>')
            .append(showButton)
            @box(3, div)
            .append(imageBox)
            .append(selectButton)
          @getActionBox(div)

      when "team-other"
        @headline += " - Freitext"
        @openType = (div) =>
          getTeamBox(div)
          @box(5, div).append($('<pre/>').text(@data.description))
          @getActionBox(div)
      else
        @openType = (div) =>
          @getActionBox(div)

  handleDate: () =>
    getAppointmentBox = (appendTo, headline = "Termin", id = @data.appointment_id) =>
      box = @box(5, appendTo).append($('<h4/>').text(headline))
      Fss.getResource 'appointments', id, (appointment) =>
        box.append(
          $('<a/>')
          .attr('href', "/appointments/#{id}")
          .text("#{appointment.name} (#{parseDateTime(appointment.dated_at).toLocaleDateString()})")
        )
        .append("<br/>ID: #{id}")
        .append("<br/>Ort: #{appointment.place}")
        .append("<br/>Typ: #{appointment.event}")
        .append("<br/>")
        .append($("<pre/>").text(appointment.description))
        .append("<br/>Disziplinen: #{appointment.disciplines}")

    @headline = "Termin"
    switch @key
      when "appointment-edit"
        @headline += " - Änderung"
        @openType = (div) =>
          getAppointmentBox(div)
          correctBox = @box(5, div)
          .append($('<h4/>').text("Korrektur"))
          .append("Name: #{@data.appointment.name}")
          .append("<br/>")
          .append($("<pre/>").text(@data.appointment.description))
          .append("Disziplinen: #{@data.appointment.disciplines}")

          if @data.appointment.place_id
            Fss.getResource 'places', @data.appointment.place_id, (place) =>
              correctBox.append("<br/>Ort: #{place.name}")
          else
            @data.appointment.place_id = null
          if @data.appointment.event_id
            Fss.getResource 'events', @data.appointment.event_id, (event) =>
              correctBox.append("<br/>Typ: #{event.name}")
          else
            @data.appointment.event_id = null
          @getActionBox(div, () =>
            Fss.put "appointments/#{@data.appointment_id}", appointment: @data.appointment, log_action: "update", () => @confirmDone()
          , 2)
      else
        @openType = (div) =>
          @getActionBox(div)

  handleLink: () =>
    getLinkBox = (appendTo, id = @data.link_id) =>
      box = @box(5, appendTo).append($('<h4/>').text("Link"))
      Fss.getResource 'links', id, (link) =>
        box.append(
          $('<a/>')
          .attr('href', link.linkable_url)
          .text("#{link.linkable_id} #{link.linkable_type}")
        )
        .append("<br/>")
        .append(
          $('<a/>')
          .attr('href', link.url)
          .text(link.label)
        )
        .append("<br/>Name: #{link.label}")
        .append("<br/>Ziel: #{link.url}")

    @headline = "Link"
    switch @key
      when "report-link"
        @headline += " - Meldung"
        @openType = (div) =>
          getLinkBox(div)
          @box(3, div)
          .append($('<a/>').attr('href', "/backend/links/#{@data.link_id}/edit").text("Link bearbeiten"))
          @getActionBox(div)
          .append("<br/>")
          .append($('<div/>').addClass("btn btn-info").text('Link löschen').click( () => 
            @confirmAction(
              () =>
                Fss.ajaxRequest "DELETE", "links/#{@data.link_id}", {}, {}, () =>
                  @confirmDone()
              "Link löschen?"
            )
          ))
      else
        @openType = (div) =>
          @getActionBox(div)


Fss.ready 'backend/change_request', ->
  reloadErrors()

