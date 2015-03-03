---
layout: post
title: "Linux获取Nikon相机的照片"
category: Linux
tags: [Linux, DSLR]
---
{% include JB/setup %}

***(refer)[http://www.dpreview.com/forums/thread/2945968]***

###[examples](http://www.gphoto.org/doc/manual/using-gphoto2.html)###

```
$ gphoto2 --list-ports
Devices found: 2
Path                             Description
--------------------------------------------------------------
ptpip:                           PTP/IP Connection               
usb:001,010                      Universal Serial Bus            
```

```
$ gphoto2 --list-files
There is no file in folder '/'.                                                
There is no file in folder '/store_00010001'.
There is no file in folder '/store_00010001/DCIM'.
There are 102 files in folder '/store_00010001/DCIM/100D3300'.
#1     DSC_0004.JPG               rd  5847 KB 4496x3000 image/jpeg
#2     DSC_0006.JPG               rd  4950 KB 4496x3000 image/jpeg
#3     DSC_0007.JPG               rd  4565 KB 4496x3000 image/jpeg
#4     DSC_0008.JPG               rd  4511 KB 4496x3000 image/jpeg
#5     DSC_0009.JPG               rd  4515 KB 4496x3000 image/jpeg
```

```
$ gphoto2 --get-all-files
Downloading 'DSC_0004.JPG' from folder '/store_00010001/DCIM/100D3300'...      
Saving file as DSC_0004.JPG                                                    
Downloading 'DSC_0006.JPG' from folder '/store_00010001/DCIM/100D3300'...
Saving file as DSC_0006.JPG                                                    
Downloading 'DSC_0007.JPG' from folder '/store_00010001/DCIM/100D3300'...
Saving file as DSC_0007.JPG                                                    
Downloading 'DSC_0008.JPG' from folder '/store_00010001/DCIM/100D3300'...
Saving file as DSC_0008.JPG                                                    
Downloading 'DSC_0009.JPG' from folder '/store_00010001/DCIM/100D3300'...
Saving file as DSC_0009.JPG                                  
```
