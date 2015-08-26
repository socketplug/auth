lapis = require "lapis"

class extends lapis.Application
    @include "api/v1"
    "/": =>
		"ayy lmao"
