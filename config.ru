require 'sinatra/base'
require 'json'
require './enclient'
require '~/scripts/rubylibs/util'

# The project root directory
$root = ::File.dirname(__FILE__)
$token = JSON.parse(Util.read_file("../personal/evernote-heatmap.json"))["authToken"]

class SinatraStaticServer < Sinatra::Base

  get("/estimate") do
    content_type :json
    client = ENClient.new($token)
    client.all_notes_number.to_json
    1400.to_json
  end

  get("/do") do
    # content_type :json
    client = ENClient.new($token)
    oo = client.guid_name
    Util.write_file('./public/static/evernote.json', oo.to_json)
    "done"
  end

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
