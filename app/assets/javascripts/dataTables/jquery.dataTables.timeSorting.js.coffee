normalize = (a, b) ->
  x = (a == "D") ? 999999 : a.replace( /,/, "." )
  y = (b == "D") ? 999999 : b.replace( /,/, "." )
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

    return 'score-time' if sData is 'D'

    for i in [0..sData.length]
      char = sData.charAt(i)
      return null if sValidChars.indexOf(char) is -1

      if char is ","
        return null if bDecimal
        bDecimal = true
    return 'score-time' if bDecimal 
    return null

)