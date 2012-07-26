# Add the Thrift & Evernote Ruby libraries to the load path.
# This will only work if you run this application from the ruby/sample/client
# directory of the Evernote API SDK.
dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.push("#{dir}/evernote-sdk-ruby/lib")
$LOAD_PATH.push("#{dir}/evernote-sdk-ruby/lib/thrift")
$LOAD_PATH.push("#{dir}/evernote-sdk-ruby/lib/Evernote/EDAM")

require "thrift/types"
require "thrift/struct"
require "thrift/protocol/base_protocol"
require "thrift/protocol/binary_protocol"
require "thrift/transport/base_transport"
require "thrift/transport/http_client_transport"
require "Evernote/EDAM/user_store"
require "Evernote/EDAM/user_store_constants.rb"
require "Evernote/EDAM/note_store"
require "Evernote/EDAM/limits_constants.rb"

class ENClient
  attr_accessor :token, :noteStore, :tags, :notebooks, :version
  # attr_accessor :token, :evernoteHost, :userStoreUrl,
                # :userStoreTransport, :userStoreProtocol, :userStore,
                # :notesStoreTransport, :notesStoreProtocol, :notesStore

  # Pbublic: Initialize a new client.
  #
  # authToken - Developer Token.
  def initialize(authToken)
    if (authToken == "your developer token" or authToken == "")
      puts "Please fill in your developer token"
      puts "To get a developer token, visit https://sandbox.evernote.com/api/DeveloperToken.action"
      exit(1)
    end

    # Initial development is performed on our sandbox server. To use the production
    # service, change "sandbox.evernote.com" to "www.evernote.com" and replace your
    # developer token above with a token from
    # https://www.evernote.com/api/DeveloperToken.action
    evernoteHost = "www.evernote.com"
    userStoreUrl = "https://#{evernoteHost}/edam/user"

    userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
    userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
    userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)

    versionOK = userStore.checkVersion("Evernote EDAMTest (Ruby)",
                                    Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
                                    Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
    self.version = versionOK
    if (!versionOK)
      puts "Is my Evernote API version up to date?  #{versionOK}"
      exit(1)
    end

    # Get the URL used to interact with the contents of the user's account
    # When your application authenticates using OAuth, the NoteStore URL will
    # be returned along with the auth token in the final OAuth request.
    # In that case, you don't need to make this call.
    noteStoreUrl = userStore.getNoteStoreUrl(authToken)

    noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)

    self.token = authToken
    self.noteStore = noteStore
    self.notebooks = self.all_notebooks
    self.tags = self.all_tags
  end

  def all_notebooks
    out = {}
    self.noteStore.listNotebooks(self.token).each do |notebook|
      out[notebook.guid] = notebook.name
    end
    out
  end

  def all_tags
    out = {}
    self.noteStore.listTags(self.token).each do |tag|
      out[tag.guid] = tag.name
    end
    out
  end

  def all_notes
    out = []
    offset = 0
    pageSize = 100
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = "-created:#{Time.now.strftime("%Y%m%d")}"
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    spec.includeNotebookGuid = true
    spec.includeTitle = true
    spec.includeCreated = true
    spec.includeTagGuids = true
    noteList = self.noteStore.findNotesMetadata(self.token, filter, offset, pageSize, spec)
    while 0 <= (noteList.totalNotes - (noteList.startIndex + noteList.notes.length))
      noteList.notes.each do |meta|
        out.push meta
      end
      offset = offset + pageSize
      noteList = self.noteStore.findNotesMetadata(self.token, filter, offset, pageSize, spec)
    end
    out
  end

  def guid_name
    out = []
    self.all_notes.each do |note|
      hash = {"guid" => "", "created" => 0, "notebook" => "", "tags" => []}
      hash["guid"] = note.guid
      hash["created"] = note.created
      hash["notebook"] = self.notebooks[note.notebookGuid].force_encoding('utf-8')
      tags = []
      unless note.tagGuids == nil
        note.tagGuids.each do |guid|
          tags.push self.tags[guid].force_encoding('utf-8')
        end
      end
      hash['tags'] = tags
      out.push hash
    end
    out
  end

  def all_notes_number
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = "-created:#{Time.now.strftime("%Y%m%d")}"
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    noteList = self.noteStore.findNotesMetadata(self.token, filter, 0, 10, spec)
    noteList.totalNotes
  end


end # /ENClient

# client = ENClient.new(authToken)
# notes = client.all_notes
