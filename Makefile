##
# Makefile to build featmap from source
##
.DEFAULT_GOAL := featmap
VERSION       := $(shell git describe --abbrev=0 --tags)
NODE_VERSION  := 16
GOOS          := linux
GOARCH        := arm64

.PHONY: deps
deps:
	@echo "Check npm"
	@command -v npm
	@echo "Check go-bindata"
	@command -v go-bindata
	@echo "Check go"
	@command -v go
	@echo "Node version $(NODE_VERSION)"
	@node -v | grep '^v$(NODE_VERSION)\.'

.PHONY: deps-oci
deps-oci:
	@echo "Check Docker binary"
	@command -v docker

.PHONY: webapp
webapp: deps
	@echo "Build webapp"
	@cd webapp && npm install && npm run build;

.PHONY: assets
assets: deps
	@echo "Generate static assets"
	cd migrations; go-bindata -pkg migrations .
	go-bindata -pkg tmpl -o ./tmpl/bindata.go ./tmpl/
	go-bindata -pkg webapp -o ./webapp/bindata.go ./webapp/build/...

.PHONY: featmap
featmap: webapp assets
	@echo "Build Featmap go binary"
	export GOOS=$(GOOS); export GOARCH=$(GOARCH); go build -o bin/featmap;

.PHONY: oci
oci:
	@echo "Build OCI"
	docker build -t featmap .
