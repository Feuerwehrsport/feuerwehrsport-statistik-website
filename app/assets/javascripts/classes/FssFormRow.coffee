#= require classes/EventHandler

autoGeneratedFormRowId = 0

class @FssFormRow extends EventHandler
  constructor: (@fields...) ->
    @classes = []
    super()

  focus: -> false

  addClass: (className) ->
    @classes.push(className)
    this

  appendData: (data) -> data

  content: =>
    container = $('<div/>').addClass('fss-form-row')
    for className in @classes
      container.addClass(className)
    container.append(field) for field in @fields
    container

class @FssFormRowFile extends FssFormRow
  constructor: (@name, label, @defaultValue = false) ->
    @files = null
    @field = $('<input/>')
      .attr('type', 'file')
      .attr('name', @name)
      .on('change', (event) =>
        @files = event.target.files
      )
    super(@field)

  appendData: (data) =>
    if not @files or @files.length is 0
      data[@name] = []
    else
      data[@name] = @files
    data

class @FssFormRowCheckbox extends FssFormRow
  constructor: (@name, label, @defaultValue = false) ->
    @field = $('<input/>')
      .attr('type', 'checkbox')

    @field.attr('checked', true) if @defaultValue

    @label = $('<label/>')
      .addClass('checkbox-label')
      .append(@field)
      .append($('<span/>').text(label))
    super(@label)

  appendData: (data) =>
    data[@name] = @field.is(':checked')
    data

class @FssFormRowDescription extends FssFormRow
  constructor: (description) ->
    super($('<p/>').html(description.replace(/\n/, '<br/>')))
    @addClass('description')

class FssFormRowSplit extends FssFormRow
  constructor: (label, field) ->
    super($('<div/>').addClass('col-md-2').append(label), $('<div/>').addClass('col-md-10').append(field))
    @addClass('row label-row')

class FssFormRowLabelField extends FssFormRow
  constructor: (label, @field) ->
    rowId = autoGeneratedFormRowId++
    @field.attr('id', "fss-form-row-#{rowId}")

    @label = $('<label/>')
      .addClass('text-label')
      .text(label)
      .attr('for', "fss-form-row-#{rowId}")
    super(@label, @field)

  focus: =>
    @field.focus()
    true

  appendData: (data) =>
    data[@name] = @field.val()
    data

class @FssFormRowText extends FssFormRowLabelField
  constructor: (@name, label, @defaultValue = '', @listValues = []) ->
    input = $('<input/>').val(@defaultValue)
    super(label, input)
    if @listValues.length > 0
      rowId = autoGeneratedFormRowId++
      input.attr('list', "fss-list-#{rowId}")
      datalist = $('<datalist/>').prop('id', "fss-list-#{rowId}")
      for value in @listValues
        datalist.append($('<option/>').text(value))
      @fields.push(datalist)

class @FssFormRowTextarea extends FssFormRowLabelField
  constructor: (@name, label, @defaultValue = '') ->
    super(label, $('<textarea/>').val(@defaultValue))

class @FssFormRowHtml extends FssFormRowTextarea
  constructor: (args...) ->
    super(args...)
    @on 'after-add', (fssWindow) =>
      fssWindow.on 'after-open', =>
        @field.htmlarea()

class @FssFormRowSelect extends FssFormRowLabelField
  constructor: (@name, label, @defaultValue = '', options = []) ->
    select = $('<select/>')
    for option in options
      select.append($('<option/>').text(option.display).attr('value', option.value))
    select.val(@defaultValue) if @defaultValue?
    super(label, select)

class @FssFormRowRadio extends FssFormRowLabelField
  constructor: (@name, label, @defaultValue = '', options = []) ->
    @div = $('<div/>').addClass('field-box')
    for option in options
      radio = $('<input/>').attr('type', 'radio').attr('name', @name).attr('value', option.value)
      radio.attr('checked', 'checked') if option.value is @defaultValue
      text = $('<span/>').html(option.display)
      innerLabel = $('<label/>').addClass('checkbox-label').append(radio).append(text)
      @div.append(innerLabel).append($('<br/>'))
    super(label, @div)

  focus: =>
    @div.find('input:nth(0)').focus()
    true

  appendData: (data) =>
    data[@name] = @div.find('input:checked').val()
    data

class @FssFormRowDate extends FssFormRowLabelField
  constructor: (@name, label, defaultDate = '') ->
    d = new Date()
    defaultValues = {
      year: d.getFullYear().toString()
      month: @twoDigits(d.getMonth() + 1)
      day: @twoDigits(d.getDate())
    }
    result = defaultDate.match(/^(\d{4})-(\d{2})-(\d{2})$/)
    if result
      defaultValues = $.extend defaultValues, {
        year: result[1]
        month: result[2]
        day: result[3]
      }

    @day = $('<select/>')
    for val in [1..31]
      @day.append($('<option/>').text(@twoDigits(val)))
    @day.val(defaultValues.day)

    @month = $('<select/>')
    for val in [1..12]
      @month.append($('<option/>').text(@twoDigits(val)))
    @month.val(defaultValues.month)

    @year = $('<select/>')
    for val in [d.getFullYear() - 30..d.getFullYear() + 10]
      @year.append($('<option/>').text(val))
    @year.val(defaultValues.year)

    div = $('<div/>').addClass('field-box').append(@day).append(@month).append(@year)
    super(label, div)

  twoDigits: (input) ->
    input = input.toString()
    if input[1]? then input else "0#{input[0]}"

  focus: =>
    @day.focus()
    true

  appendData: (data) =>
    data[@name] = "#{@year.val()}-#{@month.val()}-#{@day.val()}"
    data


class ScoreParticipation extends EventHandler
  constructor: (@wk, @position, @score, @context, @fssWindow, @team_id, @gender) ->
    @score.participations = [] unless @score.participations
    @score.participations[@position] = this

    @person_id = @score["person_#{@position + 1}"]
    @person_first_name = @score["person_#{@position + 1}_first_name"]
    @person_last_name = @score["person_#{@position + 1}_last_name"]

    @render()

  set: (@person_id, @person_first_name, @person_last_name) =>
    @render()

  render: =>
    if @person_id is null || @person_id is 'NULL'
      text = 'Hinzufügen'
    else
      text = "#{@person_first_name[0]}. #{@person_last_name}"
    @context.children().remove()
    $('<div/>').appendTo(@context).addClass('btn btn-default btn-xs').text(text).click( => @openPopup())

  openPopup: =>
    @fssWindow.hide()
    $.post '/api/suggestions/people', { person_id: @person_id }, (result) =>
      currentPerson = result.people[0]
      params = { score_id: @score.id, position: @position + 1, real_gender: @gender }
      $.post '/api/suggestions/people', params, (result) =>
        @buildPopup(currentPerson, result.people)

  buildPopup: (currentPerson, people) =>
    buildPersonTr = (person) ->
      $('<tr/>')
        .append($('<td/>').addClass('last-name').text(person.last_name))
        .append($('<td/>').addClass('first-name').text(person.first_name))
        .append($('<td/>').addClass('teams').text(person.teams.join(', ')))
    buildSuggestions = (people) =>
      table.children().remove()
      for person in people
        do (person) =>
          buildPersonTr(person).appendTo(table).click =>
            @set(person.id, person.first_name, person.last_name)
            popup.fire('cancel').close()
            @fssWindow.unhide()
    table = $('<table/>').addClass('table table-condensed table-hover select-person')
    buildSuggestions(people)
    input = $('<input/>').on 'keyup', =>
      newValue = input.val()
      @lastValue = newValue if @lastValue isnt newValue and newValue isnt ''

      params = {
        name: @lastValue,
        order_team_id: @team_id,
      }
      if @gender isnt 'male' or not searchInput.find('input[type=checkbox]').prop('checked')
        params.real_gender = @gender
      $.post '/api/suggestions/people', params, (result) ->
        buildSuggestions(result.people)
        add.show()

    add = $('<button/>').addClass('btn btn-default btn-xs').text('Neuen Wettkämpfer hinzufügen').on('click', (e) =>
      popup.close()
      Fss.getResources 'nations', (nations) =>
        genderOptions = [
          { value: 'male', display: 'männlich' }
          { value: 'female', display: 'weiblich' }
        ]
        nationOptions = nations.map (nation) ->
          { value: nation.id, display: nation.name }

        FssWindow.build('Person hinzufügen')
        .add(new FssFormRowText('first_name', 'Vorname'))
        .add(new FssFormRowText('last_name', 'Nachname'))
        .add(new FssFormRowSelect('gender', 'Geschlecht', null, genderOptions))
        .add(new FssFormRowSelect('nation_id', 'Nation', null, nationOptions))
        .on('submit', (personData) =>
          Fss.post('people', { person: personData }, (result) =>
            @set(result.created_id, personData.first_name, personData.last_name)
            @fssWindow.unhide()
          )
        )
        .open()
    ).hide()

    remove = $('<button/>').addClass('btn btn-default btn-xs').text('Wettkämpfer entfernen').on('click', (e) =>
      e.preventDefault()
      @set('NULL', null, null)
      popup.fire('cancel').close()
      @fssWindow.unhide()
    )

    cancel = $('<button/>').addClass('btn btn-default btn-xs').text('Abbrechen').on('click', (e) =>
      e.preventDefault()
      popup.fire('cancel').close()
      @fssWindow.unhide()
    )

    popup = new FssWindow("Wettkämpfer für #{@wk} zuordnen")
    if currentPerson?
      current = $('<table/>').addClass('table table-condensed').append(buildPersonTr(currentPerson))
      popup.add(new FssFormRowSplit('Aktuell', current))

    searchInput = $('<p/>').append(input)
    if @gender is 'male'
      searchInput.append($('<label/>').append($('<input type="checkbox"/>')
      .click( -> input.keyup() )).append(' Auch Frauen anzeigen'))
    popup.add(new FssFormRowSplit('Suche', searchInput.addClass('search-input-line')))
    .add(new FssFormRowSplit('Vorschläge', table))
    .add((new FssFormRow(add, remove, cancel)).addClass('submit-row'))
    .open()

    input.focus()

class @FssFormRowScores extends FssFormRow
  constructor: (@name, @scores, @wks, @fssWindow, @team_id, @gender) ->
    @table = $('<table/>').addClass('score-table')
    tr = $('<tr/>').append($('<td/>')).appendTo(@table)
    tr.append($('<th/>').text(wk)) for wk in @wks
    @appendScore(score, scoreNumber) for score, scoreNumber in @scores
    super(@table)

  appendScore: (score, scoreNumber) =>
    tr = $('<tr/>').append($('<th/>').text(score.second_time)).appendTo(@table)

    for wk, position in @wks
      new ScoreParticipation(wk, position, score, $('<td/>').appendTo(tr), @fssWindow, @team_id, @gender)

    if scoreNumber > 0
      arrowTr = $('<tr/>').append($('<td/>')).insertBefore(tr)
      for wk, position in @wks
        ((partTop, partBottom) ->
          $('<td/>').addClass('text-center').append(
            $('<button/>').text('↧').click (ev) ->
              ev.preventDefault()
              partBottom.set(partTop.person_id, partTop.person_first_name, partTop.person_last_name)
          ).appendTo(arrowTr)
        )(@scores[scoreNumber - 1].participations[position], score.participations[position])

  focus: ->
    true

  appendData: (data) =>
    returnScores = []
    for score, i in @scores
      returnScores[i] = { id: score.id }
      for wk, c in @wks
        returnScores[i]["person_#{c+1}"] = score.participations[c].person_id
    data.scores = returnScores
    data
