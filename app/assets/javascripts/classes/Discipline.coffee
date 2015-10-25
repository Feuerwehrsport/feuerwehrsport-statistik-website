#= require classes/InputLine
#= require classes/TestScoreResult
#= require classes/MissingTeam

class Discipline extends EventHandler
  constructor: (@discipline, @sex) ->
    super
    @testScoresContainer = $('<div/>')
    
    @fieldset = $('<fieldset/>')
      .addClass('discipline')
      .addClass('discipline-' + @discipline)
      .addClass(@sex)

    content = $('<div/>')
    $('<legend/>')
      .text(Fss.disciplines[@discipline] + " - " + Fss.sexes[@sex])
      .click( () -> content.toggle() )
      .appendTo(@fieldset)

    $('<button/>')
      .addClass('top-right')
      .text('Löschen')
      .click(@remove)
      .appendTo(content)

    @inputLine = new InputLine(@discipline)
    content.append(@inputLine.get())
    @fieldset.append(content)

    @textarea = $('<textarea/>')
    @selectSeparator = $('<select/>')
      .append($('<option/>').text('TAB').val("\t"))
      .append($('<option/>').text(',').val(","))
      .append($('<option/>').text('|').val("|"))

    content = $('<div/>')
      .append(@textarea)
      .append(@selectSeparator)
      .append($('<button/>').text('Testen').click(@testInput))
    @fieldset.append(content).append(@testScoresContainer)

    $('#disciplines').append(@fieldset)

  testInput: () =>
    Fss.post 'get-test-scores', 
      discipline: @discipline,
      sex: @sex,
      rawScores: @textarea.val(),
      seperator: @selectSeparator.val(),
      headlines: @inputLine.val()
    , (data) =>
      @textarea.animate(height: 90)
      @testScoresContainer.children().remove()
      @showMissingTeams(data.teams)
      @showTestScores(data.scores)
  
  showTestScores: (scores) =>
    @resultScores = []
    table = $('<table/>').addClass('table table-bordered table-condensed')
    fields = { times: 0 }

    for score in scores
      testScoreResult = new TestScoreResult(score, fields)
      fields = testScoreResult.getFields()
      @resultScores.push(testScoreResult)
    
    for resultScore in @resultScores
      table.append(resultScore.get(fields))
    button = $('<button/>').text('Eintragen').click(@selectCategory)
    @testScoresContainer.append(table).append(button)

  getGroupScoreCategories: (callback) =>
    input =
      competitionId: $('#competitions').val()
      discipline: @discipline
    Fss.post 'get-group-score-categories', input, (data) =>
      callback(data.categories)

  selectCategory: () =>
    if !@categoryId and $.inArray(@discipline, ['hl', 'hb']) is -1
      @getGroupScoreCategories (categories) =>
        return @addCategory() if categories.length is 0

        options = []
        for category in categories
          options.push
            display: "#{category.name} - #{category.type_name}"
            value: category.id


        addCategoryButton = $('<button/>').text('Neue Kategorie').on('click', (e) => 
          e.preventDefault()
          currentWindow.close()
          @addCategory()
        )

        currentWindow = FssWindow.build("Kategorie auswählen")
        .add(new FssFormRowRadio('categoryId', 'Kategorie', categories[0].id, options))
        .add(new FssFormRow(addCategoryButton))
        .on('submit', (data) =>
          @categoryId = data.categoryId
          @addResultScores()
        )
        .open()
    else
      @addResultScores()

  addCategory: () =>
    Fss.post 'get-group-score-types', discipline: @discipline, (data) =>
      types = []
      types.push(value: type.id, display: type.name) for type in data.types

      FssWindow.build("Kategorie hinzufügen")
      .add(new FssFormRowText('name', 'Name', "default"))
      .add(new FssFormRowRadio('groupScoreTypeId', 'Typ', null, types))
      .on('submit', (data) =>
        data.competitionId = $('#competitions').val()
        Fss.post 'add-group-score-category', data, () =>
          @selectCategory()
      )
      .open()

  addResultScores: () =>
    scores = []
    for resultScore in @resultScores
      scores.push(resultScore.getObject()) if resultScore.isCorrect()

    i = -1
    importRows = =>
      i++
      nextScores = scores.slice(15 * i, 15 * (i + 1))
      if nextScores.length is 0
        @fire('refresh-results')
        @remove()
        return

      input =
        scores: nextScores
        competitionId: $('#competitions').val()
        groupScoreCategoryId: @categoryId
        discipline: @discipline
        sex: @sex
      Fss.post 'add-scores', input, (data) ->
        importRows()
    importRows()

  showMissingTeams: (teams) =>
    return unless teams.length 
    ul = $('<ul/>').addClass('disc').addClass('missing-teams')
    for team in teams
      missingTeam = new MissingTeam(team, @testInput)
      ul.append(missingTeam.get())
    @testScoresContainer.append(ul)

  remove: () =>
    @fieldset.remove()
