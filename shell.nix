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

  # A pretty dumb untested hook trying to figure out where non-NixOS systems
  # put their libcuda.so
  shellHook = ''
    if [[ -d "${addOpenGLRunpath.driverLink}/lib"  ]] ; then
      addToSearchPath LD_LIBRARY_PATH "${addOpenGLRunpath.driverLink}/lib"
      if [[ ! -e "${addOpenGLRunpath.driverLink}/lib/libcuda.so" ]] ; then
        cat << \EOF >&2
        You seem to be running NixOS, but /run/opengl-driver/lib/libcuda.so doesn't exist
        Did you forget to set `hardware.opengl.enable = true` and `services.xserver.videoDrivers = [ "nvidia" ]`?
    EOF
      fi
    elif [[ -d .cuda-driver ]] ; then
      echo Using "$PWD/.cuda-driver/libcuda.so" >&2
      addToSearchPath LD_LIBRARY_PATH "$PWD/.cuda-driver"
    elif [[ -e /etc/ld.so.cache ]] ; then
      echo Found /etc/ld.so.cache, using it to populate "$PWD/.cuda-driver"
      if [[ ! -d .cuda-driver ]] ; then
        while read -r p ; do
          mkdir -p .cuda-driver
          ln -s "$p" .cuda-driver/
          echo Symlinking "$p" to "$PWD/.cuda-driver/" >&2
        done < <(strings /etc/ld.so.cache | ${gnugrep}/bin/grep -oE '/[[:alnum:]/_-]+/(libcuda.so|libnvidia-ml.so)\b')
      fi
      addToSearchPath LD_LIBRARY_PATH "$PWD/.cuda-driver"
    else
      echo "Couldn't locate libcuda.so, you'll have to do it manually" >&2
    fi
  '';
}
