% Soru-1 Kodu

clear all
close all
clc

image = imread('lena.bmp');
A = double(image)-128;
[M,N] = size(A);
blockLen = 8;
dctMat = dctMatrixFunc(blockLen);
quantizMat = [16 11 10 16 24  40  51  61;
              12 12 14 19 26  58  60  55;
              14 13 16 24 40  57  69  56;
              14 17 22 29 51  87  80  61;
              18 22 37 56 68 109 103  77;
              24 35 55 64 81 104 113  92;
              49 64 78 87 103 121 120 101;
              72 92 95 98 112 100 103  99];

%% DCT + Quantization
numIterRow = M/blockLen;
numIterCol = N/blockLen;
imageBlockMat = zeros(blockLen, blockLen, numIterRow, numIterCol);
for i = 1:numIterRow
    for j = 1:numIterCol
        imageBlock = A((i-1)*blockLen+1:i*blockLen, (j-1)*blockLen+1:j*blockLen);
        imageBlockMat(:,:,i,j) = round(dctMat*imageBlock*dctMat'./quantizMat);
    end
end

%% Zigzag & Huffman Encoding
zigzagArr = zeros(1, blockLen*blockLen, numIterRow, numIterCol);
for i = 1:numIterRow
    for j = 1:numIterCol
        zigzagArr(:,:,i,j) = zigzagFunc(imageBlockMat(:,:,i,j));
    end
end
zigzagReshaped = reshape(zigzagArr, 1, []);
numSet = getMsg(zigzagReshaped);
probs = getProbs(zigzagReshaped, numSet);
table = getHuffman(numSet, probs);
code = huffmanEncoder(zigzagReshaped, table);

%% Huffman Decoding & Inv Zigzag
decodedStr = huffmanDecoder(code, table);
decodedStr = reshape(decodedStr, 64, length(decodedStr)/64);
decodedStr = decodedStr';
imageBlockMatDecoded = zeros(size(imageBlockMat));
for i = 1:numIterRow
    for j = 1:numIterCol
        index = (i-1)*64+j;
        imageBlockMatDecoded(:,:,j,i) = inv_zigzagFunc(decodedStr(index,:),8,8);
    end
end

%% Dequantization + Inverse DCT
dqImageBlockMat = imageBlockMatDecoded.*quantizMat;
for i = 1:numIterRow
    for j = 1:numIterCol
        idctImageBlock = dctMat'*dqImageBlockMat(:,:,i,j)*dctMat;
        idctImageBlockMat((i-1)*blockLen+1:i*blockLen, (j-1)*blockLen+1:j*blockLen) = idctImageBlock;
    end
end

imageRectonst = uint8(idctImageBlockMat + 128);
psnrImage = psnr(imageRectonst, image);
ssimImage = ssim(imageRectonst, image);
compressionRatio = (512*512*8)/length(code);

figure
subplot(1,2,1), imshow(image)
title("Original Image")
subplot(1,2,2), imshow(imageRectonst)
title("Reconstructed Image")
imwrite(imageRectonst, 'lenaReconstructed.bmp')

%% Functions
function T = dctMatrixFunc(M)
    T = zeros(M);
    for p = 0:M-1
        for q = 0:M-1
            if p ~= 0
                T(p+1,q+1) = sqrt(2/M)*cos(pi*(2*q+1)*p/(2*M));
            else
                T(p+1,q+1) = 1/sqrt(M);
            end
        end
    end
end

function zigzagArrray = zigzagFunc(matrix)
    [m, n] = size(matrix);
    mn = m * n;
    zigzagArrray = zeros(1, mn);
    matrixColumn = 1;
    matrixRow = 1;
    changedBit = 0;
    for indexZigZag = 1:mn
        zigzagArrray(indexZigZag) = matrix(matrixRow, matrixColumn);
        if mod(matrixColumn, 2) == 1
            if matrixRow == 1 || matrixRow == 8
                matrixColumn = matrixColumn + 1;
                changedBit = 1;
            end
        end
        if mod(matrixRow, 2) == 0
            if matrixRow == 8 && matrixColumn == 8
                changedBit = 1;
            elseif matrixColumn == 1 || matrixColumn == 8
                matrixRow = matrixRow + 1;
                changedBit = 1;
            end
        end
        if changedBit == 0
            if mod((matrixColumn + matrixRow), 2) == 0
                matrixColumn = matrixColumn + 1;
                matrixRow = matrixRow - 1;
            elseif mod((matrixColumn + matrixRow), 2) == 1
                matrixRow = matrixRow + 1;
                matrixColumn = matrixColumn - 1;
            end
        end
        changedBit = 0;
    end
end

function matrix = inv_zigzagFunc(zigzagArray, wantedRow, wantedColumn)
    matrix = zeros(wantedRow, wantedColumn);
    matrixColumn = 1;
    matrixRow = 1;
    changedBit = 0;
    mn = wantedRow * wantedColumn;
    for indexZigZag = 1:mn
        matrix(matrixRow, matrixColumn) = zigzagArray(indexZigZag);
        if mod(matrixColumn, 2) == 1
            if matrixRow == 1 || matrixRow == 8
                matrixColumn = matrixColumn + 1;
                changedBit = 1;
            end
        end
        if mod(matrixRow, 2) == 0
            if matrixRow == 8 && matrixColumn == 8
                changedBit = 1;
            elseif matrixColumn == 1 || matrixColumn == 8
                matrixRow = matrixRow + 1;
                changedBit = 1;
            end
        end
        if changedBit == 0
            if mod((matrixColumn + matrixRow), 2) == 0
                matrixColumn = matrixColumn + 1;
                matrixRow = matrixRow - 1;
            elseif mod((matrixColumn + matrixRow), 2) == 1
                matrixRow = matrixRow + 1;
                matrixColumn = matrixColumn - 1;
            end
        end
        changedBit = 0;
    end
end

function out = huffmanDecoder(code, table)
    tmp = [];
    out = [];
    k = 1;
    while length(code) ~= 0
        for i = 1:length([table{:,1}])
            if isequal(tmp, table{i,2})
                out = [out, table{i,1}];
                code(1:length(tmp)) = [];
                tmp = [];
                k = 1;
            end
        end
        if ~isempty(code)
            tmp = [tmp, code(k)];
        end
        k = k + 1;
    end
end

function codeword = huffmanEncoder(str, table)
    codeword = [];
    for i = 1:length(str)
        index = strfind([table{:,1}], str(i));
        codeword = [codeword, table{index,2}];
    end
end

function table = getHuffman(msgSet, probs)
    [sortedProbs, sort_ind] = sort(probs, 'descend');
    sortedMsgSet = msgSet(sort_ind);
    for i = 1:length(sortedMsgSet)
        table{i,1} = sortedMsgSet(i);
        table{i,2} = '';
        table{i,3} = sortedProbs(i);
    end
    auxTable = table;
    flag = true;
    while flag
        for j = 1:length(auxTable{end-1,1})
            upInd = strfind([table{:,1}], auxTable{end-1,1}(j));
            table{upInd,2} = ['1', table{upInd,2}];
        end
        for j = 1:length(auxTable{end,1})
            downInd = strfind([table{:,1}], auxTable{end,1}(j));
            table{downInd,2} = ['0', table{downInd,2}];
        end
        auxTable{end-1,1} = [auxTable{end-1,1}, auxTable{end,1}];
        auxTable{end-1,3} = auxTable{end-1,3} + auxTable{end,3};
        auxTable(end,:) = [];
        [~, sort_ind] = sort([auxTable{:,3}], 'descend');
        for i = 1:length(sort_ind)
            tmp{i,1} = auxTable{sort_ind(i),1};
            tmp{i,2} = auxTable{sort_ind(i),2};
            tmp{i,3} = auxTable{sort_ind(i),3};
        end
        auxTable = tmp;
        tmp = [];
        if ((auxTable{end,3} + auxTable{end-1,3}) == 1)
            flag = false;
        end
    end
    for j = 1:length(auxTable{end-1,1})
        upInd = strfind([table{:,1}], auxTable{end-1,1}(j));
        table{upInd,2} = ['1', table{upInd,2}];
    end
    for j = 1:length(auxTable{end,1})
        downInd = strfind([table{:,1}], auxTable{end,1}(j));
        table{downInd,2} = ['0', table{downInd,2}];
    end
end

function probs = getProbs(str, msgSet)
    strLength = length(str);
    setSize = length(msgSet);
    for idx = 1:setSize
        probs(idx) = sum(str == msgSet(idx))/strLength;
    end
end

function msgSet = getMsg(str)
    strLength = length(str);
    msgSet = [];
    for i = 1:strLength
        if isempty(find(msgSet == str(i)))
            msgSet = [msgSet, str(i)];
        end
    end
end