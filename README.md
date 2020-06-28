![About This Mac](https://i.imgur.com/kp7ymS0.png)
 
 
 What's this for? Not too many X299 hardware running macOS, let alone OpenCore so thought I'd post this ;p 
 Please use this as a base **and not a guide** .For a proper guide, please follow the [OpenCore Desktop Guide](https://dortania.github.io/OpenCore-Desktop-Guide/)
 
 I also include a clover config as well in case you feel your issues are OpenCore based, please note that the OpenCore config is for 0.5.9 
 
 **Note**: This system was built with the BIOS Version 2002, and I've had reports that Version 3006 has broken a few things:
 
 * BIOS cannot properly unlock the MSR E2 register
   * This will require AppleCpuPmCfgLock and AppleXcpmCfgLock enabled
 * AWAC clock has been added
   * This will require [SSDT-AWAC](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/SSDT-AWAC.dsl)
 
# What work and what doesn't

Works:
* macOS High Sierra, Mojave, Catalina and Big Sur
  * See below on note regarding Big Sur support
* Native NVRAM
* Bootcamp
* Sleep
* USB power(Including iPad Pro 12.9 Charging!)
* CPU Power Management
* iTunes and Netflix
* Handoff, AirDrop and all Apple services
* [Display Brightness and Volume with Apple Keyboard](https://github.com/the0neyouseek/MonitorControl/releases)
* CPU Name
   * Easy fix under `PlatformInfo->SMBIOS->ProcessorType->3841`
* Boot Chime to internal speaker(hooked up a genuine PowerMac speaker)
* OpenCore GUI
  * Above 2 will require the resources folder to be populated with files from here: [OcBinaryData](https://github.com/acidanthera/OcBinaryData)

Doesn't work:

* Onboard Wifi: Won't work, I removed it and use a genuine Apple Airport BCM94360CD Card with PCIe x1 adapter.
* Onboard Bluetooth: Works inconsistently, replaced with BCM94360CD so didn't look into it, see [this thread](https://github.com/daliansky/XiaoMi-Pro-Hackintosh/issues/262) for some ideas.
* SideCar: Since 10.15.4, I've not been able to get sidecar working, been actively looking for fixes though:  [Sidecar not working on iGPU-less systems reliably](https://github.com/AMD-OSX/bugtracker/issues/1)
 
Big Sur note:

* To run macOS Big Sur, you'll need the following:
  * Lastest builds of all your kexts
  * Build of OpenCore 0.6.0
  * Big Sur installed on some media(kext injection in the installer is not yet supported with OpenCore)
    * VM or real mac will be required
  * RTC patch
  
For the last one, this is due to Asus not mapping all the RTC regions for some reason. Specifically skipping regions 0x72 and 0x73. And in Big Sur, AppleRTC gets a lot saltier with this and won't boot. So we force in the extra regions with a simple 0x02 to 0x04 replace, see below patch:

Under ACPI -> Patch

* Find:
  * `5F435253 11180A15 47017000 70000102 47017400 74000104 22000179`
* Replace:
  * `5F435253 11180A15 47017000 70000104 47017400 74000104 22000179`

# OpenCore Specifics

X299 config.plist specifics:
* `DevirtualiseMmio` + `ProvideCustomSlide`
  * to fix allocation errors, no need for `slide=0`
* `RebuildAppleMemoryMap` + `SyncRuntimePermissions`
  * To fix widows booting
* `DisableIoMapper` set to `YES`
  * not needed if VT-D is disabled
* `alc-layout-id` set to 1
* iMacPro1,1 or MacPro7,1 SMBIOS
  * Note that MacPro7,1 is Catalina only
  * iMacPro1,1 will need WhateverGreen.kext as well


X299 SSDTs specifics:
* `SSDT-EC-USBX-X299`: 
   * Creates a fake EC and fixes USB power. Note I do not power off the original EC, reason for this is due to a huge mess around sleep and _GPE. Turning off this EC makes waking a pain without hacky fixes
* `SSDT-PLUG-X299`: 
   * Sets `Plugin-type=1` to `SB.SCK0.CP00`
* `SSDT-SBUS-MCHC`: 
   * Creates SMBus device allowing AppleSMBus to load

X299 kexts specifics:

* `X299-Map`: 
   * Maps USB ports, **please make your own as this is just an example**
* [`VoodooTSCSync`](https://github.com/RehabMan/VoodooTSCSync): 
   * Synchronize the TSC, **required to boot on Asus X299 and other HEDT systems**


Other kexts that are needed regardless of system:

* [`VirtualSMC`](https://github.com/acidanthera/VirtualSMC)
* [`Lilu`](https://github.com/vit9696/Lilu/releases)
* [`AppleALC`](https://github.com/vit9696/AppleALC/releases)
* [`WhateverGreen`](https://github.com/acidanthera/WhateverGreen/releases)
  * not needed on MacPro7,1

Ethernet:

* [`IntelMausiEthernet`](https://github.com/Mieze/IntelMausiEthernet): For most intel controllers.

# Hardware Specifics

Hardware:
* i9 7920X
* Noctua NH D15
* Asus Strix X299-E Gaming
* Multiple GPUs tested:
  * GT 710
  * MSI Armour RX 580
  * MSI AirBoost Vega 56
  * Gigabyte RX 5700XT
    * This guy will need either `agdpmod=pikera` on iMacPro1,1 or remove WhateverGreen entirely for MacPro7,1
* WD Black SN750 1TB NVMe
* 32GB 2666Mhz (4x8GB)
* Apple BCM94360CD(pulled from a genuine iMac14,2)

Main important BIOS settings:

* Asus Multicore: Auto
* CPU Core Ratio: All Core Sync
* MSR Lock: Disabled
   * If can't disable, turn on `AppleCpuPmCfgLock` and `AppleXcpmCfgLock`. Without this, you won't go far for install.
   * newer BIOS updates do show this option
* Legacy USB: Disabled
* Above 4G ecoding: Enabled
* CSM: Disabled
* OS Type: Windows UEFI

I've also provided a BIOS-settings.txt here, you can actually load it off a USB so you know you didn't miss any weird settings: [X299_Strix_OpenCore_setting.txt](/X299_Strix_OpenCore_setting.txt)
