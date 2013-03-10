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
      @config ||= MikutterFabster.config.select {|key, val| [:host, :port].include? key }
    end

    def client
      @client ||= Mongo::MongoClient.new(config)
    end

    def tweets
      client.db("tweeamon").cllection("tweets")
    end

    def my_mosts
      tweets.find({"user.id" => @id }, {"favorite_count" => {"$gt" => 0}}).sort({"favorite_count" => -1})
    end

    class ExtHash
      def initialize(raw)
        @raw = raw
      end

      def method_missing(name, *args)
        @raw.hash_key?(name.to_s) ? @raw[name.to_s] : @raw.__send__(:method_missing, name, *args)
      end

      def respond_to_missing(name, include_private)
        @raw.hash_key?(name) || @raw.__send__(:respond_to_missing, name, include_private)
      end
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
      timeline(:fabster) << [msgs]
    end
  end
end
