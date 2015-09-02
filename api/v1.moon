lapis = require "lapis"
rand = require "vendor.random"
http = require "lapis.nginx.http"

import capture_errors_json, yield_error from require "lapis.application"
import assert_valid from require "lapis.validate"
import from_json, to_json from require "lapis.util"
import json_params from require "lapis.application"

import Model from require "lapis.db.model"

class Users extends Model
     @timestamp: true

class TempUsers extends Model
    @timestamp: true

class ApiV1 extends lapis.Application
    @path: "/v1"

    "/create/:id": capture_errors_json =>
        assert_valid @params, {{ "id", is_integer:true, "invalid_id" }}

        tokens = token: rand.token(64), secret: rand.token(64)

        -- update or create temporary user row
        user = TempUsers\find @params.id
        if user
            user\update tokens
        else
            user = TempUsers\create {
                id: @params.id,
                token: tokens.token,
                secret: tokens.secret
            }

        -- return the token and secret
        json: tokens

    "/verify/:id": capture_errors_json json_params => 
        assert_valid @params, {{ "id", is_integer:true, "invalid_id" }}

        -- get and remove user from temporary user table
        user = TempUsers\find @params.id
        if user then user\delete! else yield_error "no_id" 
        print "the set secret is #{user.secret}"
        print "the given secret is #{@params.secret}"
        assert_valid @params, {{ "secret", equals: user.secret, "bad_secret"}}

        -- get user's api object from plug.dj
        api_body, api_status_code, h = http.simple {
            url: "https://plug.dj/_/users/#{@params.id}"
            method: "GET"
            headers: {
                "cookie": "session=#{get_session!}"
            }
        }
        api = from_json api_body
        unless api_status_code == 200 and api.status == "ok"
            yield_error "plug_api_failure"

        -- make sure the slug actually exists, there are "false users"
        unless (type api.data[1].slug) == "string" then yield_error "no_slug"

        -- get user profile page and see if it contains the token
        blurb_body, s, h = http.simple "https://plug.dj/@/#{api.data[1].slug}"
        m, err = ngx.re.match(blurb_body, user.token)
        unless m then yield_error "bad_token"

        -- user was successfully authenticated, send out a permanent token
        perm_token = rand.token(64)
        perm_user = id: @params.id, token: perm_token
        user = Users\find @params.id
        if user
            user\update perm_user
        else
            Users\create perm_user

        json: { token: perm_token }

    "/auth/:id": capture_errors_json json_params =>
        assert_valid @params, {
            { "id", is_integer:true, "invalid_id" }
            { "token", exists:true, "no_token_requested" }
        }

        user = Users\find @params.id
        assert_valid @params, {{"token", equals: user.token, "bad_token"}}

        json: { status: "ok" }
