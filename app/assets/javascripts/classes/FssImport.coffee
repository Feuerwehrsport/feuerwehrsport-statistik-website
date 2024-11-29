#= require classes/Discipline
#= require classes/PublishStatus

class @FssImport
  constructor: ->
    @selectCompetition = $('#competitions').change(@changeCompetition)
    @competitions = []
    @lastValue = null

    Fss.checkLogin =>
      Fss.getResources 'score_types', (@scoreTypes) =>
        undefined

    $('#change-competition-score-type').click (ev) =>
      ev.preventDefault()

      options = [{ display: '--', value: '' }]
      for type in @scoreTypes
        options.push({ display: "#{type.score}/#{type.run}/#{type.people}", value: type.id })

      Fss.checkLogin =>
        FssWindow.build('Mannschaftswertung')
        .add(new FssFormRowSelect('score_type_id', 'Wertung', @competition.score_type_id, options))
        .on('submit', (data) =>
          competitionId = @selectCompetition.find('option:selected').val()
          params = {
            competition: data
            log_action: 'update-competition:score-type'
          }
          Fss.put("competitions/#{competitionId}", params, => @addSuccess( => @changeCompetition) )
        )
        .open()

    $("input[name='competition-type']").change(@selectCompetitionType)

    $('.transfer-file').each (i, td) =>
      td = $(td)
      $('<button/>').text('Übertragen').addClass('btn btn-default btn-xs').appendTo(td).click =>
        competitionId = @selectCompetition.find('option:selected').val()
        fileId = td.data('id')
        FssWindow.build('Datei übertragen')
        .add(new FssFormRowCheckbox('zk_female', 'ZK weiblich'))
        .add(new FssFormRowCheckbox('hb_female', 'HB weiblich'))
        .add(new FssFormRowCheckbox('hl_female', 'HL weiblich'))
        .add(new FssFormRowCheckbox('gs_female', 'GS weiblich'))
        .add(new FssFormRowCheckbox('fs_female', 'FS weiblich'))
        .add(new FssFormRowCheckbox('la_female', 'LA weiblich'))
        .add(new FssFormRowCheckbox('zk_male', 'ZK männlich'))
        .add(new FssFormRowCheckbox('hb_male', 'HB männlich'))
        .add(new FssFormRowCheckbox('hl_male', 'HL männlich'))
        .add(new FssFormRowCheckbox('fs_male', 'FS männlich'))
        .add(new FssFormRowCheckbox('la_male', 'LA männlich'))
        .on('submit', (data) =>
          keys = []
          for key, value of data
            keys.push(key) if value
          Fss.ajaxReload('PUT', "import_request_files/#{fileId}", 
            { import_request_file: { transfer_competition_id: competitionId, transfer_keys_string: keys.join(',') } }
          )
        )
        .open()

    $('.add-place').click =>
      Fss.checkLogin =>
        FssWindow.build('Ort hinzufügen')
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post('places', { place: data }, => @addSuccess) )
        .open()

    $('.add-event').click =>
      Fss.checkLogin =>
        FssWindow.build('Typ hinzufügen')
        .add(new FssFormRowText('name', 'Name'))
        .on('submit', (data) => Fss.post('events', { event: data }, => @addSuccess) )
        .open()

    $('.add-group-score-type').click =>
      Fss.checkLogin =>
        options = []
        for discipline in ['la', 'fs', 'gs']
          options.push({
            value: discipline
            display: Fss.disciplines[discipline]
          })
        FssWindow.build('Gruppen-Typ hinzufügen')
        .add(new FssFormRowText('name', 'Name'))
        .add(new FssFormRowRadio('discipline', 'Disziplin', null, options))
        .on('submit', (data) => Fss.post('group_score_types', { group_score_type: data }, => @addSuccess) )
        .open()

    $('.add-competition').click (event) =>
      defaultValues = $(event.target).data('competition') || {}
      Fss.checkLogin =>
        Fss.getResources 'events', (events) =>
          Fss.getResources 'places', (places) =>
            eventOptions = []
            for event in events
              eventOptions.push({ display: event.name, value: event.id }) 
              defaultValues['event_id'] = event.id if defaultValues['event'] == event.name

            placeOptions = []
            for place in places
              placeOptions.push({ display: place.name, value: place.id })
              defaultValues['place_id'] = place.id if defaultValues['place'] == place.name

            FssWindow.build('Wettkampf hinzufügen')
            .add(new FssFormRowText('name', 'Name', defaultValues['name']))
            .add(new FssFormRowSelect('place_id', 'Ort', defaultValues['place_id'], placeOptions))
            .add(new FssFormRowSelect('event_id', 'Typ', defaultValues['event_id'], eventOptions))
            .add(new FssFormRowDate('date', 'Datum', defaultValues['date']))
            .on('submit', (data) => Fss.post('competitions', { competition: data }, =>
              @addSuccess ->
                $("input[name='competition-type'][value='latest']").prop('checked', true).trigger('change')
            ))
            .open()

    $('.add-discipline').click (ev) =>
      fssImport = this
      button = $(ev.target)
      for className in ev.target.className.split(' ')
        res = className.match(/^discipline-([a-z]{2})-((?:fe)?male)$/)
        if res
          key = res[1]
          gender = res[2]
          discipline = new Discipline(key, gender)
          discipline.on('refresh-results', -> fssImport.changeCompetition())
          discipline.importRows(button.data('rows'))

          return false

        res = className.match(/^discipline-([a-z]{2})-indifferent$/)
        if res
          key = res[1]
          discipline = new Discipline(key, "female")
          discipline.on('refresh-results', -> fssImport.changeCompetition())
          discipline.importRows(button.data('rows'))

          discipline = new Discipline(key, "male")
          discipline.on('refresh-results', -> fssImport.changeCompetition())
          discipline.importRows(button.data('rows'))

    @reloadCompetitions(@selectCompetitionType)

  addSuccess: (callback = false) =>
    new AlertFssWindow 'Eingetragen', '', =>
      @reloadCompetitions =>
        @selectCompetitionType()
        callback() if(callback)


  changeCompetition: =>
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

  selectCompetitionType: =>
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
      sortedCompetitions.sort((a, b) -> b.date.localeCompare(a.date))
    else if value is 'latest'
      sortedCompetitions.sort((a, b) -> b.id - a.id)
    else
      $('#select-competitions').hide()
      $('#create-competitions').show()
      $('#show-group-score-types').show()
      $('#competition-scores').hide()
      $('#competition-published').hide()
    
    for c in sortedCompetitions
      select.append($('<option/>').val(c.id).text("#{c.date} - #{c.event} - #{c.place}"))
    @changeCompetition()

  loadScores: =>
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
