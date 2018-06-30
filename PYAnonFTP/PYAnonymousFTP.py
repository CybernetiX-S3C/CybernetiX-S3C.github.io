import os
import time
import datetime
import socket
import random
import signal
import ipaddr

#import threading #WILL SUPPORT
#import ipaddr #GOOGLE SORCE CODE

#status = 0 # status of connection

def Menu():
#	global loggin
	global choice
	global verbose
	global net4
	print("\n\
		##############################\n\
		#     Anon and FTP checker   #\n\
		#        John Modica         #\n\
                #         CybernetiX         #\n\
		##############################\n\
	This tools is for scanning the net for FTP\n\
	Servers using FTP and anonymous connections.\n\
	\n\
	1)Use IP RANGE AND CONNECT and check for Anonymous logins.\n\
	2)WILL USE MASKING AND SUPPORT IN FUTURE\n\
	3)IP List Creator\n")
	#logging = str(raw_input("[*] Would you like to enable loging? Yes(Y) or No(N)"))   #Will Support Logging of data and what you want to store
	verbose = str(input("[*] Would you like it verbose or VV? Yes(Y) or VV(vv) or Enter for NO: "))
	if verbose == "yes" or verbose == "Yes" or verbose ==  "YES" or verbose == "y" or verbose == "Y" or verbose == "v":
		verbose = 1
		print(bcolors.Green + "[*] Verbose Activated", bcolors.ENDC)
	elif verbose == "VV" or verbose == "vv":
		verbose = 2
		print(bcolors.Green + "[*] VERY Verbose Activated", bcolors.ENDC)
	choice = str(input("[*] What would you like to do: "))
	return choice, #logging # will return loggin value
	
def ChoiceSelection():
	global status
	if choice == "1":
		if verbose == 1 or verbose == 2:
			print(bcolors.Green + "[*] Starting Ip Range Creation", bcolors.ENDC)
		#print "\nWhat is you network range you would like to scan using masking?"
		#print "Using classfull maksing:\n\
	#/8 = 255.0.0.0        ex. 192.0.0.0/8\n\
	#/16 = 255.255.0.0     ex. 192.168.0.0/16\n\
	#/24 = 255.255.255.0   ex. 192.168.1.0/24\n\
	#	Classless is also supported:\n\
	#/25 = 255.255.255.128 ex. 192.168.1.0/25 = .0 -> .127\n"
		#net4 = raw_input("[*]What is your IP: ")   #Still not working -- NEED TO CONVERT OUTPUT TO STRING
		#net4 = ipaddr.IPv4Network(net4)			#Still not working
		start_ip = input("[*] What is your start IP: ")
		end_ip = input("[*] What is your ending IP: ")
		ipRange(start_ip,end_ip)
		status = 0
		#port = []
		#port.append(21)
		#port.append(990)
		if verbose == 1 or verbose == 2:
			print(bcolors.Green + "[*] starting Port Scan", bcolors.ENDC)
		for address in ip_range:
			portscan(address,port)
			if status == 1:
				if verbose == 1 or verbose == 2:
					print(bcolors.Green + "[*] Starting Anonymous Login at:", address, bcolors.ENDC)
				AnonLogin(address,port)
			status = 0	
	if choice == "3":
		count = 0
		net4 = input("[*]What is your IP: ") 
		if verbose == 1 or verbose == 2:
			print(bcolors.Green + "[*] starting to open file as Ipaddress.txt", bcolors.ENDC)
		try:
			output = open("Ipaddress.txt" ,"ab+")
		except:
			print(bcolors.Red + "Could not make file!", bcolors.ENDC)
			main()
		net4 = ipaddr.IPv4Network(net4)
		if verbose == 1 or verbose == 2:
			print(bcolors.Green + "[*] starting to write IP's to file", bcolors.ENDC)
		for x in net4.iterhosts():  # will use this for masking
			count += 1
			k = x
			k = str(k)
			try:
				output.write(k + "\n");
			except:
				print(bcolors.Red + "Could not write to file!", bcolors.ENDC) 
				print(IOError)
				print("Returning home....")
				main()
		output.close()
		print(bcolors.Green + "[*] Saved as Ipaddress.txt in working DIR", bcolors.ENDC)
		print(bcolors.Green + "[*] Worte:", count, " IP's", bcolors.ENDC)
		
	main()

def signal_handler(signum, frame):
	raise Exception("Timed out!")
	

def ipRange(start_ip, end_ip):
   global ip_range
   start = list(map(int, start_ip.split(".")))
   end = list(map(int, end_ip.split(".")))
   temp = start
   ip_range = []
   ip_range.append(start_ip)
   while temp != end:
      start[3] += 1
      for i in (3, 2, 1):
         if temp[i] == 256:
            temp[i] = 0
            temp[i-1] += 1
      ip_range.append(".".join(map(str, temp)))    
   return ip_range

def AnonLogin(address,port):
	ftp=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	ftp.settimeout(9)
	try: 
		ftp.connect((address, port)); # passing it our address and port we want to connect to
		banner=ftp.recv(45)
		signal.signal(signal.SIGALRM, signal_handler)
		signal.alarm(3)
		try:
			banner += ftp.recv(1024) # receive the rest of the banner
		except: 
			pass
		if verbose == 1 or verbose ==2:
			print(banner)
		banner.replace("\r\n", ' ')
		ftp.send("USER anonymous\r\n")
		ftp.recv(1024)
		ftp.send("PASS anon@\r\n")
		response=ftp.recv(1024)
		if verbose == 1 or verbose == 2:
			print(response)
		try:
			if response.index("230")!=-1:
				status="Success"
				print(bcolors.Cyan + "$$$$$$--Money--$$$$$$", bcolors.ENDC)
				print("[*]", address, "is a", status, "at a Anonymous login on PORT:", port)
				eval(input("Press Enter to continue..."))
		except ValueError:
			status="Failure"
			if verbose == 1 or verbose == 2:
				print(bcolors.FAIL + "[*]", status, "at logging in at", address, bcolors.ENDC)
		else:
			print(status)
	except socket.error: # if we cant connect at all we will pass
		pass
	ftp.close()
	return

def portscan(address,port): # will perfrom a socket connection and if error detection is seen it will return status of 0
	global verbose
	global status
	status = 0
	port = [21] #still working this list / LOOP out but it works for now
	address = str(address)
	for portscan in port:
		try:
			s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			s.settimeout(1) #how long will we wait to hear for a connection "NEED TO ADD OPTION FOR THIS"
			s.connect((address,21))
			if verbose == 1 or verbose == 2:
				print(bcolors.Magenta + "[*]", address,"on: ",portscan,"is OPEN", bcolors.ENDC)
				if portscan == 990:
					print(bcolors.Magenta + "[-] Found a SFTP service possibly on", portscan, bcolors.ENDC)
			s.shutdown(socket.SHUT_RDWR)
			s.close
			status = 1
		except socket.error as msg: # we can print the caught error
			if verbose == 2:
				print(bcolors.Yellow +"[*]", msg, bcolors.ENDC)
				print(bcolors.Yellow + "[*] Failure on port:", portscan, "at:", address, bcolors.ENDC)
			err = True
		except: continue # if its not a socket error? Do i need this?
		finally: #insuring that the socket is closed to be reopened 
			s.close()
	return status
	
	
class bcolors:
	HEADER = '\033[95m'
	OKBLUE = '\033[94m'
	OKGREEN = '\033[92m'
	WARNING = '\033[93m'
	FAIL = '\033[91m'
	ENDC = '\033[0m'	
	Red = '\033[91m'
	Green = '\033[92m'
	Blue = '\033[94m'
	Cyan = '\033[96m'
	White = '\033[97m'
	Yellow = '\033[93m'
	Magenta = '\033[95m'
	Grey = '\033[90m'
	Black = '\033[90m'
	Default = '\033[99m'
	

def main():
	global choice
	global port
	global verbose
	global start_ip
	global end_ip
	print(bcolors.WARNING + "Warning: This will be used at your own risk scanning the web :)" + bcolors.ENDC)
	port = 21 # global port we want to check 
	Menu() #Print Menu
	ChoiceSelection() # What we do if we pick something

		

if __name__=="__main__":
    main()
