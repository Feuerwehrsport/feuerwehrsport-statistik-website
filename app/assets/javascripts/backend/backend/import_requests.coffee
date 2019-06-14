#= require classes/Fss
#= require classes/FssImport

Fss.ready('backend/import_requests/', -> 
  return if $('input#competition-type-sorted').length is 0
  new FssImport()
)
