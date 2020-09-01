# OpenCore running on Asus X299-E Strix

![](/images/aboutthismac.png)
 
 What's this for? Not too many X299 hardware running macOS, let alone OpenCore so thought I'd post this ;p 
 Please use this as a base **and not a guide** .For a proper guide, please follow the [OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/)
 
 **Note**: This system was built with the BIOS Version 2002, and I've had reports that Version 3006+ has broken a few things:
 
 * ~~BIOS cannot properly unlock the MSR E2 register~~
   * v3105 resolves this issue
 * AWAC clock has been added
   * This will require [SSDT-RTC0-RANGE.dsl](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/SSDT-RTC0-RANGE.dsl)
 
## What work and what doesn't

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
* Boot Chime to internal speaker(hooked up a genuine PowerMac speaker!)
* OpenCore GUI
  * Above 2 will require the resources folder to be populated with files from here: [OcBinaryData](https://github.com/acidanthera/OcBinaryData)
* Serial Debugging
  * If you do a lot of kernel debugging like I do, this board will be great. Remember to enable serial in the BIOS and have a [Serial header to DB9](https://www.amazon.ca/gp/product/B001Y1F0HW/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1), and another machine to recieve the signal(if the other machine doesn't have serial, this [DB9 to USB  RS 232 adapter](https://www.amazon.ca/gp/product/B075YGKFC1/ref=ppx_yo_dt_b_asin_title_o00_s01?ie=UTF8&psc=1) will work fine). I recommend having [CoolTerm](https://freeware.the-meiers.org) for serial logging, I found it the simplest to use.
  * You'll also need the following added to boot-args for proper output:
  
```
debug=0x8 serial=5
```

Doesn't work:

* Onboard Wifi: Won't work, I removed it and use a genuine Apple Airport BCM94360CD Card with PCIe x1 adapter.
  * For supported card, see here: [Wireless Buyers guide](https://dortania.github.io/Wireless-Buyers-Guide/)
* Onboard Bluetooth: Works inconsistently, replaced with BCM94360CD so didn't look into it, see [this thread](https://github.com/daliansky/XiaoMi-Pro-Hackintosh/issues/262) for some ideas.
* SideCar: Since 10.15.4, I've not been able to get sidecar working, been actively looking for fixes though:  [Sidecar not working on iGPU-less systems reliably](https://github.com/AMD-OSX/bugtracker/issues/1)
 
Big Sur note:

* To run macOS 11, Big Sur, you'll need the following:
  * Latest builds of all your kexts
  * Build of OpenCore 0.6.0
  * RTC patch
  
For the last one, this is due to Asus not mapping all the RTC regions for some reason. Specifically skipping regions 0x72 and 0x73. And in Big Sur, AppleRTC gets a lot saltier with this and won't boot. So we force in the extra regions with a simple 0x02 to 0x04 replace, see below patch:

Under ACPI -> Patch:
  
| Comment | String | Fix RTC Range |
| :--- | :--- | :--- |
| Enabled | Boolean | YES |
| Count | Number | 0 |
| Limit | Number | 0 |
| Find | Data | 5F435253 11180A15 47017000 70000102 47017400 74000104 22000179 |
| Replace | Data | 5F435253 11180A15 47017000 70000104 47017400 74000104 22000179 |

Alternatively you can also use the sample SSDT-RTC0-RANGE, which may be better suited if you plan to dual boot with Linux and Windows often. I documented the process in OpenCorePkg: [SSDT-RTC0-RANGE.dsl](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/AcpiSamples/SSDT-RTC0-RANGE.dsl)

## OpenCore Specifics

### Kexts

* [`VirtualSMC`](https://github.com/acidanthera/VirtualSMC)
* [`Lilu`](https://github.com/vit9696/Lilu/releases)
* [`AppleALC`](https://github.com/vit9696/AppleALC/releases)
* [`WhateverGreen`](https://github.com/acidanthera/WhateverGreen/releases)
  * Not needed on MacPro7,1
* [`IntelMausiEthernet`](https://github.com/Mieze/IntelMausiEthernet)
* [`TscAdjustReset`](https://github.com/interferenc/TSCAdjustReset)
  * Note that this kext needs to be configured to the amount of threads minus 1 in your CPU
* [`X299-Map`](/Kexts/X299-Map.kext.zip)
   * Maps USB ports, **please make your own as this is just an example**

### config.plist

#### ACPI

##### Add

* [SSDT-EC-USBX-X299](/ACPI-Compiled/SSDT-EC-USBX-X299.aml)
  * Creates a fake EC and fixes USB power. Note I do not power off the original EC, reason for this is due to a huge mess around sleep and `_GPE`. Turning off this EC makes waking a pain without hacky fixes
* [SSDT-PLUG-X299](/ACPI-Compiled/SSDT-PLUG-X299.aml)
  * Sets `Plugin-type=1` to `SB.SCK0.CP00` allowing for proper CPU power management
* [SSDT-SBUS-MCHC](/ACPI-Compiled/SSDT-SBUS-MCHC.aml)
   * Creates SMBus device allowing AppleSMBus to load
* [SSDT-RTC0-RANGE-v3006](/ACPI-Compiled/SSDT-RTC0-RANGE-v3006.aml)
  * BIOS v2002 and older should use [SSDT-RTC0-RANGE-v2002](/ACPI-Compiled/SSDT-RTC0-RANGE-v2002.aml)
  

#### Booter

##### Quirks

| Quirk | Enabled | Comment |
| :--- | :--- | :--- |
| AvoidRuntimeDefrag | True | Needed to boot |
| DevirtualiseMmio | True | Adds extra allocation areas |
| EnableWriteUnprotected | False | Conflicts with RebuildAppleMemoryMap below |
| ProvideCustomSlide | True | Ensures bad sectors aren't used for booting |
| RebuildAppleMemoryMap | True | Fix allocations due to memory map issues |
| SyncRuntimePermissions | True | Needed for booting Windows and linux correctly |


#### DeviceProperties

##### PciRoot(0x0)/Pci(0x1F,0x3)

```
layout-id | Data | 01000000
```

#### Kernel

##### Quirks

| Quirk | Enabled | Comment |
| :--- | :--- | :--- |
| DisableIOMapper | True | Needed if you plan to use VT-D in Windows or Linux |
| PanicNoKextDump | True | Helps with troubleshooting |
| PowerTimeoutKernelPanic | True | Helps with audio related kernel panics |


#### NVRAM

###### 7C436110-AB2A-4BBB-A880-FE41995C9F82

| arg | value |
| :--- | :--- |
| boot-args | -v debug=0x100 keepsyms=1 |


#### SMBIOS

* iMacPro1,1 or MacPro7,1 SMBIOS
  * Note that MacPro7,1 is Catalina+ only
  * iMacPro1,1 will need WhateverGreen.kext as well

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
   * Newer BIOS updates do show this option, make sure you're on v3105 for best results
* Legacy USB: Disabled
* Above 4G encoding: Enabled
* CSM: Disabled
* OS Type: Windows UEFI

I've also provided a BIOS-settings.txt here, you can actually load it off a USB so you know you didn't miss any weird settings: [X299_Strix_OpenCore_setting.txt](/X299_Strix_OpenCore_setting.txt)
