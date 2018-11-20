TOPDIR = $(dir $(lastword $(MAKEFILE_LIST)))
RELEASE_VERSION ?= $(shell cat $(TOPDIR)/release.version)
DOCKER_TARGETS = docker_build docker_push docker_tag
DOCKER_TAG ?= latest

.PHONY: build clean release all $(DOCKER_TARGETS)

clean:
	./dep.sh clean

docker_build:
	./dep.sh docker_build

docker_tag:
	./dep.sh docker_tag

docker_push: docker_tag
	./dep.sh docker_push

all: docker_build docker_push

