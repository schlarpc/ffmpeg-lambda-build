#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SUDO=''
if [[ $(id -u) -ne 0 ]] ; then
    SUDO='sudo'
fi

$SUDO yum groupinstall -y 'development tools'
$SUDO yum install -y mercurial gperf libxml2-devel libxslt-devel docbook2X python27-pip python27-devel
$SUDO pip install lxml six

BUILD=~/build
PREFIX=$BUILD/prefix

export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export MAKEFLAGS='-j4'

rm -rf $BUILD
mkdir -p $BUILD
cd $BUILD
PATH=$BUILD/prefix/bin:$PATH

git clone --depth=1 git://cmake.org/cmake.git
cd cmake
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://github.com/yasm/yasm.git
cd yasm
./autogen.sh --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://github.com/madler/zlib
cd zlib
./configure --prefix=$PREFIX
make
make install
cd -

curl http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz | tar xz
cd bzip2-*
sed -i'' "s|PREFIX=.*|PREFIX=$PREFIX|" Makefile
make -f Makefile-libbz2_so
make install
cp libbz2.so.* $PREFIX/lib
cd -

git clone --depth=1 git://git.videolan.org/x264.git
cd x264
./configure --prefix=$PREFIX --enable-shared
make
make install
cd -

git clone --depth=1 https://chromium.googlesource.com/webm/libvpx
cd libvpx
./configure --prefix=$PREFIX --enable-shared
make
make install
cd -

svn checkout http://svn.xvid.org/trunk/xvidcore --username anonymous --password '' --non-interactive
cd xvidcore/build/generic
./bootstrap.sh
./configure --prefix=$PREFIX
make
make install
cd -

hg clone https://bitbucket.org/multicoreware/x265
cd x265/build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DCMAKE_ASM_YASM_FLAGS='-DARCH_X86_64=1 -f elf64' ../source
make
make install
cd -

git clone --depth=1 git://git.sv.nongnu.org/freetype/freetype2.git
cd freetype2
./autogen.sh
LDFLAGS="-L$PREFIX/lib" CPPFLAGS="-I$PREFIX/include" ./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://anongit.freedesktop.org/fribidi/fribidi
cd fribidi
sed -i'' 's|SUBDIRS = .*|SUBDIRS = gen.tab charset lib bin test|' Makefile.am
./bootstrap
./configure --prefix=$PREFIX
MAKEFLAGS='' make
make install
cd -

git clone --depth=1 git://github.com/libexpat/libexpat
cd libexpat/expat
ln -s `which db2x_docbook2man` $PREFIX/bin/docbook2x-man
./buildconf.sh
./configure --prefix=$PREFIX
make
make install
rm $PREFIX/bin/docbook2x-man
cd -

git clone --depth=1 git://anongit.freedesktop.org/fontconfig
cd fontconfig
./autogen.sh --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://github.com/libass/libass
cd libass
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://github.com/cacalabs/libcaca
cd libcaca
./bootstrap
./configure --prefix=$PREFIX
make
make install
cd -

git clone https://git.xiph.org/ogg.git
cd ogg
./autogen.sh
./configure --prefix=$PREFIX --exec-prefix=$PREFIX
make
make install
cd -

git clone git://git.code.sf.net/p/soxr/code soxr
mkdir -p soxr/build
cd soxr/build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make
make install
cd -

git clone --depth=1 git://github.com/georgmartius/vid.stab
mkdir -p vid.stab/build
cd vid.stab/build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make
make install
cd -

cvs -d:pserver:cvsanon:@cvs.maptools.org:/cvs/maptools/cvsroot login
cvs -z3 -d:pserver:cvsanon:@cvs.maptools.org:/cvs/maptools/cvsroot co -P libtiff
cd libtiff
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://git.code.sf.net/p/libpng/code libpng
cd libpng
./autogen.sh
CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" ./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 -b openjpeg-1.5 git://github.com/uclouvain/openjpeg
mkdir -p openjpeg/build
cd openjpeg/build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make
make install
cd -

git clone --depth=1 https://chromium.googlesource.com/webm/libwebp
cd libwebp
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 -b OpenSSL_1_0_2-stable git://github.com/openssl/openssl
cd openssl
./config  --prefix=$PREFIX --openssldir=$PREFIX shared zlib-dynamic
CPPFLAGS="-I$PREFIX/include" make
make install
cd -

git clone git://git.ffmpeg.org/rtmpdump
cd rtmpdump
sed -i'' "s|prefix=.*|prefix=$PREFIX|" Makefile
sed -i'' "s|prefix=.*|prefix=$PREFIX|" librtmp/Makefile
CPPFLAGS="-I$PREFIX/include" XLDFLAGS="-L$PREFIX/lib" make
make install
cd -

git clone --depth=1 git://github.com/sekrit-twc/zimg
cd zimg
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

cvs -d:pserver:anonymous:@lame.cvs.sourceforge.net:/cvsroot/lame login
cvs -z3 -d:pserver:anonymous:@lame.cvs.sourceforge.net:/cvsroot/lame co -P lame
cd lame
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://git.code.sf.net/p/opencore-amr/vo-amrwbenc
cd vo-amrwbenc
libtoolize --force
aclocal
automake --force-missing --add-missing
autoconf
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://git.code.sf.net/p/opencore-amr/code opencore-amr
cd opencore-amr
libtoolize --force
aclocal
automake --force-missing --add-missing
autoconf
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://github.com/dyne/frei0r
cd frei0r
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone https://git.xiph.org/vorbis.git
cd vorbis
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone https://git.xiph.org/theora.git
cd theora
./autogen.sh
LDFLAGS="-L$PREFIX/lib" CPPFLAGS="-I$PREFIX/include" ./configure --prefix=$PREFIX
make
make install
cd -

git clone https://git.xiph.org/speex.git
cd speex
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone https://git.xiph.org/opus.git
cd opus
./autogen.sh
./configure --prefix=$PREFIX
make
make install
cd -

git clone --depth=1 git://git.videolan.org/git/ffmpeg.git
cd ffmpeg
./configure \
	--prefix=$PREFIX --enable-gpl --enable-version3 --enable-nonfree \
	--enable-shared --extra-cflags="-I$PREFIX/include" \
	--extra-ldflags="-L$PREFIX/lib -L$PREFIX/lib64" \
	--enable-libmp3lame --enable-frei0r \
	--enable-libopencore-amrwb --enable-libopencore-amrnb \
	--enable-libsoxr --enable-libvpx --enable-libwebp \
	--enable-libx264 --enable-libx265 --enable-libzimg \
	--enable-libxvid --enable-openssl  --enable-librtmp \
	--enable-libvorbis --enable-libopus --enable-libtheora \
	--enable-libspeex --enable-libvidstab --enable-libvo-amrwbenc \
    --enable-libopenjpeg --enable-libfribidi --enable-libfreetype \
    --enable-libfontconfig --enable-libass --enable-libcaca
# Unenabled libraries/features as of April 9 2017:
# Many of these are encoding targets and data sources, not decoding support.
# The libraries that *are* enabled should represent most output formats in common use.
# Of course, patches are welcome to increase library support here :)
#
# avisynth
# chromaprint
# gcrypt (unneeded due to librtmp)
# gmp (unneeded due to librtmp)
# gnutls (unneeded due to openssl)
# jni
# ladspa
# libbluray (not useful in Lambda)
# libbs2b
# libcelt
# libcdio (not useful in Lambda)
# libdc1394 (not useful in Lambda)
# libfdk-aac
# libflite
# libgme
# libgsm
# libiec61883
# libilbc
# libkvazaar (using libx265)
# libmodplug
# libnut
# libopencv
# libopenh264 (using libx264)
# libopenmpt
# libpulse (not useful in Lambda)
# librubberband
# libschroedinger
# libshine
# libsmbclient
# libsnappy
# libssh
# libtesseract
# libtwolame
# libv4l2 (not useful in Lambda)
# libwavpack
# libxavs
# libxcb
# libxcb-shm
# libxcb-xfixes
# libxcb-shape
# libzmq
# libzvbi
# decklink (not useful in Lambda)
# mediacodec (Android only)
# netcdf
# openal
# opencl
# opengl
make
make install
cd -

svn checkout svn://svn.mplayerhq.hu/mplayer/trunk mplayer
cd mplayer
cp -r $PREFIX/include/libavutil/ .
LD_LIBRARY_PATH=$PREFIX/lib ./configure --prefix=$PREFIX --disable-ffmpeg_a --extra-cflags="-I$PREFIX/include" --extra-ldflags="-L$PREFIX/lib"
LD_LIBRARY_PATH=$PREFIX/lib make
make install
cd -

git clone --depth=1 git://github.com/NixOS/patchelf
cd patchelf
./bootstrap.sh
./configure --prefix=$PREFIX
make
make install
cd -

echo "Build complete, running prepare script"
$SCRIPT_DIR/prepare.sh
