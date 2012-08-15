# 
# Wordsmith Server v1.0
# getwordsmith.co
#
# Copyright (c) Rich Hollis, Jess Eddy 2012
# Available under the BSD and MIT licenses: http://getwordsmith.co/license/
#
require 'sinatra'
require 'yaml'

require 'net/http'
require 'uri'
require 'json'

require './model.rb'

# config
config = YAML.load_file("config.yaml")

# set configuration
configure do
	set :app_name => config['app_name']
	set :api_key => config['api_key']
	set :ga_id => config['ga_id']
end

# echo config to console
puts config
  
# helper methods
def open(url)
  Net::HTTP.get(URI.parse(url))
end

#
# route: /
#
get "/" do

  erb :about
  
end

#
# route: /css/definition.css
#
get "/css/definition.css" do

  less :definition

end

#
# route: /:word
#
get '/:word' do

  definitions_url = URI.encode("http://api.wordnik.com//v4/word.json/" + params[:word] + "/definitions?includeRelated=false&includeTags=false&limit=200&sourceDictionaries=ahd&useCanonical=false" + "&api_key=" + settings.api_key)
  examples_url = URI.encode("http://api.wordnik.com//v4/word.json/" + params[:word] + "/examples?includeDuplicates=false&useCanonical=false" + "&api_key=" + settings.api_key)
  
  @attributions = Array.new
  @definitions = Array.new
  @examples = Array.new

  definitions_content = open(definitions_url)
  @definition_json = JSON.parse(definitions_content)
  if @definition_json.include? 'type' and @definition_json['type'] == 'error'
	erb :definition_error
  else
    @definition_json.each do |d|
      definition = Definition.new(d['partOfSpeech'], d['text'], d['attributionText'])
      @definitions.push definition
      @attributions.push d['attributionText']
    end
	
    examples_content = open(examples_url)
    @examples_json = JSON.parse(examples_content)
    if @examples_json.include? 'examples'
      @examples_json['examples'].each do |e|
        example = Example.new(e['title'], e['text'], e['rating'], e['url'])
        @examples.push example
      end
    end

    unless @attributions.count > 0
      erb :definition_not_found
    else
      erb :definition, :layout => :layout 
    end

  end

end
