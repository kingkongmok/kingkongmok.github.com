---
layout: post
title: "win7启动Virtualbox服务和子系统的ACPIShutdown"
category: linux
tags: [vbox, virtualbox, service, acpid]
---
{% include JB/setup %}

### virtualbox service on windows 7.

* [VirtualBoxService-v0.1](https://code.google.com/p/virtualboxservice/)，用于生成virtualbox的服务，经测试方便易用。
* 微软的方法需安装[AutoExNT Service](http://support.microsoft.com/kb/243486)，
* Oracle的建议使用第三方的控制[runasservice](http://sourceforge.net/projects/runasservice/)

### VirtualBoxService-v0.1 installation

* Download and extract to a folder of your choice
* Run virtualboxservice.exe and install using the GUI
* Open Virtualbox and add the following template to the description of the machines you wish to be controlled by VirtualBoxService:<!VirtualboxService--{"Autostart":"true", "ShutdownType":"ACPIShutdown", "ACPIShutdownTimeout": "300000"}--/VirtualboxService>
* Customize the parameters:
* Autostart: "true" or "false", defines, if the machine should be controlled
* ShutdownType: "ACPIShutdown", "SaveState" or "HardOff"
* ACPIShutdownTimeout: Milliseconds to wait for machine to shutdown once the ACPI-Command has been sent

* 其中`template to the description`，需要打开`D:\bin\VirtualBox\VirtualBox.exe`，并在需要启动的gentoo虚拟机上 - settings - description 中添加template.
* ACPIShutdown 需要虚拟机支持acpid。

### kernel for acpi

[acipd on gentoo](http://wiki.gentoo.org/wiki/ACPI)

目前的模块已经支持acpi，只需要安装acpid即可。

```
$ grep -i acpi .config | grep -vP ^#
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=m
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_CONTAINER=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_PNPACPI=y
CONFIG_ATA_ACPI=y
CONFIG_PATA_ACPI=m
CONFIG_DMA_ACPI=y
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
```

### acpid settings

/etc/acpi/default.sh中设置了power的行为。可以对应之前的description中的ACPIShutdown行为控制子系统。所以，安装acpid后只需要简单的update-rc即可。

```
$ perl -0777ne 'while(/(case.*?action.*?power.*?;;)/gs){print $1}' /etc/acpi/default.sh
case "$group" in
    button)
        case "$action" in
            power)
                /etc/acpi/actions/powerbtn.sh
                ;;
```
