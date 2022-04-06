---
layout: post
title: "kill command"
category: linux
tags: [kill, signal, pid]
---

### [Kill Commands In Linux](https://www.baeldung.com/linux/kill-commands)


##  SIGTERM (15)
The default behavior of kill is to send the SIGTERM signal to a process, by which we ask that process to gracefully shutdown.

As it’s the default behavior, we can call kill the process by simply providing its PID:

```
kill 123
```


To explicitly send the SIGTERM signal we use:

```
kill -s SIGTERM 123
```


We can shorten it further by using the signal id:

```
kill -15 123
```

In the following examples, we’ll be using this short format so we can get familiar with the numerical values.

## SIGQUIT (3)
Sending a process the SIGQUIT signal is the same as asking it to shutdown with SIGTERM. The difference is that SIGQUIT makes the OS perform what is called a core dump:

```
kill -3 123
```

The core dump is a snapshot of the working memory of the process at the time we sent the kill signal and by default will be written to the current working directory.

We can use core dumps for debugging purposes.

Note that while quitting is the default behavior, Java is an example of a process that doesn’t quit with a SIGQUIT, it only does a core dump.

##  SIGKILL (9)
By choice of the programmer, processes don’t have to respond to every signal.

In such a case, or for processes that are hogging CPU for example, we can force it to terminate using the SIGKILL signal:

```
kill -9 123
```

With SIGKILL we ask the kernel to immediately shut down the process. The process dies and won’t clean up after itself.

This means there is a risk of data loss or even worse, data corruption.

Now, while SIGTERM, SIGQUIT and SIGKILL are certainly the most common, we’ve got one more signal to look at: SIGSTOP.

## SIGSTOP (19)
Unlike the name might suggest, the SIGSTOP signal will not terminate a process. It is the equivalent of stopping and putting a process in the background with ctrl+z.

We stop a program with:

```
kill -19 123
```

## SIGCONT (18):
The process can be resumed by sending the continue signal SIGCONT (18):

```
kill -18 123
```


