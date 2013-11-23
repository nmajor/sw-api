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

#### FACEBOOK AUTH
# facebook api info
APP_ID     = 765250496833974
APP_SECRET = '8f969c5891556b3bbcb337a7f7e18b43'

configure do
  MongoConfig.configure
end

enable :sessions

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
  #get_current_user

  redirect '/'
end

#### VIEW ROUTES
get '/' do
  if session['access_token']
        graph = Koala::Facebook::GraphAPI.new(session["access_token"])
            current_fb_user = graph.get_object("me")
                user = User.first( :fb_id => current_fb_user["id"].to_i )
    "<h1>hey</h1>#{session['access_token']} #{user.to_json} #{session['access_token'].to_s} #{current_fb_user} #{current_fb_user['id'].to_i}"
      #@current_user = get_current_user
      #erb :home

      # do some stuff with facebook here
      # for example:
      # @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
      # publish to your wall (if you have the permissions)
      # @graph.put_wall_post("I'm posting from my new cool app!")
      # or publish to someone else (if you have the permissions too ;) )
      # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
    else
      erb :login
    end
end

get '/chronicle/:fb_id/new' do
  @title = 'New Video'
  @user = get_user(params[:fb_id])
  erb :chronicle_new
end

get '/user/friends' do
  @graph = Koala::Facebook::API.new(session['access_token'])
  @friends = @graph.get_connections("me", "friends")
  erb :user_friends
end

get '/connection/:id' do
  @graph = Koala::Facebook::API.new(session['access_token'])
  @friend = @graph.get_object(params[:id])
  erb :connection
end

get '/chronicle/:fb_id' do
  @user = get_user(params[:fb_id])
  erb :chronicle
end

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
  user = get_user(params[:fb_id])
  video_name = upload(params[:file][:filename] + user.fb_id.to_s, params[:file][:tempfile])
  if video_name
    video = Video.new({
      :desc => params[:desc],
      :subject_id => '',
      :name => video_name
    })
  end
  video.user = user
  video.save
  user.save
  video.to_json
  redirect "/chronicle/#{params[:fb_id]}"
end


post '/connection' do
  connection_user = get_user(params[:fb_id])
  current_user = get_current_user
  #current_user.child_user_ids << connection_user.id
  current_user.save

  redirect '/'
end
