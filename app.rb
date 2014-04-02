require "bundler/setup"
require "sinatra"
require 'haml'
require 'json'
require "net/http"
require 'koala'
require 'pg'
require 'sinatra/activerecord'
require './config/environments'

require './models/user'


class FacebookInfo < Sinatra::Base

  APP_ID = "225822807607273"
  APP_SECRET = "c24367e01fc94ea71b50a0aceaa9e19a"
  if Sinatra::Base.development?
    CALLBACK_URL = "http://localhost:9292/facebook_callback"
  else
    CALLBACK_URL = "http://facebook-info.herokuapp.com/facebook_callback"
  end

  get '/' do
    @oauth = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, CALLBACK_URL)
    haml :index, :format => :html5
  end

  get "/facebook_callback" do
    @oauth = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, CALLBACK_URL)
    access_token = @oauth.get_access_token(params[:code])
    logger.info "Access Token -> #{access_token}"
    @graph = Koala::Facebook::API.new(access_token, APP_SECRET)
    @profile = @graph.get_object("me")

    user = User.find_or_create_by_fb_id(:fb_id => @profile["id"])

    if user
      user.update_attributes(
        :access_token => access_token,
        :username => @profile["username"],
        :name => @profile["name"],
        :first_name => @profile["first_name"],
        :last_name => @profile["last_name"],
        :link => @profile["link"],
        :gender => @profile["gender"],
        :hometown => @profile["hometown"]['name'],
        :location => @profile["location"]['name'],
        :religion => @profile["religion"],
        :political => @profile["political"],
        :timezone => @profile["timezone"],
        :locale => @profile["locale"]
      )
    end
    redirect to('/user/' + @profile["id"].to_s)
  end

  get '/user/:id' do
    @user = User.find_by_fb_id(params[:id])
    if @user
      haml :user_profile, :format => :html5
    else
      status 404
      body "Not found!"
    end
  end


  get '/api/user/' do
    logger.info "DEBUG request.ev -> #{request.env}"
    access_token = request.env['HTTP_AUTHORIZATION_TOKEN']
    logger.info "Access Token: #{access_token}"
    @user = User.find_by_access_token(access_token)
    content_type :json
    if @user
      { :user => @user }.to_json
    else
      status 404
      { :message => "Not found!" }.to_json
    end
  end

end
