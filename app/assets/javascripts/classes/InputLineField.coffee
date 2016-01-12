class @InputLineField
  @singleFields: ['last_name', 'first_name', 'team', 'run']
  @multipleFields: ['time', 'col']

  constructor: (line, name) ->
    @container = $('<span/>').addClass('input-line-field')
    @selectField = $('<select/>')
    
    for f in InputLineField.singleFields
      @selectField.append($('<option/>').text(f).val(f))

    for f in InputLineField.multipleFields
      @selectField.append($('<option/>').text(f).val(f))

    removeButton = $('<button/>').text('x').click () => line.removeField(@)
    @container.append(@selectField).append(removeButton)
    @select(name)

  get: () =>
    @container

  select: (name) =>
    @selectField.val(name)

  remove: () =>
    @container.remove()

  val: () =>
    @selectField.val()