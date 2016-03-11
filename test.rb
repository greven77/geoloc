require 'geocoder' #can be used to get distances and gps coordinates
require 'json'
require 'mysql2'
require 'global_phone' #can be used to get names and codes
GlobalPhone.db_path = 'db/global_phone.json'
#in order to work offline check
#if database is empty, pre-fetch all countries/prefixes codes
#and its cities codes/prefixes (maybe implement an option to store in a csv/json or database)

#then after fetching all countries and its cities map them to their
#central GPS location
#could be stored in a table named Country and in a table named City or
#just named Location
#containing fields: name, prefix, gps_location

#then somehow make the distance calculation either:
#manually or via geocoder gem
