# auth
a third party authentication service for plug.dj hosted at auth.socketplug.org

**The server at the url auth.socketplug.org was shut down when plug was in fall 2015,
but it will come alive again sometime before plug.dj comes out of staging.**

Additionally, some things may not work, or work differently, because I have not tested it since I have learned of the staging servers.
They will be tested when I have time.

Lots of love, and good hope for plug.dj

\- chip (@git)


# Starting the verification process

### Creating a temporary token
Start off with the api endpoint `/api/v1/create/:id` where the `:id` is the plug user's id who you want to start a verification process for.  You will receive back 2 hashes in a json format, one being `token` (your public token) and `secret` (a secret, private token).

### Creating a way to verify for socketplug-auth
You then set the user's blurb (their profile text) to the public token.  (It would be a polite idea to save what you are changing it from so you can change it back later)

Then, you post to `/api/v1/verify/:id` with `:id` again being the plug user's id and you should be posting the secret.  Whether you post the secret in json, or as a regular post request, it shouldn't matter, but the key `secret` with the value of the secret needs to exist (and be valid to verify correctly).  If you do not receive an error, then you will get the user's new, 'permanent' token in json format with the key `token`.

At this point you do not need the temporary token, and it would be polite to set the user's blurb back to what they had it to when you cached it.

Please mind that currently a user can only have 1 valid permanent token at a time, so if they go through the create and verify process again, the old token will be invalid.  This is likely to change in the future, along with allowing users to view/delete their current sessions (and see who made them?).

Either way, you now have a valid token that verifies that they are a user.  Just like the session token on plug itself, if somebody compromises this token, they can then impersonate as that user (just like you can put someone else's plug.dj session cookies into yours and you will then be logged in as that user).

Keep that token in localhost or whatever, but please try to cache it and only create it if it doesn't exists or is invalid - to be nice to the server.

Congratulations, you have successfully gotten a user verified to allow for 3rd party authentication with Socketplug Auth.

### How is this token useful?

If you post to the endpoint `/api/v1/auth/:id` with `:id` being the plug user's id again and with the post payload being the key `token` along with the permanent token (delivered either by json or regular posting like before) you will get a response.  That response will either be an error with `bad_token` as the json error value, or it will validate, and you will receive a json key `status` with the value `ok` (much like some of plug's pre-shutdown api, and also maybe today's api cause I have not checked).

That means, if you want to verify that a user is who they say they are to a service that you want to provide (say logging in to a websocket for private messaging in your plugin), or basically anything where you want to be able to verify that a user is who they say they are, send over the Socketplug Auth token.  Then, your server can hit that `/api/v1/auth/:id` endpoint and see if that user's id matches their session token.  It is also useful for seeing if a cached token is valid when you start your client plugin, so that you know if you need to create a new one or not.

I use to have a small and not fleshed out script that automated it all, but I lost it since I thought plug was lost forever.  If I find it, I'll post it.  I'll also remake it again as a full and proper script when I find the time in the future.  If you make one for yourself that would work for general use, feel free to share.

