require 'sinatra'
require 'uri'
require 'mongoid'
require 'logger'

# Load the mongoid config file
Mongoid.load! File.join(File.dirname(__FILE__), 'mongoid.config')

class URLShortener
  $log = Logger.new(STDOUT)
 
  def get_short_string(url)
    begin
      # generate random 8  character long alpha numeric string
      str = (0...8).map { (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).flatten[rand(61)] }.join

      output = UrlMappings.where(original_url: url)
      short_string = output.count > 0 ? output.first.short_string : ''
      
      if !short_string or short_string.empty?
        UrlMappings.create_indexes
        status = UrlMappings.create(timestamp: Time.new.to_i, original_url: url, short_string: str )
        short_string = str
      end
      short_string
    rescue Exception => e
      $log.error("[Exception] get_short_string:: #{e.class} :: #{e.message}")
    end
  end

  def get_original_url(short_string)
    begin
     response = UrlMappings.where(short_string: short_string) 
     response.count > 0 ? response.first.original_url : ''

    rescue Exception => e
      $log.error("[Exception] get_original_url:: #{e.class} :: #{e.message}")
    end
  end

end

# Mongodb collection 
class UrlMappings
  include Mongoid::Document

  field :timestamp, type: Integer
  field :original_url, type: String
  field :short_string, type: String

  validates :timestamp, presence: true
  validates :original_url, presence: true
  validates :short_string, presence: true

  index({original_url: 1}, {unique: true})
end


# Routes
get '/:str' do
  str = params[:str]
  
  url_shortener = URLShortener.new
  original_url = url_shortener.get_original_url(str)  
  if original_url and !original_url.empty?
    redirect original_url, 302
  else
    status 404
    body "There is no mapping found for the short_string #{str}"
  end
end

get '/' do
  t = %w[text/css text/html application/javascript]
  request.accept              
  request.accept? 'text/xml'
  request.preferred_type(t) 
  erb :layout
end


post '/' do
  @input_url = params['input_url']
  
  url_shortener = URLShortener.new
  short_string = url_shortener.get_short_string(@input_url)
  
  if @input_url.empty? or !@input_url.start_with? 'http'
    @error = "Invalid URL <b>#{@input_url}</b>. The URL should start with http/https"
  else
    scheme = URI.parse(url).scheme
    host = URI.parse(url).host.downcase
    port = URI.parse(url).port
    @short_url = "#{scheme}://#{host}:#{port}/#{short_string}"
  end
  erb :layout
end
