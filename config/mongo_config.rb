require 'mongo_mapper'

class MongoConfig
  def self.configure
    if ENV['MONGOHQ_URL']
      MongoMapper.setup({'production' => {'uri' => ENV['MONGODB_URI']}}, 'production')
    else
      MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :pool_size => 5, :timeout => 5)
      MongoMapper.database = 'chronicle'
    end
  end
end
