# OpenSSH over Wifi for initramfs-tools

## OpenSSH-initramfs

OpenSSH-initramfs starts up an OpenSSH server during initram for remote unlocking of cryptroot (Or other activities, it can be configured).

### Configuration

In `/etc/initramfs-tools/conf.d/openssh` you will find 5 values.

- `OPENSSH_PORTS` - A comma separated list of ports to listen on. This overrides the `sshd_config`.

- `OPENSSH_CONFIG_DIRECTORY` - The directory where the rest of the configuration resides.
- `OPENSSH_GENERATE_SERVER_KEYS` - Whether or not to automatically generate new server keys if they do not exist already. Can be `true`, `false`, `standard`, or `tpm` (if ssh-tpm-agent is installed).

- `OPENSSH_AUTHORIZED_USER` - The username that will be used to login. **NOTE:** If the user is not `root` a small suid helper program (See [cryptroot-unlock-suid.cpp](https://github.com/Kale-Ko/initramfs-scripts/blob/main/openssh-initramfs/cryptroot-unlock-suid.cpp)) is required to allow the user to unlock the disk, while I am fairly certain it is safe I can not be 100% sure.
- `OPENSSH_AUTHORIZED_KEYS_FILE` - The `authorized_keys` file to be copied into the initramfs.

#### `sshd_config`

The `sshd_config` is stored at `{OPENSSH_CONFIG_DIRECTORY}/sshd_config`, if it does not exist it will be created with some default (recommended) values.

#### `ssh_host_keys`

SSH host keys are stored in `{OPENSSH_CONFIG_DIRECTORY}` and must match one of the following patterns.

- `ssh_host*_key` - Standard SSH host keys (RSA, ECDSA, ED25519). **Note:** These are not encrypted in any way, someone with with access to the boot partition can read them.
- `ssh_tpm_host*_key*` - SSH TPM host keys (if ssh-tpm-agent is installed). When a TPM host key is present ssh-tpm-agent will be copied onto the initramfs and ran to unlock the host key. This has the advantage of not requiring you to potentially expose your SSH host key to someone with access to your device. Note that both the `{key}.tpm` and `{key}.pub` must be present for these to work.

## Wireless-initramfs

Made with help from the great tutorial at [https://www.marcfargas.com/](https://www.marcfargas.com/2017/12/enable-wireless-networks-in-debian-initramfs/)

Wireless-initramfs will connect your computer to a specified WiFi network during initram.

Wireless-initramfs requires configuration before it can be used.

### Configuration

In `/etc/initramfs-tools/conf.d/wireless` you will find 4 values.

- `WIRELESS_INTERFACE` - The interface name of your WiFi card (Check `ip link`).
- `WIRELESS_MODULES` - The kernel modules that need to be loaded for your WiFi card to work (See [https://wireless.docs.kernel.org/](https://wireless.docs.kernel.org/en/latest/en/users/drivers.html)).

- `WIRELESS_SSID` - The name/SSID of your WiFi network.
- `WIRELESS_PASSWORD` - The password of your WiFi network. Leave blank for open WiFi networks. **Note:** This is not encrypted in any way, someone with with access to the boot partition can read it.

If your network uses a security type other than WPA-PSK/WPA2-PSK then you will need to edit `/usr/share/initramfs-tools/hooks/wireless` to accommodate.

## ssh-tpm-agent

ssh-tpm-agent is just an optional packaging of [Foxboron/ssh-tpm-agent](https://github.com/Foxboron/ssh-tpm-agent) along with 4 basic services to run it.

It has 2 user services and 2 system services.

- `ssh-agent.service` - A user service that runs the default ssh-agent.
- `ssh-tpm-agent.service` - A user service that runs the ssh-tpm-agent with the default ssh-agent as a fallback.

- `sshd-agent.service` - A system service like `ssh-agent.service` but for sshd host keys.
- `sshd-tpm-agent.service` - A system service like `ssh-tpm-agent.service` but for sshd host keys.

Users with `ssh-agent.service` or `ssh-tpm-agent.service` enabled will have their `SSH_AUTH_SOCK` variable set automatically. The sshd `HostKeyAgent` option is also set automatically upon installation.
