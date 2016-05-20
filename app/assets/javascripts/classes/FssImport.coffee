#= require classes/Discipline
#= require classes/PublishStatus

class @FssImport
  constructor: () ->
    @selectCompetition = $('#competitions').change(@changeCompetition)
    @competitions = []
    @lastValue = null

    Fss.checkLogin () =>
      Fss.getResources 'score_types', (@scoreTypes) =>

    $('#change-competition-score-type').click (ev) =>
      ev.preventDefault()

      options = [{display: "--", value: ""}]
      for type in @scoreTypes
        options.push({display: "#{type.score}/#{type.run}/#{type.people}", value: type.id})

      Fss.checkLogin () =>
        FssWindow.build("Mannschaftswertung")
        .add(new FssFormRowSelect('score_type_id', 'Wertung', @competition.score_type_id, options))
        .on('submit', (data) =>
          competitionId = @selectCompetition.find('option:selected').val()
          params = 
            competition: data
            log_action: "update-score-type"
          Fss.put("competitions/#{competitionId}", params, () => @addSuccess( () => @changeCompetition() ) )
        )
        .open()

    $("input[name='competition-type']").change(@selectCompetitionType)

    $(".add-place").click () =>
      Fss.checkLogin () =>
        FssWindow.build("Ort hinzufügen")
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post('places', place: data, log_action: "add-place", () => @addSuccess() ) )
        .open()

    $(".add-event").click () =>
      Fss.checkLogin () =>
        FssWindow.build("Typ hinzufügen")
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post('events', event: data, log_action: "add-event", () => @addSuccess() ) )
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
        .on('submit', (data) => Fss.post('group_score_types', group_score_type: data, log_action: "add-group-score-type", () => @addSuccess() ) )
        .open()

    $(".add-competition").click () =>
      Fss.checkLogin () =>
        Fss.getResources 'events', (events) =>
          Fss.getResources 'places', (places) =>
            eventOptions = []
            eventOptions.push({display: event.name, value: event.id}) for event in events
            placeOptions = []
            placeOptions.push({display: place.name, value: place.id}) for place in places
            
            FssWindow.build("Wettkampf hinzufügen")
            .add(new FssFormRowText('name', 'Name'))
            .add(new FssFormRowSelect('place_id', 'Ort', null, placeOptions))
            .add(new FssFormRowSelect('event_id', 'Typ', null, eventOptions))
            .add(new FssFormRowDate('date', 'Datum'))
            .on('submit', (data) => Fss.post 'competitions', competition: data, log_action: "add-competition", () =>
              @addSuccess () ->
                $("input[name='competition-type'][value='latest']").prop('checked', true).trigger('change')
            )
            .open()

    $('.add-discipline').click (ev) =>
      for className in ev.target.className.split(' ')
        res = className.match(/^discipline-([a-z]{2})-((?:fe)?male)$/)
        if res
          discipline = new Discipline(res[1], res[2])
          discipline.on('refresh-results', () => @changeCompetition() )
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
        .attr('href', "/competitions/#{option.val()}")
        .text(option.text())
      $('#competition-link-admin')
        .attr('href', "/backend/competitions/#{option.val()}")
        .text("#{option.text()} - Admin")
      @loadCompetition(option.val())

  loadCompetition: (competitionId) =>
    Fss.getResource 'competitions', competitionId, (@competition) =>
      $('#change-competition-score-type span').text("(#{@competition.score_type})")
      @loadScores()
      new PublishStatus($('#competition-published'), @competition)

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
      sortedCompetitions.sort (a, b) -> return b.date.localeCompare(a.date)
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
    container = $('#competition-scores')
    container.children().remove()

    table = $('<table/>').appendTo(container)
    for discipline, genders of @competition.score_count
      for gender, gender_count of genders
        if gender_count > 0
          table.append($('<tr/>')
            .addClass("discipline-#{discipline}").addClass('discipline').addClass(gender)
            .append($('<th/>').text("#{discipline}-#{gender}"))
            .append($('<td/>').text(gender_count))
          )

  reloadCompetitions: (callback) =>
    Fss.getResources 'group_score_types', (@groupScoreTypes) =>
      table = $('#show-group-score-types table')
      table.children().remove()
      for scoreType in @groupScoreTypes
        table.append($('<tr/>').append($('<td/>').text(scoreType.discipline)).append($('<td/>').text(scoreType.name)))

    Fss.getResources 'competitions', (@competitions) =>
      callback()