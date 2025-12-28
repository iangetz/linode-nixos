# NixOS on Linode

You can provision a Linode running NixOS using these instructions: [Install NixOS on a Linode](https://www.linode.com/docs/guides/install-nixos-on-linode/). Follow all instructions up through '[Configure NixOS](https://www.linode.com/docs/guides/install-nixos-on-linode/#configure-nixos)'. Stop once you enter `cd /mnt/etc/nixos`.

Important: Do not rewrite device identifiers which causes a conflict when you try to run NixOS installer ([open GitHub issue](https://github.com/linode/docs/issues/7375)).

## Replace Sample Configuration

Download the sample configuration.nix from this repo:

1. Change directory

	```bash
	cd /mnt/etc/nixos
	```

2. Rename currenty configuration.nix

	```bash
	mv configuration.nix configuration.nix.original
	```

3. Download the configuration.nix from this repo to the current directory

	```bash
	curl -L -o configuration.nix https://raw.githubusercontent.com/iangetz/linode-nixos/main/configuration.nix
	```

4. Inspect the original configuration.nix to confirm the `system.stateVersion` and note the version number (e.g. `"25.11"`).

	```bash
	tail configuration.nix.original
	```

5. Edit downloded configuration.nix

	```bash
	nano configuration.nix
	```

	Update anything denoted with `# Change this:`, including
	
	* `networking.hostName`
	* `time.timeZone`
	* `users.users.you` (i.e. replace `you` with your username and add your SSH public key)
	* `ip protocol tcp tcp dport 22 ct state new ip saddr` (i.e. replace `1.1.1.1` with your connecting IP adress)
	* `system.stateVersion` if it does not match the original configuration.nix

## Resume Instructions

Pickup the instructions at [Run the NixOS Installer](https://www.linode.com/docs/guides/install-nixos-on-linode/#run-the-nixos-installer), starting with `nixos-install`.

## Enable a Firewall

You technically can (and _should_) protect your Linode with a firewall before you even start the instructions above. If not before, add the new NixOS Linode to a firewall now. Allow only the IP addresses and services that should be able to access your Linode.