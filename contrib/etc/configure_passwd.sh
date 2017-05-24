#!/bin/bash

function configure_passwd() {
  sed "/^default/s/[^:]*/$(id -u)/3" /etc/passwd > /tmp/passwd
  cat /tmp/passwd > /etc/passwd
  rm /tmp/passwd
}

configure_passwd

# Execute the Dockerfile's CMD
${@}