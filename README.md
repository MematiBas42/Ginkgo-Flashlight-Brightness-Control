# Ginkgo-Flashlight-Brightness-Control
# brightness.sh

A simple shell script to customize and permanently apply flashlight brightness on Android Redmi Note 8 (maybe more) devices with a kernel supporting adjustable LED levels (thanks to Flopster101).

## Table of Contents

* [Features](#features)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [Removing Permanent Brightness](#removing-permanent-brightness)
* [License](#license)
* [Credits](#credits)

## Features

* Set custom flashlight brightness level on supported kernels.
* Persist brightness setting across reboots by installing a service script.

## Prerequisites

* **Root access** on your Android device.
- A kernel that supports adjustable flashlight brightness — such as the [Flop Ginkgo Kernel by Flopster101](https://github.com/FlopKernel-Series/flop_ginkgo_kernel), which includes support for customizable LED levels.
* A terminal emulator (e.g., Termux) with `su` command available.

## Installation

1. Copy the script to the Adb shell data directory:

   ```bash
   cp bright.sh /data/adb/bright.sh
   ```
2. Make the script executable:

   ```bash
   su -c "chmod +x /data/adb/bright.sh"
   ```

## Usage

Run the script as root to set your desired brightness:

```bash
# Option 1: Switch to root, then execute
su
/data/adb/bright.sh

# Option 2: Single command
su -c "/data/adb/bright.sh"
```

Follow the on-screen prompts to choose and apply a brightness level. The script will:

1. Write the chosen level to the appropriate sysfs node for the flashlight LED.
2. Create a service script at `/data/adb/service.d/99permanent_flashlight_brightness.sh` to reapply the setting on every boot.

## Removing Permanent Brightness

If you decide to revert to the kernel default after reboot, remove the service file:

```bash
su -c "rm /data/adb/service.d/99permanent_flashlight_brightness.sh"
```

After removal, the brightness will follow the kernel default or last manual setting after reboot.

## License

This project is licensed under the MIT License.

**What does this mean for you?**

* You can **use**, **copy**, **modify**, **merge**, **publish**, **distribute**, **sublicense**, and/or **sell** copies of the script.
* You **must include** the original MIT License and copyright notice in any distribution.
* The software is provided **"as is"**, without warranty of any kind — use it at your own risk.

See the [LICENSE](LICENSE) file for the full text.

## Credits

* **Flopster101** for the kernel feature enabling adjustable flashlight brightness.
* **You**, for testing and using this script.

Pull requests are more than welcome — we make this place better together!
