.PHONY: doc clean

VERSION := $(shell grep VERSION main.lua | sed -e 's/    VERSION=$"//' -e 's/$",//')

out/vohttp_packed.lua: response.lua server.lua dispatch.lua request.lua main.lua lib/tcpsock.lua util.lua
	mkdir -p out
	tools/volupack vohttp main.lua out/vohttp_packed.lua

release: out/vohttp_packed.lua
	rm -rf _release
	mkdir -p _release/vohttp-$(VERSION)
	cp out/vohttp_packed.lua _release/vohttp-$(VERSION)/vohttp_packed.lua
	git checkout-index -f -a --prefix=_release/vohttp/
	cd _release/vohttp && ldoc .
	mv _release/vohttp/doc _release/vohttp-$(VERSION)/
	rm -rf _release/vohttp
	cd _release && zip -r vohttp-$(VERSION).zip vohttp-$(VERSION)
	cd _release && gpg --armor --detach-sign vohttp-$(VERSION).zip
	cd _release && tar cvzf vohttp-$(VERSION).tar.gz vohttp-$(VERSION)
	cd _release && gpg --armor --detach-sign vohttp-$(VERSION).tar.gz

release-upload: release
	ssh 0x0b.de mkdir -p /var/www/vohttp.0x0b.de/htdocs/releases/
	rsync -avz --delete -e ssh _release/* srv:/var/www/vohttp.0x0b.de/htdocs/releases/

clean:
	rm -r out

doc:
	ldoc .
