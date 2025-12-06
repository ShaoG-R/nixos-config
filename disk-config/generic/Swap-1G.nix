{ lib, disko, ... }:
{
  imports = [
    disko.nixosModules.disko
    ../boot.nix
  ];

  disko.devices.disk.main = {
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "64M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efi";
          };
        };
        
        swap = {
          priority = 2;
          size = "1G";
          content = {
            type = "swap";
            discardPolicy = "both";
            resumeDevice = true;
          };
        };

        root = {
          priority = 3;
          size = "100%";
          content = {
            type = "luks";
            name = "crypted";
            # 通用参数
            extraOpenArgs = [ "--allow-discards" ];
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress-force=zstd:3" "noatime" "space_cache=v2" ];
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;
}