#!/bin/sh
sudo nice -n 19 emerge --sync && \
sudo nice -n 19 emerge --update --deep --with-bdeps=y --newuse @world && \
sudo nice -n 19 emerge @preserved-rebuild \
sudo nice -n 19 emerge --depclean && \
sudo nice -n 19 revdep-rebuild
