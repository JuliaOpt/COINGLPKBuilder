# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "COINGLPKBuilder"
version = v"1.10.5"

# Collection of sources required to build COINGLPKBuilder
sources = [
    "https://github.com/coin-or-tools/ThirdParty-Glpk/archive/releases/1.10.5.tar.gz" =>
    "85292f5f1816a5717b384a1f010d1edf75cd03249511b709642b9cab78974819",

]

# Bash recipe for building across all platforms
script = raw"""
set -e
cd $WORKSPACE/srcdir
cd ThirdParty-Glpk-releases-1.10.5/

# Get Glpk from mirror. gnu.org can be unreliable. Note: this will fail if wget or fetch are not present
cp get.Glpk get.Glpk.orig
cat > get.Glpk.patch <<'END'
--- get.Glpk.orig 2018-08-23 15:09:22.682356366 -0400
+++ get.Glpk2018-08-23 15:09:51.562429801 -0400
@@ -25,7 +25,7 @@
 rm -f glpk*.tar.gz
 
 echo "Downloading the source code from ftp.gnu.org..."
-$wgetcmd ftp://ftp.gnu.org/gnu/glpk/glpk-${glpk_ver}.tar.gz
+$wgetcmd http://ftpmirror.gnu.org/gnu/glpk/glpk-${glpk_ver}.tar.gz
 
 echo "Uncompressing the tarball..."
 gunzip -f glpk-${glpk_ver}.tar.gz
END
patch -l get.Glpk.orig get.Glpk.patch -o get.Glpk

./get.Glpk
update_configure_scripts
mkdir build
cd build/
../configure --prefix=$prefix --with-pic --disable-pkg-config --host=${target} --enable-shared --enable-static --enable-dependency-linking lt_cv_deplibs_check_method=pass_all
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcoinglpk", :libcoinglpk)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

