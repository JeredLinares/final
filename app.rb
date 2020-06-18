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
    @places=DB[:places]
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
    @players = DB[:players]
    view "players"

end
get "/locations" do
    view "locations"

end
get "/locations/:id" do
    view "locationdesc"

end
get "/new/location" do


    view "newlocation"

end

post "/new/location/validate" do
    search_add =  params["address"]+", "+params["city"]+", "+params["state"]
    puts search_add
    results = Geocoder.search(search_add)

    puts params.inspect
    puts results.inspect
    puts results.length

    if results.length >=1

            coords = results[0].latitude.to_s+","+results[0].longitude.to_s
            puts coords

            places_table.insert(
                name: params["name"],
                coordinates: coords
            )



            if results.length==1
                @add_note="New Location added"
            else
                @add_note="There were multiple matches, the first match was used"
            end
        view "locations"
    else 
        # bad
        @add_note="No results, no location added, please try again."
        view "newlocation"
    end


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
