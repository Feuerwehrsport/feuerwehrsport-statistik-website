sortNormalizeScore = (a, b) ->
  x = if a is 'D' then 999999 else a.replace( /,/, '.' )
  y = if b is 'D' then 999999 else b.replace( /,/, '.' )
  x = parseFloat( x )
  y = parseFloat( y )
  if x < y then -1 else (if x > y then 1 else 0)

sortNormalizePlace = (a, b) ->
  x = if a is '' then 999999 else parseInt(a, 10)
  y = if b is '' then 999999 else parseInt(b, 10)
  if x < y then -1 else (if x > y then 1 else 0)

$.extend $.fn.dataTableExt.oSort, {
  'score-time-asc': (a, b) ->
    sortNormalizeScore(a, b)
  'score-time-desc': (a, b) ->
    sortNormalizeScore(b, a)
  'score-place-asc': (a, b) ->
    sortNormalizePlace(a, b)
  'score-place-desc': (a, b) ->
    sortNormalizePlace(b, a)
}

$.fn.dataTableExt.aTypes.unshift(
  (sData) ->
    return 'score-time' if sData is 'D' or sData.match(/^\d+(,\d+)?$/)
    return 'score-place' if sData is '' or sData.match(/^\d+$/)
    null
)
