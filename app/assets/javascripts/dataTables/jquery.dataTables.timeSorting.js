// DataTables 2 sorting for times ("19,22", "D" = invalid, last) and places (empty = last)
(function () {
  var normalizeScore = function (value) { return value === 'D' ? 999999 : parseFloat(value.replace(/,/, '.')); };
  var normalizePlace = function (value) { return value === '' ? 999999 : parseInt(value, 10); };

  DataTable.type('score-time', {
    detect: function (data) { return typeof data === 'string' && (data === 'D' || /^\d+(,\d+)?$/.test(data)); },
    order: { pre: function (data) { return normalizeScore(String(data)); } },
  });
  DataTable.type('score-place', {
    detect: function (data) { return typeof data === 'string' && (data === '' || /^\d+$/.test(data)); },
    order: { pre: function (data) { return normalizePlace(String(data)); } },
  });
})();
