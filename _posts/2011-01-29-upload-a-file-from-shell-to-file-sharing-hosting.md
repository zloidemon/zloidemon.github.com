---
layout:    post
title:     Upload a file from shell to file sharing hosting
tags:      [ zalil, upload, script, shell ]
permalink: /page/upload-a-file-from-shell-to-file-sharing-hosting
---

I often sharing my files with use a file hosting. :) But I don't like use a browser for it. Now I've wrote the function for my .zshrc.

```bash
function zalil(){
	if [ -n "$1" -a -f "$1" ];then
		if  [ "`du -k $1|awk '{print $1}'`"  -lt "51200" ];then
			curl -s -i -F "file"=@"$1" -F "submit=%20%20Send%20%20" \
				http://zalil.ru/upload/|grep Location \
				| sed "s/Location: /http://zalil.ru/"
		else
			echo file $1 is large
		fi
	else
		echo file $1 is empty
	fi
}
```
