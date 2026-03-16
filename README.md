<div align="center">
  <img src="./.github/assets/logo-tirtayana.png" width="500" alt="TIrtayana Logo"><br>

  <b>Custom Firmware for STB B860H (Amlogic S905X)</b>

  [![Build OpenWrt](https://github.com/Krisnarhesa/openwrt-TIrtayana/actions/workflows/build-b860h.yml/badge.svg)](https://github.com/Krisnarhesa/openwrt-TIrtayana/actions/workflows/build-b860h.yml)
  [![License](https://img.shields.io/badge/License-GPL%202.0-blue.svg)](https://opensource.org/licenses/GPL-2.0)
  
  *Dedicated to Computer Network Research & Education — Information Technology, Udayana University*
</div>

---

## Overview

**TIrtayana OpenWrt** is an automated Continuous Integration (CI) repository specifically designed to construct custom firmware for the **STB B860H (Amlogic S905X)** device. This project facilitates the simultaneous compilation of three distinct firmware profiles (Minimal, Standard, and Education) with support for dynamic custom kernel selection and modern user interface ecosystem injection.

This build employs a hybrid **two-stage** system to ensure maximum reliability and hardware compatibility:
1. **OpenWrt Base Compilation:** Builds a pure root filesystem for the `armsr/armv8` (Generic EFI) architecture.
2. **Firmware Repackaging:** Injects customized Amlogic kernels and hardware bootloaders leveraging the `ophub/amlogic-s9xxx-openwrt` library.

---

## Key Features

* **Full Automation (CI/CD):** Firmware image production runs directly on GitHub servers, eliminating local computing overhead.
* **Multi-Profile Support:** Accommodates three separate compilation configurations (`minimal`, `standard`, `education`).
* **Dynamic Kernels:** Automatic selection and compilation of stable kernels (5.15.y, 6.1.y, 6.6.y) with specific override capabilities.
* **Custom Argon Theme:** Integrates directly with a specially modified `luci-theme-argon` to match the TIrtayana visual identity.
* **Preset Configurations:** Pre-configured IP (`192.168.1.1`), Root authentication, custom Banners, and package optimizations (sysctl) embedded directly into the base system.

---

## Supported Hardware Specifications

| Parameter | Specification |
| :--- | :--- |
| **Model** | STB B860H |
| **SoC** | Amlogic S905X (Quad-core ARM Cortex-A53, 1.5 GHz) |
| **RAM** | 2 GB DDR3 |
| **Primary Storage** | 8 GB eMMC |
| **Physical Connectivity** | 10/100 Mbps Ethernet, 2x USB 2.0, HDMI 2.0 |
| **Support Status** | **Supported** (Exclusive to S905X SoC variants) |

*Note: STB B860H variants featuring the HiSilicon Hi3798MV200 chip architecture are **not supported** by this firmware design.*

---

## Quick Start Guide

### Building Firmware via GitHub Actions (Recommended)
The most efficient method to build these firmware images is by utilizing the CI/CD system within this repository:

1. Navigate to the **[Actions](../../actions)** page on the repository navigation menu.
2. Select the **Build TIrtayana OpenWrt for B860H** workflow on the left sidebar.
3. Click the **Run workflow** button to execute. You may adjust the following matrix parameters:
   * **Profile Build** (Define release: `minimal`, `standard`, `education`, or `all`)
   * **Override Kernel** (Leave default, or enter a specific version such as `6.6.y`)
   * **Default IP Address** (System default is `192.168.1.1`)
   * **RootFS Partition Size** (Ideally kept at `1024` MB)
4. Allow the Runner fleet to complete compilation (Takes approximately 1-2 hours depending on GitHub server load). Ready-to-use archives (`.img.gz`) can be downloaded directly from the **Releases** channel.

### B860H Device Installation
1. Extract the compiled `.img.gz` file.
2. Utilize dedicated utility software such as **BalenaEtcher** or **Rufus** (Windows) to flash the Image onto an external storage device (Flash drive / MicroSD, min. 4GB recommended).
3. Insert the external storage into the USB port of the STB B860H.
4. Connect the STB power supply to initiate the initial OpenWrt firmware boot process.
5. Access the device administration terminal (*LuCI*) via your local web browser at the URL `http://192.168.1.1` (Default Credentials: `TIudayana`).

---

## Local Source Build (Manual Compilation)

Should testing environments require local execution on an Ubuntu/Debian system:

1. **System Dependency Preparation:**
   ```bash
   sudo apt-get update && sudo apt-get full-upgrade -y
   sudo apt-get install build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev -y
   ```

2. **Clone the Repository Locally:**
   ```bash
   git clone -b openwrt-Tirtayana https://github.com/Krisnarhesa/openwrt-TIrtayana.git
   cd openwrt-TIrtayana
   ```

3. **Trigger the Packager Script (Automated Local Build):**
   The system includes an agnostic script to bridge the Amlogic kernel compilation:
   ```bash
   sudo ./scripts/pack-b860h.sh -p standard -k 6.1.y
   ```
   *You can explore more complex parameter arguments by passing the help flag: `./scripts/pack-b860h.sh -h`*

---

## Licensing and Module Acknowledgements

This networking environment compilation module is released to the public under the [GPL-2.0](https://opensource.org/licenses/GPL-2.0) open-source license protocol. 
Highest appreciation is given to the foundational computing projects driving this open-source device:
* [Official OpenWrt Project](https://openwrt.org)
* [Amlogic Ophub Integration](https://github.com/ophub/amlogic-s9xxx-openwrt)
* [LuCI Argon Theme Development (jerrykuku)](https://github.com/jerrykuku/luci-theme-argon)

---

<br>
<div align="center">
  <b>TIrtayana OpenWrt</b> — Modern Networking Ecosystem<br>
  Final Project Module • Built with enthusiasm for Computer Science Research and Education
</div>