# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

players_table = DB.from(:players)
places_table = DB.from(:places)
flags_table = DB.from(:flags)
@failed=0           #has there been a failed login

before do
    @current_user = players_table.where(:id=>session[:user_id]).to_a[0]
    puts "the user"
    puts @current_user.inspect
end


get "/" do
    view "home"
end

get "/login" do
    view "login"
end

post "/login/validate" do
    puts params

    username = params["username"]
    #Note: This is a security vulnerability. 
    #Should upgrade to client side password encryption.
    #We are depending on transmission encryption which is likely not as strong as BCrypt
    entered_password = params["password"]
    matching_user = players_table.where(:username => username).to_a[0]

    if matching_user

        if BCrypt::Password.new(matching_user[:password]) == entered_password
            @failed=0
            session[:user_id]=matching_user[:id]
            view "home"
        else    
            #may not have entered a password
            @failed=1
            view "login"
        end
    else
        @failed=1
        view "login"
    end


end


get "/players" do
    view "players"

end
get "/locations" do
    view "locations"

end
get "/locations/:id" do
    view "locationdesc"

end
get "/new/location" do
    view "home"

end
get "/new/player" do
    view "newplayer"
end

post "/new/player/validate" do

    players_table.insert(:username=> params["username"],
                        :team=>params["team"],
                        :password=>BCrypt::Password.create(params["password"]))
    puts params
    view "usercreated"
end

get "/score" do
    view "score"
end
get "/logout" do
    session.clear
    view "home"
end
