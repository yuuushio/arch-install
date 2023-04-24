# Arch Install Notes w/ Scripts

- Before booting from installation media, `secure boot` needs to be disabled (via BIOS).

### Verify Boot Mode
Verifying that you're running UEFI:
```shell
ls /sys/firmware/efi/efivars
```
If the contents of the directory are listed, then the system is booted in UEFI mode.

## Internet
### Connect to a Network
```bash
iwctl # to enter iwd interactive prompt
```

```bash
device list
```
Scan the network; then list the found/available networks:
```bash
station [device-id] scan
station [device-id] get-networks
```
```bash
# connecting to desired network
station [device-id] connect [network-name]
```
`exit` out of iwd.

### Ping
Ping to verify that you're connected to the internet:

```shell
ping archlinux.org
```

### Update System Clock
```bash
timedatectl set-ntp true
```

## Partition Disks
List the connected devices:
```shell
fdisk -l
```

```shell
# To start the partitioning process
gdisk /dev/[disk-to-be-partitioned]
```

Create a `GPT` if it doesn't automatically do so.

```
o
```

### Partitions
#### Partition 1 (EFI)
```
n
Partition number: [enter]
First Sector: [enter]
Last Sector: +512M
Code: ef00
```

#### Partition 2 (Swap)
```
n
Partition number: [enter]
First Sector: [enter]
Last Sector: +8G
Code: 8200
```


#### Partition 3 (Root/Home)
```
n
Partition number: [enter]
First Sector: [enter]
Last Sector: [enter]
Code: [enter]
```

### Write/Save Changes
```
w
```

## - Script 1 -

- Format partitions.
- Mount partitions.
- Pacstrap.
- Fstab
- Chroot

```bash
curl -o chroot.sh https://raw.githubusercontent.com/yuuushio/arch-install/main/chroot.sh
chmod +x *.sh
./chroot.sh
```

## - Script 2 -

- General machine info/config.
- Boot loader.
- Network Manager

```bash
curl -o config.sh https://raw.githubusercontent.com/yuuushio/arch-install/main/config.sh
chmod +x *.sh
./config.sh
```

### New User

```shell
useradd -mG wheel [username]
passwd [username]
usermod -aG audio,disk,input,storage,video [username]
```

#### Enable `sudo` privileges
Uncomment `%wheel ALL = (All) All`.
```shell
vim /etc/sudoers
```

### Edit `mkinitcpio.conf`
```shell
vim /etc/mkinitcpio.conf
```
Inside `MODULES` brackets, type your GPU card - either - `amdgpu` or `nvidia`.

After making changes:
```shell
sudo mkinitcpio -p linux 
```

### Reboot
`exit` chroot.

`reboot` the system.

## - Script 3 -


### Reconnecting using `nmcli`
```shell
nmcli device wifi list
nmcli device wifi connect [network] password [password]
```

Post installation:

- yay
- Packages
- Dots
- dwm.desktop in xsessions

```
curl -o post.sh https://raw.githubusercontent.com/yuuushio/arch-install/main/post.sh
chmod +x *.sh
./post.sh
```

## Post Install

### Emptty Conf
Config at `sudo vim /etc/emptty/conf`

```
# uncomment and set your user
DEFAULT_USER=<user>

# uncomment or add and set your DE/WM
DEFAULT_SESSION=dwm

ENABLE_NUMLOCK=true
```

### Bluetooth Conf
`sudo vim /etc/bluetooth/main.conf`

```
AlwaysPairable=true

ControllerMode = bredr

FastConnectable = true
```

### Pipewire Conf
From Gentoo wiki: `/usr/share/pipewire/pipewire.conf`

Might need to disable wireplumber if pavucontrol is malfunctioning.

### Set DNS

`nm-connection-editor`
- `1.1.1.1`
- `1.0.0.1`

### Virt-manager

- Change from UEFI to bios.
- Under "CPUs," ensure that the "Copy host CPU configuration" checkbox is unchecked. You can also try changing the "CPU model" to a different option, such as `qemu64`.
