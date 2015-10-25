normalize = (a, b) ->
  x = if a == "D" then 999999 else a.replace( /,/, "." )
  y = if b == "D" then 999999 else b.replace( /,/, "." )
  x = parseFloat( x )
  y = parseFloat( y )
  ((x < y) ? -1 : ((x > y) ?  1 : 0))

$.extend $.fn.dataTableExt.oSort, 
  "score-time-asc": (a, b) ->
    normalize(a, b)
  "score-time-desc": (a,b) ->
    normalize(b, a)


$.fn.dataTableExt.aTypes.unshift(
  (sData) ->
    sValidChars = "0123456789,"
    bDecimal = false

    if sData is 'D' or sData.match(/^\d+(,\d+)?$/) then 'score-time' else null
)