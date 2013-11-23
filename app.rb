require 'rubygems'
require 'sinatra'
require 'mongo_mapper';
require 'json/ext'
require 'digest/md5'

Dir[File.dirname(__FILE__) + "/config/*.rb"].each {|file| require file }
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }
require 'helpers.rb'

configure do
  MongoConfig.configure
end

enable :sessions

#### VIEW ROUTES
get '/' do
  "Hello Ogden StartupWeekend #swogden"
end

#### API METHODS
# User methods
post '/user' do
  content_type :json
  user = User.new({
  	:username => params[:username],
  	:password => params[:password]
  	});
  user.save
  user.to_json
end

post '/login' do
  user = User.first(:username => params[:username], :password => params[:password])
  unless user.nil?
    session[:id] = user.id
  end
  user.id.to_json
end

get '/logout' do
  session.clear
end

# Video methods
get '/video/?' do
  content_type :json
  videos = Video.all(:user_id => session[:id])
  videos.to_json
end

get '/video/:id/?' do
  content_type :json
  video = Video.find(params[:id], :user_id => session[:id])
  video.to_json
end

post '/video' do
  video_url = upload(params[:content]['file'][:filename], params[:content]['file'][:tempfile])
  if video_url
  video = Video.new({
    :name => params[:name],
    :description => params[:description],
    :user_id => session[:user_id],
    :subject_id => params[:subject_id],
    :url => url
  })
  video.save
  video.to_json
end
