addOption = (select, id, label, info, desc) ->
  removeOption(select, id)
  select.append(
    $('<option/>').attr('selected', true).
      attr('value', id).
      data('info', info).
      data('desc', desc).
      text(label)
  )

removeAllOptions = (select) ->
  select.find("option").remove()

removeOption = (select, id) ->
  select.find("option[value=#{id}]").remove()

updateList = (list, dataCache, listTemplate, clickCallback) ->
  list.empty()
  $.each dataCache, (index, value) ->
    li = listTemplate.clone()
    li.data('id', value[0])
    li.find('.as-info').text(value[2] || '')
    li.find('.as-label').text(value[1])
    li.find('.as-desc').text(value[3] || '')
    li.find('.as-desc').hide() unless value[3]
    li.find('.as-selectable, .as-remove').addBack('.as-selectable, .as-remove').click ->
      clickCallback(value[0], value[1], value[2], value[3])
      li.slideUp ->
        li.remove()
    list.append(li)

M3.ready ->
  $('.association-select-wrapper').each ->
    wrapper = $(this)
    url = wrapper.data('url')
    select = wrapper.find('select')
    multiple = select.is('[multiple]')
    addButton = wrapper.find('.as-add')
    removeAllButton = wrapper.find('.as-remove-all')
    list = wrapper.children('ul')
    first = list.children('li').first()
    listTemplate = first.clone()
    first.remove()

    modal = wrapper.find(addButton.attr('href'))
    modalList = modal.find('.as-ul')
    modalFirst = modalList.children('li').first()
    modalListTemplate = modalFirst.clone()
    modalFirst.remove()
    modalSearch = modal.find('.as-search')
    modalGroups = modal.find('.as-groups')
    modalGroupsFirst = modalGroups.children().first()
    modalGroupTemplate = modalGroupsFirst.clone()
    modalGroups.empty().hide()

    dataCache = []
    ajaxHandle = null

    updateDataCache = ->
      dataCache = []
      select.children('option:selected').each ->
        dataCache.push [
          $(this).val(),
          $(this).text(),
          $(this).data('info'),
          $(this).data('desc'),
        ] if $(this).val()

    updateRemoveAllButton = ->
      if dataCache.length > 1
        removeAllButton.show()
      else
        removeAllButton.hide()

    updateListWithRemoveButton = ->
      updateDataCache()
      updateRemoveAllButton()
      updateList list, dataCache, listTemplate, (id) ->
        window.setTimeout(
          -> select.trigger('change'),
          300
        )
        removeOption(select, id)
        updateDataCache()
        updateRemoveAllButton()

    updateListWithRemoveButton()

    updateListWithAddButton = (data) ->
      updateList modalList, data.results, modalListTemplate, (id, name, info, desc) ->
        window.setTimeout(
          -> select.trigger('change'),
          300
        )
        modal.modal('hide')
        removeAllOptions(select) unless multiple
        addOption(select, id, name, info, desc)
        updateListWithRemoveButton()

    updateGroups = (data) ->
      groups = data.groups || {}
      if groups && !jQuery.isEmptyObject(groups)
        modalGroups.empty()
        for name, options of groups
          do (name, options) ->
            button = modalGroupTemplate.clone()
            button.text(name)
            button.click ->
              for option in options
                addOption(select, option[0], option[1], option[2], option[3])
              updateListWithRemoveButton()
              modal.modal('hide')
            modalGroups.append(button)
        modalGroups.slideDown(100)
      else
        modalGroups.slideUp(100)

    modalSearch.on 'input', ->
      searchTerm = $(this).val()
      ajaxHandle.abort() if ajaxHandle
      modal.addClass('is-loading')

      separator = if url.indexOf('?') == -1 then '?' else '&'
      ajaxHandle = $.get url + separator + 'q=' + encodeURIComponent(searchTerm), (response) ->
        if response.payload
          updateListWithAddButton(response.payload)
          updateGroups(response.payload) if multiple
        modal.removeClass('is-loading')

    addButton.click (e) ->
      e.preventDefault()
      modalSearch.val('').trigger('input')
      modal.modal('show')
      window.setTimeout(
        -> modalSearch.focus(),
        300
      )
      modalSearch.focus()
      updateListWithAddButton(dataCache)

      modalSearch.trigger('input')

    removeAllButton.click ->
      modal.modal('hide')
      removeAllOptions(select)
      updateListWithRemoveButton()
      window.setTimeout(
        -> select.trigger('change'),
        300
      )
