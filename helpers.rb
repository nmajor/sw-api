helpers do
  def upload(filename, file)
    bucket = 'sw-api'
    awskey     = 'AKIAJFHIT33VWGUAEG7A'
    awssecret  = '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'
    AWS::S3::Base.establish_connection!(
      :access_key_id     => awskey,
      :secret_access_key => awssecret,
    )
    AWS::S3::S3Object.store(
      filename,
      open(file.path),
      bucket,
      :access => :public_read
    )
    url = "https://#{bucket}.s3.amazonaws.com/#{filename}"
    return url
  end

  def get_current_user
    graph = Koala::Facebook::GraphAPI.new(session["access_token"])
    current_fb_user = graph.get_object("me")
    user = User.first( :fb_id => current_fb_user["id"].to_i )
    return user if user
    user = User.new({
      :fb_id => current_fb_user["id"],
      :avatar => graph.get_picture("me", :type => "large"),
      :name => current_fb_user["name"]
    })
    user.save
    return user
  end

  def get_user(id)
    graph = Koala::Facebook::GraphAPI.new(session["access_token"])
    fb_user = graph.get_object(id)
    user = User.first( :fb_id => id.to_i )
    user = User.find_by_id( :id => id ) if ! user
    return user if user

    user = User.new({
      :fb_id => fb_user["id"],
      :avatar => graph.get_picture(fb_user["id"], :type => "large"),
      :name => fb_user["name"]
    })
    user.save
    return user
  end

end
