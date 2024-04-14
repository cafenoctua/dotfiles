#!/bin/bash

.PHONY: set_ubuntu
set_ubuntu:
	cd ubuntu ; \
	bash set_dotfiles.sh ; \
	bash set_alactritty.sh