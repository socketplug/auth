sessions = {}
for line in io.lines "session_cookies"
    sessions[#sessions+1] = line

count = 1
export get_session = ->
    temp = count
    count = if count + 1 > #session then 1 else count + 1
    sessions[temp]
