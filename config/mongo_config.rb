require 'mongo_mapper'

class MongoConfig
  def self.configure
    if ENV['MONGOHQ_URL']
      db = URI.parse(ENV['MONGOHQ_URL'])
      remote_name = db.path.gsub(/^\//, '')
      MongoMapper.connection = Mongo::Connection.new(db.host, db.port).db(remote_name)
      MongoMapper.connection.authenticate(db.user, db.password)
    else
      MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :pool_size => 5, :timeout => 5)
      MongoMapper.database = 'chronicle'
    end
  end
end