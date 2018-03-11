#= require classes/Fss
#= require classes/SortTable

Fss.ready 'competition', ->
  new SortTable({ selector: '.datatable-competitons', direction: 'desc' })
  new SortTable({ selector: '.datatable.scores-group', direction: 'asc', sortCol: 1 })
  new SortTable({ selector: '.datatable.scores-zk', direction: 'asc', sortCol: 4 })
  new SortTable({ selector: '.datatable.scores-single', direction: 'asc', sortCol: 3 })


  if $('#competition-map').length > 0
    elem = $('#competition-map')
    FssMap.loadStyle ->
      red = elem.data('map').red
      map = FssMap.getMap('competition-map')
      markers = elem.data('map').markers or []
      markers = for marker in markers
        L.marker(marker.latlon, { icon: FssMap.defaultIcon() }).bindPopup(marker.popup).addTo(map)
      markers.push(L.marker(red.latlon, { icon: FssMap.redIcon() }).bindPopup(red.popup).addTo(map))
      setTimeout( ->
        map.fitBounds(L.featureGroup(markers).getBounds(), { padding: [20, 20] })
      , 300)

  $('#add-file').click ->
    Fss.checkLogin ->
      $('#add-file-form').removeClass('hide')
      $('#add-file').hide()

  fileCounter = 0
  $('#more-files').click (ev) ->
    ev.preventDefault()
    fileCounter++
    tr = $('.input-file-row').closest('tr').clone().removeClass('input-file-row')
    file = tr.find('input[type=file]').val('')
    file.attr('name', file.attr('name').replace(/competition_file\[[0-9]+\]/, "competition_file[#{fileCounter}]"))
    tr.find(':checkbox').each ->
      checkbox = $(this).removeAttr('checked')
      checkbox.attr('name', checkbox.attr('name').replace(/competition_file\[[0-9]+\]/,
        "competition_file[#{fileCounter}]"))
    $('.input-file-row').closest('table').append(tr)

  $('#add-change-request').click ->
    competitionId = $(this).data('competition-id')
    competitionName = $(this).data('competition-name')

    Fss.checkLogin ->
      options = [
        { value: 'name', display: 'Name des Wettkampfs vorschlagen' },
        { value: 'hint', display: 'Hinweis geben' },
      ]
      FssWindow.build('Auswahl des Fehlers')
      .add(new FssFormRowDescription('Bitte wählen Sie den Typ der Meldung aus:'))
      .add(new FssFormRowRadio('what', 'Was wollen Sie tun?', null, options))
      .on('submit', (data) ->
        selected = data.what

        if selected is 'name'
          FssWindow.build('Namen vorschlagen')
          .add(new FssFormRowDescription('Bitte geben Sie den Namen an:'))
          .add(new FssFormRowText('name', 'Name', competitionName))
          .on('submit', (data) ->
            requestData = {
              competition_id: competitionId
              name: data.name
            }
            Fss.changeRequest('competition-change-name', requestData)
          )
          .open()
        else if selected is 'hint'
          FssWindow.build('Hinweis beschreiben')
          .add(new FssFormRowDescription('Bitte geben Sie ihren Hinweis ausführlich an:'))
          .add(new FssFormRowTextarea('description', 'Beschreibung', ''))
          .on('submit', (data) ->
            requestData = {
              competition_id: competitionId
              hint: data.description
            }
            Fss.changeRequest('competition-add-hint', requestData)
          )
          .open()
      )
      .open()
