#= require classes/InputLineField

class @InputLine
  constructor: (discipline) ->
    @fields = []
    start = []
    if $.inArray(discipline, ['hl', 'hb', 'hw']) isnt -1
      start = ['last_name', 'first_name', 'team', 'time', 'time']
    else if discipline is 'la'
      start = ['team', 'time', 'time']
    else if discipline is 'gs'
      start = ['team', 'time']
    else if discipline is 'fs'
      start = ['team', 'time', 'run']
    
    for s in start
      @fields.push(new InputLineField(this, s))

  get: =>
    container = $('<div/>').addClass('input-line')

    for field in @fields
      container.append(field.get())
    
    addButton = $('<button/>').text('+').click =>
      newField = new InputLineField(this, 'time')
      @fields.push(newField)
      newField.get().insertBefore(addButton)

    container.append(addButton)

  removeField: (removeField) =>
    for field, i in @fields
      if removeField is field
        field.remove()
        return @fields.splice(i, 1)

  val: (separator) =>
    outputs = []
    for field in @fields
      outputs.push(field.val())
    outputs.join(separator)
