with import <nixpkgs> { config.allowUnfree = true; };

# Default to clang instead of gcc
(mkShell.override { stdenv = llvmPackages_latest.stdenv; }) {
  buildInputs = with cudaPackages; [
    cuda_cudart
    cuda_cccl # Thrust, CUB, &c
  ];
  packages = [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_nvprof
    cudaPackages.nsight_systems
    cudaPackages.cuda_sanitizer_api

    llvmPackages_latest.openmp

    gcc

    cmake
    pkg-config
  ];

  # Expose libcuda.so on NixOS
  LD_LIBRARY_PATH = "${addOpenGLRunpath.driverLink}/lib";
}
