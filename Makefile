#!/bin/bash

.PHONY: mac ubuntu

mac:
	cd mac && bash install.sh

set_ubuntu:
	cd ubuntu ; \
	bash set_dotfiles.sh ; \
	bash set_alactritty.sh
