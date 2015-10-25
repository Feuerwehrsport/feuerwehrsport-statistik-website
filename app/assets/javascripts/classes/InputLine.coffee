#= require classes/InputLineField

class InputLine
  constructor: (discipline) ->
    @fields = []
    start = []
    if $.inArray(discipline, ['hl', 'hb']) != -1
      start = ['name', 'firstname', 'team', 'time', 'time']
    else if discipline == 'la'
      start = ['team', 'time', 'time']
    else if discipline == 'gs'
      start = ['team', 'time']
    else if discipline == 'fs'
      start = ['team', 'time', 'run']
    
    for s in start
      @fields.push(new InputLineField(@, s))

  get: () =>
    container = $('<div/>').addClass('input-line')

    for field in @fields
      container.append(field.get())
    
    addButton = $('<button/>').text('+').click () =>
      newField = new InputLineField(@, 'time')
      @fields.push(newField)
      newField.get().insertBefore(addButton)

    container.append(addButton)

  removeField: (removeField) =>
    for field, i in @fields
      if removeField is field
        field.remove()
        return @fields.splice(i, 1)

  val: () =>
    outputs = []
    for field in @fields
      outputs.push(field.val())
    outputs.join(',')