# -*- coding: utf-8 -*-
require 'yaml'
require 'mongo'

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
    attr_accessor :most_limit, :recent_limit, :last_limit

    def initialize(id)
      @id = id
      @most_limit = 20
      @recent_limit = 50
      @last_limit = 200
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
        .limit(most_limit)
    end

    def my_recents
      tweets.find({"user.id" => @id, "favorite_count" => {"$gt" => 0}})
        .sort({"id" => -1})
        .limit(recent_limit)
    end

    def last_tweets
      tweets.find.sort({"id" => -1}).limit(last_limit)
    end
  end

  if defined?(Plugin)
    Plugin.create :fabster do
      store = DataStore.new(Service.primary.user_obj.id)
      store.most_limit = UserConfig[:fabster_most_count] if UserConfig[:fabster_most_count]
      store.recent_limit = UserConfig[:fabster_recent_count] if UserConfig[:fabster_recent_count]
      store.last_limit = UserConfig[:fabster_last_count] if UserConfig[:fabster_last_count]

      def celebrate?(msg)
        turnings = [50, 100, 250]
        msg.from_me? && turnings.include?(msg.favorited_by.count)
      end

      def celebrate(msg)
        link = "http://twitter.com/#{Service.primary.user_obj}/status/#{msg.id}"
        Plugin.call(
          :update,
          nil,
          [Message.new(message: "Congrats on your #{msg.favorited_by.count} tweet! #{link}", system: true)]
        )
      end

      def faved_one?(message)
        message.from_me? && !(message.favorited_by.empty?)
      end

      def to_msg(source)
        message_source = JSON.parse(source.to_json).symbolize
        message = MikuTwitter::ApiCallSupport::Request::Parser.message(message_source)
        if message_source[:favorite_users]
          users = message_source[:favorite_users].map &MikuTwitter::ApiCallSupport::Request::Parser.method(:user)
          message.favorited_by.merge users
        end
        message
      end

      tab :fabster_most, 'M' do
        timeline :fabster_most do
          order do |message|
            message.favorited_by.size
          end
        end
      end

      tab :fabster_recent, 'R' do
        timeline :fabster_recent do
          order do |message|
            Time.parse(message.to_hash[:created_at]).strftime("%s").to_i
          end
        end
      end

      on_boot do
        store.last_tweets.each do |tweet|
          timeline(:home_timeline) << to_msg(tweet)
        end
      end

      on_period do
        store.my_mosts.each do |most|
          Plugin.call(:most_modified, to_msg(most))
        end

        store.my_recents.each do |recent|
          Plugin.call(:recent_modified, to_msg(recent))
        end
      end

      on_message_modified do |message|
        timeline(:fabster_recent) << message if faved_one?(message)
        timeline(:fabster_most) << message if faved_one?(message)
        celebrate(message) if celebrate? message
      end

      on_most_modified do |message|
        timeline(:fabster_most) << message if faved_one?(message)
      end

      on_recent_modified do |message|
        timeline(:fabster_recent) << message if faved_one?(message)
      end

      settings "fabster" do
        adjustment('most count', :fabster_most_count, 1, 400).tooltip('How many tweets to show')
        adjustment('recent count', :fabster_recent_count, 1, 400).tooltip('How many tweets to show on boot')
        adjustment('load count', :fabster_last_count, 1, 1000).tooltip('How many tweets to load on boot')
      end
    end
  end
end
