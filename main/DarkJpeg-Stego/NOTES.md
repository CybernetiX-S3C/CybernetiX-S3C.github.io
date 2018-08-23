darkjpeg
========

DarkJPEG is a new generation open source steganography web service. It is supposed to serve people's needs for the freedom of communication even in those countries which break human rights by forcing some kind of Internet censorship or even denying to use cryptography by law. The service uses strong steganography methods to hide the very fact of hiding data among with strong cryptography methods to protect the data of being read by non-trusted groups of people.

Main features:
- SHA3 key generation;
- AES256 encryption;
- JPEG steganography;
- Random containers;
- Client side encoding;
- Anonymity and privacy;
- MIT License.

### Components

Supported encapsulation methods:
- auto, which is used by default and suitable for most cases (note: data is being encoded with the join method);
- join, which simply concatenates a container and encrypted data together producing a valid JPEG on the output and giving infinite container capacity among with moderate security;
- steg, which uses strong steganography algorithms allowing to inject encrypted data directly into JPEG discrete cosine transform coefficients and giving about 20% of the container size capacity and the maximal security level, please note this is the only method to be used in the case of hiding some serious content.

Supported container types:
- rand, which downloads a random image from Wikimedia;
- grad, which generates a random image using gradient algorithms;
- image, which allows to use one's own image as a container.

Note: unsafe option can be used to reduce output file size and prevent some additional container transformations at the cost of security but that could be still useful on slow computers.

### RarJPEG support

It was decided not to allow one to use an empty password for the security reasons. However, this could be done using the join method producing a concatenation of two files together. This gives an ability to join e.g. a rar-archive to any JPEG container which then could be simply opened by any archive software without using this service. Note: every encoded file has an additional header in the beginning and JPEG EOI (0xFFD9) word at the end in the reasons of security.

### Deniable encryption

Data can be injected in a container in three ways: using the join method, using the steg method and using them both simultaneously. This gives an ability to join fake secret data to an already encoded by the steg method image containing real secret content. Deniable encryption allows an encrypted message to be decrypted to different sensible plaintexts, depending on the key used. This allows one to have plausible deniability if compelled to give up the encryption key.

### Server-less

No server is needed to encode or decode files at all. All computations are being run on the client giving additional performance and privacy, so the service never tracks any requests and nobody could possibly know about one's actions what gives the one maximum anonymity and security.

### App Engine support

This service allows to provide a URL instead of selecting or drag'n'dropping a file. But note that there is a web-restriction named CORS which denies the service to download data directly from other domains. So there are two proxy services (hugs-01 and hugs-02) running on the Google App Engine platform. They are an optional part allowing not to download files manually but with the HUGS support. Note: there's a daily bandwidth quota of 2048 MiB had been set by Google and since the service out of it, a URL cannot be used instead of a file. In that case please mention there is a special browser extension available which gives an ability to decode images directly on any website just by clicking a context menu item on it.

### Developer's guide

The service core is built as an asynchronous web-worker dark.js. It can deal with the following json-requests:
```
- {action: "encrypt", name: "file.ext", pass: "password", buffer: ArrayBuffer}
- {action: "encode", method: "join", width: 0, height: 0, buffer: ArrayBuffer}
- {action: "encode", method: "auto | join | steg", width: image.width, height: image.height, buffer: ImageData}
- {action: "decode", method: "auto | join |steg", buffer: ArrayBuffer}
- {action: "decrypt", pass: "password"}
```

The answers should be processed by the worker.onmessage function and look like this:
```
- {type: "encrypt", size: encrypted}
- {type: "encode", time: duration, isize: res.length, csize: enc.length, rate: 100*isize/csize, buffer: ArrayBuffer}
- {type: "decode", time: duration, isize: res.length, csize: dec.length, rate: 100*isize/csize}
- {type: "decrypt", name: "file.ext", buffer: ArrayBuffer}
- {type: "progress", name: "encrypt | decrypt | encode | decode", progress: percent}
- {type: "error", name: "encrypt | decrypt | encode | decode", msg: message}
```

DarkJPEG file format:
```
- container: [ JPEG <+> encoded data ] or [ JPEG ][ encoded data ]
- encoded:   [ 16-bit encryption salt ][ AES256 encrypted data ][ 0xFFD9 ]
- encrypted: [ 0x3141593 ][ 32-bit file size ][ 16-bit file name length ][ UTF-16 file name ][ DATA ][ zero padding ]
```

### See also

- [Cryptography](http://en.wikipedia.org/wiki/Cryptography);
- [Steganography](http://en.wikipedia.org/wiki/Steganography);
- [Crypto-anarchism](http://en.wikipedia.org/wiki/Crypto-anarchism);
- [Plausible deniability](http://en.wikipedia.org/wiki/Plausible_deniability);
- [A Cypherpunk's Manifesto](http://www.activism.net/cypherpunk/manifesto.html).


