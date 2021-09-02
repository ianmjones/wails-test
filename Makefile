APP = wails-test
VERSION = 0.1.0
ID = com.ianmjones.$(APP)
BIN = build/$(APP)
BACKEND_SRC = $(wildcard *.go)
FRONTEND_SRC = \
	$(wildcard frontend/*.js) \
	$(wildcard frontend/*.json) \
	$(wildcard frontend/public/*.*) \
	$(wildcard frontend/src/*.*) \
	$(wildcard frontend/src/components/*.svelte)
TGZ = $(APP)-$(VERSION).tgz
FLATPAK_MANIFEST = flatpak/$(ID).yml
SNAPCRAFT_YAML = snap/snapcraft.yaml

.PHONY: all tgz clean clean-all

#
# By default, just build the binary.
#
$(BIN): $(BACKEND_SRC) $(FRONTEND_SRC)
	wails build

all: $(BIN) tgz flatpak snap

#
# Just tar gz the binary.
#
tgz: $(TGZ)

$(TGZ): $(BIN)
	tar -C build -czvf $@ $(^F)

#
# Targets for building a Flatpak.
#
.PHONY: flatpak flatpak-run flatpak-install flatpak-clean flatpak-clean-all

flatpak: $(FLATPAK_MANIFEST) $(BIN)
	flatpak-builder .flatpak-tmp $< --force-clean

flatpak-run: $(FLATPAK_MANIFEST) $(BIN) flatpak
	flatpak-builder --run .flatpak-tmp $< $(APP)

flatpak-install: $(FLATPAK_MANIFEST) $(BIN)
	flatpak-builder .flatpak-tmp $< --user --install --force-clean

flatpak-clean:
	rm -rf .flatpak-tmp

flatpak-clean-all: flatpak-clean
	rm -rf .flatpak-builder

#
# Targets for building a snap.
#
# By default uses multipass VM for building.
# You can instead use something like the following to use LXD instead:
# SNAPCRAFT_BUILD_ENVIRONMENT=lxd make snap
#
# Always want to use LXD?
# export SNAPCRAFT_BUILD_ENVIRONMENT=lxd
#
.PHONY: snap snap-debug snap-prime-shell snap-clean snap-clean-all

snap: $(SNAPCRAFT_YAML) $(BACKEND_SRC) $(FRONTEND_SRC)
	snapcraft

#
# If the build fails you'll be dropped into the VM or container.
#
snap-debug: $(SNAPCRAFT_YAML) $(BACKEND_SRC) $(FRONTEND_SRC)
	snapcraft --debug

#
# Useful for poking around in VM or container
# to see what's going to be in the snap.
#
snap-prime-shell:
	snapcraft prime --shell-after

snap-clean:
	rm -f *.snap

#
# !!! Will remove associated VM or container !!!
#
snap-clean-all: snap-clean
	snapcraft clean

#
# Clean output files.
#
clean: flatpak-clean snap-clean
	rm -rf build frontend/public/build $(TGZ)

#
# !!! Clean output files and *ALL* caches and intermediates !!!
#
clean-all: clean flatpak-clean-all snap-clean-all
	rm -rf frontend/node_modules
