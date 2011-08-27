position_clouds = () ->
  $(".cloud").each (i, e) ->
    el = $(e)
    el.offset({
      left: Math.floor( Math.random() * (960 - el.width()) ),
      top: Math.floor( Math.random() * ($(window).height() - 400) )
    })

$(document).ready () ->
  position_clouds()