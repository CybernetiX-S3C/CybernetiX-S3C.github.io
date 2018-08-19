import urllib, os, sys
import urllib2
from urllib2 import urlopen
from termcolor import colored, cprint
if __name__ == "__main__":
    my_ip = urlopen('http://ip.42.pl/raw').read()
    print ''' 

                Get Reverse DNS, GeoIP, NMAP, Traceroute
                  Pulls HTTP Headers for an IP address

    '''
    print 'Your Public IP address is {0}'.format(my_ip)
    print('\n')
    badip = raw_input('Target IP: ')
    os.system('cls')
    reversed_dns = urllib.urlopen('http://api.hackertarget.com/reverseiplookup/?q=' + badip).read()
    print('Reverse DNS Information:')
    print colored  (reversed_dns, 'green')
    print('\n')
    geoip = urllib.urlopen('http://api.hackertarget.com/geoip/?q=' + badip).read()
    print('GEOIP Information:')
    print colored (geoip, 'green')
    print('\n')
    nmap = urllib.urlopen('http://api.hackertarget.com/nmap/?q=' + badip).read()
    print('NMAP Scan Result of Traget (Only Ports: 21,25,80 and 443):')
    print colored (nmap, 'green')
    print('\n')
    httpheaders = urllib.urlopen('http://api.hackertarget.com/httpheaders/?q=' + badip).read()
    print('HTTP Headers:')
    print colored (httpheaders, 'green')
    print('\n')
    tracert = urllib.urlopen('http://api.hackertarget.com/mtr/?q=' + badip).read()
    print('Trace Route Scan:')
    print colored (tracert, 'green')
    print('\n')    
