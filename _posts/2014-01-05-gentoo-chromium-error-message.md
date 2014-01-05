---
layout: post
title: "gentoo chromium error message"
category: linux
tags: [gentoo, error]
---
{% include JB/setup %}

MLBaseElement.idl"
FAILED: cd ../../third_party/WebKit/Source/bindings; perl -w -Iscripts -I../core/scripts -I../../../../third_party/JSON/out/lib/perl5 scripts/generate_bindings.pl --outputDir ../../../../out/Release/gen/blink/bindings --idlAttributesFile scripts/IDLAttributes.txt --include ../core --include ../modules --include ../../../../out/Release/gen/blink --interfaceDependenciesFile ../../../../out/Release/gen/blink/InterfaceDependencies.txt --additionalIdlFiles "../core/testing/GCObservation.idl ../core/testing/Internals.idl ../core/testing/InternalProfilers.idl ../core/testing/InternalSettings.idl ../core/testing/LayerRect.idl ../core/testing/LayerRectList.idl ../core/testing/MallocStatistics.idl ../core/testing/TypeConversions.idl \"../../../../out/Release/gen/blink/InternalSettingsGenerated.idl\" \"../../../../out/Release/gen/blink/InternalRuntimeFlags.idl\"" --preprocessor "/usr/bin/gcc -E -P -x c++" --write-file-only-if-changed 1 "../core/html/HTMLBaseElement.idl"
Can't locate JSON.pm in @INC (@INC contains: scripts ../core/scripts ../../../../third_party/JSON/out/lib/perl5 /etc/perl /usr/local/lib64/perl5/5.16.3/x86_64-linux /usr/local/lib64/perl5/5.16.3 /usr/lib64/perl5/vendor_perl/5.16.3/x86_64-linux /usr/lib64/perl5/vendor_perl/5.16.3 /usr/local/lib64/perl5 /usr/lib64/perl5/vendor_perl /usr/lib64/perl5/5.16.3/x86_64-linux /usr/lib64/perl5/5.16.3 .) at scripts/idl_serializer.pm line 38.
BEGIN failed--compilation aborted at scripts/idl_serializer.pm line 38.
Compilation failed in require at scripts/generate_bindings.pl line 34.
BEGIN failed--compilation aborted at scripts/generate_bindings.pl line 34.
ninja: build stopped: subcommand failed.
 * ERROR: www-client/chromium-31.0.1650.63::gentoo failed (compile phase):
 *   (no error message)
 * 
 * Call stack:
 *     ebuild.sh, line  93:  Called src_compile
 *   environment, line 4803:  Called die
 * The specific snippet of code:
 *       ninja -C out/Release -v -j $(makeopts_jobs) ${ninja_targets} || die;
 * 
 * If you need support, post the output of `emerge --info '=www-client/chromium-31.0.1650.63::gentoo'`,
 * the complete build log and the output of `emerge -pqv '=www-client/chromium-31.0.1650.63::gentoo'`.
 * 
 * MemTotal:        3842816 kB
 * SwapTotal:       2449964 kB
 * 
 * The complete build log is located at '/var/tmp/portage/www-client/chromium-31.0.1650.63/temp/build.log'.
 * The ebuild environment file is located at '/var/tmp/portage/www-client/chromium-31.0.1650.63/temp/environment'.
 * Working directory: '/var/tmp/portage/www-client/chromium-31.0.1650.63/work/chromium-31.0.1650.63'
 * S: '/var/tmp/portage/www-client/chromium-31.0.1650.63/work/chromium-31.0.1650.63'

>>> Failed to emerge www-client/chromium-31.0.1650.63, Log file:

>>>  '/var/tmp/portage/www-client/chromium-31.0.1650.63/temp/build.log'

 * Messages for package sys-kernel/gentoo-sources-3.10.25:

 * If you are upgrading from a previous kernel, you may be interested
 * in the following document:
 *   - General upgrade guide: http://www.gentoo.org/doc/en/kernel-upgrade.xml

 * Messages for package www-client/chromium-31.0.1650.63:

 * bindist enabled: H.264 video support will be disabled.
 * ERROR: www-client/chromium-31.0.1650.63::gentoo failed (compile phase):
 *   (no error message)
 * 
 * Call stack:
 *     ebuild.sh, line  93:  Called src_compile
 *   environment, line 4803:  Called die
 * The specific snippet of code:
 *       ninja -C out/Release -v -j $(makeopts_jobs) ${ninja_targets} || die;
 * 
 * If you need support, post the output of `emerge --info '=www-client/chromium-31.0.1650.63::gentoo'`,
 * the complete build log and the output of `emerge -pqv '=www-client/chromium-31.0.1650.63::gentoo'`.
 * The complete build log is located at '/var/tmp/portage/www-client/chromium-31.0.1650.63/temp/build.log'.
 * The ebuild environment file is located at '/var/tmp/portage/www-client/chromium-31.0.1650.63/temp/environment'.
 * Working directory: '/var/tmp/portage/www-client/chromium-31.0.1650.63/work/chromium-31.0.1650.63'
 * S: '/var/tmp/portage/www-client/chromium-31.0.1650.63/work/chromium-31.0.1650.63'

 * GNU info directory index is up-to-date.


