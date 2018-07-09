# PANTSPARTY

A backdoor (public key) in the SSH daemon that allows EQGRP to connect to the server and it will spawn a root shell. Using existing non-root users and non-existing users are supported (it will all spawn a root shell). Logging has also be adapted so it either doesn't show up or it shows that the authentication failed.

From the [Snowden archive](https://snowdenarchive.cjfe.org/greenstone/collect/snowden1/index/assoc/HASH01b2/dc5bd489.dir/doc.pdf):

```
( T S / / S I / / R E L ) PANT SPARTY is a backdoor in the SSH daemon for
*NIX, based on OpenSSH portable. It allows a public key to be embedded
in the sshd binary and will then always grant a root login shell if
presented with the proper key pair for that key. In other words, it behaves
as if the given key is in ~/.ssh/authorized_keys.
( T S / / S I / / R E L ) Currently DSD uses authorized_keys as a quick-and-easy
method of persistence against certain *NIX targets. In most cases this
works, but it obviously isn't very stealthy and can run into problems if
that file is deleted or the SSH configuration changes to not use it. The goal
for this project was to provide the same level of persistence but embedded
in the sshd binary itself (obviously, assuming root access, as before).
( T S / / S I / / R E L ) By adding my own check in several key places within the
SSH code I was able to grant authorization to a key embedded in the
binary without too much trouble. The hard part came in granting that
user root privileges even if the configuration specifically banned root
login. That was achieved by setting a flag in the authorization context
within the server that essentially said "this is our backdoor, let it happen,
oh and stop logging also."
( T S / / S I / / R E L ) Then I wanted to have it so if you provide a normal
username as a login, it still grants you a root shell. SSH has a lot of checks
to make sure you can't switch usernames in the middle of a login (go
figure) so this was a bit tricky to bypass. Ultimately I was able to use the
same flag as the previous step, and just had to put checks for it in other
places.
( T S / / S I / / R E L ) More fun was to be had when I wanted to allow an
arbitrary username to be provided (i.e. one that doesn't exist on the
system) while still allowing for root login. This led to all sorts of problems
where I didn't even get a valid authorization context at all, and I couldn't
manually call the C function to get one for root because the connection is
a de-privileged child process, so I had to force-feed it a fake one for root.
Of course, the force-fed hash for root doesn't match the entry in passwd,
so I had to throw in another check there to return true if it's the backdoor.
And there's all sorts of fun happening with pre-auth where I had to revert
the authorization context back to its original value to postpone its
processing (a standard authorization step in some cases) and then
properly update it to root during the actual authorization step later on.
Once I got this working, however, a user is able to run "ssh
abcdefg@target" and the target's logs only show "Invalid username
abcdefg" without the follow-on message of "Accepted publickey for root
from 10.0.0.1 port 55000 ssh2". Presenting a valid username leads to the
only logged output being that the public key check failed.
( S / / S I / / R E L ) I set my new implant development PR on this project! My
previous record was 3 days for DIRTYDEEDS, but I finished this in 2.
Technically I had it working in a day, but it wasn't what I considered
releasable, so I'll have to wait for some other opportunity to present itself
so I can achieve the feat of an implant-in-a-day.
```
