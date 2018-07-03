# Date: 06/19/2017
# Author: John Modica @ CybernetiX S3C
# Description: Generates possible passwords
#
# imports
import os
import sys
import time
import urllib2
import subprocess

# current version
__version__ = 0.1

class Update(object):
 def __init__(self):
  self.vers = __version__
  self.html = None # src code
  self.file = '.code.txt' # hidden file for reading for updates
  self.code = 'https://github.com/CybernetiX-S3C/PassGen-master'

 def check(self):
  print 'Checking for an update ...'
  try:self.open()
  except:
   subprocess.call(['clear'])
   raw_input('Unable to update, please check your connection\n\n[Press Enter To Continue]')
   return
  self.fetch()
  self.read()
  self.remove()

 def remove(self):
  os.remove(self.file)

 def open(self):
  self.html = urllib2.urlopen(self.code).read()

 def fetch(self):
  with open(self.file,'w+') as fwrite:
   fwrite.write(self.html)

 def read(self):
  with open(self.file,'r') as fread:
   for line in fread:
    line = line.replace('\n','').split()
    if line:
     if line[0] == '__version__':
      try:
       if eval(line[2]) > self.vers:
        subprocess.call(['clear'])
        update = raw_input('Found an update, would you like to install it?\n\nEnter (y/n): ')
        if update:
         if update[0].lower() == 'y':self.update()
         return
      except:pass
   else:
    subprocess.call(['clear'])
    raw_input('No updates found\n\n[Press Enter To Continue]')

 def update(self):
  with open(sys.argv[0],'w') as fwrite:
   fwrite.write(self.html)
  subprocess.call(['clear'])
  raw_input('Restart program to install updates\n\n[Press Enter To Continue]')

class Generator(object):
 def __init__(self):
  self.list  = [] # holds numbers, don't mix with numbers or symbols
  self.word  = [] # holds words, mix with numbers and symbols
  self.file  = [] # the passwords to write
  self.symb  = ['!@#','!','@','#','!!!']
  self.l33t  = {'a':4,'b':8,'e':3,'g':9,'i':1,'l':1,'o':0,'s':5,'t':7,'z':2}
  self.nums  = [123,1234,143,1,2,3,69,6969,420,111,123456,321,12,23,24,34,2468]

 def now(self):
  return time.strftime('%m-%d-%Y_%I:%M:%S',time.localtime())

 def leet(self,word):
  locations = [ndex for ndex,letter in enumerate(word) if letter.lower() in self.l33t]
  leets = [''.join([str(self.l33t[letter.lower()]) if letter.lower() in self.l33t and ndex == num else letter for ndex,letter in enumerate(word)]) for num in locations]
  return [case for _leet in leets for case in self.cases(_leet)]

 def cases(self,word):
  # firstname, Firstname, FIRSTNAME
  return word.lower(),word,word.upper()

 def numbers(self,word):
  # firstname123
  return ['{}{}'.format(''.join(word),num) for word in self.cases(word) for num in self.nums]

 def symbols(self,word):
  # firstname!@#
  return ['{}{}'.format(''.join(word),sym) for word in self.cases(word) for sym in self.symb]

 def comb(self,word):
  # firstname123!@#
  return ['{}{}{}'.format(''.join(word),num,sym) for word in self.cases(word) for num in self.nums for sym in self.symb]

 def default(self,essid,bssid):
  # default passkey on routers
  return '{}{}{}'.format(essid[:-2],''.join([k for i,k in enumerate(bssid) if any([i==9,i==10,i==12,i==13])]),essid[-2:])

 def writefile(self):
  with open('wordlist-{}.lst'.format(self.now()),'w') as fwrite:
   for item in self.file:
    fwrite.write('{}\n'.format(item))

 def generate(self):
  print 'please wait ...'
  self.file = self.list if self.list else self.file
  for word in self.word:
   # generate passwords
   leet = self.leet(word)
   self.file.append(word)
   self.file = self.file + [_leet for _leet in leet] # leet style
   self.file = self.file + list(set([num for _leet in leet for num in self.numbers(_leet)])) # leet with number
   self.file = self.file + list(set([sym for _leet in leet for sym in self.symbols(_leet)])) # leet with symbols
   self.file = self.file + list(set([comb for _leet in leet for comb in self.comb(_leet)])) # leet with num & symbols
   self.file = self.file + [num for num in self.numbers(word) if not num in self.file] # comb between word & numbers
   self.file = self.file + [sym for sym in self.symbols(word) if not sym in self.file] # comb between word & symbols
   self.file = self.file + [comb for comb in self.comb(word) if not comb in self.file] # comb between word, numbers, & symbols
  self.writefile()

class Questions(object):
 def __init__(self):
  self.vends = ['TG1','DVW','DG8','U10','TC8']
  self.questions = {
               0:{'name':'spousename','value':None},
               1:{'name':'middlename','value':None},
               2:{'name':'childname','value':None},
               3:{'name':'firstname','value':None},
               4:{'name':'yearOfBirth','value':None},
               5:{'name':'spouseYOB','value':None},
               6:{'name':'maidename','value':None},
               7:{'name':'lastname','value':None},
               8:{'name':'nickname','value':None},
               9:{'name':'childYearOB','value':None},
               10:{'name':'surname','value':None},
               11:{'name':'petname','value':None},
               12:{'name':'phone','value':None},
               13:{'name':'essid','value':None},
               14:{'name':'bssid','value':None},
               15:{'name':'ssn','value':None},
               16:{'name':'pin','value':None}
              }

 def cmds(self):
  # help
  print 'usage: [fieldname] = [value]'
  print '*Do Not Use Any Symbols\n'
  print 'help              \tdisplay help'
  print 'exit              \tto exit'
  print 'reset             \tclear fields'
  print 'update            \tcheck for update'
  print 'generate          \tgenerate password list'
  print 'current version   \t{}'.format(__version__)
  print 'reset [fieldname] \tclear field'
  raw_input('\n[Press Enter To Continue]')

 def mklist(self):
  for num in self.questions:
   q = self.questions[num]
   n = q['name']
   v = q['value']

   if v:
    # are we looking at a pin
    if n=='pin':
     generator.nums.append(v)
     generator.list.append(v)

    # are we looking at wifi info
    elif n == 'essid' or n == 'bssid':
      if n != 'essid':continue
      essid = v
      bssid = [key for key in self.questions if self.questions[key]['name']=='bssid']
      bssid = bssid[0] if bssid else bssid
      if not bssid:continue
      bssid = self.questions[bssid]['value']

      # generate default password
      if len(essid)>3:
       if essid[:3] in self.vends:
        passkey = generator.default(essid,bssid)
        if not passkey in generator.list:
         generator.list.append(passkey)

    # full name
    elif n == 'firstname':
     firstname,lastname = v,[self.questions[key]['value'] for key in self.questions if self.questions[key]['name']=='lastname'][0]
     generator.word.append(firstname)

     if lastname:
      generator.word.append('{}{}'.format(firstname,lastname.lower()))
      generator.word.append('{}{}'.format(firstname,lastname))

    elif n == 'spousename' or n == 'childname':
     # love makes people weak
     generator.word.append(v)
     generator.word.append('ilove{}'.format(v))
     generator.word.append('love{}'.format(v))
     generator.word.append('iloveU{}'.format(v))
     generator.word.append('mylove{}'.format(v))

    # are we looking basic info
    else:
     if v.isdigit():
      if any([n=='yearOfBirth',n=='spouseYOB',n=='childYearOB']):
       rev  = ''.join([n for n in reversed([n for n in v])])
       end  = v[-2:]

       # different formats of year
       if not v in generator.nums:
        generator.nums.append(v)
       if not rev in generator.nums:
        generator.nums.append(rev)
       if not end in generator.nums:
        generator.nums.append(end)

      else:
       if not v in generator.list:
        generator.list.append(v)
     else:
      if not v in generator.word:
       generator.word.append(v)

  # generate password list & reset
  generator.generate()
  self.reset()

 def fresh(self):
  # fresh start ?
  return False if [key for key in self.questions if self.questions[key]['value']] else True

 def display(self):
  subprocess.call(['clear'])
  for n,q in enumerate(self.questions):
   if not n:
    print '-------------------------------'
    print '||    Name     ||    Value   ||'
    print '-------------------------------'
   q = self.questions[q]
   n = str(q['name']).ljust(11)
   v = str(q['value']).ljust(7)
   print '|| {} || {}'.format(n,v)

 def reset(self,item=None):
  del generator.list[:]
  del generator.word[:]
  for num in self.questions:
   q = self.questions[num]
   if not item:
    q['value'] = None
   else:
    if q['name']==item:
     q['value'] = None

def main():
 while 1:
  answers.display()
  print '\ntype: \'help\' for help' if answers.fresh() else ''
  cmd = raw_input('\n> ')
  subprocess.call(['clear'])

  # check for assignments
  if '=' in cmd:
   try:
    name = cmd.split()[0].lower().strip().replace('\n','')
    value = cmd.split()[2].lower().strip().replace('\n','')
   except:continue
   key = [key for key in answers.questions if answers.questions[key]['name'].lower() == name]
   if not key:continue
   key = key[0]

   # check if name exists
   if key:
    q = answers.questions[key]
    v = value.upper() if q['name']=='essid' or q['name']=='bssid' else value.title()
    q['value'] = v
   continue

  else:
   # check for key words, such as help, reset, and generate
   cmd = cmd.lower()
   [answers.cmds() if cmd=='help' else answers.reset() if cmd=='reset' else answers.mklist() if cmd=='generate' else exit() if cmd=='exit' else Update().check() if cmd=='update' else None]

   # reset field
   cmd = cmd.split()
   if len(cmd)==2:
    if cmd[0] == 'reset' and [key for key in answers.questions if answers.questions[key]['name'] == cmd[1]][0]:
     answers.reset(cmd[1])

if __name__ == '__main__':
 answers = Questions()
 generator = Generator()
 try:
  main()
 except KeyboardInterrupt:
  exit('\n')
