class @TestScoreResult
  constructor: (@raw, @fields) ->
    if @raw.last_name?
      @needField('last_name')
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
      tr.toggleClass('valid-row').toggleClass('invalid-row')
      @raw.valid = !@raw.valid
    
    appendTd = (text) -> $('<td/>').text(text).appendTo(tr)

    if @raw.valid
      tr.addClass('valid-row')
    else
      tr.addClass('invalid-row');

    if @raw.last_name?
      if @raw.people? and @raw.people.length > 1
        $('<td/>').append(@personSelect()).appendTo(tr)
      else if @raw.people? and @raw.people.length
        appendTd("#{@raw.last_name} #{@raw.first_name}")
        @raw.person_id = @raw.people[0].id
      else
        appendTd("#{@raw.last_name} #{@raw.first_name}").addClass('person-not-found')
      $('<td/>').append(@personLinks()).appendTo(tr)
    else if fields.last_name
      appendTd('')
      appendTd('')

    if @raw.team_names?
      @raw.team = @raw.team_names[0]
      if @raw.team_names.length > 1
        $('<td/>').append(@teamSelect()).appendTo(tr)
      else
        appendTd(@raw.team_names[0])
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
        td.addClass('null') if time is 99999999
      for i in [@raw.times.length..fields.times]
        appendTd('')
    else
      for i in [0..fields.times]
        appendTd('')
    appendTd(@raw['line']).addClass('raw-line')
    tr

  isValid: () =>
    @raw.valid

  getObject: () =>
    obj = {}
    for key in ['team_number', 'team_id', 'run', 'times', 'person_id', 'last_name', 'first_name']
      obj[key] = @raw[key] if @raw[key]?
    obj

  teamSelect: () =>
    teamIds = @raw.team_ids
    team_names = @raw.team_names
    select = $('<select/>')
    for team, i in team_names
      $('<option/>').text("#{team} #{teamIds[i]}").val(i).appendTo(select)
    select.change () =>
      @raw.team_id = teamIds[parseInt(select.val())]
      @raw.team = team_names[parseInt(select.val())]

  personSelect: () =>
    select = $('<select/>')
    for p in @raw.people
      $('<option/>').text("#{p[1]} #{p[2]} #{p[0]}").val(p[0]).appendTo(select)
    select.change () =>
      @raw.person_id = select.val()

  personLinks: () =>
    span = $('<span/>')
    if @raw.people?
      for p in @raw.people
        $('<a/>').text("#{p[0]}").attr('href', "/people/#{p[0]}").appendTo(span)
        span.append(' ')
    span

  teamLinks: () =>
    span = $('<span/>')
    if @raw.team_ids?
      for t in @raw.team_ids
        $('<a/>').text("#{t}").attr('href', "/teams/#{t}").appendTo(span)
        span.append(' ')
    span