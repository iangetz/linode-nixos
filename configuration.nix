# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
	];

	# GRUB 2 boot loader defined in Linode configuration file

	boot.kernelParams = [ "console=ttyS0,19200n8" ];
	boot.loader.grub.extraConfig = ''
		serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
		terminal_input serial;
		terminal_output serial
	'';
	boot.loader.grub.forceInstall = true;
	boot.loader.grub.device = "nodev";
	boot.loader.timeout = 10;
	
	networking.hostName = "your-hostname";       # Change this: Add your hostname
	time.timeZone = "UTC";                       # Change this: Select your time zone

	# Enable modern Nix CLI and flakes support system-wide
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Delete any store paths that are older than 30 days and no longer referenced
	nix.gc = {
		automatic = true;
		dates = "daily";
		options = "--delete-older-than 30d";
	};

	# Reduce disk storage by deduplicating identify files in Nix store
	nix.settings.auto-optimise-store = true;

	# Change this: Define your user account and add your SSH public key
	users.users.you = {
		isNormalUser = true;
		home = "/home/you";
		description = "You";
		extraGroups = [ "wheel" "networkmanager" ];
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRoaXMgaXMgYSBkdW1teSBTU0gga2V5IGZvciBleGFtcGxlIG9ubHk= your_public_key"
		];
	};

	# List packages installed in system profile
	# You can use https://search.nixos.org/ to find more packages (and options)
	environment.systemPackages = with pkgs; [
		btop
		duf
		mtr
		ncdu
		sysstat
	];

	networking.usePredictableInterfaceNames = false;
	networking.useDHCP = false;						# Disable DHCP globally unless specified (see below)
	networking.interfaces.eth0.useDHCP = true;		# Only enable for eth0
	# Do not use default hostname 'nixos'
	networking.dhcpcd.extraConfig = ''
		# Do not accept a hostname from DHCP
		nooption host_name

		# Do not run the hostname hook
		nohook hostname
	'';

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];

	# Disable the legacy firewall
	networking.firewall.enable = false;
	# Enable nftables
	networking.nftables.enable = true;
	
	# nftables ruleset to allow SSH from specific IP addresses
	networking.nftables.ruleset = ''
	table inet filter {
		chain input {
			type filter hook input priority 0; policy drop;

			# Accept established/related traffic
			ct state established,related counter accept

			# Allow loopback
			iif "lo" accept

			# DHCPv4 client (server port 67 -> client port 68)
			udp sport 67 udp dport 68 counter accept

			# Allow SSH from known IPv4 addresses only (new connections)
			ip protocol tcp tcp dport 22 ct state new ip saddr {
				1.1.1.1,		# Change this: Add your connecting IP address
			} limit rate 10/minute counter accept

			# Drop all other SSH
			tcp dport 22 counter drop
		}

		chain forward {
			type filter hook forward priority 0; policy drop;
		}
		
		chain output {
			type filter hook output priority 0; policy accept;
		}
	}
	'';

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		openFirewall = false; # Do not automatically add firewall rules for SSH

		settings = {
			LoginGraceTime = "30s";
			PermitRootLogin = "no";
			StrictModes = true;
			MaxAuthTries = 4;
			PasswordAuthentication = false;
			PermitEmptyPasswords = false;
			KbdInteractiveAuthentication = false; # Legacy name = ChallengeResponseAuthentication
			ClientAliveInterval = 300;
		};
	};

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "25.11"; # Did you read the comment?

	# Change this: Only change the line above if it does not match your default configuration.nix
}