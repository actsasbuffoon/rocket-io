$(document).ready () ->
  $("#wrapper").append("<img class='cloud' id='cloud#{i}' src='images/cloud#{i}.png' />") for i in [1..7]
  
  $(".cloud").each (i, e) ->
    el = $(e)
    el.offset({left: Math.floor(Math.random() * (960 - el.width())), top: Math.floor(Math.random() * ($(window).height() - 400))})