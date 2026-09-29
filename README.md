# device_xiaomi_amethyst-recovery

Recovery tree for this Xiaomi device
- Xiaomi Redmi Note _14 Pro+_ 5G (codename: `amethyst`) (January 2025)

## Device specifications

Device                  | Redmi Note 14 Pro+ 5G
:-----------------------|:-------------------------------------
SoC                     | Qualcomm Snapdragon® 7s Gen 3 (SM7635)
Board                   | `volcano`                            
CPU                     | Octa-core (1x2.5 GHz Cortex-A720 & 3x2.4 GHz Cortex-A720 & 4x1.8 GHz Cortex-A520)
GPU                     | Adreno 810
Memory                  | 8/12 GB RAM
Shipped Android Version | 14.0 (HyperOS 1)
Storage                 | 256/512 GB (UFS 2.2)
MicroSD                 | No
Battery                 | Non-removable Li-Po 5110 mAh (Global)
Dimensions              | 162.5 x 74.7 x 8.8 mm
Display                 | 6.67" CrystalRes AMOLED, 120Hz, 1220x2712

## Checklist
- [x] ADB
- [x] Decryption
- [x] Touchscreen
- [x] FastbootD
- [x] Flashing
- [x] MTP
- [x] Sideload
- [x] Backups
- [x] Filesystems/Mounts
- [x] Slot switch
- [x] Haptics
- [x] Flashlight
- [x] Custom splash

## How to build
This recovery tree was initially made for `amethyst`. For historical purposes,
build the `twrp_amethyst` target

```shell
lunch twrp_amethyst-bp2a-eng && mka adbd recoveryimage
```
