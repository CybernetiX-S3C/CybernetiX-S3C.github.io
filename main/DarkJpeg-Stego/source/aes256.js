
/** @fileOverview Low-level AES implementation.
 *
 * This file contains a low-level implementation of AES, optimized for
 * size and for efficiency on several browsers.  It is based on
 * OpenSSL's aes_core.c, a public-domain implementation by Vincent
 * Rijmen, Antoon Bosselaers and Paulo Barreto.
 *
 * An older version of this implementation is available in the public
 * domain, but this one is (c) Emily Stark, Mike Hamburg, Dan Boneh,
 * Stanford University 2008-2010 and BSD-licensed for liability
 * reasons.
 *
 * @author Emily Stark
 * @author Mike Hamburg
 * @author Dan Boneh
 */

/**
 * Schedule out an AES key for both encryption and decryption.  This
 * is a low-level class.  Use a cipher mode to do bulk encryption.
 *
 * @constructor
 * @param {Array} key The key as an array of 4, 6 or 8 words.
 *
 * @class Advanced Encryption Standard (low-level interface)
 */

var AES256 = function (data, pass, dir)
{
    var AESKey;

    function precompute()
    {
        AES256.prototype.tables = [[[],[],[],[],[]],[[],[],[],[],[]]];

        var encTable = AES256.prototype.tables[0],
            decTable = AES256.prototype.tables[1],
            sbox = encTable[4],
            sboxInv = decTable[4],
            i, x, xInv, d = [],
            th = [],
            x2, x4, x8, s, tEnc, tDec;

        // Compute double and third tables
        for (i = 0; i < 256; i++)
        {
            th[(d[i] = i << 1 ^ (i >> 7) * 283) ^ i] = i;
        }

        for (x = xInv = 0; !sbox[x]; x ^= x2 || 1, xInv = th[xInv] || 1)
        {
            // Compute sbox
            s = xInv ^ xInv << 1 ^ xInv << 2 ^ xInv << 3 ^ xInv << 4;
            s = s >> 8 ^ s & 255 ^ 99;
            sbox[x] = s;
            sboxInv[s] = x;

            // Compute MixColumns
            x8 = d[x4 = d[x2 = d[x]]];
            tDec = x8 * 0x1010101 ^ x4 * 0x10001 ^ x2 * 0x101 ^ x * 0x1010100;
            tEnc = d[s] * 0x101 ^ s * 0x1010100;

            for (i = 0; i < 4; i++)
            {
                encTable[i][x] = tEnc = tEnc << 24 ^ tEnc >>> 8;
                decTable[i][s] = tDec = tDec << 24 ^ tDec >>> 8;
            }
        }

        // Compactify.  Considerable speedup on Firefox.
        for (i = 0; i < 5; i++)
        {
            encTable[i] = encTable[i].slice(0);
            decTable[i] = decTable[i].slice(0);
        }
    }

    function init(key)
    {
        if (!AES256.prototype.tables)
        {
            precompute();
        }

        var i, j, tmp,
            encKey, decKey,
            sbox = AES256.prototype.tables[0][4],
            encTable = AES256.prototype.tables[0],
            decTable = AES256.prototype.tables[1],
            keyLen = key.length,
            rcon = 1;

        AESKey = [encKey = key, decKey = []];

        // schedule encryption keys
        for (i = keyLen; i < 4 * keyLen + 28; i++)
        {
            tmp = encKey[i - 1];

            // apply sbox
            if (i % keyLen === 0 || (keyLen === 8 && i % keyLen === 4))
            {
                tmp = sbox[tmp >>> 24] << 24 ^ 
                    sbox[tmp >> 16 & 255] << 16 ^
                    sbox[tmp >> 8 & 255] << 8 ^ sbox[tmp & 255];

                // shift rows and add rcon
                if (i % keyLen === 0)
                {
                    tmp = tmp << 8 ^ tmp >>> 24 ^ rcon << 24;
                    rcon = rcon << 1 ^ (rcon >> 7) * 283;
                }
            }

            encKey[i] = encKey[i - keyLen] ^ tmp;
        }

        // schedule decryption keys
        for (j = 0; i; j++, i--)
        {
            tmp = encKey[j & 3 ? i : i - 4];
            if (i <= 4 || j < 4)
            {
                decKey[j] = tmp;
            }
            else
            {
                decKey[j] = decTable[0][sbox[tmp >>> 24]] ^
                    decTable[1][sbox[tmp >> 16 & 255]] ^
                    decTable[2][sbox[tmp >> 8 & 255]] ^
                    decTable[3][sbox[tmp & 255]];
            }
        }
    }

    function process(input, dir)
    {
        var key = AESKey[dir],
            // state variables a,b,c,d are loaded with pre-whitened data
            a = input[0] ^ key[0],
            b = input[dir ? 3 : 1] ^ key[1],
            c = input[2] ^ key[2],
            d = input[dir ? 1 : 3] ^ key[3],
            a2, b2, c2,

            nInnerRounds = key.length / 4 - 2,
            i,
            kIndex = 4,
            out = [0, 0, 0, 0],
            table = AES256.prototype.tables[dir],

            // load up the tables
            t0 = table[0],
            t1 = table[1],
            t2 = table[2],
            t3 = table[3],
            sbox = table[4];

        // Inner rounds.  Cribbed from OpenSSL.
        for (i = 0; i < nInnerRounds; i++)
        {
            a2 = t0[a >>> 24] ^ t1[b >> 16 & 255] ^ t2[c >> 8 & 255] ^ t3[d & 255] ^ key[kIndex];
            b2 = t0[b >>> 24] ^ t1[c >> 16 & 255] ^ t2[d >> 8 & 255] ^ t3[a & 255] ^ key[kIndex + 1];
            c2 = t0[c >>> 24] ^ t1[d >> 16 & 255] ^ t2[a >> 8 & 255] ^ t3[b & 255] ^ key[kIndex + 2];
            d = t0[d >>> 24] ^ t1[a >> 16 & 255] ^ t2[b >> 8 & 255] ^ t3[c & 255] ^ key[kIndex + 3];
            kIndex += 4;
            a = a2;
            b = b2;
            c = c2;
        }

        // Last round.
        for (i = 0; i < 4; i++)
        {
            out[dir ? 3 & -i : i] = sbox[a >>> 24] << 24 ^ sbox[b >> 16 & 255] << 16 ^
                sbox[c >> 8 & 255] << 8 ^ sbox[d & 255] ^ key[kIndex++];
            a2 = a;
            a = b;
            b = c;
            c = d;
            d = a2;
        }

        return out;
    }

    var a, b, c, d, i, s, z, k = 4,
        progress, lastProgress = 0,
        result = new Uint8Array(((data.length >> 4) << 4) + 4);

    if (dir == 0)
    {
        s = -Math.random() * (1 << 30) | 0;
        result[0] = s >> 24;
        result[1] = (s >> 16) & 0xFF;
        result[2] = (s >> 8) & 0xFF;
        result[3] = s & 0xFF;
    }
    else
        s = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
    
    init(SHA3(pass + s));

    if (dir == 1)
    {
        k = 0;
        i = 4;
        a = (data[i +  0] << 24) | (data[i +  1] << 16) | (data[i +  2] << 8) | data[i +  3];
        b = (data[i +  4] << 24) | (data[i +  5] << 16) | (data[i +  6] << 8) | data[i +  7];
        c = (data[i +  8] << 24) | (data[i +  9] << 16) | (data[i + 10] << 8) | data[i + 11];
        d = (data[i + 12] << 24) | (data[i + 13] << 16) | (data[i + 14] << 8) | data[i + 15];
        z = process([a, b, c, d], dir);

        if (z[0] != 0x3141593)
            throw new Exception('decrypt', "Wrong password");
    }

    for (i = 4 - k; i < result.length; i += 16)
    {
        a = (data[i +  0] << 24) | (data[i +  1] << 16) | (data[i +  2] << 8) | data[i +  3];
        b = (data[i +  4] << 24) | (data[i +  5] << 16) | (data[i +  6] << 8) | data[i +  7];
        c = (data[i +  8] << 24) | (data[i +  9] << 16) | (data[i + 10] << 8) | data[i + 11];
        d = (data[i + 12] << 24) | (data[i + 13] << 16) | (data[i + 14] << 8) | data[i + 15];
        z = process([a, b, c, d], dir);

        result[k++] = z[0] >> 24;
        result[k++] = (z[0] >> 16) & 0xFF;
        result[k++] = (z[0] >> 8) & 0xFF;
        result[k++] = z[0] & 0xFF;
        result[k++] = z[1] >> 24;
        result[k++] = (z[1] >> 16) & 0xFF;
        result[k++] = (z[1] >> 8) & 0xFF;
        result[k++] = z[1] & 0xFF;
        result[k++] = z[2] >> 24;
        result[k++] = (z[2] >> 16) & 0xFF;
        result[k++] = (z[2] >> 8) & 0xFF;
        result[k++] = z[2] & 0xFF;
        result[k++] = z[3] >> 24;
        result[k++] = (z[3] >> 16) & 0xFF;
        result[k++] = (z[3] >> 8) & 0xFF;
        result[k++] = z[3] & 0xFF;

        progress = 100.0 * i / result.length | 0;
        if (progress > lastProgress + 9)
        {
            lastProgress = progress;
            postMessage({type: 'progress', progress: progress,
                name: ((dir == 0) ? 'en' : 'de') + 'crypt'});
        }
    }

    return result;
};
