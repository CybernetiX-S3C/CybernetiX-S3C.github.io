#!/usr/bin/env python3
# -*- coding:utf-8 -*- 
#
# @name   : E-ntel - Email Information Gathering
# @url    : http://github.com/CybernetiX-S3C
# @author : John Modica (CybernetiX S3C)

from lib.output import *
from lib.request import *
from lib.parser import *

class Google(Request):
	def __init__(self,target):
		Request.__init__(self)
		self.target = target

	def search(self):
		test('Searching "%s" in Google...'%(self.target))
		url = "https://www.google.it/search?num=1000&hl=en&q=%40{target}".format(
			target=self.target)
		try:
			resp = self.send(
				method = 'GET',
				url = url
				)
			return self.getemail(resp.content,self.target)
		except Exception as e:
			pass

	def getemail(self,content,target):
		return parser(content,target).email()