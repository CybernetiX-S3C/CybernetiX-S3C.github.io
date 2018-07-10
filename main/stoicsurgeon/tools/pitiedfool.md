### [Home](https://CybernetiX-S3C.github.io)   [Main](https://CybernetiX-S3C.github.io/main)

[STOIC SURGEON](https://CybernetiX-S3C.github.io/main/stoicsurgeon)
[RESEARCH](https://CybernetiX-S3C.github.io/main/stoicsurgeon/research)
[CONTRIBUTING](https://CybernetiX-S3C.github.io/main/stoicsurgeon/contrib)
[ABOUT](https://CybernetiX-S3C.github.io/main/stoicsurgeon/about)

# PITIEDFOOL
 
File system destroyer. It destroys the MFT on each partition and volume shadow copies with MFT copies.

From the [Snowden archive](https://snowdenarchive.cjfe.org/greenstone/collect/snowden1/index/assoc/HASH01b2/dc5bd489.dir/doc.pdf):

```
(U//FOUO) PITIED FOOL

( T S / / S I / / R E L ) PITIEDFOOL is a suite of CNA tools I'm developing for
use against file systems, initially focused on Windows. More information
can be found on the DSD wiki, but it's a bit ugly at this point.
( T S / / S I / / R E L ) Determined that it was a combination of the volume
shadow copy and deleted entries in the shadow copy that were causing
my recovery woes. As a result of the shadow copy having large chunks of
MFT data in it, and much of these records still being mostly correct,
recovery programs were able to reconstruct most of the system drive. I
added functionality to PITIEDFOOL to overwrite the contents of the
shadow copy on each partition encountered.
( T S / / S I / / R E L ) Now that I was overwriting large chunks of data for
every partition, I could no longer ignore the performance issues with
writing to a disk one sector at a time. I refactored my code to overwrite in
blocks configurable by a pre-processor definition and sped up execution
about 15-fold, with the possiblity of it going even faster with increased
memory usage.
( T S / / S I / / R E L ) After all this I tested PITIEDFOOL within FUZZYEBOLA
and it worked flawlessly. I took a build of FUZZYEBOLA from last
month, and without recompiling inserted the PITIEDFOOL binary with
configuration details to execute it at a certain time. At that time I saw the
process usage slightly increase (from 0% to around 2%) and a few minutes
later the system rebooted and didn't come back up. Running a file
recovery tool over the entire drive yielded some files (from scraping
headers) but nearly the entire contents of the drive were irrecoverable,
and if it had been configured to securely wipe every sector on the drive
after killing the MFT and VSS it wouldn't have been able to recover
anything at all. Success!
(U/ /FOUO) Documented my work.
```
