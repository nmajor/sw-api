class Subject
  include MongoMapper::Document

  key :first_name, String
  key :last_name, String
  key :notes, String
  key :creator_id, ObjectId
  timestamps!
end