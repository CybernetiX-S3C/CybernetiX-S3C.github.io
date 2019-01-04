### [Home](https://CybernetiX-S3C.github.io)   [Main](https://CybernetiX-S3C.github.io/main)

![](https://blog.flamingtext.com/blog/2018/09/23/flamingtext_com_1537720698_1017233232.png)

[![Github all releases](https://img.shields.io/github/downloads/Naereen/StrapDown.js/total.svg)](https://GitHub.com/CybernetiX-S3C/wifipackage/)

## Author: John Modica @ CybernetiX S3C

wifi Package is a basic bash script package of scripts to manually place you wireless cards into monitor and managed mode. I have also implemented a TxPower script to change your TxPower strength to a higher but possibly legal db. 

**Please Note:**
Unlike airmon-ng the mon mode will still be left as wlan0 or wlan1 instead of the usual wlan0mon or wlan1mon.

```
Get the script:

git clone https://github.com/CybernetiX-S3C/wifiackage
cd wifipackage

To start the scripts just use one of the following: 
bash nameoffile.sh
sh nameoffile.sh
./nameoffile.sh

cat << "EOF"            
             __________
            /'        /|
           /         / |_
          /         /  //|
         /_________/  ////|
        |   _ _    | 8o////|
        | /'// )_  |   8///|
        |/ // // ) |   8o///|
        / // // //,|  /  8//|
       / // // /// | /   8//|
      / // // ///__|/    8//|
     /.(_)// /// |       8///|
    (_)' `(_)//| |       8////|___________
   (_) /_\ (_)'| |        8///////////////
   (_) \"/ (_)'|_|         8/////////////
    (_)._.(_) d' Hb         8oooooooopb'
      `(_)'  d'  H`b
            d'   `b`b
           d'     H `b
          d'      `b `b
         d'           `b
        d'             `b
EOF
WARNING!! 
Changing the TxPower is and can be dangerous and also illegal 
in differrent countries!
Changing any higher can cause radiation poisoning, cancer,
and can burn your card out!

Note:
As it states in the video, and the scripts, the only things that change is the mode, NOT the name! wlan1 will stay wlan1. wla0 with stay wlan0. when doing your packet collecing use wlan0/wlan1.

```

https://www.cisco.com/c/en/us/support/docs/dial-access/asynchronous-connections/15380-trans-rec-15380.html

https://www.snbforums.com/threads/dangerous-to-rise-tx-power.19240/

https://forums.kali.org/showthread.php?28809-Raising-TX-Power-What-Does-This-Really-Do

# WifiPackage Tutorial
[Wifi](https://www.youtube.com/watch?v=Ae6NImby6ZA)
