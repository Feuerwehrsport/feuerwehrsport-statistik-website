class TestScoreResult
  constructor: (@raw, @fields) ->
    if @raw.name?
      @needField('name')
      @needField('person_link')
    @needField('teams')              if @raw.teams?      
    @needField('team_ids')           if @raw.team_ids?   
    @needField('team_number')        if @raw.team_number?
    @needField('run')                if @raw.run?       
    @needTimes(@raw['times'].length) if @raw.times?

  needField: (field) =>
    @fields[field] = true
  
  needTimes: (count) => 
    @fields['times'] = Math.max(@fields['times'], count)

  getFields: () =>
    @fields

  get: (fields) =>
    tr = $('<tr/>').click () =>
      tr.toggleClass('correct').toggleClass('not-correct')
      @raw.correct = !@raw.correct
    
    appendTd = (text) -> $('<td/>').text(text).appendTo(tr)

    if @raw.correct
      tr.addClass('correct')
    else
      tr.addClass('not-correct');

    if @raw.name?
      if @raw.persons? and @raw.persons.length > 1
        $('<td/>').append(@personSelect()).appendTo(tr)
      else if @raw.persons? and @raw.persons.length
        appendTd("#{@raw.name} #{@raw.firstname}")
        @raw.person_id = @raw.persons[0].id
      else
        appendTd("#{@raw.name} #{@raw.firstname}").addClass('person-not-found')
      $('<td/>').append(@personLinks()).appendTo(tr)
    else if fields.name
      appendTd('')
      appendTd('')

    if @raw.teams?
      @raw.team = @raw.teams[0]
      if @raw.teams.length > 1
        $('<td/>').append(@teamSelect()).appendTo(tr)
      else
        appendTd(@raw.teams[0])
    else if fields.team
      appendTd('')

    if @raw.team_ids?
      @raw.team_id = @raw.team_ids[0]
      td = $('<td/>').append(@teamLinks()).appendTo(tr)
      td.addClass('null') if @raw.team_ids.length > 1
    else if fields.team_id
      appendTd('')

    if @raw.team_number?
      appendTd(@raw['team_number'])
    else if fields.team_number
      appendTd('')

    if @raw.run?
      appendTd(@raw['run'])
    else if fields.run
      appendTd('')

    if @raw.times?
      for time in @raw.times
        td = appendTd(time)
        td.addClass('null') if time is 'NULL'
      for i in [@raw.times.length..fields.times]
        appendTd('')
    else
      for i in [0..fields.times]
        appendTd('')
    appendTd(@raw['line']).addClass('raw-line')
    tr

  isCorrect: () =>
    @raw.correct

  getObject: () =>
    @raw

  teamSelect: () =>
    teamIds = @raw.team_ids
    teams = @raw.teams
    select = $('<select/>')
    for team, i in teams
      $('<option/>').text("#{team} #{teamIds[i]}").val(i).appendTo(select)
    select.change () =>
      @raw.team_id = teamIds[parseInt(select.val())]
      @raw.team = teams[parseInt(select.val())]

  personSelect: () =>
    select = $('<select/>')
    for p in @raw.persons
      $('<option/>').text("#{p.name} #{p.firstname} #{p.id}").val(p.id).appendTo(select)
    select.change () =>
      @raw.person_id = select.val()

  personLinks: () =>
    span = $('<span/>')
    if @raw.persons?
      for p in @raw.persons
        $('<a/>').text("#{p.id}").attr('href', "/page/person-#{p.id}.html").appendTo(span)
        span.append(' ')
    span

  teamLinks: () =>
    span = $('<span/>')
    if @raw.team_ids?
      for t in @raw.team_ids
        $('<a/>').text("#{t}").attr('href', "/page/team-#{t}.html").appendTo(span)
        span.append(' ')
    span