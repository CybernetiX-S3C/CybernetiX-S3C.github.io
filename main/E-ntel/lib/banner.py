#!/usr/bin/env python3
# -*- coding:utf-8 -*- 
#
# @name   : E-ntel - Email Information Gathering
# @url    : http://github.com/CybernetiX-S3C
# @author : John Modica (CybernetiX S3C)

from lib.colors import *

class Banner:
	def banner(self):
		print("_"*40)
		print(" E-ntel - Email Information Gathering")
		print("\tJohn Modica (CybernetiX S3C)")
		print("      %shttps://github.com/CybernetiX-S3C%s"%(Y%0,E))
		print("_"*40 + "\n")

	def usage(self,_exit_=False):
		self.banner()
		print("Usage: E-ntel.py [OPTIONS]\n")
		print("\t-d --domain\tTarget URL/Name")
		print("\t-s --source\tSource data, default \"all\":\n")
		print("\t\tall\tUse all search engine")
		print("\t\tgoogle\tUse google search engine")
		print("\t\tbing\tUse bing search engine")
		print("\t\tyahoo\tUse yahoo search engine")
		print("\t\task\tUse ask search engine")
		print("\t\tbaidu\tUse baidu search engine")
		print("\t\tdogpile\tUse dogpile search engine")
		print("\t\texalead\tUse exalead search engine")
		print("\t\tpgp\tUse pgp search engine\n")
		print("\t-b --breach\tCheck if email breached")
		print("\t-i --info\tGet email informations")
		print("\t-v --verbose\tVerbosity level (1,2 or 3)")
		print("\t-H --help\tShow this help and exit\n")
		print("Example:")
		print("\tE-ntel.py --domain site.gov -v 3")
		print("\tE-ntel.py --info admin@site.gov -v 3")
		print("\tE-ntel.py --domain site.gov --breach -v 3")
		print("\tE-ntel.py --info admin@site.gov --breach -v 3")
		print("\tE-ntel.py --domain site.gov --source google -v 3\n")
		if _exit_: exit(0)
