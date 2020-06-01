#!/bin/bash
set -x
systemctl stop collectors.service
cp /cm/shared/scripts/jobmonitoring/collectors.service /etc/systemd/system/collectors.service
systemctl enable collectors.service
systemctl start collectors.service

systemctl stop programdetection.service
cp /cm/shared/scripts/jobmonitoring/programdetection.service /etc/systemd/system/programdetection.service
systemctl enable programdetection.service
systemctl start programdetection.service


