require 'bcrypt'

#puts "hello world"

puts BCrypt::Password.create("12345").to_s


