class User
  include MongoMapper::Document

  key :username, String
  key :hashed_password, String
end