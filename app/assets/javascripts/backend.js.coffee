#= require bootstrap-wysihtml5
#= require bootstrap-wysihtml5/locales/de-DE

$ ->
  $('#asdf').click (ev) ->
    ev.preventDefault()
    Fss.checkLogin () ->
      options = [
        { value: 'Team', display: 'Zusammenschluss (Team)'}
        { value: 'Feuerwehr', display: 'Einzelne Feuerwehr'}
      ]

      FssWindow.build('Mannschaft anlegen')
      .add(new FssFormRowText('name', 'Name'))
      .add(new FssFormRowText('short', 'Abkürzung'))
      .add(new FssFormRowDescription('Kurzer Name (maximal 10 Zeichen)'))
      .add(new FssFormRowSelect('type', 'Typ der Mannschaft', null, options))
      .on('submit', (data) ->
        Fss.post 'add-team', data, () ->
          location.reload()
      )
      .open()