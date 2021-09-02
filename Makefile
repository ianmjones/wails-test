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
SNAPCRAFT_YAML := snap/snapcraft.yaml

.PHONY: tgz flatpak run-flatpak install-flatpak snap snap-prime-shell clean clean-all

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

snap: $(SNAPCRAFT_YAML) $(BACKEND_SRC) $(FRONTEND_SRC)
	snapcraft --use-lxd

snap-debug: $(SNAPCRAFT_YAML) $(BACKEND_SRC) $(FRONTEND_SRC)
	snapcraft --use-lxd --debug

snap-prime-shell:
	snapcraft prime --shell-after --use-lxd

snap-clean:
	snapcraft clean --use-lxd

clean:
	rm -rf $(APP).tgz build frontend/public/build .flatpak-tmp *.snap

clean-all: clean
	rm -rf frontend/node_modules .flatpak-builder
