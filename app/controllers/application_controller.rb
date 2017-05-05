class ApplicationController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

  get "/" do
    if logged_in?
      redirect "/users/#{current_user.slug}"
    else
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :landing
    end
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    if condition
      
    else
      
    end
    if params[:img][:type] =~ /image/
      file_ext = /image\/(.+)/.match(params[:img][:type])[1]
      File.open("public/images/profile_pic.#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:img][:tempfile], binmode: true))}
    else
      "You didn't upload an image dummy!!"
    end
  end

  get "/login" do
    if logged_in?
      redirect "/users/#{current_user.slug}"
    else
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :login
    end
  end

  post "/login" do

  end

  get "/logout" do
    session.clear
    redirect '/'
  end

end