require 'rubygems'
require 'sinatra'
require 'mongo_mapper';
require 'json/ext'
require 'digest/md5'

Dir[File.dirname(__FILE__) + "/config/*.rb"].each {|file| require file }
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }
Dir[File.dirname(__FILE__) + "/helpers/*.rb"].each {|file| require file }

configure do
  MongoConfig.configure
end

enable :sessions

get '/' do
  "Hello Ogden StartupWeekend #swogden"
end

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
  video = Video.new({
    :name => params[:name],
    :description => params[:description],
    :user_id => session[:id]
  })
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