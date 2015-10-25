class PublishStatus
  @status: ['not-ready', 'ready', 'published']

  constructor: (@container, @competitionId) ->
    @load()

  load: () =>
    Fss.post 'get-competition-published', { competitionId: @competitionId }, (data) =>
      @currentStatus = data['published']
      @rebuild()

  rebuild: () =>
    colors = ['#FF1414', '#FFF013', '#76FF06']

    @container.children().remove()
    @container.append( 
      $('<div/>')
        .text(PublishStatus.status[@currentStatus])
        .click(() => @click())
        .css(backgroundColor: colors[@currentStatus])
    )

  click: () =>
    options = []
    options.push({ value: "#{i}", display: name }) for name, i in PublishStatus.status

    FssWindow.build('Status festlegen')
    .add(new FssFormRowRadio('published', '', @currentStatus, options))
    .on('submit', (data) =>
      data.competitionId = @competitionId
      Fss.post 'set-competition-published', data, () =>
        @load()
    )
    .open()

    
