#!/bin/bash

#
# A simple script to print the versions of required system packages.
#

print_version() {
  VERSION="$(apt show $1 2>/dev/null | grep Version)"
  echo "$1 ${VERSION#Version: }"
}

print_line() {
  printf "$(head -c 80 /dev/zero | tr '\0' '*')\n"
}

declare -a DEPENDENCIES=(
  "openjdk-11-jdk-headless"
  "openjdk-11-jre-headless"
  "gcc"
  "python2"
  "ffmpeg"
  "curl"
  "zip"
  "unzip"
  "libturbojpeg"
  "libopenjp2-tools"
  "libtiff5"
  "libtiff5-dev"
  "libtiff-tools"
  "make"
  "build-essential"
)

print_line
echo "               System dependency versions"
print_line

# Refresh packages so we can query them
apt update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt -y upgrade > /dev/null 2>&1

for DEPENDENCY in "${DEPENDENCIES[@]}" ; do
  print_version $DEPENDENCY
done

print_line
