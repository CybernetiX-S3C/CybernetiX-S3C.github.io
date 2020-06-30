#
# Regular cron jobs for the kali-db package
#
0 4	* * *	root	[ -x /usr/bin/kali-db_maintenance ] && /usr/bin/kali-db_maintenance
