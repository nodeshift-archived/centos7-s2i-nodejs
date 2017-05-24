#!/bin/bash

if [ -ne /opt/app-root ] ; then
  mkdir /opt/app-root
fi

chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root