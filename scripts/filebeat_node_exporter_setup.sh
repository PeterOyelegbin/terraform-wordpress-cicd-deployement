#!/bin/bash
set -e

echo "---- Installing Filebeat ----"
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.15.0-amd64.deb
sudo dpkg -i filebeat-8.15.0-amd64.deb

cat <<EOF | sudo tee /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  paths:
    - /var/log/nginx/access.log
    - /var/log/nginx/error.log

output.logstash:
  hosts: ["${ELK_SERVER_IP}:5044"]
EOF

sudo systemctl enable filebeat
sudo systemctl restart filebeat

echo "---- Installing Node Exporter ----"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "✅ Filebeat (→ELK) and Node Exporter (9100) running"
