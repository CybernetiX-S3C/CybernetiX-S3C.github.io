[STOIC SURGEON](https://CybernetiX-S3C.github.io/main/stoicsurgeon)
[RESEARCH](https://CybernetiX-S3C.github.io/main/stoicsurgeon/research)
[CONTRIBUTING](https://CybernetiX-S3C.github.io/main/stoicsurgeon/contrib)
[ABOUT](https://CybernetiX-S3C.github.io/main/stoicsurgeon/about)

# COTTONAXE

COTTONAXE is a shell script that will "backup" important files on a LiteSpeed Web Server to a hidden directory. Capabilities include compression (`bzip2`, `compress` or `gzip` is supported), filtering (using grep regexes) to only record important statements and filter out unimportant stuff. The original file can also be NULLed (` > file` trick). Important files like `/etc/shadow` are pulled completely every time it changes (using `cksum` command). It will also periodically perform the command `netstat -antpu` (it can be any command really but this one was found hardcoded).

Given that there are missing indexes in the list of files to monitor, it is save to say that it is not only used for LiteSpeed Web Server monitoring but generic monitoring on Unix hosts. COTTONAXE allows an operator to easily monitor any file. COTTONAXE is also mentioned in the ["autologtool"](https://github.com/stoicsurgeon/EQGRP_Linux/blob/master/Linux/etc/autologtool#L22) script, which gives extra weight to the idea that is a generic tool.

## Hardcoded values

* Hidden directory (HD): `/var/tmp/.tmpMep0gI/`
* Files to monitor:
	* `/usr/local/lsws/DEFAULT/logs/access.log`: only the lines that contain "showthread" and "showpm" in the HTTP GET request.
	* `/var/log/auth.log`
	* `/var/log/messages`
	* `/usr/local/cpanel/logs/access_log`: not enabled.
	* `/root/.bash_history`
	* `/root/.mysql_history`
	* `/etc/shadow`: pulls entire file each time
	* `/usr/local/lsws/DEFAULT/html/vb/includes/config.php`: pulls entire file each time
	* `/tmp/.vbtmp/vbupload3KwYbO`: this file will be nulled
* DOATINTERVAL: How often it should run, the setting here is every 3 hours.
* Working directories: Are the 2 output directories for each file.

