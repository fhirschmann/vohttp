-- written by Andy

-- hacked for http use (post data does not send CRLF)
-- "\n\r\n" is now appended when all data has been received
-- that was requested by Content-Length

local TCP = {}


local function SetupLineInputHandlers(conn, conn_handler, line_handler, disconn_handler)
  local buf = ''
  local match
  local connected
  local wait_for = nil
  local in_body = false

  conn.tcp:SetReadHandler(function()
    local msg, errcode = conn.tcp:Recv()
    if not msg then
      if not errcode then return end
      local err = conn.tcp:GetSocketError()
      if err then log.error(err) end
      conn.tcp:Disconnect()
      disconn_handler(conn)
      conn = nil
      return
    end
    buf = buf..msg
    repeat
    if in_body then
        if buf:len() == wait_for then
            buf = buf.."\n\r\n"
        end
    end
      buf,match = string.gsub(buf, "^([^\n]*)\n", function(line)
        if line:find("^Content%-Length") then
            wait_for = tonumber(line:match("Content%-Length: (%d+)"))
        elseif line == "\r" then
            in_body = true
        end
        local result, err_msg = pcall(line_handler, conn, line)
        if not result then
            console_print(err_msg)
            console_print(debug.traceback())
        end
        return ''
      end)
    until (match==0)
  end)

  local writeq = {}
  local qhead,qtail=1,1

  -- returns true if some data was written
  -- returns false if we need to schedule a write callback to write more data
  local write_line_of_data = function()
    --print(tostring(conn)..': sending  '..writeq[qtail])
    local bsent = conn.tcp:Send(writeq[qtail])
    -- if we sent a partial line, keep the rest of it in the queue
    if bsent == -1 then
      -- EWOULDBLOCK?  dunno if i can check for that
      return false
      --error(string.format("write(%q) failed!", writeq[qtail]))
    elseif bsent < string.len(writeq[qtail]) then
      -- consume partial line
      writeq[qtail] = string.sub(writeq[qtail], bsent+1, -1)
      return false
    end
    -- consume whole line
    writeq[qtail] = nil
    qtail = qtail + 1
    return true
  end
  
  -- returns true if all available data was written
  -- false if we need a subsequent write handler
  local write_available_data = function()
    while qhead ~= qtail do
      if not write_line_of_data() then
        return false
      end
    end
    qhead,qtail = 1,1
    return true
  end

  local writehandler = function()
    if write_available_data() then 
      conn.tcp:SetWriteHandler(nil)
    end
  end

  function conn:Send(line)
    --print(tostring(conn)..': queueing '..line)
    writeq[qhead] = line
    qhead = qhead + 1
    if not write_available_data() then
      conn.tcp:SetWriteHandler(writehandler)
    end
  end

  local connecthandler = function()
    conn.tcp:SetWriteHandler(writehandler)
    connected = true
    local err = conn.tcp:GetSocketError()
    if err then 
      conn.tcp:Disconnect()
      return conn_handler(nil, err)
    end
    return conn_handler(conn)
  end

  conn.tcp:SetWriteHandler(connecthandler)
end

-- raw version
function TCP.make_client(host, port, conn_handler, line_handler, disconn_handler)
  local conn = {tcp=TCPSocket()}

  SetupLineInputHandlers(conn, conn_handler, line_handler, disconn_handler)

  local success,err = conn.tcp:Connect(host, port)
  if not success then return conn_handler(nil, err) end

  return conn
end

function TCP.make_server(port, conn_handler, line_handler, disconn_handler)
  local conn = TCPSocket()
  local connected = false
  local buf = ''
  local match

  conn:SetConnectHandler(function()
    local newconn = conn:Accept()
    --print('Accepted connection '..newconn:GetPeerName())
    SetupLineInputHandlers({tcp=newconn}, conn_handler, line_handler, disconn_handler)
  end)
  local ok, err = conn:Listen(port)
  if not ok then error(err) end

  return conn
end

return TCP
