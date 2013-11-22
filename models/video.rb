class Video
  include MongoMapper::Document

  key :name, String
  key :description, String
  key :url, String
end