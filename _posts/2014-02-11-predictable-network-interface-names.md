---
layout: post
title: "Predictable Network Interface Names"
category: linux
tags: [udev, gentoo, interface, network]
---
{% include JB/setup %}


##What precisely has changed in v197?

With systemd 197 we have added native support for a number of different naming policies into systemd/udevd proper and made a scheme similar to biosdevname's (but generally more powerful, and closer to kernel-internal device identification schemes) the default. The following different naming schemes for network interfaces are now supported by udev natively:

+ Names incorporating Firmware/BIOS provided index numbers for on-board devices (example: eno1)
+ Names incorporating Firmware/BIOS provided PCI Express hotplug slot index numbers (example: ens1)
+ Names incorporating physical/geographical location of the connector of the hardware (example: enp2s0)
+ Names incorporating the interfaces's MAC address (example: enx78e7d1ea46da)
- Classic, unpredictable kernel-native ethX naming (example: eth0)
