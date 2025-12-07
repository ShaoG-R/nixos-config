{ pkgs, inputs, ... }:
{
  imports = [
    inputs.chaotic.nixosModules.nyx-cache
    inputs.chaotic.nixosModules.nyx-overlay
    inputs.chaotic.nixosModules.nyx-registry
  ];

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
}
