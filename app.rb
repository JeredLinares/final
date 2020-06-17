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
    view "makeuser"
end
get "/score" do
    view "score"
end
get "/logout" do
    view "home"
end
