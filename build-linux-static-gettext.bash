#!/bin/bash -x

sed -i 's/^int _nl_msg_cat_cntr;$/extern int _nl_msg_cat_cntr;/' gettext-runtime/intl/loadmsgcat.c

cd gettext-runtime
make > build.log
cd src
for exe in $(ls -1 .libs | grep '^[A-Za-z-]\+$'); do
  $(cat ../build.log | grep " \.libs/$exe " | sed 's/^libtool: link: //' | sed 's/^\(\S\+\)/\1 -static/' | sed 's/\(\S\+\)\.so/\1.a/g')
done
cd ../..

cd libtextstyle
make
cd ..

cd gettext-tools
make > build.log
cd src
for exe in $(ls -1 .libs | grep '^[A-Za-z-]\+$'); do
  $(cat ../build.log | grep " \.libs/$exe " | sed 's/^libtool: link: //' | sed 's/^\(\S\+\)/\1 -static/' | sed 's/\(\S\+\)\.so/\1.a/g')
done
cd ../..
