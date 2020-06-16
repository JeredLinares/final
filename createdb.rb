# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model

#Jered's Domain model
#Tables:
#	players / place / flags

DB.create_table! :players do
	primary_key :id
	String :username
	String :team
	String :email
end

DB.create_table! :places do
  primary_key :id
  String :name
  String :coordinates
end

DB.create_table! :flags do
  primary_key :id
  foreign_key :flag_id
  foreign_key :player_id
  Timestamp :time_captured, 'timestamp with time zone'
end

# Insert initial (seed) data
players_table = DB.from(:players)
places_table = DB.from(:places)
flags_table = DB.from(:flags)

players_table.insert(username: "jered",
					team: "blue"
                    email: "jered.linares@kellogg.northwestern.edu")

places_table.insert(name: "The Arch", 
                    coordinates: "42.051130,-87.677226")

places_table.insert(name: "The Global Hub", 
                    coordinates: "42.057452,-87.672452")

places_table.insert(name: "Bonfire Pit", 
                    coordinates: "42.053828, -87.670237")


flags_table.insert(flag_id: 1,
					player_id: 1)
