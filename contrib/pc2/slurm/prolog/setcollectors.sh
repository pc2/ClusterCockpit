#!/bin/bash
if [ "$SPANK_COLLECTORS" == "off" ];
then
  touch /tmp/disablecollectors
else
  rm -f /tmp/disablecollectors
fi
