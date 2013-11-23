require 'mongo_mapper'

class MongoConfig
  def self.configure
    if ENV['MONGOLAB_URI']
      MongoMapper.setup({'production' => {'uri' => ENV['MONGOLAB_URI']}}, 'production')
    else
      MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :pool_size => 5, :timeout => 5)
      MongoMapper.database = 'chronicle'
    end
  end
end
