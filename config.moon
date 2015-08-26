config = require "lapis.config"

config "prod", ->
	port 80
	num_workers 1
	code_cache "on"
	postgres ->
		backend "pgmoon"
		user "socketplug_auth"
		database "socketplug_auth"
		password "SECRET"
