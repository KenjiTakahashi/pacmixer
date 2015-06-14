#!/usr/bin/env sh
# pacmixer
# Copyright (C) 2015 Karol 'Kenji Takahashi' Woźniak
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

FLAGS=${FLAGS:-$(echo "$*" | grep -q 'debug' && echo "-Wall -O0 -ggdb3" || echo "-Wall -O2")}
BUILDFILE="build.ninja"
EXCLUDES="src/backend.c src/main.mm"

printf "include defs.ninja\n" > "${BUILDFILE}"

echo "$*" | grep -q 'tests' && TESTS="tests/"
for TYPE in c cpp m mm; do
    for FILE in $(find src/ ${TESTS} -type f -name "*.${TYPE}"); do
        if !([ -n "${TESTS}" ] && echo "${EXCLUDES}" | grep -q "${FILE}"); then
            OUTFILE="build/${TESTS}$(basename ${FILE}).o"
            OBJECTS="${OBJECTS} ${OUTFILE}"
            printf "build ${OUTFILE}: ${TYPE} ${FILE}\n" >> "${BUILDFILE}"
        fi
    done
done

if [ -n "$TESTS" ]; then
    printf "flags = ${FLAGS} -D TESTS=1\n" >> "${BUILDFILE}"
    printf "build pacmixer_run_tests: link ${OBJECTS}\n" >> "${BUILDFILE}"
else
    printf "flags = ${FLAGS}\nldflags2 = -lpulse\n" >> "${BUILDFILE}"
    printf "build pacmixer: link ${OBJECTS}\n" >> "${BUILDFILE}"
fi

ninja -v

if echo "$*" | grep -q 'install'; then
    PREFIX=${PREFIX:-/usr/local}
    MANPREFIX=${MANPREFIX:-"${PREFIX}/share/man"}
    DIR="${DESTDIR}${PREFIX}"
    BIN="${DIR}/bin"
    MAN="${DESTDIR}${MANPREFIX}/man1"
    echo "Installing executable file into ${BIN}"
    mkdir -p "${BIN}"
    install -m 755 pacmixer "${BIN}"
    echo "Installing man page file into ${MAN}"
    mkdir -p "${MAN}"
    install -m 644 pacmixer.1 "${MAN}"
fi
