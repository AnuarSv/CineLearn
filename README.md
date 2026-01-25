# CineLearn

<p align="center">
  <img src="assets/icon/icon.jpg" width="120" height="120" style="border-radius: 24px">
</p>

## Releases

<p align="center">
  <h3>Latest Release (v1.0.0)</h3>
  <br>
  <!-- ARM64 (Most modern phones) -->
  <a href="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk">
    <img src="https://img.shields.io/badge/Download-Modern%20Phones%20(ARM64)-2ea44f?style=for-the-badge&logo=android&logoColor=white" alt="Download Modern APK">
  </a>
  <br><br>
  <!-- ARMv7 (Older phones) -->
  <a href="build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk">
    <img src="https://img.shields.io/badge/Download-Older%20Phones%20(ARMv7)-000000?style=for-the-badge&logo=android&logoColor=white" alt="Download Legacy APK">
  </a>
  <br>
  <br>
  <small><b>Note:</b> We now provide optimized builds (~46MB) instead of a single massive file.</small>
</p>

---

## Overview

CineLearn is a premium language learning platform designed to bridge the gap between entertainment and education. By leveraging a high-performance video player integrated with advanced linguistic tools, it enables users to learn languages naturally through cinema.

## Technical Foundations

The application is built on a modern stack prioritizeing stability, performance, and aesthetic excellence.

*   **Engine**: Flutter with Impeller rendering for fluid 60FPS interactions.
*   **Media Core**: Custom video player integration supporting 4K playback and embedded subtitle extraction.
*   **Linguistic Processing**: Integrated dictionary services providing instant morphological analysis.
*   **Intelligence**: Spaced-repetition algorithm (SM-2) for optimized long-term vocabulary retention.
*   **Storage**: Low-latency reactive database (Drift/SQLite) for real-time UI updates.

## Core Architecture

The system is partitioned into several specialized modules:

1.  **Library Module**: Intelligent file management with automatic subtitle track detection and extraction from MKV/MP4 containers.
2.  **Playback Module**: High-precision interaction layer allowing users to analyze speech segments in real-time.
3.  **Vocabulary Module**: Advanced persistence layer for saved lexicon, including automated context mapping.
4.  **Reels Module**: A short-form video review system that utilizes logical clipping to prevent storage bloat.

## License

Copyright 2026 CineLearn. All Rights Reserved.

This software and its source code are the exclusive property of CineLearn. Access to this repository is granted under the following strict conditions:

1.  **Modification Prohibited**: No person, entity, or automated system is permitted to modify, alter, or adapt any part of the source code without express written authorization from CineLearn.
2.  **Commercial Restriction**: No corporation, business, or third-party entity is permitted to use, integrate, or deploy this code for any purpose, commercial or otherwise.
3.  **Exclusive Rights**: The right to distribute, market, and sell the CineLearn application belongs solely to the original owners of CineLearn.
4.  **Enforcement**: Any unauthorized use, reproduction, or distribution of this code will be pursued to the maximum extent permitted by intellectual property law.

By accessing or using this codebase, you agree to abide by the terms of the CineLearn License.
