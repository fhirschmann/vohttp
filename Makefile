.PHONY: doc out pack

pack: main.lua
	mkdir -p out
	tools/volupack vohttp main.lua out/vohttp_packed.lua

clean:
	rm -r out

doc:
	ldoc .
