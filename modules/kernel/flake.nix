{
  description = "CachyOS Kernel Modules - Partition Inputs";

  inputs = {
    # CachyOS 内核依赖
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  # 注意：这个 flake 只作为 extraInputsFlake 使用
  # 不需要定义 outputs，flake-parts 会自动处理
  outputs = { ... }: { };
}
