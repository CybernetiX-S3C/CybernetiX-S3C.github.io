## ID-OSINT - OSINT scraping framework


Initial attack vectors for recon usually involve utilizing pay-for-data/API (Recon-NG), or paying to utilize transforms (Maltego) to get data mining results. ID-OSNIT utilizes some basic python webscraping (BeautifulSoup) of PII paywall sites to compile passive information on a target on a ramen noodle budget.


Installation
----
```
$ git clone https://github.com/CybernetiX-S3C/ID-OSINT.git ID-OSINT
$ cd ID-OSINT
```
__Install requirements__
```
$ pip3 install -r requirements.txt
```
__Run__
```
$ python3 ID-OSINT.py -l (phone|email|sn|name|plate)
```

Usage
----
Full details on how to use ID-OSINT are on the wiki located [here](https://github.com/CybernetiX-S3C/ID-OSINT/wiki)
