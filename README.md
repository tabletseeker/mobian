<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/tabletseeker/mobian/blob/master/media/logo_light.png" width=64% height=58%>
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/tabletseeker/mobian/blob/master/media/logo_dark.png" width=64% height=58%>
  <img alt="Shows a black logo in light color mode and a white one in dark color mode.">
</picture>

A 100% Debian Linux, free, privacy focused, open-source operating system targeting x86-x64 touch devices, designed to liberate users from any kind of Google or third party surveilance, data collection and security concerns. This fork only uses official Debian sources, meaning no third party repositories, packages or code of any kind, while granting users complete control over every single package that is installed. The native implementation of custom kernels with the included build recipes enables support for almost any brand/model of x86-x64 tablet or lap-top, such as Surface Pro 3-10, Zenbook, Thinkpad, Chromebook etc.  and a range of ARM phones. Additionally, custom or deb packages and files of any kind can also be included. The mobian build-script produces personalized images, with unlimited customization of any available setting and device behavior.

<img src=https://github.com/tabletseeker/mobian/blob/master/media/1.png width=100% height=100%>

## Roadmap
- [ ] [Preview](https://github.com/tabletseeker/mobian/blob/master/README.md#general-ui)
- [ ] [Features](https://github.com/tabletseeker/mobian/blob/master/README.md#highlights)
- [ ] [Installation](https://github.com/tabletseeker/mobian/blob/master/README.md#images)
- [ ] [Building](https://github.com/tabletseeker/mobian/blob/master/README.md#building)
    - [ ] [Dependencies](https://github.com/tabletseeker/mobian/blob/master/README.md#dependencies)
    - [ ] [How it works](https://github.com/tabletseeker/mobian/blob/master/README.md#description)
    - [ ] [Target Devices](https://github.com/tabletseeker/mobian/blob/master/README.md#devices)
    - [ ] [Parameters](https://github.com/tabletseeker/mobian/blob/master/README.md#build-arguments)
    - [ ] [Custom Kernel](https://github.com/tabletseeker/mobian/blob/master/README.md#kernel-packages)
    - [ ] [Custom Packages](https://github.com/tabletseeker/mobian/blob/master/README.md#user-packages-and-files)
    - [ ] [Sample Commands](https://github.com/tabletseeker/mobian/blob/master/README.md#command-structure)
- [ ] [Build Preparation](https://github.com/tabletseeker/mobian/blob/master/README.md#before-you-start)
- [ ] [Custom Apps](https://github.com/tabletseeker/mobian/blob/master/README.md#webapp-manager)
- [ ] [System Settings](https://github.com/tabletseeker/mobian/blob/master/README.md#configuration)
- [ ] [Credits](https://github.com/tabletseeker/mobian/blob/master/README.md#credits-)
- [ ] [Donations](https://github.com/tabletseeker/mobian/blob/master/README.md#donations-)
- [ ] [Community](https://github.com/tabletseeker/mobian/blob/master/README.md#community-)


## Sneak Peek
- [x] Preview
### General UI
* Mobian uses a phosh environment by default which if so desired can be replaced with a simple change in the base package list. For example, other comparable mobile environments are Lomiri and Plasma Mobile.

  <img src="https://github.com/tabletseeker/mobian/blob/master/media/preview.gif" width="70%" height="70%">

### Spotify
* The spotify-client .deb package can be installed directly or during building by placing it in `mobian/overlays/packages/deb`.

  <img src="https://github.com/tabletseeker/mobian/blob/master/media/spotify.gif" width="70%" height="70%">

### Netflix
* At the time of writing Debian does not yet offer a Netflix package. Webapp-manager appears to be the most conveniant solution. Both previews are displaying the webapp versions of Netflix and Spotify. See [🔼 Webapp Manager](#Webapp-Manager)

  <img src="https://github.com/tabletseeker/mobian/blob/master/media/netflix.gif" width="70%" height="70%">

[🔼 Back to Top](#Roadmap)

## Highlights
- [x] Features

* 100% Debian FOSS
* 100% Official Debian Sources
* No 3rd party Mobian repositories or packages
* Adding support for custom kernels & many x86-x64 touch devices (Surface Pro, Zenbook, Yoga etc.)
* Major amd64 UI & Bug fixes
* Adding Phosh defaults like OSK, Intel Chipset Support etc.
* Fixed amd64 installer & added Live/Minimal calamares version
* Enabling inclusion of .deb and ordinary files into image filesystem
* Github CI
* Support for all Debian releases - bookworm,trixie,forky,sid
* Updated build script & recipes
* Customizable package lists & default settings
* Code refactoring

[🔼 Back to Top](#Roadmap)

## Images
- [x] Installation

### x86-x64 Laptops, All-In-Ones & Tablets

#### Installer Image

By using option `-o` during building, you can produce a Mobian installer image that contains a basic Phosh environemnt and calamares to install the filesystem.

This repo features two branches, which produce different installer images.

1. master
   * Full Phosh Live Environment, allowing users to test their device before starting the installation
   * Custom kernels are also installed on the live system, so touch sensitivity and other hardware can be checked
   * Essential firmware and wifi drivers enabling internet access in case additional packages are needed for testing
   
   Note: Live installer images come with a Calamares shortcut that starts the installation.
   
   <img src=https://github.com/tabletseeker/mobian/blob/master/media/install1.png width=65% height=75%>

2. mobian-light
   * Designed to be lightweight
   * Installer-Only, no desktop environment
   * Includes essential firmware, limited locales/language support, minimal base & phosh package lists
   
   Note: Build option `-K` globally enables automatic on-screen-keyboard for devices w/o a physical keyboard.
   
   <img src=https://i.postimg.cc/W3qqKK08/Screenshot-2026-06-06-00-48-19.png width=65% height=75%>
 
1. Download or build your installer image. Extract it, if compression was chosen.
      ```sh
       unxz -kv mobian-<release>.img.xz
      ```
2. The following command will create a bootable USB Stick.
      ```sh
      dd if=mobian-<release>.img of=/dev/sdX bs=4096K status=progress
      ```

3.  Launch the installer and complete all steps.

    <img src=https://github.com/tabletseeker/mobian/blob/master/media/install2.png width=45% height=75%>
    <img src=https://github.com/tabletseeker/mobian/blob/master/media/install3.png width=45% height=75%>
    <img src=https://github.com/tabletseeker/mobian/blob/master/media/install4.png width=45% height=75%>
    <img src=https://github.com/tabletseeker/mobian/blob/master/media/install5.png width=45% height=75%>

#### Github Releases

Multiple installer images can be found on the Github Release page. The postfix `-live` represents master and `-minimal` lightweight branch builds.

<img src=https://i.postimg.cc/50jTvBrL/live.png width=60% height=75%>
<img src=https://i.postimg.cc/7hn3ZcNB/minimal.png width=60% height=75%>

Images featuring a custom kernel for specific devices carry an additional identifier. In the following example, the linux-surface kernel for Surface Pro devices has been included. 

<img src=https://i.postimg.cc/DyfwSZdf/minimal.png width=60% height=75%>

#### Test with Qemu
You can also run images locally using qemu and even install it to a .qcow2 disk.
1. Create .qcow2 file if you intend to install the image locally.
    ```
    qemu-img create -f qcow2 target_disk.qcow2 20G
    ```
2. Change directory into your build folder.
    ```
    cd mobian
    ```
3. Run the installer image with Qemu.
    ```
    qemu-system-x86_64 -drive format=raw,file=$(find . -type f -name "*.img" | tail -1) -enable-kvm -cpu host -device VGA,xres=1600,yres=1000 -global VGA.vgamem_mb=64 -m 2048 -smp cores=4 -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd -drive file=target_disk.qcow2,format=qcow2,if=virtio

    ```

4. After installing Mobian to the disk, you can run it like so.
    ```
    qemu-system-x86_64 -enable-kvm -cpu host -device VGA,xres=1600,yres=1000 -global VGA.vgamem_mb=64 -m 2048 -smp cores=4 -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd -drive file=target_disk.qcow2,format=qcow2,if=virtio

    ```

    <img src=https://i.ibb.co/bR6ck0v5/image.png width=65% height=75%>

#### Standard Image

Regular Mobian images come with the default kernel package `linux-image-amd64` and don't have any additional options, title pre- or postfixes.

<img src=https://i.postimg.cc/xCqhHvZ5/regular.png width=60% height=75%>

You can directly write a regular Mobian image to any device by using bmaptool.

     sudo bmaptool copy <image> /dev/sdX

It can also be run with Qemu using the following command.

    qemu-system-x86_64 -drive format=raw,file=$(find . -type f -name "*.img" | tail -1) -enable-kvm -cpu host -device VGA,xres=1600,yres=1000 -global VGA.vgamem_mb=64 -m 2048 -smp cores=4 -drive  if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd


### For Phones & ARM Devices (SD Card)

1. Insert a MicroSD card into your computer, and type the following command:
    ```
    sudo bmaptool copy <image> /dev/<sdcard>
    ```

2. You can also use `dd` to accomplish the same result.
    ```sh
    sudo dd if=<image> of=/dev/<sdcard> bs=1M
    ```

[🔼 Back to Top](#Roadmap)

## Building

### Dependencies
- [x] Install dependencies
- [x] Clone repository
1. Debian Host
   ```
    sudo apt-get install -y debos bmap-tools f2fs-tools squashfs-tools-ng xz-utils
   ```
2. Non-Debian Host

   * If your host system is not debian based, make sure to install the following packages.
   ```
    debootstrap qemu-system-x86 qemu-user-static binfmt-support squashfs-tools-ng
   ```
3. Building for Qualcom devices requires additional dependencies
   ```
    sudo apt install android-sdk-libsparse-utils yq mkbootimg
   ```
4. Building with encryption requires the package `cryptsetup`
 
5. Clone repo
   ```sh
   git clone --depth=1 --branch=master https://github.com/tabletseeker/mobian
   ```

### Description
- [x] How it works

The build script `/mobian/build.sh` processes and passes on build arguments to debos which installs a debian minbase using debootstrap, sets up packages, partitions, bootloader etc. and ultimately creates the image according to the included debos recipes. More information about debos can be found at the official debos github repistory.
https://github.com/go-debos/debos

### Devices
- [x] Target Devices

1. X86-X64 Laptops and All in One Devices: Surface Pro 3-10, Zenbook, Thinkpad, Chromebook, XPS, Lenovo Yoga etc.
  * `amd64` (includes non-free sources to install firmware)
  * `amd64-free`

2. Phones & Tablets
  * `pinephone|pinetab|sunxi`
  
  * `pinephonepro|pinetab2|rockchip`
  
  * `librem5`
 
  * `sdm845|sdm670|sm6350|sc7280|qcom-wip`

### Build Arguments
- [x] Parameters

### Switch Arguments

* These arguments do not accept values.

|  Option     | Description | Variable |
| ------------| -------------------------|-----------|
| `-k` | Install custom kernel | kernel
| `-c` | Use encryption | crypt_root
| `-d` | Use docker to run debos | use_docker
| `-D` | Enable debugging mode | debug
| `-v` | Enable verbose output | verbose
| `-i` | Only build the image | image_only
| `-z` | Enable compression | do_compress
| `-b` | Do not use bmaptool create | no_blockmap
| `-s` | Install openssh-server | ssh
| `-o` | Create installer image | installer
| `-Z` | Setup zram devices | zram
| `-C` | Inlclude contrib repository | contrib
| `-r` | Install miniramfs | miniramfs
| `-K` | Enable On-Screen-Keyboard | keyboard
| `-L` | Loads Kern Modules for Intel | intel_chipset

* Option `-K` enables the On-Screen-Keyboard by default, which can be useful for devices that exclusively rely on touch input or want the OSK to emerge when no mechanical keyboard input is attached.
* Option `-L` fixes a conflict with the `soc_button_array` and `pinctrl_intel` driver which can cause mechanical buttons like Volume Control +/- and the Power Button to stop working on Intel Chipsets. 

### Positional Arguments

* User defined values are accepted.

|  Option     | Description              | Variable | Sample Value |
| ------------| -------------------------|------------|-------|
| `-R` | Encryption password | crypt_password | lombax
| `-e` | Name of `include/${environment}.yaml` | environment | phosh
| `-H` | Set the hostname | hostname | mobian
| `-f` | Set debos env ftp_proxy | ftp_proxy | 127.0.0.1:45
| `-h` | Set debos env http_proxy | http_proxy | 127.0.0.2:53
| `-g` | Signee user id | sign | jeffrey
| `-M` | Debootstrap mirror | mirror | https://deb.debian.org/debian
| `-m` | Debos memory value | memory | 16GB
| `-p` | 4 digit system password | password | 1234
| `-t` | Target device | device | amd64
| `-u` | System username | username | jeffrey
| `-F` | Image partition fs | filesystem | ext4
| `-x` | Debian suite | debian_suite | forky
| `-S` | Suite | suite | forky
| `-Q` | Scratchdisk Size | scratchsize | 8G
| `-T` | Installer Image Size | installersize | 10GB
| `-I` |Image Size | imagesize | 15GB


[🔼 Back to Top](#Roadmap)

### Default Values

|  Variable     | Default Value |
| ------------|-------|
| `device` | pinephone 
| `username` | mobian
| `password` | 1234
| `image` | image
| `partitiontable` | gpt
| `filesystem` | ext4
| `environment` | phosh
| `arch` | arm64
| `debian_suite` | trixie

#### Default Distribution
`stable` i.e. `trixie` is the default distribution that will be built, if option `-x` is not invoked.
To build a `testing` image based on forky, use `-x forky` , or `-x bookworm` for bookworm.
`sid` can also be built, but beware of stability and realibility issues.

### Kernel Packages
- [x] Custom Kernel

1. Some devices without mainline support require custom kernels in order to enable things like touch sensitivity, cameras and other similar hardware related functionalities.

2. There are many resources such as community kernel projects allowing users to simply download pre-built kernels or providing patch tutorials and compilation guides.
   * Surface Pro 3-10: https://github.com/linux-surface/linux-surface/releases
   * Lenovo: https://gist.github.com/jbuncle/7dacde983b3c33b3b816b10e2fd2308a
   * HP Chromebook: https://github.com/1000001101000/HP_Chromebook_15
   * XPS 13: https://github.com/endeavour/DellXps7390-2in1-Manjaro-Linux-Fixes
   * HP Spectre: https://github.com/aigilea/hp_spectre_x360_14_eu0xxx
   * Samsung Galaxy Book: https://github.com/joshuagrisham/samsung-galaxybook-extras
  
4. Add your kernel files, which must be .deb packages `linux-image-{version}.deb` and `linux-headers-{version}.deb` to `mobian/kernel`
5. Use option `-k` when running the build script in order to trigger the installation of your kernel packages.

### User Packages and Files
- [x] Custom Packages

1. `.deb` packages can be added to `mobian/overlays/packages/deb` and will be automatically installed without the need for any additional build arguments.

2. Pre-built packages can be added in-tree form to `mobian/overlays/packages/amd64`, `mobian/overlays/packages/phone` and `mobian/overlays/packages/sunxi`(pinephone). For example, a pre-built package could be included by adding `usr/lib/<package_libs>` and `usr/bin/<package_binary>`.

3. Files of any kind can also be added to the locations mentioned above. For example a custom wallpaper can be added by including the following tree. `mobian/overlays/packages/amd64/usr/share/backgrounds/mobian/wallpaper.jpg`

[🔼 Back to Top](#Roadmap)
 
### Command Structure
- [x] Sample Commands
    
1. Building against device amd64-free (non-free packages excluded) with default values
  
    ```sh
    ./build.sh -t amd64-free
    ```
2. Building against device amd64 with a custom kernel
  
    ```sh
    ./build.sh -t amd64 -k
    ```
3. Building against device amd64 with a custom kernel, installer and default On-Screen-Keyboard enabled (tablets or no physical keyboard)
  
    ```sh
    ./build.sh -t amd64 -k -o -K
    ```
4. Building against device amd64 with a custom kernel, installer, default On-Screen-Keyboard enabled and loading drivers for Intel Chipsets.
  
    ```sh
    ./build.sh -t amd64 -k -v -z -o -K -L -x forky
    ```
5. Building against device amd64 with img compression, custom kernel, verbose output, debian trixie suite and a specific user and password
  
    ```sh
    ./build.sh -t amd64 -z -v -k -u "jeffrey" -p "9999" -x "bookworm"
    ```
6. Building against device pinephone with default values
  
    ```sh
    ./build.sh -t pinephone
    ```
7. Building against device librem5 with img compression and encryption
  
    ```sh
    ./build.sh -t librem5 -z -c -R "lombax"
    ```

## Before you start
- [x] Build Preparation

1. #### Caching
   The build system will cache and re-use it's output files. To create a fresh build remove *.tar.gz, *.sqfs and *.img before starting the build. For    testing or repetitive builds use `cache:true` with debootstrap and package install actions.

2. #### Docker
   Running `./build.sh -d` runs the build i.e debos inside a docker container, thus installing debos would not be required in this case.

3. #### QEMU
   `amd64` produces x86_64 raw images which can be run/tested with QEMU using the following command.
  
   ```     
   qemu-system-x86_64 -drive format=raw,file=<imagefile.img> -enable-kvm \
   -cpu host -vga std -m 2048 -smp cores=4 \
   -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd
   ```

    Using SSH to access the QEMU image, in order to collect
    logs directly from the host system, can be achieved with the following command.
    
   ```
    qemu-system-x86_64 -drive format=raw,file=<imagefile.img> -enable-kvm \
    -cpu host -vga std -m 2048 -smp cores=4 \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
    -nic user,hostfwd=tcp::8888-:22
   ```
    
    This forwards port 8888 on the host to port 22 on the guest system. Then connect the host to the guest like so.
  
   ```
     ssh mobian@localhost -p 8888
     sftp -P 8888 mobian@localhost
   ```

4. #### Virt Manager
   To create a VM based on the mobian x86_64 image, launch virt-manager, click New VM -> Import existing disk image -> select the raw image and OS version then progress to the Ready to begin installation page, check customize configuration before install then click finish.
   
   Under Hypervisor Details, change firmware to `UEFI x86_64: /usr/share/OVMF/OVMF_CODE_4M.fd` then apply and begin installation,
   the image should now boot up.
   
   Use `qemu-img` to resize and convert the raw image as needed.
      ```sh
       qemu-img convert -f raw -O qcow2 <raw_image.img> <qcow_image.qcow2>
       qemu-img resize -f qcow2 <qcow_image.qcow2> +20G
      ```

[🔼 Back to Top](#Roadmap)

## Webapp Manager
- [x] Custom Apps

1. Download the webapp-manager .deb package from any mirror of your choice. Example: https://mirrors.edge.kernel.org/linuxmint-packages/pool/main/w/webapp-manager/

   * The commands below will download the latest version from the Linux Mint Archives.
    ```sh
    MIRROR="https://mirrors.edge.kernel.org/linuxmint-packages/pool/main/w/webapp-manager/"
    DEB="$(curl -s "${MIRROR}" | grep -Po "webapp-manager[_.-a-z0-9]+_all.deb" | tail -1)"
    curl -s "${MIRROR}${DEB}" -o "${DEB}"
    ```
3. Install the webapp-manager .deb package.
    ```sh
    sudo dpkg --install -- webapp-manager*_all.deb || sudo apt install -fy
    ```
4. (Optional) Build with the webapp-manager .deb package included.
    Add the `webapp-manager*_all.deb` file to `mobian/overlays/packages/deb/` before running the build script.
5. Follow the instructions in this Youtube Tutorial which explains how to create local apps with webapp-manager.
    * Note that webapp-manager does not need to be installed separately.
  
      [![Webapp Tutorial](https://i.postimg.cc/ZR5WjZDj/1.png)](https://www.youtube.com/watch?v=pznHxmxfqPY&t=44s)

[🔼 Back to Top](#Roadmap)

## Configuration
- [x] System Settings

1. The system natively uses an On-Screen-Keyboard during touch operation and automatically switches to Mouse and Keyboard once detected.

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/4.png width=55% height=55%>

2. Mobian is designed to be 100% Google free, however it is still possible to connect accounts should users absolutely require this functionality. (Don't)

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/5.png width=55% height=55%>

3. Multiple backgrounds come pre-installed. Custom background images can be overlayed during building.

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/7.png width=55% height=55%>

4. Dark Mode and various color schemes are available out of the box. 

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/8.png width=55% height=55%>

5. Workspace management and multi-tasking features can also be leveraged. 

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/9.png width=55% height=55%>
   <img src=https://github.com/tabletseeker/mobian/blob/master/media/10.png width=55% height=55%>

6. Devices like the Surface Pro 8,9,10 with higher refresh rates will be adjustable in the display menu.

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/11.png width=55% height=55%>

7. Wireguard VPN connections are extremely power efficient on mobile devices thanks to mainline support.

   <img src=https://github.com/tabletseeker/mobian/blob/master/media/12.png width=55% height=55%>

## Credits 🥇
**Huge** thanks to the developers @mobian-team! \
Please support their work, without them none of this would be possible. \
The original project can be found here: \
https://salsa.debian.org/Mobian-team/mobian-recipes

## Donations 💗
 This project will be maintained for most devices, with all major or device specific features being implemented upon request.
 Any support is appreciated.

 Bitcoin Address: bc1qxaf820c6zynvlqv62xkyucd654e8j2xqxc4nmw
 
 <img src=https://i.postimg.cc/BbxdX478/Screenshot-2026-06-22-11-58-33.png width=10% height=10%>

## Community 🤝
For any questions, feature requests, announcements and general communication, head over to the Discussions section. \
https://github.com/tabletseeker/mobian/discussions


[🔼 Back to Top](#Roadmap)
