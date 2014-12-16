#!/bin/sh
sudo nice -n 19 emerge --sync && \
sudo nice -n 19 emerge --update --deep --with-bdeps=y --newuse @world && \
sudo nice -n 19 emerge --depclean && \
sudo nice -n 19 revdep-rebuild

if [ -d "/usr/portage/packages" ] ; then
    sudo nice eclean -C -q packages 
fi

sudo nice eclean -C -q -d -t1w distfiles
