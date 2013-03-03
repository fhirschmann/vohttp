---------------
-- ## HTTP utility functions.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.util = {}

--- Escapes a string for transmittion over the HTTP protocol.
-- @param s the string to escape
-- @return an escaped string
function vohttp.util.escape(s)
    local s = string.gsub(s, "([&=+%c])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    s = string.gsub(s, " ", "+")
    return s
end

--- Unescapes a previously escaped string.
-- @param s the string to unescape
-- @return an unescaped string
function vohttp.util.unescape(s)
    local s = string.gsub(s, "+", " ")
    s = string.gsub(s, "%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end

--- Decodes a previously encoded key/value string.
-- @param s the string to decode
-- @return a table of key and values
function vohttp.util.decode(s)
    local cgi = {}
    for name, value in s:gmatch("([^&=]+)=([^&=]+)") do
        name = vohttp.util.unescape(name)
        value = vohttp.util.unescape(value)
        cgi[name] = value
    end
    return cgi
end

--- Encodes a table of key/values for transmittion over the HTTP protocol.
-- @param t the table to encode
-- @return a string-encoded key-value table
function vohttp.util.encode(t)
    local s = ""
    for k,v in pairs(t) do
        s = s .. "&" .. vohttp.util.escape(k) .. "=" .. vohttp.util.escape(v)
    end
    return s:sub(2)
end
