$(document).ready(function() {
  var i;
  for (i = 1; i <= 7; i++) {
    $("#wrapper").append("<img class='cloud' id='cloud" + i + "' src='images/cloud" + i + ".png' />");
  }
  return $(".cloud").each(function(i, e) {
    var el;
    el = $(e);
    return el.offset({
      left: Math.floor(Math.random() * (960 - el.width())),
      top: Math.floor(Math.random() * ($(window).height() - 400))
    });
  });
});