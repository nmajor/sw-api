class User
  include MongoMapper::Document
  key :fb_id, Integer
  key :avatar, String
  key :name, String
  #key :child_user_ids, Array, :typecast => 'ObjectId'
  #many :child_users, :in => :child_user_ids, :class_name => 'User'
  #many :video
  timestamps!

  def parent_users
    User.where(:child_user_ids => self.id)
  end

end
