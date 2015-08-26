lapis = require "lapis"

class extends lapis.Application
    @include "api/v1"
    "/": =>
		"Welcome to Lapis #{require "lapis.version"}, startup #{greeting_message}!"
