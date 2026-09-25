#!/bin/sh

set -e

[ -n "$CI" ]

llvm_version=23

if [ "$RUNNER_OS" = Windows ]; then
  # Homebrew does not support Windows, and the official LLVM release for
  # Windows does not include MLIR, so use a prebuilt package that does.
  llvm_release=$llvm_version.1.2
  llvm_prefix=$RUNNER_TEMP\\llvm

  curl -fsSL -o llvm.7z https://github.com/TyrsDev/llvm-package-windows/releases/download/v$llvm_release/LLVM-$llvm_release-win64.7z
  7z x -bd -o"$llvm_prefix" llvm.7z >/dev/null
  rm llvm.7z

  echo MLIR_SYS_${llvm_version}0_PREFIX=$llvm_prefix >>$GITHUB_ENV
  echo LIBCLANG_PATH=$llvm_prefix\\bin >>$GITHUB_ENV
  exit
fi

brew install llvm@$llvm_version
llvm_prefix=$(brew --prefix llvm@$llvm_version)

echo MLIR_SYS_${llvm_version}0_PREFIX=$llvm_prefix >>$GITHUB_ENV
echo LD_LIBRARY_PATH=$llvm_prefix/lib:$LD_LIBRARY_PATH >>$GITHUB_ENV

# For the discovery of the zstd library on macOS
echo LIBRARY_PATH=$(brew --prefix)/lib >>$GITHUB_ENV
