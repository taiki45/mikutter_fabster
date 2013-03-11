# -*- coding: utf-8 -*-
require 'yaml'
require 'mongo'
require 'pry'

module MikutterFabster
  class << self
    def config
      @config ||= Hash[YAML.load_file(path).map {|k, v| [k.to_sym, v] }]
    end

    def path
      File.expand_path('../config.yaml', __FILE__)
    end
  end

  class DataStore
    def initialize(id)
      @id = id
    end

    def config
      @config ||= MikutterFabster.config.select {|k, v| [:host, :port].include? k }.map {|k, v| v }
    end

    def client
      @client ||= Mongo::MongoClient.new(*config)
    end

    def tweets
      client.db("tweeamon").collection("tweets")
    end

    def my_mosts
      tweets.find({"user.id" => @id, "favorite_count" => {"$gt" => 0}})
        .sort({"favorite_count" => -1})
        .limit(50)
    end
  end

  Plugin.create :fabstar do
    id = Service.primary.user_obj.id
    store = DataStore.new id

    tab :fabster, 'f' do
      timeline :fabster
    end

    on_period do
      timeline(:fabster).clear
      timeline(:fabster) << store.my_mosts.map do |most|
        message_source = JSON.parse(most.to_json).symbolize
        message = MikuTwitter::ApiCallSupport::Request::Parser.message(message_source)
        if message_source[:favorite_users]
          users = message_source[:favorite_users].map &MikuTwitter::ApiCallSupport::Request::Parser.method(:user)
          message.favorited_by.merge users
        end
        message
      end
    end
  end
end
