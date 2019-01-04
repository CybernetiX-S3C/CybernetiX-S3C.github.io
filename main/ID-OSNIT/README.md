## ID-OSINT - OSINT scraping framework


Initial attack vectors for recon usually involve utilizing pay-for-data/API (Recon-NG), or paying to utilize transforms (Maltego) to get data mining results. ID-OSINT utilizes some basic python webscraping (BeautifulSoup) of PII paywall sites to compile passive information on a target on a ramen noodle budget.


Installation
----
```
$ git clone https://gitlab.com/CybernetiX-S3C/ID-OSINT.git ID-OSINT
$ cd ID-OSINT
```
__Install requirements__
```
$ pip install -r requirements.txt
```
__Run__
```
$ python ID-OSINT.py -l (phone|email|sn|name|plate)
```

