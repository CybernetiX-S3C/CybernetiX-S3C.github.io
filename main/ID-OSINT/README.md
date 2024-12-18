## ID-OSINT - OSINT scraping framework
![python](https://img.shields.io/badge/python-2.7-green.svg) ![version](https://img.shields.io/badge/version-0.2.0-brightgreen.svg) ![licence](https://img.shields.io/badge/license-GPLv3-lightgrey.svg) 


Initial attack vectors for recon usually involve utilizing pay-for-data/API (Recon-NG), or paying to utilize transforms (Maltego) to get data mining results. ID-OSNIT utilizes some basic python webscraping (BeautifulSoup) of PII paywall sites to compile passive information on a target on a ramen noodle budget.


Installation
----
```
$ git clone https://gitlab.com/CybernetiX-S3C/ID-OSINT.git ID-OSINT
$ cd ID-OSNIT
```
__Install requirements__
```
$ pip install -r requirements.txt
```
__Run__
```
$ python ID-OSINT.py -l (phone|email|sn|name|plate)
```


