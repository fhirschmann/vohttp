---------------
-- ## A simple HTTP Server for Vendetta Online.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.Server = {}

--- Creates a new Server instance.
-- @return a new Server instance
function vohttp.Server:new()
    self._socket = nil
    self._routes = {}
    self._buffer = {}

    return self
end

--- Adds a new route dispatcher to this VOServe instance.
-- Use this method to add routes under which your application
-- should respond to.
-- @param route the route (string)
-- @param dispatcher a dispatcher function that returns a response
function vohttp.Server:add_route(route, dispatcher)
    self._routes[route] = dispatcher
end

--- Called when a new connection is made (internal function).
-- @param con the connection context
function vohttp.Server:_connection_made(con)
    print("Connection from "..con.tcp:GetPeerName())
    self._buffer[con.tcp:GetPeerName()] = {}
end

--- Called when a new line is received (internal function).
-- @param con the connection context
-- @param line the line that was received
function vohttp.Server:_line_received(con, line)
    if line == "\r" then
        -- Andy's tcpsock strips off the \n in \r\n

        local request = vohttp.request.Request:new(con)
        request:load_query(self._buffer[con.tcp:GetPeerName()])
        self:_request_received(con, request)
    else
        table.insert(self._buffer[con.tcp:GetPeerName()],
                     line:sub(0, line:len() - 1))
    end
end

--- Called when a new HTTP request was received.
-- @param con the connection context
-- @param request the request received
function vohttp.Server:_request_received(con, request)
    local response

    if self._routes[request.path] then
        response = self._routes[request.path](request)
    else
        response = vohttp.response.NotFoundResponse:new()
    end

    for _, line in ipairs(response:construct()) do
        con:Send(line.."\n")
    end
end

--- Called when a connection is lost (internal function).
-- @param con the connection context
function vohttp.Server:_connection_lost(con)
    print("Lost connection")
end

--- Starts listening for requests.
-- @param port the port to listen to
function vohttp.Server:start(port)
    if self._socket then
        print("ERROR: Socket already open.")
    else
        self._socket = TCP.make_server(port,
                        function(con, err)
                            if con then
                                self:_connection_made(con)
                            end
                        end,
                        function(con, line)
                            self:_line_received(con, line)
                        end,
                        function(con)
                            self:_connection_lost(con)
                        end)
        print("OK: Now listening on port "..port)
    end
end

-- Stops listening for requests.
function vohttp.Server:stop()
    if self and self._socket then
        self._socket:Disconnect()
        self._socket = nil
    else
        print("Error: Server is not listening.")
    end
end
