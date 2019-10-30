# The X299 OpenCore Hackintosh

Hardware:
* i9 7920X
* Noctua NH D15
* Asus Strix X299-E Gaming
* MSI AirBoost Vega 56 with AIO cooler
* WD Black SN750 1TB NVMe
* 32GB 2666Mhz (4x8GB)
* Apple BCM94360CD

X299 config.plist specifics:
* `slide=N`
* `DisableIoMapper` set to `YES`
* Ethernet set to `built-in`
* `AppleRTC` kernel Patches(reboots into BIOS safemode)
* `layout-id` set to 11

For building the rest of the config.plist, see [OpenCore Vanilla Desktop Guide](https://khronokernel-2.gitbook.io/opencore-vanilla-desktop-guide/)

X299 SSDTs:
* `SSDT-EC-USBX-X299`: Powers off `EC0` controller and creates a fake EC just for macOS, needed for all Catalina users
* `SSDT-PLUG-X299`: Sets `Plugin-type=1` to `CP00`
* `SSDT-HPET`: Resolves IRQ conflicts, not needed but for piece of mind
* `SSDT-SBUS-MCHC`: Creates SMbus device and resolves issues with DeviceProperties injection when using SSDTs like `SSDT-XHCI`, `SSDT-XHCX` and `SSDT-SATA`
* `SSDT-XHCI`, `SSDT-XHCX` and `SSDT-SATA`: DeviceProperties injection, mostly cosmetic

X299 specific kexts:

* `X299-Map`: Maps USB chipset ports
* `AsMedia-Map`: Maps AsMedia 3.1 ports, both front and rear
* `VoodooTSCSync`: Synchronize the TSC, can be fixed via OpenCore as well. Change `IOCPUNumber` inside the `Info.plist` to 1 less than total number of threads


What doesn't work?
* CPU Name: Too lazy to fix atm, easy to set it in OpenCore


BIOS settings:
* CFG-Lock: Disable
   * If can't disable, turn on `AppleCpuPmCfgLock` and `AppleXcpmCfgLock`. Without this, you won't go far for install
* UEFI mode
* CSM: Off
* legacy USB: Off
* Mass Storage Device: Off
