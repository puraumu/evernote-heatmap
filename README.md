# Evernote HeatMap

Evernote HeatMap visualizes Evernote metadata using [d3.js](https://github.com/mbostock/d3) and [Evernote Cloud API](http://dev.evernote.com/documentation/cloud/).

# Overview

* `rake server` - run sinatra server
* `localhost:9292/` - view heatmap
* `localhost:9292/reload` - regenerate JSON file via Cloud API

Paste your "Developer Tokens" to config.ru

Evernote HeatMap uses [evernote/evernote-sdk-ruby](https://github.com/evernote/evernote-sdk-ruby) (already in the repository). 

# Requirements

To run `rake server`, following libraries, gems or datas will be required:

* [CoffeeScript](http://coffeescript.org/)
* [Sinatra](http://www.sinatrarb.com/)
* [Compass](http://compass-style.org/)
* [Developer Tokens](http://dev.evernote.com/documentation/cloud/chapters/Authentication.php)

# For minimalists

If you would like to view your Evernote data immediately, you need followings:

* Ruby Programming Language
* Sinatra Gem
* Developer Token

If you you know and available above, edit config.ru like

	$token = "YOUR-DEVELOPER-TOKEN"

to

	$token = "S=s1:U=279bf:E=13f92f064bf:C=1383b3f38c3:P=1cd:A=en-devtoken:H=725df8b086b2cb08e13a7bf5ca186406"

Then, open [the URL](http://localhost:9292/reload) and skip to [Generating JSON](#generating-json).

This script is written in [Ruby Programming Language](http://www.ruby-lang.org/en/). You need to install Ruby. To install Ruby, read [this](http://www.ruby-lang.org/en/downloads/) page. If you are using Mac, you don't need to install Ruby. You can check whether Ruby is woking by typing the following command in Command-Line (e.g. Terminal):

	ruby -e "puts 'hello, world'"

[Sinatra gem](http://www.sinatrarb.com/) requires [RubyGems](http://docs.rubygems.org/read/chapter/1/). Because RubyGems is a part of Ruby, RubyGems is basically available if Ruby is installed. To get Sinatra gem, type:

	gem install sinatra

To get Developer Token, visit [Evernote developer page](http://dev.evernote.com/documentation/cloud/chapters/Authentication.php#devtoken) and [get a production developer token](https://www.evernote.com/api/DeveloperToken.action). Once you've got developer token, 

edit config.ru file using TextEditor, not Word Processor. find the line something like this:

	$token = "YOUR-DEVELOPER-TOKEN"

Change that line like so:

	$token = "S=s1:U=279bf:E=13f92f064bf:C=1383b3f38c3:P=1cd:A=en-devtoken:H=725df8b086b2cb08e13a7af5ca186406"


**Make suer you quote Developer token using " (quotation mark).** When you finish editing the file, you can run Rackup Server by typing following command in Command-Line:

	rackup

Then open your browser and go to [the URL](http://localhost:9292/reload):

	http://localhost:9292/reload

## Generating JSON

This page will generate JSON file. But the page does not immediately generate JSON file unless you click "reload" button. So the page seems no error or no warning, click the button.

When you got some error,  check out the message or google some words.

# License

(The MIT License)

Copyright (C) 2012 Puraumu

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.