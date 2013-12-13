---
layout: post
title: "gentoo xfce4"
category: 
tags: []
---
{% include JB/setup %}


{% highlight bash %}
# emerge --ask xfce4-meta xfce4-notifyd

 * IMPORTANT: 7 news items need reading for repository 'gentoo'.
 * Use eselect news to read news items.


 * IMPORTANT: config file '/etc/portage/package.use' needs updating.
 * See the CONFIGURATION FILES section of the emerge
 * man page to learn how to update config files.

These are the packages that would be merged, in order:

Calculating dependencies... done!
[ebuild  N     ] dev-util/gperf-3.0.4 
[ebuild  N     ] media-libs/libogg-1.3.0  USE="-static-libs" 
[ebuild  N     ] app-text/sgml-common-0.6.3-r5 
[ebuild  N     ] app-text/poppler-data-0.4.6 
[ebuild  N     ] sys-power/pm-quirks-20100619 
[ebuild  N     ] dev-libs/libusb-1.0.9  USE="-debug -doc -static-libs" 
[ebuild  N     ] media-libs/libpng-1.5.17-r1  USE="apng (-neon) -static-libs" 
[ebuild  N     ] dev-libs/gobject-introspection-common-1.36.0 
[ebuild  N     ] virtual/libusb-1 
[ebuild  N     ] app-arch/rpm2targz-9.0.0.5g 
[ebuild  N     ] dev-libs/vala-common-0.22.1 
[ebuild  N     ] app-arch/zip-3.0-r1  USE="bzip2 crypt unicode -natspec" 
[ebuild  N     ] virtual/eject-0 
[ebuild  N     ] x11-themes/hicolor-icon-theme-0.12 
[ebuild  N     ] app-text/iso-codes-3.45 
[ebuild  N     ] app-text/docbook-xml-dtd-4.1.2-r6 
[ebuild  N     ] app-text/docbook-xml-dtd-4.2-r2 
[ebuild  N     ] app-admin/eselect-opengl-1.2.7 
[ebuild  N     ] app-admin/eselect-lib-bin-symlink-0.1.1 
[ebuild  N     ] app-admin/eselect-mesa-0.0.10 
[ebuild  N     ] app-admin/eselect-notify-send-0.1 
[ebuild  N     ] sys-libs/libcap-2.22  USE="pam" 
[ebuild  N     ] dev-util/desktop-file-utils-0.21  USE="-emacs" 
[ebuild  N     ] media-libs/libexif-0.6.21  USE="nls -doc -static-libs" 
[ebuild  N     ] dev-libs/libusb-compat-0.1.5  USE="-debug -static-libs" 
[ebuild  N     ] dev-libs/libcdio-0.83  USE="cxx -cddb -minimal -static-libs" 
[ebuild  N     ] virtual/libusb-0 
[ebuild  N     ] app-arch/libarchive-3.1.2-r1  USE="acl bzip2 e2fsprogs iconv lzma zlib -expat -lzo -nettle -static-libs -xattr" 
[ebuild  N     ] dev-util/gdbus-codegen-2.36.4-r1  PYTHON_TARGETS="python2_7 python3_3 -python2_6 -python3_2" 
[ebuild     U  ] dev-libs/glib-2.36.4-r1 [2.32.4-r1] PYTHON_TARGETS="python2_7%* -python2_6%" 
[ebuild  N     ] x11-misc/xdg-user-dirs-0.15  USE="gtk" 
[ebuild  N     ] x11-libs/libXext-1.3.2  USE="-doc -static-libs" 
[ebuild  N     ] sys-apps/dbus-1.6.12  USE="X -debug -doc (-selinux) -static-libs -systemd {-test}" 
[ebuild  N     ] dev-libs/dbus-glib-0.100.2  USE="-debug -doc -static-libs {-test}" 
[ebuild  N     ] x11-proto/damageproto-1.2.1-r1 
[ebuild  N     ] x11-libs/libXmu-1.1.2  USE="ipv6 -doc -static-libs" 
[ebuild  N     ] x11-proto/renderproto-0.11.1-r1 
[ebuild  N     ] x11-libs/libXrender-0.9.8  USE="-static-libs" 
[ebuild  N     ] media-libs/alsa-lib-1.0.27.1  USE="-alisp -debug -doc -python" PYTHON_SINGLE_TARGET="python2_7" PYTHON_TARGETS="python2_7" 
[ebuild  N     ] x11-proto/xf86vidmodeproto-2.3.1-r1 
[ebuild  N     ] dev-perl/LWP-MediaTypes-6.20.0 
[ebuild  N     ] dev-perl/XML-NamespaceSupport-1.110.0 
[ebuild  N     ] virtual/perl-Locale-Maketext-Simple-0.210.0-r2 
[ebuild  N     ] app-text/libpaper-1.1.24-r1 
[ebuild  N     ] x11-libs/libxkbfile-1.0.8  USE="-static-libs" 
[ebuild  N     ] x11-apps/xkbcomp-1.2.4 
[ebuild  N     ] dev-lang/nasm-2.10.07  USE="-doc" 
[ebuild  N     ] x11-proto/recordproto-1.14.2-r1  USE="-doc" 
[ebuild  NS    ] sys-devel/autoconf-2.13 [2.69]
[ebuild  N     ] x11-libs/libXxf86vm-1.1.3  USE="-static-libs" 
[ebuild  N     ] x11-proto/xf86miscproto-0.9.3 
[ebuild  N     ] dev-perl/Encode-Locale-1.30.0 
[ebuild  N     ] virtual/perl-File-Temp-0.220.0-r2 
[ebuild  N     ] xfce-base/libxfce4util-4.10.0  USE="-debug" 
[ebuild  N     ] xfce-base/xfconf-4.10.0  USE="-debug -perl" 
[ebuild  N     ] xfce-base/garcon-0.2.0  USE="-debug" 
[ebuild  N     ] x11-proto/compositeproto-0.4.2-r1 
[ebuild  N     ] media-libs/jbig2dec-0.11-r1  USE="png -static-libs {-test}" 
[ebuild  N     ] x11-libs/libfontenc-1.1.2  USE="-static-libs" 
[ebuild  N     ] x11-apps/mkfontscale-1.1.1 
[ebuild  N     ] x11-apps/mkfontdir-1.0.7 
[ebuild  N     ] media-fonts/encodings-1.0.4 
[ebuild  N     ] media-fonts/dejavu-2.33  USE="X -fontforge" 
[ebuild  N     ] virtual/ttf-fonts-1 
[ebuild  N     ] media-fonts/urw-fonts-2.4.9  USE="X" 
[ebuild  N     ] net-misc/curl-7.31.0  USE="ipv6 ldap ssl -adns -idn -kerberos -metalink -rtmp -ssh -static-libs {-test} -threads" CURL_SSL="openssl -axtls -cyassl -gnutls -nss -polarssl" 
[ebuild  N     ] dev-util/cmake-2.8.11.2  USE="ncurses -emacs -qt4 (-qt5) {-test} -vim-syntax" 
[ebuild  N     ] app-text/qpdf-4.1.0  USE="-doc -examples -static-libs {-test}" 
[ebuild  N     ] x11-apps/xprop-1.2.2 
[ebuild  N     ] x11-apps/xset-1.2.3 
[ebuild  N     ] x11-proto/randrproto-1.4.0-r1 
[ebuild  N     ] x11-libs/libXrandr-1.4.2  USE="-static-libs" 
[ebuild  N     ] x11-proto/fixesproto-5.0-r1 
[ebuild  N     ] x11-libs/libXfixes-5.0.1  USE="-static-libs" 
[ebuild  N     ] x11-libs/libXi-1.7.2  USE="-doc -static-libs" 
[ebuild  N     ] x11-libs/libXdamage-1.1.4-r1  USE="-static-libs" 
[ebuild  N     ] x11-libs/libXcursor-1.1.14  USE="-static-libs" 
[ebuild  N     ] x11-libs/libXcomposite-0.4.4-r1  USE="-doc -static-libs" 
[ebuild  N     ] media-gfx/graphite2-1.2.1  USE="-perl {-test}" 
[ebuild  N     ] x11-libs/pixman-0.32.4  USE="(-altivec) (-iwmmxt) (-loongson2f) -mmxext (-neon) -sse2 -ssse3 -static-libs" 
[ebuild  N     ] x11-misc/xkeyboard-config-2.9 
[ebuild  N     ] x11-proto/resourceproto-1.2.0 
[ebuild  N     ] x11-libs/libXres-1.0.7  USE="-static-libs" 
[ebuild  N     ] media-libs/flac-1.2.1-r3  USE="cxx ogg -3dnow (-altivec) -debug -sse -static-libs" 
[ebuild  N     ] media-libs/libvorbis-1.3.3  USE="-static-libs" 
[ebuild  N     ] media-libs/libsndfile-1.0.25  USE="alsa -minimal -sqlite -static-libs" 
[ebuild  N     ] x11-libs/libXtst-1.2.2  USE="-doc -static-libs" 
[ebuild  N     ] sys-block/parted-3.1-r1  USE="debug nls readline -device-mapper (-selinux) -static-libs {-test}" 
[ebuild  N     ] dev-libs/icu-51.2-r1  USE="-debug -doc -examples -static-libs" 
[ebuild  N     ] sys-apps/gptfdisk-0.8.6  USE="icu ncurses -static" 
[ebuild  N     ] dev-libs/nspr-4.10.2  USE="-debug" 
[ebuild  N     ] dev-lang/spidermonkey-1.8.5-r4  USE="-debug -minimal -static-libs {-test}" 
[ebuild  N     ] x11-apps/iceauth-1.0.6 
[ebuild  N     ] x11-apps/xrdb-1.1.0 
[ebuild  N     ] media-libs/libsamplerate-0.1.7  USE="-sndfile" 
[ebuild  N     ] media-sound/alsa-utils-1.0.27.1-r1  USE="libsamplerate ncurses nls -doc (-selinux)" 
[ebuild  N     ] dev-libs/libcroco-0.6.8  USE="{-test}" 
[ebuild  N     ] x11-libs/libXxf86misc-1.0.3  USE="-static-libs" 
[ebuild  N     ] x11-apps/xwininfo-1.1.3 
[ebuild  N     ] x11-apps/appres-1.0.4 
[ebuild  N     ] x11-proto/scrnsaverproto-1.2.2-r1  USE="-doc" 
[ebuild  N     ] dev-perl/Net-SSLeay-1.520.0 
[ebuild  N     ] dev-perl/HTML-Tagset-3.200.0 
[ebuild  N     ] dev-perl/HTML-Parser-3.690.0  USE="{-test}" 
[ebuild  N     ] media-libs/libjpeg-turbo-1.3.0  USE="-java -static-libs" 
[ebuild  N     ] virtual/jpeg-0  USE="-static-libs" 
[ebuild  N     ] media-libs/tiff-4.0.3-r4  USE="cxx jpeg zlib -jbig -lzma -static-libs" 
[ebuild  N     ] media-libs/lcms-2.5  USE="jpeg tiff zlib -doc -static-libs {-test}" 
[ebuild  N     ] media-libs/netpbm-10.51.00-r2  USE="X jpeg png tiff xml zlib -jbig -jpeg2k -rle -svga" 
[ebuild  N     ] perl-core/Time-Local-1.230.0 
[ebuild  N     ] virtual/perl-Time-Local-1.230.0 
[ebuild  N     ] dev-perl/HTTP-Date-6.20.0 
[ebuild  N     ] dev-perl/File-Listing-6.40.0 
[ebuild  N     ] perl-core/IO-1.25 
[ebuild  N     ] virtual/perl-IO-1.25 
[ebuild  N     ] perl-core/MIME-Base64-3.130.0 
[ebuild  N     ] virtual/perl-MIME-Base64-3.130.0-r2 
[ebuild  N     ] dev-perl/URI-1.600.0 
[ebuild  N     ] dev-perl/WWW-RobotRules-6.10.0 
[ebuild  N     ] perl-core/Compress-Raw-Bzip2-2.60.0 
[ebuild  N     ] virtual/perl-Compress-Raw-Bzip2-2.60.0 
[ebuild  N     ] perl-core/Compress-Raw-Zlib-2.60.0 
[ebuild  N     ] virtual/perl-Compress-Raw-Zlib-2.60.0 
[ebuild  N     ] perl-core/Scalar-List-Utils-1.270.0 
[ebuild  N     ] virtual/perl-Scalar-List-Utils-1.270.0 
[ebuild  N     ] dev-perl/IO-Socket-SSL-1.840.0  USE="-idn" 
[ebuild  N     ] perl-core/IO-Compress-2.60.0 
[ebuild  N     ] virtual/perl-IO-Compress-2.60.0 
[ebuild  N     ] dev-perl/Net-HTTP-6.60.0 
[ebuild  N     ] perl-core/Encode-2.470.0 
[ebuild  N     ] virtual/perl-Encode-2.470.0 
[ebuild  N     ] dev-perl/HTTP-Message-6.30.0 
[ebuild  N     ] dev-perl/HTTP-Cookies-6.0.0 
[ebuild  N     ] dev-perl/HTTP-Daemon-6.10.0 
[ebuild  N     ] dev-perl/HTTP-Negotiate-6.0.0 
[ebuild  N     ] perl-core/JSON-PP-2.272.0 
[ebuild  N     ] virtual/perl-JSON-PP-2.272.0-r1 
[ebuild  N     ] perl-core/CPAN-Meta-YAML-0.8.0 
[ebuild  N     ] virtual/perl-CPAN-Meta-YAML-0.8.0 
[ebuild  N     ] perl-core/Parse-CPAN-Meta-1.440.400 
[ebuild  N     ] virtual/perl-Parse-CPAN-Meta-1.440.400 
[ebuild  N     ] perl-core/version-0.990.100 
[ebuild  N     ] virtual/perl-version-0.990.100 
[ebuild  N     ] perl-core/CPAN-Meta-Requirements-2.122.0 
[ebuild  N     ] virtual/perl-CPAN-Meta-Requirements-2.122.0 
[ebuild  N     ] perl-core/Test-Simple-0.980.0 
[ebuild  N     ] virtual/perl-Test-Simple-0.980.0-r2 
[ebuild  N     ] perl-core/File-Spec-3.400.0 
[ebuild  N     ] virtual/perl-File-Spec-3.400.0 
[ebuild  N     ] perl-core/ExtUtils-Manifest-1.610.0 
[ebuild  N     ] virtual/perl-ExtUtils-Manifest-1.610.0 
[ebuild  N     ] perl-core/ExtUtils-Install-1.540.0 
[ebuild  N     ] virtual/perl-ExtUtils-Install-1.540.0 
[ebuild  N     ] perl-core/ExtUtils-Command-1.170.0 
[ebuild  N     ] virtual/perl-ExtUtils-Command-1.170.0-r3 
[ebuild  N     ] virtual/perl-libnet-1.230.0 
[ebuild  N     ] perl-core/digest-base-1.170.0 
[ebuild  N     ] virtual/perl-digest-base-1.170.0-r1 
[ebuild  N     ] perl-core/Digest-MD5-2.520.0 
[ebuild  N     ] virtual/perl-Digest-MD5-2.520.0 
[ebuild  N     ] x11-proto/dri2proto-2.8 
[ebuild  N     ] sys-devel/llvm-3.1-r2  USE="libffi -debug -gold -multitarget -ocaml {-test} -udis86 -vim-syntax" 
[ebuild  N     ] x11-proto/glproto-1.4.16 
[ebuild  N     ] x11-proto/xf86driproto-2.1.1 
[ebuild   R    ] dev-libs/libxml2-2.9.1-r1  USE="python*" PYTHON_TARGETS="python3_3* -python3_2*" 
[ebuild     U  ] sys-apps/kmod-15-r1 [13-r1] USE="openrc%*" 
[ebuild  N     ] dev-perl/XML-SAX-Base-1.80.0 
[ebuild  N     ] dev-perl/XML-SAX-0.990.0 
[ebuild  N     ] dev-perl/XML-LibXML-1.900.0  USE="{-test}" 
[ebuild  N     ] perl-core/Storable-2.390.0 
[ebuild  N     ] virtual/perl-Storable-2.390.0 
[ebuild  N     ] dev-perl/XML-Simple-2.200.0 
[ebuild  N     ] x11-misc/icon-naming-utils-0.8.90 
[ebuild  N     ] x11-themes/gnome-icon-theme-3.8.3  USE="branding" 
[ebuild  N     ] virtual/freedesktop-icon-theme-0 
[ebuild  N     ] perl-core/Test-Harness-3.260.0 
[ebuild  N     ] virtual/perl-Test-Harness-3.260.0 
[ebuild  N     ] virtual/perl-Package-Constants-0.20.0-r2 
[ebuild  N     ] virtual/perl-IO-Zlib-1.100.0-r2 
[ebuild  N     ] perl-core/Archive-Tar-1.900.0 
[ebuild  N     ] virtual/perl-Archive-Tar-1.900.0 
[ebuild  N     ] perl-core/Perl-OSType-1.2.0  USE="{-test}" 
[ebuild  N     ] virtual/perl-Perl-OSType-1.2.0-r1 
[ebuild  N     ] perl-core/Params-Check-0.360.0 
[ebuild  N     ] virtual/perl-Params-Check-0.360.0 
[ebuild  N     ] perl-core/Module-Metadata-1.0.11 
[ebuild  N     ] virtual/perl-Module-Metadata-1.0.11 
[ebuild  N     ] perl-core/Module-CoreList-2.840.0 
[ebuild  N     ] virtual/perl-Module-CoreList-2.840.0 
[ebuild  N     ] perl-core/Module-Load-0.240.0 
[ebuild  N     ] virtual/perl-Module-Load-0.240.0 
[ebuild  N     ] perl-core/Module-Load-Conditional-0.540.0 
[ebuild  N     ] virtual/perl-Module-Load-Conditional-0.540.0 
[ebuild  N     ] perl-core/IPC-Cmd-0.780.0 
[ebuild  N     ] virtual/perl-IPC-Cmd-0.780.0 
[ebuild  N     ] perl-core/ExtUtils-CBuilder-0.280.205 
[ebuild  N     ] virtual/perl-ExtUtils-CBuilder-0.280.205 
[ebuild  N     ] perl-core/ExtUtils-ParseXS-3.180.0 
[ebuild  N     ] virtual/perl-ExtUtils-ParseXS-3.180.0 
[ebuild  N     ] dev-libs/gobject-introspection-1.36.0-r1  USE="cairo -doctool {-test}" PYTHON_SINGLE_TARGET="python2_7" PYTHON_TARGETS="python2_7" 
[ebuild  N     ] x11-libs/gdk-pixbuf-2.28.2  USE="X introspection jpeg tiff -debug -jpeg2k {-test}" 
[ebuild  N     ] dev-libs/atk-2.8.0  USE="introspection nls {-test}" 
[ebuild  N     ] x11-libs/libxklavier-5.2.1  USE="introspection -doc" 
[ebuild  N     ] app-accessibility/at-spi2-core-2.8.0  USE="introspection" 
[ebuild  N     ] app-accessibility/at-spi2-atk-2.8.1  USE="{-test}" 
[ebuild  N     ] media-libs/fontconfig-2.10.92  USE="-doc -static-libs" 
[ebuild  N     ] app-admin/eselect-fontconfig-1.1 
[ebuild  N     ] x11-libs/libXft-2.3.1-r1  USE="-static-libs" 
[ebuild  N     ] x11-libs/xcb-util-0.3.9  USE="-doc -static-libs {-test}" 
[ebuild  N     ] x11-libs/xcb-util-wm-0.3.9  USE="-doc -static-libs {-test}" 
[ebuild  N     ] x11-libs/xcb-util-keysyms-0.3.9  USE="-doc -static-libs {-test}" 
[ebuild  N     ] x11-libs/xcb-util-renderutil-0.3.8  USE="-doc -static-libs {-test}" 
[ebuild  N     ] x11-libs/xcb-util-image-0.3.9  USE="-doc -static-libs {-test}" 
[ebuild  N     ] x11-libs/startup-notification-0.12  USE="-static-libs" 
[ebuild  N     ] sys-auth/polkit-0.112  USE="gtk introspection nls pam -examples -kde (-selinux) -systemd" 
[ebuild  N     ] sys-auth/consolekit-0.4.6  USE="acl pam policykit -debug -doc (-selinux) -systemd-units {-test}" 
[ebuild  N     ] x11-libs/libnotify-0.7.5-r1  USE="introspection -doc {-test}" 
[ebuild  N     ] dev-perl/libwww-perl-6.30.0  USE="ssl" 
[ebuild   R    ] sys-fs/udev-204  USE="gudev* hwdb* introspection*" 
[ebuild  N     ] sys-apps/hwids-20130329  USE="udev" 
[ebuild   R    ] virtual/udev-200  USE="gudev* hwdb* introspection*" 
[ebuild  N     ] dev-libs/libatasmart-0.19-r1  USE="-static-libs" 
[ebuild  N     ] sys-fs/udisks-2.1.0  USE="gptfdisk introspection -cryptsetup -debug (-selinux) -systemd" 
[ebuild  N     ] sys-apps/systemd-208-r2  USE="acl filecaps firmware-loader gudev introspection kmod pam policykit tcpd -audit -cryptsetup -doc -gcrypt -http -lzma -python -qrcode (-selinux) {-test} -vanilla -xattr" PYTHON_SINGLE_TARGET="python2_7" PYTHON_TARGETS="python2_7" 
[ebuild  N     ] sys-apps/gentoo-systemd-integration-2 
[ebuild     U  ] virtual/udev-208 [200] USE="gudev* introspection*" 
[ebuild  N     ] sys-apps/hwids-20130915.1  USE="udev" 
[ebuild  N     ] x11-libs/libpciaccess-0.13.2  USE="zlib -minimal -static-libs" 
[ebuild  N     ] app-laptop/radeontool-1.6.3 
[ebuild  N     ] sys-power/pm-utils-1.4.1-r2  USE="alsa -debug -ntp" VIDEO_CARDS="intel radeon" 
[ebuild  N     ] sys-power/upower-0.9.21  USE="introspection -doc -ios -systemd" 
[ebuild  N     ] x11-libs/libdrm-2.4.46  USE="-libkms -static-libs" VIDEO_CARDS="intel nouveau radeon vmware (-exynos) (-freedreno) (-omap)" 
[ebuild  N     ] media-libs/mesa-9.1.6  USE="bindist classic egl gallium llvm nptl shared-glapi -debug -gbm -gles1 -gles2 -openvg -osmesa -pax_kernel -pic (-r600-llvm-compiler) (-selinux) -vdpau (-wayland) -xa -xorg -xvmc" PYTHON_SINGLE_TARGET="python2_7 -python2_6" PYTHON_TARGETS="python2_7 -python2_6" VIDEO_CARDS="intel nouveau radeon vmware -i915 -i965 -r100 -r200 -r300 -r600 (-radeonsi)" 
[ebuild  N     ] x11-libs/cairo-1.12.14-r4  USE="X glib opengl svg xcb (-aqua) -debug -directfb -doc (-drm) (-gallium) (-gles2) -legacy-drivers -openvg (-qt4) -static-libs -valgrind -xlib-xcb" 
[ebuild  N     ] app-text/poppler-0.24.3  USE="cairo cxx introspection jpeg lcms png tiff utils -cjk -curl -debug -doc -jpeg2k -qt4" 
[ebuild  N     ] media-libs/harfbuzz-0.9.23  USE="cairo glib graphite truetype -icu -introspection -static-libs" 
[ebuild  N     ] x11-libs/pango-1.34.1  USE="X introspection -debug" 
[ebuild  N     ] virtual/opengl-7.0 
[ebuild  N     ] perl-core/ExtUtils-MakeMaker-6.640.0 
[ebuild  N     ] virtual/perl-ExtUtils-MakeMaker-6.640.0 
[ebuild  N     ] dev-perl/LWP-Protocol-https-6.30.0 
[ebuild  N     ] perl-core/CPAN-Meta-2.120.921 
[ebuild  N     ] virtual/perl-CPAN-Meta-2.120.921 
[ebuild  N     ] perl-core/Module-Build-0.400.300  USE="{-test}" 
[ebuild  N     ] virtual/perl-Module-Build-0.400.300 
[ebuild  N     ] dev-perl/File-BaseDir-0.30.0  USE="{-test}" 
[ebuild  N     ] dev-perl/File-DesktopEntry-0.40.0  USE="{-test}" 
[ebuild  N     ] dev-perl/File-MimeInfo-0.150.0  USE="{-test}" 
[ebuild  N     ] x11-misc/xdg-utils-1.1.0_rc1_p20130921  USE="perl -doc" 
[ebuild  N     ] net-print/cups-1.6.4  USE="X acl dbus filters pam ssl threads usb -debug -gnutls -java -kerberos -lprng-compat -python (-selinux) -static-libs -xinetd -zeroconf" LINGUAS="ca es fr ja ru" PYTHON_SINGLE_TARGET="python2_7 -python2_6" PYTHON_TARGETS="python2_7 -python2_6" 
[ebuild  N     ] x11-libs/gtk+-2.24.22  USE="cups introspection (-aqua) -debug -examples {-test} -vim-syntax -xinerama" 
[ebuild  N     ] app-text/ghostscript-gpl-9.05-r1  USE="X bindist cups dbus gtk -djvu -idn -jpeg2k -static-libs" LINGUAS="-ja -ko -zh_CN -zh_TW" 
[ebuild  N     ] net-print/cups-filters-1.0.36-r1  USE="jpeg png tiff -perl -static-libs -zeroconf" 
[ebuild  N     ] net-print/foomatic-filters-4.0.17  USE="cups dbus" 
[ebuild  N     ] x11-libs/gtk+-3.8.7  USE="X cups introspection (-aqua) -colord -debug -examples (-packagekit) {-test} -vim-syntax (-wayland) -xinerama" 
[ebuild  N     ] x11-misc/xdg-user-dirs-gtk-0.9 
[ebuild  N     ] gnome-extra/polkit-gnome-0.105 
[ebuild  N     ] xfce-base/libxfce4ui-4.10.0  USE="startup-notification -debug -glade" 
[ebuild  N     ] xfce-extra/xfce4-notifyd-0.2.2  USE="-debug" 
[ebuild  N     ] virtual/notification-daemon-0  USE="-gnome" 
[ebuild  N     ] xfce-base/exo-0.10.2  USE="-debug" 
[ebuild  N     ] x11-libs/libwnck-2.31.0  USE="introspection startup-notification -doc" 
[ebuild  N     ] net-wireless/bluez-4.101-r7  USE="alsa cups readline usb -debug -gstreamer -pcmcia (-selinux) -test-programs" PYTHON_SINGLE_TARGET="python2_7 -python2_6" PYTHON_TARGETS="python2_7 -python2_6" 
[ebuild  N     ] xfce-base/xfce4-appfinder-4.10.0-r1  USE="-debug" 
[ebuild  N     ] gnome-base/librsvg-2.39.0  USE="gtk introspection -tools -vala" 
[ebuild  N     ] x11-themes/gtk-engines-xfce-3.0.1-r200  USE="-debug" 
[ebuild  N     ] gnome-base/libglade-2.6.4  USE="-doc -static-libs {-test}" 
[ebuild  N     ] xfce-base/xfce4-panel-4.10.0-r1  USE="-debug" 
[ebuild  N     ] xfce-base/xfwm4-4.10.0-r1  USE="startup-notification xcomposite -debug" 
[ebuild  N     ] xfce-base/xfce4-settings-4.10.0  USE="libnotify xklavier -debug -libcanberra" 
[ebuild  N     ] dev-libs/openobex-1.5  USE="bluetooth usb -debug -irda -syslog" 
[ebuild  N     ] x11-misc/xscreensaver-5.22  USE="jpeg opengl pam perl -gdm -new-login (-selinux) -suid -xinerama" 
[ebuild  N     ] xfce-base/xfce4-session-4.10.0-r1  USE="consolekit policykit udev xscreensaver -debug -gnome-keyring" 
[ebuild  N     ] app-mobilephone/obex-data-server-0.4.6  USE="gtk usb -debug -imagemagick" 
[ebuild  N     ] gnome-base/gvfs-1.16.4  USE="bluetooth cdda gtk udev udisks -afp -archive -avahi -bluray -fuse -gdu -gnome-keyring -gnome-online-accounts -gphoto2 -http -ios -mtp -samba -systemd {-test}" 
[ebuild  N     ] xfce-base/thunar-1.6.2  USE="dbus exif libnotify pcre startup-notification udev -debug {-test}" XFCE_PLUGINS="trash" 
[ebuild  N     ] xfce-base/xfdesktop-4.10.2  USE="libnotify thunar -debug" 
[ebuild  N     ] xfce-base/xfce4-meta-4.10  USE="svg -minimal" 
[blocks B      ] sys-fs/udev ("sys-fs/udev" is blocking sys-apps/systemd-208-r2)
[blocks B      ] sys-apps/systemd ("sys-apps/systemd" is blocking sys-fs/udev-204)

!!! Multiple package instances within a single package slot have been pulled
!!! into the dependency graph, resulting in a slot conflict:

dev-libs/glib:2

  (dev-libs/glib-2.32.4-r1::gentoo, installed) pulled in by
    (no parents that aren't satisfied by other packages in this slot)

  (dev-libs/glib-2.36.4-r1::gentoo, ebuild scheduled for merge) pulled in by
    >=dev-libs/glib-2.36.4:2 required by (dev-util/gdbus-codegen-2.36.4-r1::gentoo, ebuild scheduled for merge)
    (and 6 more with the same problem)

sys-apps/hwids:0

  (sys-apps/hwids-20130915.1::gentoo, ebuild scheduled for merge) pulled in by
    >=sys-apps/hwids-20130717-r1[udev] required by (sys-apps/systemd-208-r2::gentoo, ebuild scheduled for merge)

  (sys-apps/hwids-20130329::gentoo, ebuild scheduled for merge) pulled in by
    <sys-apps/hwids-20130915[udev] required by (sys-fs/udev-204::gentoo, ebuild scheduled for merge)

dev-libs/libxml2:2

  (dev-libs/libxml2-2.9.1-r1::gentoo, ebuild scheduled for merge) pulled in by
    dev-libs/libxml2[python,python_targets_python2_6(-)?,python_targets_python2_7(-)?,python_single_target_python2_6(+)?,python_single_target_python2_7(+)?] required by (media-libs/mesa-9.1.6::gentoo, ebuild scheduled for merge)

  (dev-libs/libxml2-2.9.1-r1::gentoo, installed) pulled in by
    (no parents that aren't satisfied by other packages in this slot)

virtual/udev:0

  (virtual/udev-200::gentoo, ebuild scheduled for merge) pulled in by
    =virtual/udev-200 required by (sys-fs/udev-204::gentoo, ebuild scheduled for merge)
    (and 9 more with the same problem)

  (virtual/udev-208::gentoo, ebuild scheduled for merge) pulled in by
    >=virtual/udev-206 required by (sys-apps/hwids-20130915.1::gentoo, ebuild scheduled for merge)

sys-apps/kmod:0

  (sys-apps/kmod-15-r1::gentoo, ebuild scheduled for merge) pulled in by
    >=sys-apps/kmod-14-r1 required by (sys-apps/systemd-208-r2::gentoo, ebuild scheduled for merge)

  (sys-apps/kmod-13-r1::gentoo, installed) pulled in by
    (no parents that aren't satisfied by other packages in this slot)


It may be possible to solve this problem by using package.mask to
prevent one of those packages from being selected. However, it is also
possible that conflicting dependencies exist such that they are
impossible to satisfy simultaneously.  If such a conflict exists in
the dependencies of two different packages, then those packages can
not be installed simultaneously. You may want to try a larger value of
the --backtrack option, such as --backtrack=30, in order to see if
that will solve this conflict automatically.

For more information, see MASKED PACKAGES section in the emerge man
page or refer to the Gentoo Handbook.


 * Error: The above package list contains packages which cannot be
 * installed at the same time on the same system.

  (sys-apps/systemd-208-r2::gentoo, ebuild scheduled for merge) pulled in by
    >=sys-apps/systemd-208:0/1[abi_x86_32(-)?,abi_x86_64(-)?,abi_x86_x32(-)?,abi_mips_n32(-)?,abi_mips_n64(-)?,abi_mips_o32(-)?,gudev?,introspection?,kmod?,selinux?,static-libs(-)?] (>=sys-apps/systemd-208:0/1[abi_x86_32(-),gudev,introspection,kmod]) required by (virtual/udev-208::gentoo, ebuild scheduled for merge)
    >=sys-apps/systemd-207 required by (sys-apps/gentoo-systemd-integration-2::gentoo, ebuild scheduled for merge)

  (sys-fs/udev-204::gentoo, ebuild scheduled for merge) pulled in by
    >=sys-fs/udev-200[gudev?,hwdb?,introspection?,keymap?,kmod?,selinux?,static-libs?] (>=sys-fs/udev-200[gudev,hwdb,introspection,kmod]) required by (virtual/udev-200::gentoo, ebuild scheduled for merge)


For more information about Blocked Packages, please refer to the following
section of the Gentoo Linux x86 Handbook (architecture is irrelevant):

http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?full=1#blocked


The following USE changes are necessary to proceed:
 (see "package.use" in the portage(5) man page for more details)
# required by sys-fs/udisks-2.1.0
# required by gnome-base/gvfs-1.16.4[udisks]
# required by xfce-base/thunar-1.6.2[dbus,xfce_plugins_trash]
# required by xfce-base/xfdesktop-4.10.2[thunar]
# required by xfce-base/xfce4-meta-4.10
# required by xfce4-meta (argument)
=virtual/udev-200 hwdb
# required by virtual/udev-200
# required by gnome-base/gvfs-1.16.4[udev]
# required by xfce-base/thunar-1.6.2[dbus,xfce_plugins_trash]
# required by xfce-base/xfdesktop-4.10.2[thunar]
# required by xfce-base/xfce4-meta-4.10
# required by xfce4-meta (argument)
=sys-fs/udev-204 hwdb

Use --autounmask-write to write changes to config files (honoring
CONFIG_PROTECT). Carefully examine the list of proposed changes,
paying special attention to mask or keyword changes that may expose
experimental or unstable packages.
{% endhighlight %}
