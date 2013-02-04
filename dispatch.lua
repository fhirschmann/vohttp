---------------
-- ## Generic dispatcher
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschm.net>
-- @copyright 2013
-- @license MIT/X11

vohttp.dispatch = {}
vohttp.dispatch.StaticPage = {}
vohttp.dispatch.StaticFile = {}

--- Creates a dispatcher that serves a static page
-- @param path to the file to serve
-- @param the content type
function vohttp.dispatch.StaticPage:new(body, content_type)
    return function(serve)
        local r = vohttp.response.Response:new()
        r.body = body
        if content_type then
            r.headers["Content-Type"] = content_type
        end

        return r
    end
end

--- Creates a dispatcher that serves a static file
-- @param path the path to the file to serve
-- @param the content type
function vohttp.dispatch.StaticFile:new(path, content_type)
    if not content_type then
        if path:match("css.lua$") then
            content_type = "text/css"
        elseif path:match("js.lua$") then
            content_type = "application/javascript"
        end
    end
    return vohttp.dispatch.StaticPage:new(dofile(path), content_type)
end
