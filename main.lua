---------------
-- ## vohttp - an http library for Vendetta Online.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschmann.email>
-- @copyright 2013
-- @license MIT/X11

declare("vohttp", vohttp or {})

vohttp = {
    DEBUG=gkini.ReadString("vohttp", "debug", 0) == 1
    VERSION="0.5"
}

function vohttp.debug_print(msg)
    if vohttp.DEBUG then
        print(msg)
    end
end

dofile("lib/tcpsock.lua")
dofile("util.lua")
dofile("request.lua")
dofile("response.lua")
dofile("dispatch.lua")
dofile("server.lua")
