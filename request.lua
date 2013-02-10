---------------
-- ## HTTP Request Object.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.request = {}
vohttp.request.Request = {}

--- Creates a new empty HTTP Request Object.
-- @param con the connection context
function vohttp.request.Request:new(con)
    local new = {}
    for k, v in pairs(vohttp.request.Request) do
        new[k] = v
    end

    --- the command set by the client (GET, POST, HEAD).
    new.command = nil

    --- the connection context.
    new.con = con

    --- the requested path.
    new.path = nil

    --- the headers the clients sent.
    new.headers = {}

    --- the HTTP version used by the client.
    new.version = nil

    --- the GET data sent by the client.
    new.get_data = {}

    -- the POST data sent by the client.
    new.post_data = {}

    return new
end


--- Contructs an already initialized Request from a query with a client.
-- @param query the query with the client (a table of lines)
function vohttp.request.Request:load_query(query)
    self.command, self.path, self.version = query[1]:match("(.*) (.*) HTTP/(.*)")

    if self.path:find("%?") then
       self.path, self.get_data = self.path:match("(.*)%?(.*)")
       self.get_data = vohttp.util.decode(self.get_data)
    end

    for n, h in ipairs(query) do
        if n ~= 1 then
            local name, value = h:match("(.*): (.*)")
            if name then
                self.headers[name] = value
            end
        end
    end

    if self.command == "POST" then
        if self.headers["Content-Type"] == "application/x-www-form-urlencoded" then
            self.post_data = vohttp.util.decode(query[table.getn(query)])
        else
            self.post_data = query[table.getn(query)]
        end
    end

    return self
end
