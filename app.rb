require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'json/ext'
require 'digest/md5'
require "aws/s3"
require 'koala'

Dir[File.dirname(__FILE__) + "/config/*.rb"].each {|file| require file }
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }
require './helpers.rb'


# facebook api info
APP_ID     = 765250496833974
APP_SECRET = '8f969c5891556b3bbcb337a7f7e18b43'

configure do
  MongoConfig.configure
end

enable :sessions

#### VIEW ROUTES

#facebook graph
get '/' do
  if session['access_token']
      'You are logged in! <a href="/logout">Logout</a>'
      # do some stuff with facebook here
      # for example:
      # @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
      # publish to your wall (if you have the permissions)
      # @graph.put_wall_post("I'm posting from my new cool app!")
      # or publish to someone else (if you have the permissions too ;) )
      # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
    else
      '<a href="/login">Login</a>'
    end
end

#facebook login/logout
get '/login' do
  # generate a new oauth object with your app data and your callback url
  session['oauth'] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, "#{request.base_url}/callback")
  # redirect to facebook to get your code
  redirect session['oauth'].url_for_oauth_code()
end

get '/logout' do
  session['oauth'] = nil
  session['access_token'] = nil
  redirect '/'
end

get '/callback' do
  #get the access token from facebook with your code
  session['access_token'] = session['oauth'].get_access_token(params[:code])
  redirect '/'
end

get '/video/new' do
  @title = 'New Video'
  erb :video_new
end

#### API METHODS

# Video methods
get '/video' do
  content_type :json
  videos = Video.all(:user_id => session[:id])
  videos.to_json
end

get '/video/:id' do
  content_type :json
  video = Video.first(:id => params[:id], :user_id => session[:id])
  video.to_json
end

post '/video' do
  video_url = upload(params[:content]['file'][:filename], params[:content]['file'][:tempfile])
  if video_url
    video = Video.new({
      :description => params[:description],
      :user_id => '',
      :subject_id => '',
      :url => url
    })
  end
  video.save
  video.to_json
end

# Subjects
get '/subject/:id' do
  content_type :json
  subject = Subject.first(:id => params[:id])
  subject.to_json
end

post '/subject' do
  subject = Subject.new({
    :first_name => params[:first_name],
    :last_name => params[:last_name],
    :creator_id => session[:id]
  })
  subject.save
  subject.to_json
end
