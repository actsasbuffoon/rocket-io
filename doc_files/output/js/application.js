var position_clouds;
position_clouds = function() {
  return $(".cloud").each(function(i, e) {
    var el;
    el = $(e);
    return el.offset({
      left: Math.floor(Math.random() * (960 - el.width())),
      top: Math.floor(Math.random() * ($(document).height() - el.height() - 200))
    });
  });
};
$(window).load(function() {
  return position_clouds();
});