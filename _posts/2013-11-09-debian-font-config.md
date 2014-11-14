---
layout: post
title: "debian font config 在Debian的X下的config设置"
category: linux
tags: [debian, font, config]
---
{% include JB/setup %}

##这个是在家里squeeze的设置，是根据ubuntu10.04做出修改的。

**69-language-selector-zh-cn.conf**

{% highlight bash %}
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<match target="pattern">
		<test qual="any" name="family">
			<string>serif</string>
		</test>
		<edit name="family" mode="prepend" binding="strong">
			<string>DejaVu Serif</string>
			<string>Bitstream Vera Serif</string>
			<string>HYSong</string>
			<string>AR PL UMing CN</string>
			<string>AR PL UMing HK</string>
			<string>AR PL ShanHeiSun Uni</string>
			<string>AR PL New Sung</string>
			<string>WenQuanYi Bitmap Song</string>
			<string>AR PL UKai CN</string>
			<string>AR PL ZenKai Uni</string>
		</edit>
	</match> 
	<match target="pattern">
		<test qual="any" name="family">
			<string>sans-serif</string>
		</test>
		<edit name="family" mode="prepend" binding="strong">
			<string>DejaVu Sans</string>
			<string>Bitstream Vera Sans</string>
			<string>WenQuanYi Micro Hei</string>
			<string>WenQuanYi Zen Hei</string>
			<string>Droid Sans Fallback</string>
			<string>HYSong</string>
			<string>AR PL UMing CN</string>
			<string>AR PL UMing HK</string>
			<string>AR PL ShanHeiSun Uni</string>
			<string>AR PL New Sung</string>
			<string>AR PL UKai CN</string>
			<string>AR PL ZenKai Uni</string>
		</edit>
	</match> 
	<match target="pattern">
		<test qual="any" name="family">
			<string>monospace</string>
		</test>
		<edit name="family" mode="prepend" binding="strong">
			<string>DejaVu Sans Mono</string>
			<string>Bitstream Vera Sans Mono</string>
			<string>WenQuanYi Micro Hei Mono</string>
			<string>WenQuanYi Zen Hei Mono</string>
			<string>Droid Sans Fallback</string>
			<string>HYSong</string>
			<string>AR PL UMing CN</string>
			<string>AR PL UMing HK</string>
			<string>AR PL ShanHeiSun Uni</string>
			<string>AR PL New Sung</string>
			<string>AR PL UKai CN</string>
			<string>AR PL ZenKai Uni</string>
		</edit>
	</match> 
</fontconfig>
{% endhighlight %}

**99-language-selector-zh.conf**

{% highlight bash %}
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<match target="font" >
		<test name="family" compare="contains" >
			<string>Song</string>
			<string>Sun</string>
			<string>Kai</string>
			<string>Ming</string>
		</test> 
                <!-- check to see if the font is just regular -->
                <test name="weight" compare="less_eq">
                        <int>100</int>
		</test>
		<test compare="more_eq" target="pattern" name="weight" >
			<int>180</int>
		</test>
		<edit mode="assign" name="embolden" >
			<bool>true</bool>
		</edit>
	</match>
</fontconfig>
{% endhighlight %}

**其他调用的文件**

{% highlight bash %}
kk@kk:/tmp/etc/fonts/conf.d$ ls
10-antialias.conf                 65-fonts-persian.conf
10-autohint.conf                  65-nonlatin.conf
10-hinting.conf                   69-language-selector-zh-cn.conf
10-hinting-full.conf              69-unifont.conf
20-fix-globaladvance.conf         70-no-bitmaps.conf
20-unhint-small-vera.conf         80-delicious.conf
25-ttf-arphic-uming-render.conf   85-xfonts-wqy.conf
30-defoma.conf                    90-synthetic.conf
30-metric-aliases.conf            90-ttf-arphic-ukai-embolden.conf
30-urw-aliases.conf               90-ttf-arphic-uming-embolden.conf
35-ttf-arphic-uming-aliases.conf  90-ttf-bengali-fonts.conf
40-nonlatin.conf                  90-ttf-devanagari-fonts.conf
41-ttf-arphic-uming.conf          90-ttf-gujarati-fonts.conf
44-wqy-zenhei.conf                90-ttf-kannada-fonts.conf
45-latin.conf                     90-ttf-malayalam-fonts.conf
49-sansserif.conf                 90-ttf-oriya-fonts.conf
50-user.conf                      90-ttf-punjabi-fonts.conf
51-local.conf                     90-ttf-tamil-fonts.conf
53-monospace-lcd-filter.conf      90-ttf-telugu-fonts.conf
60-latin.conf                     99-language-selector-zh.conf
64-ttf-arphic-uming.conf          README
{% endhighlight %}
