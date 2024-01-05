#
# Makefile for freddie project
#

# Set the default shell
SHELL := bash

# Get script version
APP_VERSION := 	$(shell ./freddie version)

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
	@echo

.PHONY: git-release

git-release: git-check git-tag
	git push
	git push origin $(APP_VERSION)

.PHONY: git-tag

git-tag:
	git tag -a $(APP_VERSION) -m 'Version $(APP_VERSION)'

.PHONY: git-check-branch

git-checkout-branch:
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
	@if git status --porcelain > /dev/null; then \
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
