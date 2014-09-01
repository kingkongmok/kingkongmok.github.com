---
layout: post
title: "gentoo install jekyll"
category: linux
tags: [gentoo, ruby, jekyll, rake, git, blog]
---
{% include JB/setup %}

##rake的安装

**首先需要安装rake用来写帖子，**

{% highlight bash %}
sudo emerge dev-ruby/rake
{% endhighlight %}

##安装ruby和rubygems

{% highlight bash %}
sudo emerge dev-lang/ruby
sudo emerge dev-ruby/rubygems
{% endhighlight %}

##设置ruby

{% highlight bash %}
kk@gentoo /etc/fonts $ sudo equery list "*" | grep gem
dev-ruby/rubygems-2.0.3
virtual/rubygems-1
virtual/rubygems-4
virtual/rubygems-6
kk@gentoo /etc/fonts $ sudo equery uses rubygems
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for dev-ruby/rubygems-2.0.3:
 U I
 - - ruby_targets_jruby  : Build with JRuby
 + + ruby_targets_ruby18 : Build with MRI Ruby 1.8.x
 + + ruby_targets_ruby19 : Build with MRI Ruby 1.9.x
 + + ruby_targets_ruby20 : Build with MRI Ruby 2.0.x
 - - server              : Install support for the rubygems server
 - - test                : Workaround to pull in packages needed to run with FEATURES=test.
                           Portage-2.1.2 handles this internally, so don't set it in
                           make.conf/package.use anymore
{% endhighlight %}

## 选择ruby版本。

{% highlight bash %}
kk@gentoo ~/workspace/kingkongmok.gibub.com $ eselect ruby list
Available Ruby profiles:
  [1]   ruby18 (with Rubygems)
  [2]   ruby19 (with Rubygems) *
  [3]   ruby20 (with Rubygems)
kk@gentoo ~/workspace/kingkongmok.gibub.com $ sudo eselect ruby set 2
Successfully switched to profile:
  ruby19              
{% endhighlight %}

##不选择版本出异常。

{% highlight bash %}
kk@gentoo ~/workspace $ sudo gem install jekyll

Building native extensions.  This could take a while...
ERROR:  Error installing jekyll:
ERROR: Failed to build gem native extension.

    /usr/bin/ruby18 extconf.rb
checking for ffi_call() in -lffi... yes
checking for ffi_prep_closure()... yes
checking for ffi_raw_call()... yes
checking for ffi_prep_raw_closure()... yes
checking for rb_thread_blocking_region()... no
checking for rb_thread_call_with_gvl()... no
checking for rb_thread_call_without_gvl()... no
checking for ffi_prep_cif_var()... yes
creating extconf.h
creating Makefile

make  clean

...

.h\"    -fPIC -O2 -pipe -fno-strict-aliasing  -fPIC  -I/usr/lib64/libffi-3.0.11/include   -c ClosurePool.c
x86_64-pc-linux-gnu-gcc -shared -o ffi_c.so Call.o Function.o StructByReference.o Type.o DataConverter.o Types.o StructLayout.o MappedType.o ArrayType.o LastError.o MemoryPointer.o Struct.o AbstractMemory.o Pointer.o Variadic.o Platform.o DynamicLibrary.o LongDouble.o ffi.o MethodHandle.o StructByValue.o FunctionInfo.o Buffer.o Thread.o ClosurePool.o -L. -L/usr/lib64 -Wl,-R/usr/lib64 -L. -Wl,-O1 -Wl,--as-needed -rdynamic -Wl,-export-dynamic -Wl,--no-undefined     -Wl,-R -Wl,/usr/lib64 -L/usr/lib64 -lruby18 -lffi  -lffi  -lrt -ldl -lcrypt -lm   -lc
Thread.o: In function `rbffi_blocking_thread':
Thread.c:(.text+0xb1): undefined reference to `pthread_testcancel'
Thread.o: In function `cleanup_blocking_thread':
Thread.c:(.text+0x109): undefined reference to `pthread_kill'
Thread.o: In function `rbffi_frame_current':
Thread.c:(.text+0x12b): undefined reference to `pthread_getspecific'
Thread.o: In function `rbffi_frame_push':
Thread.c:(.text+0x18b): undefined reference to `pthread_getspecific'
Thread.c:(.text+0x1d4): undefined reference to `pthread_setspecific'
Thread.o: In function `rbffi_thread_blocking_region':
Thread.c:(.text+0x28e): undefined reference to `pthread_create'
Thread.c:(.text+0x2c4): undefined reference to `pthread_join'
Thread.o: In function `rbffi_Thread_Init':
Thread.c:(.text+0x35f): undefined reference to `pthread_key_create'
collect2: error: ld returned 1 exit status
make: *** [ffi_c.so] Error 1
{% endhighlight %}

今天重新设置的时候，出现一个javascript无法解析的异常
{% highlight bash %}
kk@ins14 ~/workspace/kingkongmok.github.com $ jekyll server
/usr/local/lib64/ruby/gems/1.9.1/gems/execjs-2.2.1/lib/execjs/runtimes.rb:51:in `autodetect': Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs for a list of available runtimes. (ExecJS::RuntimeUnavailable)
    from /usr/local/lib64/ruby/gems/1.9.1/gems/execjs-2.2.1/lib/execjs.rb:5:in `<module:ExecJS>'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/execjs-2.2.1/lib/execjs.rb:4:in `<top (required)>'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/coffee-script-2.3.0/lib/coffee_script.rb:1:in `<top (required)>'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/coffee-script-2.3.0/lib/coffee-script.rb:1:in `<top (required)>'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-coffeescript-1.0.1/lib/jekyll-coffeescript.rb:2:in `<top (required)>'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-2.3.0/lib/jekyll/deprecator.rb:46:in `block in gracefully_require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-2.3.0/lib/jekyll/deprecator.rb:44:in `each'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-2.3.0/lib/jekyll/deprecator.rb:44:in `gracefully_require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-2.3.0/lib/jekyll.rb:141:in `<top (required)>'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/lib64/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:53:in `require'
    from /usr/local/lib64/ruby/gems/1.9.1/gems/jekyll-2.3.0/bin/jekyll:6:in `<top (required)>'
    from /usr/local/bin/jekyll:23:in `load'
    from /usr/local/bin/jekyll:23:in `<main>'
{% endhighlight %}

[解决方法](http://jekyllrb.com/docs/troubleshooting/)
{% highlight bash %}
kk@ins14 ~ $ sudo emerge -pv nodejs

These are the packages that would be merged, in order:

Calculating dependencies... done!
[ebuild  N     ] net-libs/nodejs-0.10.30  USE="npm snapshot" 13,211 kB

Total: 1 package (1 new), Size of downloads: 13,211 kB
{% endhighlight %}
安装后正常.

