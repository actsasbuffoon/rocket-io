position_clouds = () ->
  $(".cloud").each (i, e) ->
    el = $(e)
    el.offset({
      left: Math.floor( Math.random() * (960 - el.width()) ),
      top: Math.floor( Math.random() * ($(document).height() - el.height() - 200) )
    })

$(window).load () ->
  position_clouds()