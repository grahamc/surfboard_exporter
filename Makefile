GO     := GO15VENDOREXPERIMENT=1 go
GOPATH := $(firstword $(subst :, ,$(GOPATH)))
PROMU  ?= $(GOPATH)/bin/promu
pkgs    = $(shell $(GO) list ./... | grep -v /vendor/)

PREFIX                  ?= $(shell pwd)
BIN_DIR                 ?= $(shell pwd)
DOCKER_IMAGE_NAME       ?= ipstatic/surfboard_exporter
DOCKER_IMAGE_TAG        ?= $(shell cat VERSION)

all: format vet crossbuild

style:
	@echo ">> checking code style"
	@! gofmt -d $(shell find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

format:
	@echo ">> formatting code"
	@$(GO) fmt $(pkgs)

vet:
	@echo ">> vetting code"
	@$(GO) vet $(pkgs)

build: $(PROMU)
	@echo ">> building binaries"
	@$(PROMU) build --prefix $(PREFIX)

crossbuild: $(PROMU)
	@echo ">> building binaries"
	@$(PROMU) crossbuild

tarball: $(PROMU)
	@echo ">> building release tarball"
	@$(PROMU) tarball --prefix $(PREFIX) $(BIN_DIR)

docker: crossbuild
	@echo ">> building docker image"
	@docker build -t "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" .

$(PROMU) promu:
	@GOOS= GOARCH= $(GO) get -u github.com/prometheus/promu

.PHONY: all style format vet build tarball docker promu
