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
    local new = {}
    for k, v in pairs(vohttp.Server) do
        new[k] = v
    end

    new._socket = nil
    new._routes = {}
    new._buffer = {}
    new.connections = {}
    new.listening = false

    return new
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
    vohttp.debug_print("Connection from "..con.tcp:GetPeerName())
    self._buffer[con.tcp:GetPeerName()] = {}
    self.connections[con] = true

    -- waiting for POST data
    self._wait_for = {}
end

--- Called when a new line is received (internal function).
-- @param con the connection context
-- @param line the line that was received
function vohttp.Server:_line_received(con, line)
    local ready = false

    if line == "\r" then
        -- Andy's tcpsock strips off the \n in \r\n

        if self._wait_for[con.tcp:GetPeerName()] then
            self._wait_for[con.tcp:GetPeerName()] = false
        else
            ready = true
        end

    else
        table.insert(self._buffer[con.tcp:GetPeerName()],
                     line:sub(0, line:len() - 1))
        if line:find("^Content%-Length") then
            self._wait_for[con.tcp:GetPeerName()] = true
        end
    end

    if ready then
        local request = vohttp.request.Request:new(con)
        request:load_query(self._buffer[con.tcp:GetPeerName()])
        self:_request_received(con, request)
    end
end

--- Called when a new HTTP request was received.
-- @param con the connection context
-- @param request the request received
function vohttp.Server:_request_received(con, request)
    local response

    if self._routes[request.path] then
        local status
        status, response = pcall(self._routes[request.path], request)
        if not status then
            response = response.."\n"..debug.traceback()
            log_print(response)
            response = vohttp.response.InternalServerErrorResponse:new(response)
        end
    else
        response = vohttp.response.NotFoundResponse:new()
    end

    for _, line in ipairs(response:construct()) do
        con:Send(line.."\n")
    end

    if response.disconnect then
        con.tcp:Disconnect()
    end
end

--- Called when a connection is lost (internal function).
-- @param con the connection context
function vohttp.Server:_connection_lost(con)
    vohttp.debug_print("Lost connection")
    self.connections[con] = nil
end

--- Starts listening for requests.
-- @param port the port to listen to
function vohttp.Server:start(port)
    if self.listening then
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
        self.listening = true
    end
end

-- Stops listening for requests.
function vohttp.Server:stop()
    if self and self.listening then
        for k, v in ipairs(self.connections) do
            k:Disconnect()
            self.connections[k] = nil
        end
        self._socket:Disconnect()
        self.listening = false
    else
        vohttp.print("Error: Server is not listening.")
    end
end
