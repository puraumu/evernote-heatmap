node = (elm, text) ->
  "<#{elm}>#{text}</#{elm}>"
btn = $('button')
dis = $('#display')
token = null

dis.ajaxError (e, jqxhr, settings, exception) ->
  $('#cal').hide()
  p = $ node 'p', ''
  p.append(node 'strong', "#{jqxhr.status}")
  p.append(": #{jqxhr.responseText}")
  dis.append p

$.get '/estimate', (d) ->
  state = d.state
  n = d.number
  $('#cal').hide()

  if state is "OK"
    token = true
    est = Math.round(n / 50)
    dis.append(node 'p', "You have #{n} notes.")
    dis.append(node 'p', "Estimated time: #{est} sec")

  if state is "NG"
    token = false
    dis.append(node 'strong', "Developer Token is wrong.")
    dis.append(node 'p', "Did you edit config.ru? Please read README file.")

  unless state is "NG" or state is "OK"
    dis.append(node 'p', "Server is broken or down")

btn.on 'click', () ->
  dis.append(node 'p', "Processing...")
  $.get '/do', (d) ->
    if d is "OK"
      dis.append(node 'p', "Done!")

    if d is "NG" and token is false
      dis.append(node 'strong', "Cannot authenticate to Evernote Server.")
      dis.append(node 'p', "Did you edit config.ru? Please read README file.")

    if d is "NG" and token is true
      dis.append(node 'p', "sdk is out date?")
      $.get '/check', (ver) ->
        dis.append(node 'p', "versionOK?: #{ver}")
