reloadErrors = () ->
  Fss.getResources 'change_requests', (changeRequests) ->
    table = $('#change-requests')
    table.children().remove()
    for changeRequest in changeRequests
      continue if changeRequest.done_at
      error = new Error(changeRequest.id, changeRequest.content, changeRequest.created_at, changeRequest.files)
      table.append(error.getTr())

parseDateTime = (dateTime) ->
  new Date(dateTime)

class Error
  constructor: (@id, @content, @createdAt, @files) ->
    @key = @content.key
    @data = @content.data
    @headline = @key
    @openTrs = null
    @openType = () =>
    @isOpen = false
    switch @key
      when "competition-change-name", "competition-add-hint" then @handleCompetition()
      when "person" then @handlePerson()
      when "team-other", "team-correction", "team-merge", "team-logo" then @handleTeam()
      when "date" then @handleDate()


  getTr: () =>
    creatorTd = $('<th/>').text(@creatorName)
    if @creatorEmail
      creatorTd.append(" (")
      creatorTd.append($('<a/>').attr("href", "mailto:#{@creatorEmail}").text(@creatorEmail))
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
        code = $('<tr/>').append($('<td/>').attr('colspan', 4).append($('<pre/>').text(JSON.stringify(@content))))
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
                Fss.put "competitions/#{@data.competition_id}", competition: data, () => @confirmDone()
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
    getPersonBox = (appendTo, headline = "Person", id = @content.personId) =>
      box = @box(3, appendTo).append($('<h4/>').text(headline))
      Fss.getPerson id, (person) ->
        box.append(
          $('<a/>')
          .attr('href', "/page/person-#{person.id}.html")
          .text("#{person.firstname} #{person.name} (#{person.sex})")
        ).append("<br/>ID: #{id}")
    @headline = "Person"
    switch @content.reason
      when "correction"
        @headline += " - Korrektur"
        @openType = (div) =>
          getPersonBox(div)
          @box(4, div)
            .append($('<h4/>').text("Korrektur"))
            .append("Vorname: #{@content.firstname}<br/>Nachname: #{@content.name}")
          @getActionBox div, () =>
            Fss.post 'set-person-name', @content, (data) => @confirmDone()

      when "merge"
        @headline += " - Zusammenführen"
        @openType = (div) =>
          action = (params = {}) =>
            params.newPersonId = @content.newPersonId
            params.personId = @content.personId
            Fss.post 'set-person-merge', params, (data) => @confirmDone()
          getPersonBox(div)
          getPersonBox(div, "Richtige Person", @content.newPersonId)
          @getActionBox(div, () => action() )
          .append($('<button/>').text('Immer beheben').click( () => 
            @confirmAction(
              () -> action( always: true ),
              "Beim Import wird in Zukunft immer automatisch der Name ersetzt."
            )
          ))

      when "other"
        @headline += " - Freitext"
        @openType = (div) =>
          getPersonBox(div)
          @box(5, div).append($('<pre/>').text(@content.description))
          @getActionBox(div)
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
            Fss.put "teams/#{@data.team_id}", team: @data.team, () => @confirmDone()

      when "team-merge"
        @headline += " - Zusammenführen"
        @openType = (div) =>
          action = (params = {}) =>
            params.correct_team_id = @data.correct_team_id
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
                Fss.put "teams/#{@data.team_id}", team: { image_change_request: "#{@id}-#{i}" }, () => @confirmDone()
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
    getDateBox = (appendTo, headline = "Termin", id = @content.dateId) =>
      box = @box(5, appendTo).append($('<h4/>').text(headline))
      Fss.post 'get-date', dateId: id, (data) ->
        date = data.date
        Fss.post 'get-place', placeId: date.place_id, (data) ->
          place = data.place
          Fss.post 'get-event', eventId: date.event_id, (data) ->
            event = data.event
            box.append(
              $('<a/>')
              .attr('href', "/page/date-#{date.id}.html")
              .text("#{date.name} (#{parseDateTime(date.date).toLocaleDateString()})")
            )
            .append("<br/>ID: #{id}")
            .append("<br/>Ort: #{place.name}")
            .append("<br/>Typ: #{event.name}")
            .append("<br/>")
            .append($("<pre/>").text(date.description))
            .append("<br/>Disziplinen: #{date.disciplines}")

    @headline = "Termin"
    switch @content.reason
      when "change"
        @headline += " - Änderung"
        @openType = (div) =>
          getDateBox(div)
          correctBox = @box(5, div)
          .append($('<h4/>').text("Korrektur"))
          .append("Name: #{@content.date.name}")


          Fss.post 'get-place', placeId: @content.date.placeId, (data) =>
            place = data.place
            Fss.post 'get-event', eventId: @content.date.eventId, (data) =>
              event = data.event
              correctBox
              .append("<br/>Ort: #{place.name}")
              .append("<br/>Typ: #{event.name}")
              .append("<br/>")
              .append($("<pre/>").text(@content.date.description))
              for discipline, name of Fss.disciplines
                correctBox.append("<br/>#{name}: #{@content.date[discipline]}")
          @getActionBox(div, () => 
            data = @content.date
            data.dateId = @content.dateId
            Fss.post 'set-date', data, (d) => @confirmDone()
          , 2)
      else
        @openType = (div) =>
          @getActionBox(div)


$ ->
  reloadErrors()

