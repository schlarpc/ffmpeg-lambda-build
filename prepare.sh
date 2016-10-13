#!/bin/bash

set -e

BUILD=~/build
PREFIX=$BUILD/prefix
PREP=$BUILD/ffmpeg-lambda
PATH=$BUILD/prefix/bin:$PATH

rm -rf $PREP
cp -r $PREFIX $PREP

cd $PREP
chmod -R 755 *
mv lib64/* lib/
mv sbin/* bin/
mkdir keepbin
mv bin/ffmpeg bin/ffprobe bin/rtmpdump bin/mplayer keepbin/
rm -rf etc include var misc man lib64 doc share private openssl.cnf certs sbin bin \
    lib/*.a lib/*.la lib/openjpeg-1.5 lib/pkgconfig lib/python2.7
mv keepbin bin

for item in $(find -type f); do
    echo "Patching $item"
    strip $item
    libdir='$ORIGIN/'$(realpath --relative-to=$(dirname $item) $PREP/lib/)
    patchelf --set-rpath $libdir $item
    for dependency in $(patchelf --print-needed $item); do
        fullpath=$(readlink -f $PREP/lib/$dependency)
        realso=$(basename $fullpath)
        echo "Resolving $dependency to $realso"
        patchelf --replace-needed $dependency $realso $item
    done
    echo ""
done

for item in $(find -type l); do
    rm $item
done

rm -rf $BUILD/ffmpeg-lambda.zip
cd $PREP
zip -9 -r $BUILD/ffmpeg-lambda.zip *
