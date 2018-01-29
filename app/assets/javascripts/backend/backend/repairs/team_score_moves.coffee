#= require classes/Fss

disciplineRow = (title) ->
  title = Fss.disciplines[title] || 'Einzeldisziplin'
  $('<tr/>').append($('<th/>').attr('colspan', 4).text(title).addClass('text-center'))

class Score
  constructor: (@discipline, @data, table) ->
    @move = false
    table.append(@row())
    @setMoveStatus()

  setMoveStatus: () =>
    if @move
      @ownTd.text('')
      @moveTd.text('X')
      @tr.removeClass('warning').addClass('danger')
    else
      @ownTd.text('X')
      @moveTd.text('')
      @tr.removeClass('danger').addClass('warning')

  competitionLink: () =>
    $('<a/>')
    .attr('href', "/competitions/#{@data.competition_id}")
    .text(@data.competition)

  doMove: (teamId, callback) =>
    if @move
      data = team_id: teamId
      if @discipline is 'single'
        Fss.put "scores/#{@data.id}", score: data, log_action: 'update-score:team', callback
      else
        Fss.put "group_scores/#{@data.id}", group_score: data, log_action: 'update-group-score:team', callback
    else
      callback()

  row: () =>
    @ownTd = $('<td/>')
    @moveTd = $('<td/>')
    @tr = $('<tr/>')
    .append(@ownTd)
    .append($('<td/>').text(@data.id))
    .append($('<td/>').text(@data.team_number))
    .append($('<td/>').append(@competitionLink()))
    .append(@moveTd)
    .click () => @toggleStatus()

  shortRow: () =>
    $('<tr/>')
    .append($('<td/>').text(@data.id))
    .append($('<td/>').append(@competitionLink()))
    .append($('<td/>').text(@data.date))

  toggleStatus: () =>
    @move = !@move
    @setMoveStatus()

Fss.ready 'backend/repairs/team_score_move', ->
  scores = []
  scoreTable = $('#score-table')
  if scoreTable.length > 0
    scoreTable.find('tr').not($('#headline')).remove()
    sourceId = scoreTable.data('source-team')
    destinationId = scoreTable.data('destination-team')
    Fss.getResource 'teams', sourceId, extended: 1, (result) ->      
      scores = []
      for discipline in ['la', 'fs', 'gs', 'single']
        discipline_scores = result["#{discipline}_scores"]
        continue unless discipline_scores.length > 0
        scoreTable.append(disciplineRow(discipline))
        scoreTable.append($('#headline').clone().attr('id', null))
        for score in discipline_scores
          scores.push(new Score(discipline, score, scoreTable))

    $('#do-move').click () ->
      count = 0
      for score in scores
        count++ if score.move 
      return new WarningFssWindow('Keine Zeiten ausgewählt.') if count is 0

      Fss.getResource 'teams', sourceId, (sourceTeam) ->
        Fss.getResource 'teams', destinationId, (destinationTeam) ->
          infoTable = $('<table/>').addClass('table')
          .append(
            $('<tr/>')
            .append($('<th/>').text('Von'))
            .append($('<td/>').text(sourceTeam.id))
            .append($('<td/>').text(sourceTeam.name))
            .append($('<td/>').text(sourceTeam['short']))
            .append($('<td/>').text(sourceTeam.state))
          )
          .append(
            $('<tr/>')
            .append($('<th/>').text('Nach'))
            .append($('<td/>').text(destinationTeam.id))
            .append($('<td/>').text(destinationTeam.name))
            .append($('<td/>').text(destinationTeam['short']))
            .append($('<td/>').text(destinationTeam.state))
          )

          relevantScoresTable = $('<table/>').addClass('table')
          for score in scores
            continue unless score.move
            relevantScoresTable.append(score.shortRow())

          (new FssWindow('Wirklich Zeiten verschieben?'))
          .add(new FssFormRow(infoTable))
          .add(new FssFormRow(relevantScoresTable))
          .on('submit', () ->
            currentIndex = 0

            moveIt = () ->
              scores[currentIndex].doMove destinationTeam.id, () ->
                currentIndex++
                if currentIndex < scores.length
                  moveIt()
                else
                  new AlertFssWindow 'Zeiten verschoben', "Die #{count} Zeiten wurden verschoben.", () ->
                    location.reload()
            moveIt()
          ).open()
      false
      