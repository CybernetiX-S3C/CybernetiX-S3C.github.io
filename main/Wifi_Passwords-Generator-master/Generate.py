#!/usr/bin/env python 2.7.11
import os
import sys
import time


def Ask():
	os.system('rm Big.txt')
	os.system('clear')
	Essid1 = str(raw_input('Enter The First Essid Of The Network: ')) 
	Essid  = str(raw_input('\nEnter The Second Essid Of The Network: '))
	Area   = 'True'#str(raw_input('\nEnter The Area: '))
	Generate(Essid1,Essid,Area)

def Generate(F,L,C):
	Passlist = open('Big.txt','a')
	os.system('clear')
	def First():
		for i in range(99):
			Passlist.write('%s%d\n'%(F.lower(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(F.upper(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(F.title(),i))



		#

		for i in range(99,999):
			Passlist.write('%s%d\n'%(F.title(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(F.lower(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(F.upper(),i))

	def Last():
		Passlist = open('Big.txt','a')
		for i in range(99):
			Passlist.write('%s%d\n'%(L.lower(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(L.upper(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(L.title(),i))



		#

		for i in range(99,999):
			Passlist.write('%s%d\n'%(L.title(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(L.lower(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(L.upper(),i))

	def Comb():
		Passlist = open('Big.txt','a')
		Cm = (F+L)
		
		for i in range(99,999):
			Passlist.write('%s%d\n'%(Cm.title(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(Cm.lower(),i))

		for i in range(99,999):
			Passlist.write('%s%d\n'%(Cm.upper(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(Cm.lower(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(Cm.upper(),i))

		for i in range(99):
			Passlist.write('%s%d\n'%(Cm.title(),i))
		

	def Area():
		os.system('clear')
		if os.path.exists('Phone.lst') is False:
			pass #os.system('crunch 10 10 1234567890 -t 619%%%%%%% -d 2 -o Phone.lst')
	if len(F) != 0:
		First()
	if len(L) != 0 and L.lower() != F.lower():
		Last()
	if len(C) != 0:
		Area()
	if len(F) != 0 and len(L) != 0 and L.lower() != F.lower():
		Comb()
	
			
		
if __name__=='__main__':
	Ask();os.system('clear')
	print '[-] Done'	


