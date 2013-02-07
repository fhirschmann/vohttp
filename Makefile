.PHONY: doc

out/vohttp_packed.lua: response.lua server.lua dispatch.lua test.lua request.lua main.lua lib/tcpsock.lua util.lua
	mkdir -p out
	tools/volupack vohttp main.lua out/vohttp_packed.lua

clean:
	rm -r out

doc:
	ldoc .
