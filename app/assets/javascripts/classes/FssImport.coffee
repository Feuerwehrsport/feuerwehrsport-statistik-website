#= require classes/Discipline
#= require classes/PublishStatus

class FssImport
  constructor: () ->
    @selectCompetition = $('#competitions').change(@changeCompetition)
    @competitions = []
    @lastValue = null

    Fss.checkLogin () =>
      Fss.post 'get-score-types', {}, (data) =>
        @scoreTypes = data.types

    $('#change-competition-score-type').click (ev) =>
      ev.preventDefault()

      options = [{display: "--", value: ""}]
      for type in @scoreTypes
        options.push({display: "#{type.score}/#{type.run}/#{type.persons}", value: type.id})

      Fss.checkLogin () =>
        FssWindow.build("Mannschaftswertung")
        .add(new FssFormRowSelect('scoreTypeId', 'Wertung', @competition.score_type_id, options))
        .on('submit', (data) =>
          data.competitionId = @selectCompetition.find('option:selected').val()
          Fss.post('set-score-type', data, @addSuccess)
        )
        .open()

    $("input[name='competition-type']").change(@selectCompetitionType)

    $(".add-place").click () =>
      Fss.checkLogin () =>
        FssWindow.build("Ort hinzufügen")
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post 'add-place', data, @addSuccess)
        .open()

    $(".add-event").click () =>
      Fss.checkLogin () =>
        FssWindow.build("Typ hinzufügen")
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post 'add-event', data, @addSuccess)
        .open()

    $(".add-group-score-type").click () =>
      Fss.checkLogin () =>
        options = []
        for discipline in ['la', 'fs', 'gs']
          options.push
            value: discipline
            display: Fss.disciplines[discipline]
        FssWindow.build("Gruppen-Typ hinzufügen")
        .add(new FssFormRowText('name', 'Name'))
        .add(new FssFormRowRadio('discipline', 'Disziplin', null, options))
        .on('submit', (data) => Fss.post 'add-group-score-type', data, @addSuccess)
        .open()

    $(".add-competition").click () =>
      Fss.checkLogin () =>
        Fss.getEvents (events) =>
          Fss.getPlaces (places) =>
            eventOptions = []
            for event in events
              eventOptions.push({display: event.name, value: event.id})
            
            placeOptions = []
            for place in places
              placeOptions.push({display: place.name, value: place.id})
            
            FssWindow.build("Wettkampf hinzufügen")
            .add(new FssFormRowText('name', 'Name'))
            .add(new FssFormRowSelect('placeId', 'Ort', null, placeOptions))
            .add(new FssFormRowSelect('eventId', 'Typ', null, eventOptions))
            .add(new FssFormRowDate('date', 'Datum'))
            .on('submit', (data) => Fss.post 'add-competition', data, () => 
              @addSuccess () ->
                $("input[name='competition-type'][value='latest']").attr('checked', true).change()
            )
            .open()

    $('.add-discipline').click (ev) =>
      for className in ev.target.className.split(' ')
        res = className.match(/^discipline-([a-z]{2})-((?:fe)?male)$/)
        if res
          discipline = new Discipline(res[1], res[2])
          discipline.on('refresh-results', () => @loadScores() )
          return false

    @reloadCompetitions(@selectCompetitionType)

  addSuccess: (callback=false) =>
    new AlertFssWindow 'Eingetragen', '', () =>
      @reloadCompetitions () =>
        @selectCompetitionType()
        callback() if callback


  changeCompetition: () =>
    option = @selectCompetition.find('option:selected')
    if option.length
      $('#competition-link')
        .attr('href', "/page/competition-#{option.val()}.html")
        .text(option.text())
      $('#competition-link-admin')
        .attr('href', "/?page=administration&admin=competition&id=#{option.val()}")
        .text("#{option.text()} - Admin")
      @loadCompetition(option.val())
    @loadScores()
    new PublishStatus($('#competition-published'), option.val())

  loadCompetition: (competitionId) =>
    Fss.getCompetition competitionId, (@competition) =>

  selectCompetitionType: () =>
    value = $("input[name='competition-type']:checked").val()
    return if @lastValue is value
    @lastValue = value

    $('#select-competitions').show()
    $('#create-competitions').hide()
    $('#show-group-score-types').hide()
    $('#competition-scores').show()
    $('#competition-published').show()

    select = $('#competitions')
    select.children().remove()

    sortedCompetitions = @competitions.slice()

    if value is 'sorted'
      sortedCompetitions.reverse()
    else if value is 'latest'
      sortedCompetitions.sort (a, b) -> return b.id - a.id
    else
      $('#select-competitions').hide()
      $('#create-competitions').show()
      $('#show-group-score-types').show()
      $('#competition-scores').hide()
      $('#competition-published').hide()
    
    for c in sortedCompetitions
      select.append($('<option/>').val(c.id).text("#{c.date} - #{c.event} - #{c.place}"))
    @changeCompetition()

  loadScores: () =>
    Fss.post 'get-competition-scores', { competitionId: @selectCompetition.val() }, (data) =>
      container = $('#competition-scores')
      container.children().remove()

      table = $('<table/>').appendTo(container)
      for key, sexes of data.scores
        for sexName, sex of sexes
          if sex > 0
            table.append($('<tr/>')
              .addClass("discipline-#{key}").addClass('discipline').addClass(sexName)
              .append($('<th/>').text("#{key}-#{sexName}"))
              .append($('<td/>').text(sex))
            )

  reloadCompetitions: (callback) =>
    Fss.post 'get-group-score-types', {}, (data) =>
      @groupScoreTypes = data.types
      table = $('#show-group-score-types table')
      table.children().remove()
      for scoreType in @groupScoreTypes
        table.append($('<tr/>').append($('<td/>').text(scoreType.discipline)).append($('<td/>').text(scoreType.name)))

    Fss.getCompetitions (newCompetitions) =>
      @competitions = newCompetitions
      callback()