#= require jquery2
#= require jquery_ujs
#= require bootstrap-sprockets
#= require m3/initialize
#= require m3/helper
#= require_tree ./layout
#= require_tree ./form

$(document).on 'click', '.filters-wrapper.open .filters-form', (e) ->
  e.stopPropagation()