
/*
   Copyright (C) 2011 notmasteryet

   Contributors: Yury Delendik <ydelendik@mozilla.com>
                 Brendan Dahl <bdahl@mozilla.com>

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

// - The JPEG specification can be found in the ITU CCITT Recommendation T.81
//   (www.w3.org/Graphics/JPEG/itu-t81.pdf)
// - The JFIF specification can be found in the JPEG File Interchange Format
//   (www.w3.org/Graphics/JPEG/jfif3.pdf)
// - The Adobe Application-Specific JPEG markers in the Supporting the DCT Filters
//   in PostScript Level 2, Technical Note #5116
//   (partners.adobe.com/public/developer/en/ps/sdk/5116.DCT_Filter.pdf)

var JPEGDecoder = function (method, buf)
{
    var dctZigZag = new Int8Array([
         0,  1,  8, 16,  9,  2,  3, 10,
        17, 24, 32, 25, 18, 11,  4,  5,
        12, 19, 26, 33, 40, 48, 41, 34,
        27, 20, 13,  6,  7, 14, 21, 28,
        35, 42, 49, 56, 57, 50, 43, 36,
        29, 22, 15, 23, 30, 37, 44, 51,
        58, 59, 52, 45, 38, 31, 39, 46,
        53, 60, 61, 54, 47, 55, 62, 63
    ]);

    function buildHuffmanTable(codeLengths, values)
    {
        var k = 0,
            code = [],
            i, j, length = 16;

        while (length > 0 && !codeLengths[length - 1]) length--;
        code.push({children: [], index: 0});

        var p = code[0], q;
        for (i = 0; i < length; i++)
        {
            for (j = 0; j < codeLengths[i]; j++)
            {
                p = code.pop();
                p.children[p.index] = values[k];
                while (p.index > 0)
                {
                    p = code.pop();
                }
                p.index++;
                code.push(p);
                while (code.length <= i)
                {
                    code.push(q = {children: [], index: 0});
                    p.children[p.index] = q.children;
                    p = q;
                }
                k++;
            }
            if (i + 1 < length)
            {
                code.push(q = {children: [], index: 0});
                p.children[p.index] = q.children;
                p = q;
            }
        }
        return code[0].children;
    }

    function decodeScan(data, offset,
        frame, components, resetInterval,
        spectralStart, spectralEnd,
        successivePrev, successive)
    {
        var precision = frame.precision,
            samplesPerLine = frame.samplesPerLine,
            scanLines = frame.scanLines,
            mcusPerLine = frame.mcusPerLine,
            progressive = frame.progressive,
            maxH = frame.maxH,
            maxV = frame.maxV,
            startOffset = offset,
            bitsData = 0,
            bitsCount = 0;

        function readBit()
        {
            if (bitsCount > 0)
            {
                bitsCount--;
                return (bitsData >> bitsCount) & 1;
            }
            bitsData = data[offset++];
            if (bitsData == 0xFF)
            {
                var nextByte = data[offset++];
                if (nextByte)
                {
                    throw new Exception('decode', "Unexpected JPEG marker");
                }
            }
            bitsCount = 7;
            return bitsData >>> 7;
        }

        function decodeHuffman(tree)
        {
            var node = tree,
                bit;
            while ((bit = readBit()) !== null)
            {
                node = node[bit];
                if (typeof node === 'number')
                    return node;
                if (typeof node !== 'object')
                    throw new Exception('decode', "Invalid JPEG huffman sequence");
            }
            return null;
        }

        function receive(length)
        {
            var n = 0;
            while (length > 0)
            {
                var bit = readBit();
                if (bit === null) return;
                n = (n << 1) | bit;
                length--;
            }
            return n;
        }

        function receiveAndExtend(length)
        {
            var n = receive(length);
            if (n >= 1 << (length - 1))
                return n;
            return n + (-1 << length) + 1;
        }

        function decodeBaseline(component, zz)
        {
            var t = decodeHuffman(component.huffmanTableDC);
            var diff = t === 0 ? 0 : receiveAndExtend(t);
            zz[0] = (component.pred += diff);
            var k = 1;
            while (k < 64)
            {
                var rs = decodeHuffman(component.huffmanTableAC);
                var s = rs & 15,
                    r = rs >> 4;
                if (s === 0)
                {
                    if (r < 15)
                        break;
                    k += 16;
                    continue;
                }
                k += r;
                var z = dctZigZag[k];
                zz[z] = receiveAndExtend(s);
                k++;
            }
        }

        function decodeDCFirst(component, zz)
        {
            var t = decodeHuffman(component.huffmanTableDC);
            var diff = t === 0 ? 0 : (receiveAndExtend(t) << successive);
            zz[0] = (component.pred += diff);
        }

        function decodeDCSuccessive(component, zz)
        {
            zz[0] |= readBit() << successive;
        }

        var eobrun = 0;

        function decodeACFirst(component, zz)
        {
            if (eobrun > 0)
            {
                eobrun--;
                return;
            }
            var k = spectralStart,
                e = spectralEnd;
            while (k <= e)
            {
                var rs = decodeHuffman(component.huffmanTableAC);
                var s = rs & 15,
                    r = rs >> 4;
                if (s === 0)
                {
                    if (r < 15)
                    {
                        eobrun = receive(r) + (1 << r) - 1;
                        break;
                    }
                    k += 16;
                    continue;
                }
                k += r;
                var z = dctZigZag[k];
                zz[z] = receiveAndExtend(s) * (1 << successive);
                k++;
            }
        }

        var successiveACState = 0,
            successiveACNextValue;

        function decodeACSuccessive(component, zz)
        {
            var k = spectralStart,
                e = spectralEnd,
                r = 0;
            while (k <= e)
            {
                var z = dctZigZag[k];
                switch (successiveACState)
                {
                case 0: // initial state
                    var rs = decodeHuffman(component.huffmanTableAC);
                    var s = rs & 15,
                        r = rs >> 4;
                    if (s === 0)
                    {
                        if (r < 15)
                        {
                            eobrun = receive(r) + (1 << r);
                            successiveACState = 4;
                        }
                        else
                        {
                            r = 16;
                            successiveACState = 1;
                        }
                    }
                    else
                    {
                        if (s !== 1) throw new Exception('decode', "Invalid JPEG ACn encoding");
                        successiveACNextValue = receiveAndExtend(s);
                        successiveACState = r ? 2 : 3;
                    }
                    continue;
                case 1: // skipping r zero items
                case 2:
                    if (zz[z])
                        zz[z] += (readBit() << successive);
                    else
                    {
                        r--;
                        if (r === 0)
                            successiveACState = successiveACState == 2 ? 3 : 0;
                    }
                    break;
                case 3: // set value for a zero item
                    if (zz[z])
                        zz[z] += (readBit() << successive);
                    else
                    {
                        zz[z] = successiveACNextValue << successive;
                        successiveACState = 0;
                    }
                    break;
                case 4: // eob
                    if (zz[z])
                        zz[z] += (readBit() << successive);
                    break;
                }
                k++;
            }
            if (successiveACState === 4)
            {
                eobrun--;
                if (eobrun === 0)
                    successiveACState = 0;
            }
        }

        function decodeMcu(component, decode, mcu, row, col)
        {
            var mcuRow = (mcu / mcusPerLine) | 0;
            var mcuCol = mcu % mcusPerLine;
            var blockRow = mcuRow * component.v + row;
            var blockCol = mcuCol * component.h + col;
            decode(component, component.blocks[blockRow][blockCol]);
        }

        function decodeBlock(component, decode, mcu)
        {
            var blockRow = (mcu / component.blocksPerLine) | 0;
            var blockCol = mcu % component.blocksPerLine;
            decode(component, component.blocks[blockRow][blockCol]);
        }

        var componentsLength = components.length,
            component, i, j, k, n, decodeFn;

        if (progressive)
        {
            if (spectralStart === 0)
                decodeFn = successivePrev === 0 ? decodeDCFirst : decodeDCSuccessive;
            else
                decodeFn = successivePrev === 0 ? decodeACFirst : decodeACSuccessive;
        }
        else
        {
            decodeFn = decodeBaseline;
        }
        var mcu = 0,
            marker,
            mcuExpected;

        if (componentsLength == 1)
        {
            mcuExpected = components[0].blocksPerLine * components[0].blocksPerColumn;
        }
        else
        {
            mcuExpected = mcusPerLine * frame.mcusPerColumn;
        }

        if (!resetInterval) resetInterval = mcuExpected;

        var h, v;

        while (mcu < mcuExpected)
        {
            for (i = 0; i < componentsLength; i++)
                components[i].pred = 0;
            eobrun = 0;
            if (componentsLength == 1)
            {
                component = components[0];
                for (n = 0; n < resetInterval; n++)
                {
                    decodeBlock(component, decodeFn, mcu);
                    mcu++;
                }
            }
            else
            {
                for (n = 0; n < resetInterval; n++)
                {
                    for (i = 0; i < componentsLength; i++)
                    {
                        component = components[i];
                        h = component.h;
                        v = component.v;
                        for (j = 0; j < v; j++)
                        {
                            for (k = 0; k < h; k++)
                            {
                                decodeMcu(component, decodeFn, mcu, j, k);
                            }
                        }
                    }
                    mcu++;
                }
            }

            bitsCount = 0;
            marker = (data[offset] << 8) | data[offset + 1];
            if (marker >= 0xFFD0 && marker <= 0xFFD7)
            { // RSTx
                offset += 2;
            }
            else
                break;
        }
        return offset - startOffset;
    }

    function parseMethod()
    {
        switch (method)
        {
            case undefined:
            case 'auto': method = 2; break;
            case 'join': method = 1; break;
            case 'steg': method = 0; break;
            default: throw new Exception('decode', "Unknown s-method");
        }
    }

    function jpegDecode(data)
    {
        var offset = 0,
            length = data.length,
            timeStart = new Date().getTime();

        function readUint16()
        {
            var value = (data[offset] << 8) | data[offset + 1];
            offset += 2;
            return value;
        }

        function readDataBlock()
        {
            var length = readUint16();
            var array = data.subarray(offset, offset + length - 2);
            offset += array.length;
            return array;
        }

        function prepareComponents(frame)
        {
            var maxH = 0,
                maxV = 0,
                component, componentId;
            for (componentId in frame.components)
            {
                if (frame.components.hasOwnProperty(componentId))
                {
                    component = frame.components[componentId];
                    if (maxH < component.h) maxH = component.h;
                    if (maxV < component.v) maxV = component.v;
                }
            }
            var mcusPerLine = Math.ceil(frame.samplesPerLine / 8 / maxH),
                mcusPerColumn = Math.ceil(frame.scanLines / 8 / maxV);
            for (componentId in frame.components)
            {
                if (frame.components.hasOwnProperty(componentId))
                {
                    component = frame.components[componentId];
                    var blocksPerLine = Math.ceil(Math.ceil(frame.samplesPerLine / 8) * component.h / maxH);
                    var blocksPerColumn = Math.ceil(Math.ceil(frame.scanLines / 8) * component.v / maxV);
                    var blocksPerLineForMcu = mcusPerLine * component.h;
                    var blocksPerColumnForMcu = mcusPerColumn * component.v;
                    var blocks = [];
                    for (var i = 0; i < blocksPerColumnForMcu; i++)
                    {
                        var row = [];
                        for (var j = 0; j < blocksPerLineForMcu; j++)
                            row.push(new Int32Array(64));
                        blocks.push(row);
                    }
                    component.blocksPerLine = blocksPerLine;
                    component.blocksPerColumn = blocksPerColumn;
                    component.blocks = blocks;
                }
            }
            frame.maxH = maxH;
            frame.maxV = maxV;
            frame.mcusPerLine = mcusPerLine;
            frame.mcusPerColumn = mcusPerColumn;
        }

        var jfif = null,
            adobe = null,
            pixels = null,
            frame, resetInterval,
            quantizationTables = [],
            frames = [],
            huffmanTablesAC = [],
            huffmanTablesDC = [],
            fileMarker = readUint16();

        if (fileMarker != 0xFFD8)
        {
            throw new Exception('decode', "Invalid JPEG");
        }
        
        fileMarker = readUint16();

        while (fileMarker != 0xFFD9)
        { // EOI (End of image)
            var i, j, l;
            switch (fileMarker)
            {
            case 0xFFE0: // APP0 (Application Specific)
            case 0xFFE1: // APP1
            case 0xFFE2: // APP2
            case 0xFFE3: // APP3
            case 0xFFE4: // APP4
            case 0xFFE5: // APP5
            case 0xFFE6: // APP6
            case 0xFFE7: // APP7
            case 0xFFE8: // APP8
            case 0xFFE9: // APP9
            case 0xFFEA: // APP10
            case 0xFFEB: // APP11
            case 0xFFEC: // APP12
            case 0xFFED: // APP13
            case 0xFFEE: // APP14
            case 0xFFEF: // APP15
            case 0xFFFE: // COM (Comment)
                var appData = readDataBlock();
                if (fileMarker === 0xFFE0)
                {
                    if (appData[0] === 0x4A && appData[1] === 0x46 && appData[2] === 0x49 &&
                        appData[3] === 0x46 && appData[4] === 0)
                    { // 'JFIF\x00'
                        jfif = {
                            version:
                            {
                                major: appData[5],
                                minor: appData[6]
                            },
                            densityUnits: appData[7],
                            xDensity: (appData[8] << 8) | appData[9],
                            yDensity: (appData[10] << 8) | appData[11],
                            thumbWidth: appData[12],
                            thumbHeight: appData[13],
                            thumbData: appData.subarray(14, 14 + 3 * appData[12] * appData[13])
                        };
                    }
                }
                if (fileMarker === 0xFFEE)
                {
                    if (appData[0] === 0x41 && appData[1] === 0x64 && appData[2] === 0x6F &&
                        appData[3] === 0x62 && appData[4] === 0x65 && appData[5] === 0)
                    { // 'Adobe\x00'
                        adobe = {
                            version: appData[6],
                            flags0: (appData[7] << 8) | appData[8],
                            flags1: (appData[9] << 8) | appData[10],
                            transformCode: appData[11]
                        };
                    }
                }
                break;
            case 0xFFDB: // DQT (Define Quantization Tables)
                var quantizationTablesLength = readUint16();
                var quantizationTablesEnd = quantizationTablesLength + offset - 2;
                while (offset < quantizationTablesEnd)
                {
                    var quantizationTableSpec = data[offset++];
                    var tableData = new Int32Array(64);
                    if ((quantizationTableSpec >> 4) === 0)
                    { // 8 bit values
                        for (j = 0; j < 64; j++)
                        {
                            var z = dctZigZag[j];
                            tableData[z] = data[offset++];
                        }
                    }
                    else if ((quantizationTableSpec >> 4) === 1)
                    { //16 bit
                        for (j = 0; j < 64; j++)
                        {
                            var z = dctZigZag[j];
                            tableData[z] = readUint16();
                        }
                    }
                    else throw new Exception('decode', "Invalid JPEG table spec");
                    quantizationTables[quantizationTableSpec & 15] = tableData;
                }
                break;
            case 0xFFC0: // SOF0 (Start of Frame, Baseline DCT)
            case 0xFFC2: // SOF2 (Start of Frame, Progressive DCT)
                readUint16(); // skip data length
                frame = {};
                frame.progressive = (fileMarker === 0xFFC2);
                frame.precision = data[offset++];
                frame.scanLines = readUint16();
                frame.samplesPerLine = readUint16();
                frame.components = {};
                frame.componentsOrder = [];
                var componentsCount = data[offset++],
                    componentId;
                var maxH = 0,
                    maxV = 0;
                for (i = 0; i < componentsCount; i++)
                {
                    componentId = data[offset];
                    var h = data[offset + 1] >> 4;
                    var v = data[offset + 1] & 15;
                    var qId = data[offset + 2];
                    frame.componentsOrder.push(componentId);
                    frame.components[componentId] = {
                        h: h,
                        v: v,
                        quantizationTable: quantizationTables[qId]
                    };
                    offset += 3;
                }
                prepareComponents(frame);
                frames.push(frame);
                break;
            case 0xFFC4: // DHT (Define Huffman Tables)
                var huffmanLength = readUint16();
                for (i = 2; i < huffmanLength;)
                {
                    var huffmanTableSpec = data[offset++];
                    var codeLengths = new Uint8Array(16);
                    var codeLengthSum = 0;
                    for (j = 0; j < 16; j++, offset++)
                        codeLengthSum += (codeLengths[j] = data[offset]);
                    var huffmanValues = new Uint8Array(codeLengthSum);
                    for (j = 0; j < codeLengthSum; j++, offset++)
                        huffmanValues[j] = data[offset];
                    i += 17 + codeLengthSum;
                    ((huffmanTableSpec >> 4) === 0 ?
                        huffmanTablesDC : huffmanTablesAC)[huffmanTableSpec & 15] =
                        buildHuffmanTable(codeLengths, huffmanValues);
                }
                break;
            case 0xFFDD: // DRI (Define Restart Interval)
                readUint16(); // skip data length
                resetInterval = readUint16();
                break;
            case 0xFFDA: // SOS (Start of Scan)
                var scanLength = readUint16();
                var selectorsCount = data[offset++];
                var components = [],
                    component;
                for (i = 0; i < selectorsCount; i++)
                {
                    component = frame.components[data[offset++]];
                    var tableSpec = data[offset++];
                    component.huffmanTableDC = huffmanTablesDC[tableSpec >> 4];
                    component.huffmanTableAC = huffmanTablesAC[tableSpec & 15];
                    components.push(component);
                }
                var spectralStart = data[offset++];
                var spectralEnd = data[offset++];
                var successiveApproximation = data[offset++];
                var processed = decodeScan(data, offset,
                    frame, components, resetInterval,
                    spectralStart, spectralEnd,
                    successiveApproximation >> 4, successiveApproximation & 15);
                offset += processed;
                break;
            case 0xFF00:
                offset += 1;
                break;
            default:
                if (data[offset - 3] == 0xFF &&
                    data[offset - 2] >= 0xC0 && data[offset - 2] <= 0xFE)
                {
                    offset -= 3;
                    break;
                }
                offset += 2;
                break;
            }
            fileMarker = readUint16();
        }

        if (method != 0 && data.length - offset > 9)
        {
            var result = data.subarray(offset);
            fileMarker = data.subarray(-2);
            if (fileMarker[0] == 255 && fileMarker[1] == 217)
                result = result.subarray(0, -2);     
        }
        else
        {
            var sum = 0;
            if (quantizationTables.length != 2)
                throw new Exception('decode', "Wrong JPEG tables count");
            for (var i = 0; i < 64; i++)
                sum += quantizationTables[0][i] + quantizationTables[1][i];
            if (sum != 128)
                throw new Exception('decode', "File not encrypted");
            if (frames.length != 1)
                throw new Exception('decode', "Wrong JPEG frames count");
            if (frame.componentsOrder.length != 3)
                throw new Exception('decode', "Wrong JPEG components count");

            var component = frame.components[frame.componentsOrder[0]],
                blocksPerLine = component.blocksPerLine,
                blocksPerColumn = component.blocksPerColumn,
                progress, lastProgress = 0, t = 0,
                result = [], dct, word, k = -1;

            for (var blockRow = 0; blockRow < blocksPerColumn; blockRow++){
                for (var blockCol = 0; blockCol < blocksPerLine; blockCol++){
                    for (var i = 0; i < 3; i++){
                        component = frame.components[frame.componentsOrder[i]];
                        dct = component.blocks[blockRow][blockCol];
                        for (var j = 0; j < 64; j++){
                            if (dct[dctZigZag[j]] >> 1){
                                if (!(t&3)) k++;
                                word = dct[dctZigZag[j]] & 3;
                                result[k] |= word << ((~t++&3)<<1);
                            }
                        }
                    }
                }

                progress = 100.0 * (blockRow + 1) / blocksPerColumn | 0;
                if (progress > lastProgress + 9)
                {
                    postMessage({type: 'progress', name: 'decode', progress: progress});
                    lastProgress = progress;
                }
            }
        }

        Crypto.prototype.data = new Uint8Array(result);
        var duration = new Date().getTime() - timeStart;

        postMessage({
            type: 'decode',
            time:  duration,
            isize: data.length,
            csize: result.length,
            rate:  100 * result.length / data.length,
        });
    }

    parseMethod();
    jpegDecode(new Uint8Array(buf));
}
