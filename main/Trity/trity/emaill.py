#!/usr/bin/env python
import subprocess
import time
import platform
import random
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
import sys
import os
import optparse
def spoof_email():
	def send_email_text(email,password,from_address,to_address,message,subject,sender_name):
		print info("Spoofing Header")
		msg = MIMEMultipart()
		msg['From'] = sender_name + '<'+from_address+'>'
		msg['To'] = to_address
		msg['Subject'] = subject
		print info("Building Message")
		body = str(message)
		msg.attach(MIMEText(body, 'plain'))
		text = msg.as_string()
		print info("Connecting to mail server")
		s = smtplib.SMTP('smtp.mail.com:587')
		print info("Starting TLS & Sending EHLO Request.")
		s.starttls()
		s.ehlo()
		print info("Logging into mail server")
		s.login(email,password)
		print info("Sending Spoofed Message...")
		time.sleep(1)
		s.sendmail(email,to_address,text)
		time.sleep(1)
		try:
			s.quit()
		except:
			s.close()
		print good("Spoofed Message successfully sent")
		exit(0)		

	def send_email_html(email,password,from_address,to_address,message,subject,sender_name):
		print info("Spoofing Header...")
		msg = MIMEMultipart()
		msg['From'] = sender_name + '<'+from_address+'>'
		msg['To'] = to_address
		msg['Subject'] = subject
		print info("Constructing Message...")
		body = str(message)
		msg.attach(MIMEText(body, 'html'))
		text = msg.as_string()
		print info("Connecting to smtp.mail.com")
		s = smtplib.SMTP('smtp.mail.com:587')
		print info("Starting TLS and sending EHLO request")
		s.starttls()
		s.ehlo()
		print info("Logging into mail server")
		s.login(email,password)
		print info("Sending spoofed message...")
		time.sleep(1)
		s.sendmail(email,to_address,text)
		time.sleep(1)
		try:
			s.quit()
		except:
			s.close()
		print good("Spoofed Message successfully sent")

#Defaults
	recv = 'empty_value'
	sender = 'empty_value'
	sname = 'empty_value'
	msg = 'empty'
	subject = 'empty_value'
	while True:
		try:
		
			sender_name = raw_input(que("Sender Name: "))
		
			receiver = raw_input(que("Receiving email: "))
			
			sender = raw_input(que("Email to spoof from: "))
	
			msg_file = raw_input(que("Message file: "))
			f = open(msg_file, 'r')
			msg = f.read().strip()
	
			subject = raw_input(que("Subject: "))
			print info("Would you like to use the built in credentials? Or your own mail.com credentials?")
			creds = raw_input(que("[mine/default]: "))
			if creds == "mine":
				email = raw_input(que("Your email:"))
				password = raw_input(que("Your password:"))
			else:
				email="toxictestemail@mail.com"
				password="@Toxic123"
			from_address = sender
			to_address = receiver
			message = msg
			html_or_text = raw_input(que("HTML or text: "))
			if html_or_text == "text":
				send_email_text(email,password,from_address,to_address,message,subject,sender_name)
			else:
				send_email_html(email,password,from_address,to_address,message,subject,sender_name)

		except KeyboardInterrupt:
			print('\n')
			try:
				exit(0)
			except:
				sys.exit(1)
		except:
			raise
