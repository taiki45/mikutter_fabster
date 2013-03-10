# -*- coding: utf-8 -*-
require 'mongo'
require 'pry'

module MikutterFabster
  class DataStore
    def initialize(id)
      @id = id
    end

    def client
      @client ||= Mongo::MongoClient.new
    end

    def tweets
      client.db("tweeamon").cllection("tweets")
    end

    def my_mosts
      tweets.find({"user.id" => @id })
    end
  end

  Plugin.create :fabstar do
    #store = Datastore.new(id)
    binding.pry
  end
end
