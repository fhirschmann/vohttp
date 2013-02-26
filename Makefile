.PHONY: doc clean

VERSION := $(shell grep VERSION main.lua | sed -e 's/    VERSION=$"//' -e 's/$",//')

out/vohttp_packed.lua: response.lua server.lua dispatch.lua request.lua main.lua lib/tcpsock.lua util.lua
	mkdir -p out
	tools/volupack vohttp main.lua out/vohttp_packed.lua

release: out/vohttp_packed.lua
	rm -rf _release
	mkdir _release
	cp out/vohttp_packed.lua _release/vohttpd_packed-$(VERSION).lua

release-upload: release
	scp _release/vohttpd_packed-$(VERSION).lua 0x0b.de:/var/www/vohttp.0x0b.de/htdocs/releases

clean:
	rm -r out

doc:
	ldoc .
