## ec2-build-container-host

This script sets up a container host test system based on NixOS. For configuration options consult:

https://search.nixos.org/options

To change the resulting system, edit the *configuration.nix* and re-run the script.

### Usage
```
git clone https://github.com/mrckndt/ec2-build-container-host
cd ec2-build-container-host

bash ec2-build-container-host -i <PATH-TO-IDENTITY-FILE>
or
./ec2-build-container-host -i <PATH-TO-IDENTITY-FILE>
```

Follow the shown instructions and wait...
