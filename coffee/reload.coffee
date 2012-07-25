node = (elm, text) ->
  "<#{elm}>#{text}</#{elm}>"
btn = $('button')
dis = $('#display')

$.get '/estimate', (d) ->
  $('#cal').hide()
  n = d
  est = Math.round(n / 50)
  dis.append(node 'p', "You have #{n} notes.")
  dis.append(node 'p', "Estimated time to reload Cloud API: #{est} sec")

btn.on 'click', () ->
  dis.append(node 'p', "Processing...")
  $.get '/do', (d) ->
    dis.append(node 'p', "Done!")
