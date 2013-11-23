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
end
