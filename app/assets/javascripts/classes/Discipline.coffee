#= require classes/InputLine
#= require classes/TestScoreResult
#= require classes/MissingTeam
#= require classes/EventHandler

class @Discipline extends EventHandler
  constructor: (@discipline, @gender) ->
    super()
    @testScoresContainer = $('<div/>')
    
    @fieldset = $('<fieldset/>')
      .addClass('discipline')
      .addClass('discipline-' + @discipline)
      .addClass(@gender)

    content = $('<div/>')
    $('<legend/>')
      .text(Fss.disciplines[@discipline] + ' - ' + Fss.genders[@gender])
      .click( -> content.toggle() )
      .appendTo(@fieldset)

    $('<button/>')
      .addClass('pull-right')
      .text('Löschen')
      .click(@remove)
      .appendTo(content)

    @inputLine = new InputLine(@discipline)
    content.append(@inputLine.get())
    @fieldset.append(content)

    @textarea = $('<textarea/>')
    @selectSeparator = $('<select/>')
      .append($('<option/>').text('TAB').val('\t'))
      .append($('<option/>').text(',').val(','))
      .append($('<option/>').text('|').val('|'))

    content = $('<div/>')
      .append(@textarea)
      .append(@selectSeparator)
      .append($('<button/>').text('Testen').click(@testInput))
    @fieldset.append(content).append(@testScoresContainer)

    $('#disciplines').append(@fieldset)

  testInput: =>
    Fss.post 'imports/check_lines', {
      import: {
        discipline: @discipline
        gender: @gender
        raw_lines: @textarea.val()
        separator: @selectSeparator.val()
        raw_headline_columns: @inputLine.val(@selectSeparator.val())
      }
    }, (data) =>
      @textarea.animate({ height: 90 })
      @testScoresContainer.children().remove()
      @showMissingTeams(data.missing_teams)
      @showTestScores(data.import_lines)
  
  showTestScores: (checkedLines) =>
    @resultScores = []
    table = $('<table/>').addClass('table table-bordered table-condensed')
    fields = { times: 0 }

    for checkedLine in checkedLines
      testScoreResult = new TestScoreResult(checkedLine, fields)
      fields = testScoreResult.getFields()
      @resultScores.push(testScoreResult)
    
    for resultScore in @resultScores
      table.append(resultScore.get(fields))
    button = $('<button/>').text('Eintragen').click(@selectCategory)
    @testScoresContainer.append(table).append(button)

  getGroupScoreCategories: (callback) =>
    input = {
      competition_id: $('#competitions').val()
      discipline: @discipline
    }
    Fss.getResources('group_score_categories', input, callback)

  getSingleDisciplines: (callback) =>
    input = {
      key: @discipline
    }
    Fss.getResources('single_disciplines', input, callback)

  importRows: (origRows) =>
    rows = origRows.slice()
    return unless rows?
    headline = rows.shift()

    @inputLine.removeAllFields()
    for headlineColumn in headline
      type = switch headlineColumn
        when 'Vorname' then 'first_name'
        when 'Nachname' then 'last_name'
        when 'Mannschaft' then 'team'
        when 'Lauf' then 'run'
        when 'time' then 'time'
        else 'col'
      @inputLine.addField(type)
    @textarea.val(rows.map( (row) -> row.join("\t") ).join("\n"))

  selectCategory: =>
    if not @categoryId and $.inArray(@discipline, ['hl', 'hb']) is -1
      @getGroupScoreCategories (categories) =>
        return @addCategory() if categories.length is 0

        options = []
        for category in categories
          options.push {
            display: "#{category.name} - #{category.group_score_type}"
            value: category.id
          }


        addCategoryButton = $('<button/>').text('Neue Kategorie').on('click', (e) =>
          e.preventDefault()
          currentWindow.close()
          @addCategory()
        )

        currentWindow = FssWindow.build('Kategorie auswählen')
        .add(new FssFormRowRadio('categoryId', 'Kategorie', categories[0].id, options))
        .add(new FssFormRow(addCategoryButton))
        .on('submit', (data) =>
          @categoryId = data.categoryId
          @addResultScores()
        )
        .open()
    else
      @getSingleDisciplines (singleDisciplines) =>
        options = []
        for singleDiscipline in singleDisciplines
          options.push {
            display: "#{singleDiscipline.name} - #{singleDiscipline.description}"
            value: singleDiscipline.id
          }

        currentWindow = FssWindow.build('Disziplin auswählen')
        .add(new FssFormRowRadio('singleDisciplineId', 'Einzel', singleDisciplines[0].id, options))
        .on('submit', (data) =>
          @singleDisciplineId = data.singleDisciplineId
          @addResultScores()
        )
        .open()

  addCategory: =>
    Fss.getResources 'group_score_types', { discipline: @discipline }, (groupScoreTypes) =>
      types = []
      types.push({ value: type.id, display: type.name }) for type in groupScoreTypes

      FssWindow.build('Kategorie hinzufügen')
      .add(new FssFormRowText('name', 'Name', 'default'))
      .add(new FssFormRowRadio('group_score_type_id', 'Typ', null, types))
      .on('submit', (data) =>
        data.competition_id = $('#competitions').val()
        Fss.post 'group_score_categories', { group_score_category: data }, =>
          @selectCategory()
      )
      .open()

  addResultScores: =>
    scores = []
    for resultScore in @resultScores
      scores.push(resultScore.getObject()) if resultScore.isValid()

    i = -1
    importRows = =>
      i++
      nextScores = scores.slice(15 * i, 15 * (i + 1))
      if nextScores.length is 0
        @fire('refresh-results')
        @remove()
        return

      input = {
        import: {
          scores: nextScores
          competition_id: $('#competitions').val()
          group_score_category_id: @categoryId
          single_discipline_id: @singleDisciplineId
          discipline: @discipline
          gender: @gender
        }
      }
      Fss.ajaxRequest 'POST', 'imports/scores', input, { contentType: 'json' }, ->
        importRows()
    importRows()

  showMissingTeams: (missingTeams) =>
    return unless missingTeams.length
    ul = $('<ul/>').addClass('disc').addClass('missing-teams')
    for team in missingTeams
      missingTeam = new MissingTeam(team, @testInput)
      ul.append(missingTeam.get())
    @testScoresContainer.append(ul)

  remove: =>
    @fieldset.remove()
