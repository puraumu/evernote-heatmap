require 'sinatra/base'
require 'json'
require './enclient'

$token = "YOUR-DEVELOPER-TOKEN"

class SinatraStaticServer < Sinatra::Base

  get("/estimate") do
    content_type :json
    out = {"state" => "OK", "number" => 0}
    begin
      client = ENClient.new($token)
      out["number"] = client.all_notes_number
    rescue Evernote::EDAM::Error::EDAMUserException
      out["state"] = "NG"
    end
    out.to_json
  end

  get("/do") do
    begin
      client = ENClient.new($token)
    rescue Evernote::EDAM::Error::EDAMUserException
      return "NG"
    end

    oo = client.guid_name
    write_file(oo.to_json)
    "OK"
  end

  get ("/check") do
    client = ENClient.new($token)
    client.version.to_s
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

  def write_file(out)
    f = File.new('./public/static/evernote.json', 'w')
    f.write(out)
    f.close
  end

end

$token = JSON.parse(File.read("../personal/evernote-heatmap.json"))["authToken"] if $token == "YOUR-DEVELOPER-TOKEN"

run SinatraStaticServer
