require 'sinatra'

get '/' do
  "Hello Startup Weeked Ogden"
end

get '/video' do
  "TODO: List user videos"
end

get '/video/:id' do
  "TODO: Get a specific video"
end

post '/video' do
  "TODO: Create a video"
end
