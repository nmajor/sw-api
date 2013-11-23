class User
  include MongoMapper::Document

  key :username, String
  key :first_name, String
  key :last_name, String
  many :users, :in => :connections
  timestamps!
end
