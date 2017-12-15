#!/bin/bash

##
## Installation script for prerequisites for running esm-7
##
## Script installs the sqlmap REST service as a systemd service
##
## Application Security Threat Attack Modeling (ASTAM)
##
## Copyright (C) 2017 Applied Visions - http://securedecisions.com
##
## Written by Aspect Security - http://aspectsecurity.com
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

topDir=`dirname "$0"`

# install python etc.
apt-get update
apt-get install -y python-minimal python-requests dos2unix

# copy esm-7 scripts to bin
cp /opt/attack-scripts/esm7/esm-7 /opt/attack-scripts/esm7/login-cli /opt/attack-scripts/esm7/sqlmap-client /usr/local/bin
chmod a+x /usr/local/bin/esm-7 /usr/local/bin/login-cli /usr/local/bin/sqlmap-client

# get latest sqlmap
git clone https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap
cd /opt/sqlmap
## checkout known working version
git checkout 0961f6a5e9333f77648516469296c3a54cd874ba
# create sqlmapd user
useradd -m --system sqlmapd

# setup sqlmapd service default configuration
echo "HOST=127.0.0.1" > /etc/default/sqlmapd
echo "PORT=8775"     >> /etc/default/sqlmapd

# setup sqlmapd service
cat << EOF > /etc/systemd/system/sqlmapd.service

[Unit]
Description=sqlmap REST API
After=network.target

[Service]
Type=simple
User=sqlmapd
WorkingDirectory=/opt/sqlmap/
EnvironmentFile=/etc/default/sqlmapd
ExecStart=/opt/sqlmap/sqlmapapi.py -s -H \$HOST -p \$PORT
Restart=always
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

# start the sqlmapd service
systemctl daemon-reload
systemctl enable sqlmapd
systemctl start sqlmapd
