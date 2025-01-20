---
title: Nixos in Software Inovation Studio
date: 2025-01-07
tags:
  - Nixos
---

## Nix flake

The first thing is `nix flake`, a experiment feature. I use a flake based repo to organize all of my machine, and can specific the version using hash.

## Nix Anywhere

I using `nix-anywhere` to install nixos in the HP 877E.

```txt
typer@sis
--------- 
OS: NixOS 25.05.20250116.5df4362 (Warbler) x86_64
Host: HP 877E
Kernel: 6.6.71
Uptime: 3 days, 5 hours, 13 mins 
Packages: 332 (nix-system), 420 (nix-user) 
Shell: fish 3.7.1
Resolution: 1440x900
Terminal: /dev/pts/0
CPU: Intel i7-10700 (16) @ 4.800GHz 
GPU: Intel CometLake-S GT2 [UHD Graphics 630] 
Memory: 775MiB / 15821MiB
```

Nix Anywhere use `disko` to part disk.

## Network

``` nix
networking = {
  hostName    = "sis";
  useDHCP     = false;
  useNetworkd = true;

  firewall.enable = false;
};

systemd.network.enable = true;
systemd.network.networks = {
  "50-usb-RNDIS" = {
    matchConfig.Name = "enp0s20f0*";
    DHCP = "yes";
    dns  = [ "8.8.8.8" ];
    dhcpV4Config = {
      RouteMetric = 100;
    };
  };

  "10-enp1s0" = {
    matchConfig.Name = "enp1s0";
    address = [
      "10.85.13.10/25"
    ];
    routes  = [
      { Gateway = "10.85.13.1"; Metric = 300; }
    ];
  };
};
```

And the Dnsmasq service provide dhcp server.

```nix
services.dnsmasq = {
  enable = true;
  settings = {
    interface = "enp1s0";

    bind-interfaces    = true;
    dhcp-authoritative = true;

    dhcp-host = [
      "00:e2:69:6e:2c:ed,10.85.13.20" # ss's hac
      "a8:b1:3b:8e:bc:5e,10.85.13.21" # ms's laptop
    ];

    dhcp-option = [
      "option:router,10.85.13.10"
    ];

    dhcp-range = [
      "10.85.13.40,10.85.13.90,24h"
    ];

    local-service     = true;
    bogus-priv        = true;
    domain-needed     = true;
  };
};
```

## Iot device: HP laserJet printer

```nix
# Mdns
services.avahi = {
  enable       = true;
  nssmdns4     = true;
  openFirewall = true;

  publish = {
    enable       = true;
    userServices = true;
  };
};

# Printer (HP LaserJet_Professional P1106 at sis2)
services.printing = {
  enable  = true;
  drivers = [ pkgs.hplipWithPlugin ];

  listenAddresses = [ "*:631" ];
  allowFrom       = [ "all" ];
  browsing        = true;
  defaultShared   = true;
  openFirewall    = true;

  extraConf = ''
    DefaultEncryption Never
  '';
};

hardware.printers = {
  ensureDefaultPrinter = "HP_laserjet_P1106";

  ensurePrinters = [{
    name       = "HP_laserjet_P1106";
    location   = "sis";
    deviceUri  = "hp:/usb/HP_LaserJet_Professional_P1106?serial=000000000QNBJ3P2PR1a";
    model      = "drv:///hp/hpcups.drv/hp-laserjet_professional_p1106.ppd";
    ppdOptions = { PageSize = "A4"; };
  }];
};
```
