#!/bin/bash
CSRF=`curl -c .login.headers -v --silent https://plug.dj/ 2>&1 | grep -oP '(?<=var _csrf=").*?(?=")'`
SESSION=`grep -Po '(?<=Set-Cookie: )session(.*?)$' .login.headers`
curl -i -H "Accept: application/json" -X POST -b .login.headers -H "Content-Type: application/json" -d "{\"csrf\":\"$CSRF\",\"email\":\"$1\",\"password\":\"$2\"}" "https://plug.dj/_/auth/login"
grep -Po '(?<=session\t)(.*?)$' .login.headers > session_cookie
