# MATLAB-Based JPEG Encoder & Decoder with Adaptive Quantization

This repository contains a custom implementation of a **JPEG Encoder and Decoder** pipeline developed in **MATLAB**, completed as part of the Digital Signal Processing course (ELE 474) at TOBB University of Economics and Technology (TOBB ETÜ)[cite: 2].

## Project Overview

The project is structured into two main parts[cite: 2]:
1. **Standard JPEG Codec (Part 1):** Implementation of a full, lossless/lossy image compression and reconstruction pipeline from scratch without relying on built-in toolbox encoder/decoder functions[cite: 2].
2. **Adaptive Quantization (Part 2):** Optimization of the quantization matrix dynamically using image entropy and exponential curve-fitting techniques to maintain a target image quality (PSNR $\ge$ 30) while maximizing the compression ratio[cite: 2].

---

## Pipeline Architecture

### Part 1: Standard JPEG Codec
* **Preprocessing:** Reads a grayscale bitmap image (`lena.bmp`), converts it to `double`, and centers pixel values around zero by subtracting 128[cite: 2].
* **Block Processing & DCT:** Splits the image into $8\times8$ blocks and applies the **Discrete Cosine Transform (DCT)** via matrix multiplication ($T \cdot Block \cdot T^T$) for frequency domain transformation[cite: 2].
* **Quantization:** Divides the frequency blocks by a standard quantization table and rounds to the nearest integer (lossy compression step)[cite: 2].
* **ZigZag Scanning:** Converts $8\times8$ matrices into $1\times64$ vectors following the standard ZigZag traversal pattern to group low-frequency components together[cite: 2].
* **Huffman Coding:** Generates dynamic probability-based Huffman tables and encodes the bitstream for lossless entropy reduction[cite: 2].
* **Decoder Pipeline:** Executes the exact reverse operations—Huffman Decoding, Inverse ZigZag, Dequantization, and Inverse DCT—to reconstruct the image[cite: 2].

### Part 2: Adaptive Quantization
* Evaluated multiple statistical methods (Pixel Entropy, DCT Entropy, Pixel Gradient, DCT Gradient, and FFT) to identify high/low information regions[cite: 2].
* Determined that **Pixel Entropy** coupled with an exponential scaling function provides the optimal trade-off between visual quality and file size[cite: 2].
* Dynamically scales the quantization matrix per block based on entropy boundaries to keep the Peak Signal-to-Noise Ratio (PSNR) around $\sim 30.0$[cite: 2].

---

## Performance Summary (Adaptive Methods Comparison)

| Method | PSNR | SSIM | Compression Ratio |
| :--- | :---: | :---: | :---: |
| **Standard JPEG**[cite: 2] | 30.079[cite: 2] | 0.8133[cite: 2] | 7.2865[cite: 2] |
| **DCT Entropy**[cite: 2] | 30.0804[cite: 2] | 0.8171[cite: 2] | 7.2288[cite: 2] |
| **Image Entropy (Selected)**[cite: 2] | 30.0163[cite: 2] | 0.8086[cite: 2] | 7.2826[cite: 2] |
| **Image Gradient**[cite: 2] | 30.0842[cite: 2] | 0.8039[cite: 2] | 6.7488[cite: 2] |

---

## Repository Structure

* `Soru-1.m` — Full implementation of the standard JPEG Encoder/Decoder with custom ZigZag and Huffman functions[cite: 2].
* `Soru-2.m` — Implementation of the Adaptive Quantization algorithm with entropy evaluation and exponential curve-fitting[cite: 2].
* `lena.bmp` — Input test image[cite: 2].

## Authors
* **Uğur Altınıışık**[cite: 2]
* **Oğuz Özüm**[cite: 2]

--- 
*TOBB University of Economics and Technology, Department of Electrical and Electronics Engineering[cite: 2].*