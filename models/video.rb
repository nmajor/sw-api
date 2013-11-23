class Video
  include MongoMapper::Document

  key :user_id, ObjectId
  key :name, String
  key :description, String
  key :url, String
  belongs_to :user
end
