require 'json'
require './enclient'
require '~/scripts/rubylibs/util'

src = "../../personal/evernote-heatmap.json"
out = '../public/static/evernote.json'
# out = './out.json'

obj = JSON.parse Util.read_file(src)
client = ENClient.new(obj["authToken"])
# p client
# exit
oo = client.guid_name
# p oo
# Util.write_file(out, client.guid_name.to_json)
Util.write_file(out, oo.to_json)
