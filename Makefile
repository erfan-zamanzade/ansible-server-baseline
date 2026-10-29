# Molecule runs everything in local containers; nothing here connects to a
# real server. DISTRO is one of debian13, ubuntu2404, ubuntu2604.
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help
DISTRO ?= ubuntu2404
DISTROS := debian13 ubuntu2404 ubuntu2604

help: ## Show targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

tools: ## Install uv, the Python virtualenv and Ansible collections into the repo
	scripts/install-tools.sh

lint: ## yamllint, ansible-lint, syntax check, shellcheck, promtool, actionlint
	scripts/lint.sh

test-hardening: ## Molecule: baseline, firewall, SSH, fail2ban (DISTRO=...)
	scripts/molecule.sh hardening $(DISTRO)

test-site: ## Molecule: full site with Docker, app, nginx, backups, health check (DISTRO=...)
	scripts/molecule.sh site $(DISTRO)

test: ## Both scenarios on all three distributions, one after another
	@for d in $(DISTROS); do for s in hardening site; do scripts/molecule.sh $$s $$d || exit 1; done; done

converge: ## Keep an instance up for debugging: SCENARIO=site DISTRO=...
	scripts/molecule.sh $(or $(SCENARIO),site) $(DISTRO) converge

login: ## Shell into the debugging instance
	scripts/molecule.sh $(or $(SCENARIO),site) $(DISTRO) login

destroy: ## Remove the debugging instance
	scripts/molecule.sh $(or $(SCENARIO),site) $(DISTRO) destroy

.PHONY: help tools lint test-hardening test-site test converge login destroy
