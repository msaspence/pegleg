$:.unshift File.join(File.dirname(__FILE__), '..')
ENV["RACK_ENV"] ||= "development"

require 'bundler'
Bundler.setup

Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require "pegleg/version"
require "pegleg/searcher"
require "pegleg/result"

require 'sinatra/base'
require "sinatra/reloader"
require 'sinatra/assetpack'
require 'haml'
require 'open-uri'
require 'nokogiri'
require 'pry'

module Pegleg
  class App < Sinatra::Base


    set :public_folder, 'public'

    register Sinatra::AssetPack
    assets do
      css :application, [
        '/bootstrap-3.1.1-dist/css/bootstrap.css',
        '/css/pegleg.css'
      ]
    end

    register Sinatra::Reloader
    also_reload 'pegleg/searcher'
    also_reload 'pegleg/result'

    helpers do
      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['longjonsilver', 'peicesofeight']
      end
    end

    before do
      protected!
    end

    get '/' do


      haml :index

    end

    get '/search' do
      @q = params['q']

      searcher = Searcher.new @q, 'proxybay.eu'
      @results = searcher.run.results

      haml :search

    end

  end
end