module(..., package.seeall)

local Public = {}

function Public.headers(headers_s)
    local headers = {}
    headers_s = "\n" .. headers_s .. "$$$:\n"
    local i, j = 1, 1
    local name, value, _
    while 1 do
        j = string.find(headers_s, "\n%S-:", i+1)
        if not j then break end
        _, _, name, value = string.find(string.sub(headers_s, i+1, j-1), 
					"(%S-):(.*)")
	if string.sub(value,1,1) == " " then
	   value = string.sub(value,2)
	end
        value = string.gsub(value or "", "\r\n", "\n")
        value = string.gsub(value, "\n%s*", " ")
        name = string.lower(name)
        if headers[name] then headers[name] = headers[name] .. ", " ..  value
        else headers[name] = value end
        i, j = j, i
    end
    headers["$$$"] = nil
    return headers
end

function Public.message(message_s, raw_s)
    message_s = string.gsub(message_s, "^.-\n", "")
    local _, headers_s, body
    _, _, headers_s, body = string.find(message_s, "^(.-\n)\n(.*)")
    headers_s = headers_s or ""
    body = body or ""
    return { headers = Public.headers(headers_s), body = body, raw=raw_s }
end

function Public.mbox(mbox_s, mbox)
    if not mbox then mbox = {} end
    mbox_s = "\n" .. mbox_s .. "\nFrom "
    local i, j = 1, 1
    while 1 do
        j = string.find(mbox_s, "\nFrom ", i + 1)
        if not j then break end
        table.insert(mbox, Public.message(
					  string.sub(mbox_s, i + 1, j - 1),
					  string.sub(mbox_s, i,j-1)))
        i, j = j, i
    end
    return mbox
end
 
parse = Public.mbox