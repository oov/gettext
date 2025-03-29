#!/bin/bash -xe
SCRIPT_DIR="$(dirname "${BASH_SOURCE:-$0}")"

apt update && apt install -y git zip tar curl build-essential mingw-w64

ICONV_URL="https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.18.tar.gz"
GETTEXT_URL="https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz"

ICONV_FILENAME=$(basename "$ICONV_URL")
GETTEXT_FILENAME=$(basename "$GETTEXT_URL")

ICONV_DIRNAME=$(basename "$ICONV_FILENAME" .tar.gz)
GETTEXT_DIRNAME=$(basename "$GETTEXT_FILENAME" .tar.gz)

curl -sOL "$ICONV_URL"
curl -sOL "$GETTEXT_URL"

EXPORT_LINUX=$PWD/exports/linux
EXPORT_MINGW=$PWD/exports/mingw
DIST_DIR=$PWD/dist

mkdir -p "$EXPORT_LINUX"
mkdir -p "$EXPORT_MINGW"
mkdir -p "$DIST_DIR"

tar xf "$GETTEXT_FILENAME"
cd "$GETTEXT_DIRNAME"
./configure --host=x86_64-linux-gnu --prefix="$EXPORT_LINUX" --disable-dynamic --enable-static --enable-threads=posix --disable-openmp --disable-rpath --enable-relocatable --disable-dependency-tracking --with-included-gettext && make clean
bash -x $SCRIPT_DIR/build-linux-static-gettext.bash
make install
cd ..
rm -rf "$GETTEXT_DIRNAME"

tar xf "$ICONV_FILENAME"
tar xf "$GETTEXT_FILENAME"

cd "$ICONV_DIRNAME"
CC="i686-w64-mingw32-gcc -static-libgcc" LD="i686-w64-mingw32-ld" AR="i686-w64-mingw32-ar" LDFLAGS="-dynamic" ./configure --host=i686-w64-mingw32 --prefix="$EXPORT_MINGW" --enable-dynamic && make clean && make && make install
cd ..

cd "$GETTEXT_DIRNAME"
CC="i686-w64-mingw32-gcc -static-libgcc -static-libstdc++" CXX="i686-w64-mingw32-g++ -static-libgcc -static-libstdc++" LD="i686-w64-mingw32-ld" AR="i686-w64-mingw32-ar" CFLAGS="-I$EXPORT_MINGW/include" CPPFLAGS="-I$EXPORT_MINGW/include" LDFLAGS="-L$EXPORT_MINGW/lib -dynamic" ./configure --host=i686-w64-mingw32 --prefix="$EXPORT_MINGW" --enable-dynamic --disable-libasprintf --disable-openmp && sed -i "s/@GNULIB_CLOSE@/1/" */*/unistd.in.h && make clean && make && make install
cd ..

cd $EXPORT_LINUX
tar cvJ --no-same-owner -f "$DIST_DIR/linux.tar.xz" ./
cd $EXPORT_MINGW
zip -r "$DIST_DIR/windows.zip" ./
