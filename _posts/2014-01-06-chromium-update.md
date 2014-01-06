---
layout: post
title: "chromium update"
category: linux
tags: [gentoo, chromium, update, perl]
---
{% include JB/setup %}

##安装错误

今天在升级chromium的时候出现一下错误：
FAILED: cd ../../third_party/WebKit/Source/bindings; perl -w -Iscripts -I../core/scripts -I../../../../third_party/JSON/out/lib/perl5 scripts/generate_bindings.pl --outputDir ../../../../out/Release/gen/blink/bindings --idlAttributesFile scripts/IDLAttributes.txt --include ../core --include ../modules --include ../../../../out/Release/gen/blink --interfaceDependenciesFile ../../../../out/Release/gen/blink/InterfaceDependencies.txt --additionalIdlFiles "../core/testing/GCObservation.idl ../core/testing/Internals.idl ../core/testing/InternalProfilers.idl ../core/testing/InternalSettings.idl ../core/testing/LayerRect.idl ../core/testing/LayerRectList.idl ../core/testing/MallocStatistics.idl ../core/testing/TypeConversions.idl \"../../../../out/Release/gen/blink/InternalSettingsGenerated.idl\" \"../../../../out/Release/gen/blink/InternalRuntimeFlags.idl\"" --preprocessor "/usr/bin/gcc -E -P -x c++" --write-file-only-if-changed 1 "../core/css/FontFaceSet.idl"

irc上有同学指出是perl的版本过低，需要更新perl或者JSON

**perl-cleaner --reallyall**

其中需要确认JSON和perl的版本一致，提供的检测命令可以为`qlist -e JSON`
