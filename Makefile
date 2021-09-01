APP := wails-test
ID := com.ianmjones.$(APP)
BIN := build/$(APP)
BACKEND_SRC := $(wildcard *.go)
FRONTEND_SRC := \
	$(wildcard frontend/*.js) \
	$(wildcard frontend/*.json) \
	$(wildcard frontend/public/*.*) \
	$(wildcard frontend/src/*.*) \
	$(wildcard frontend/src/components/*.svelte)
FLATPAK_MANIFEST := flatpak/$(ID).yml

.PHONY: tgz flatpak run-flatpak install-flatpak clean clean-all

$(BIN): $(BACKEND_SRC) $(FRONTEND_SRC)
	wails build

tgz: $(APP).tgz

$(APP).tgz: $(BIN)
	tar -C build -czvf $@ $(^F)

flatpak: $(FLATPAK_MANIFEST) $(BIN)
	flatpak-builder .flatpak-tmp $< --force-clean

run-flatpak: $(FLATPAK_MANIFEST) $(BIN) flatpak
	flatpak-builder --run .flatpak-tmp $< $(APP)

install-flatpak: $(FLATPAK_MANIFEST) $(BIN)
	flatpak-builder .flatpak-tmp $< --user --install --force-clean

clean:
	rm -rf $(APP).tgz build frontend/public/build .flatpak-tmp

clean-all: clean
	rm -rf frontend/node_modules .flatpak-builder
