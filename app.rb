require 'rubygems'
require 'sinatra'
require 'mongo_mapper';
require 'json/ext'
Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }

configure do
  MongoMapper.connection = Mongo::Connection.new('localhost',27017, :pool_size => 5, :timeout => 5)
  MongoMapper.database = 'chronicle'
end

enable :sessions

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
  user = User.first(:username => params[:username], :password => params[:password]);
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
  video = Video.new({
    :name => params[:name],
    :description => params[:description],
    :user_id => session[:id]
  })
  video.save
  video.to_json
end
