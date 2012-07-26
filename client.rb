require 'json'
require './enclient'

src = "../personal/evernote-heatmap.json"
out = './public/static/evernote.json'
# out = './out.json'

obj = JSON.parse File.read(src)
client = ENClient.new('hoge')
# client = ENClient.new(obj["authToken"])
# p client
# exit
oo = client.guid_name
# p oo
# exit
f = File.new(out, 'w')
f.write(oo.to_json)
f.close
