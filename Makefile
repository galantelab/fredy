#
# Makefile for freddie project
#

# Set the default shell
SHELL := bash

# Where I am
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Variables used during the installation
PREFIX ?= /usr/local
PROJECT_NAME := freddie
INSTALL_DIR = $(DESTDIR)$(PREFIX)/share/$(PROJECT_NAME)
BIN_DIR = $(DESTDIR)$(PREFIX)/bin

# Get script version
APP_VERSION := $(shell ./bin/freddie --version)

# Get VCS latest tag
VCS_VERSION := $(shell git describe --abbrev=0 --tags)

# Only release from this branch
VCS_MAIN_BRANCH := main

# Get the current branch
VCS_BRANCH := $(shell git branch --show-current)

# Test if we are inside the main branch
ifeq ($(VCS_BRANCH),$(VCS_MAIN_BRANCH))
VCS_IS_MAIN_BRANCH := 1
else
VCS_IS_MAIN_BRANCH := 0
endif

# Our image name
DOCKER_IMG := galantelab/freddie

# Set latest or dev to docker image accordig
# to the branch
DOCKER_TAG := $(if $(VCS_IS_MAIN_BRANCH),latest,dev)


.DEFAULT_GOAL := help

.PHONY: help

help:
	@echo "Makefile for freddie project"
	@echo ""
	@echo "==> Installation"
	@echo "install            Install freddie"
	@echo "uninstall          Uninstall freddie"
	@echo ""
	@echo "==> Manage git"
	@echo "git-check-status   Check if the wordir is dirty"
	@echo "git-check-version  Check if there is a new version"
	@echo "git-check-branch   Check if this is the main branch"
	@echo "git-check          Check status, version and branch"
	@echo "git-tag            Tag the new version"
	@echo "git-release        Release the new tagged version"
	@echo ""
	@echo "==> Manage docker"
	@echo "docker-build       Build a docker image"
	@echo "docker-tag         Tag the docker image version"
	@echo "docker-release     Push docker image to registry"
	@echo ""

.PHONY: install

install:
	mkdir -p $(INSTALL_DIR) $(BIN_DIR)
	cp -r --preserve=mode $(ROOT_DIR)/{bin,lib,scripts} $(INSTALL_DIR)
	ln -s $(INSTALL_DIR)/bin/* $(BIN_DIR)

.PHONY: uninstall

uninstall:
	rm -rf $(INSTALL_DIR)
	rm -f $(addprefix $(BIN_DIR)/, $(notdir $(wildcard $(ROOT_DIR)/bin/*)))

.PHONY: git-release

git-release: git-check git-tag
	git push
	git push origin $(APP_VERSION)

.PHONY: git-tag

git-tag:
	git tag -a $(APP_VERSION) -m 'Version $(APP_VERSION)'

.PHONY: git-check-branch

git-check-branch:
	@if [[ "$(VCS_IS_MAIN_BRANCH)" -eq 1 ]]; then \
		echo I only release from $(VCS_MAIN_BRANCH); \
		echo Use 'git checkout $(VCS_MAIN_BRANCH)' before release; \
	fi

.PHONY: git-check

git-check: git-check-status git-check-version git-check-branch

.PHONY: git-check-version

git-check-version:
	@if [[ "$(APP_VERSION)" == "$(VCS_VERSION)" ]]; then \
		echo There is already a git tag for the version $(APP_VERSION); \
		false; \
	fi

.PHONY: git-check-status

git-check-status:
	@if git status --porcelain | grep -qE '^ *[M?]+'; then \
		echo The working tree is dirty or has untracked files; \
		echo Use 'git status' for more details; \
		false; \
	fi

.PHONY: docker-release

docker-release: git-check docker-build docker-tag
	docker login
	docker push $(DOCKER_IMG):$(DOCKER_TAG)
	docker push $(DOCKER_IMG):$(APP_VERSION)
	docker logout

.PHONY: docker-tag

docker-tag:
	docker tag $(DOCKER_IMG):$(DOCKER_TAG) $(DOCKER_IMG):$(APP_VERSION)

.PHONY: docker-build

docker-build:
	docker build -t $(DOCKER_IMG):$(DOCKER_TAG) .
