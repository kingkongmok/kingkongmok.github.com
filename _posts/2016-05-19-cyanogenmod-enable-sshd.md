---
title: "CyanogenMod enable sshd"
layout: post
category: android
---

## [引用](http://cromwell-intl.com/technical/samsung-galaxy/ssh.html)

---

## Set Up Authorized User Public Keys

```
# mkdir /data/.ssh
# chmod 700 /data/.ssh
# chown shell:shell /data/.ssh 
```

```
Linux$ adb push ~/.ssh/authorized_keys /data/.ssh/ 
```

```
# cd /data/.ssh
# chown shell:shell *
# chmod 600 * 
```

---

## Configure the SSH Server

```
# cd /data/ssh
# cp /system/etc/ssh/sshd_config .
# chmod 600 sshd_config
# vim sshd_config 
```

有关密钥，这里一共修改了4个地方,其中 ***PasswordAuthentication*** 和 ***ChallengeResponseAuthentication*** 的原因是禁止[手工输入密码](https://blog.tankywoo.com/linux/2013/09/14/ssh-passwordauthentication-vs-challengeresponseauthentication.html)

***PubkeyAuthentication***的原因是开启rsa认证

```
# diff -u /system/etc/ssh/sshd_config /data/ssh/sshd_config                                            
--- /system/etc/ssh/sshd_config
+++ /data/ssh/sshd_config
@@ -11,6 +11,7 @@
 # default value.
 
 #Port 22
+Port 55022
 #AddressFamily any
 #ListenAddress 0.0.0.0
 #ListenAddress ::
@@ -43,6 +44,7 @@
 
 #RSAAuthentication yes
 #PubkeyAuthentication yes
+PubkeyAuthentication yes
 
 # The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
 # but this is overridden so installations will only check .ssh/authorized_keys
@@ -62,10 +64,13 @@
 
 # To disable tunneled clear text passwords, change to no here!
 #PasswordAuthentication yes
+PasswordAuthentication no
 #PermitEmptyPasswords no
+PermitEmptyPasswords no
 
 # Change to no to disable s/key passwords
 #ChallengeResponseAuthentication yes
+ChallengeResponseAuthentication no
 
 # Kerberos options
 #KerberosAuthentication no
```

---

## Start the SSH Server at Boot Time

```
# mkdir /data/local/userinit.d
# cd /data/local/userinit.d
# cp /system/bin/start-ssh 99sshd
# chmod 755 99sshd
# vim 99sshd 
```
