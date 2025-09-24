#!/bin/bash
set -e

echo "---- Updating system ----"
sudo apt update -y && sudo apt upgrade -y

echo "---- Installing Prometheus ----"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.55.0/prometheus-2.55.0.linux-amd64.tar.gz
tar xvf prometheus-2.55.0.linux-amd64.tar.gz
sudo mv prometheus-2.55.0.linux-amd64 /opt/prometheus

cat <<EOF | sudo tee /opt/prometheus/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["${WEB_SERVER_IP}:9100"]
EOF

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml
Restart=always
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "---- Installing Grafana ----"
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "✅ Prometheus (9090) + Grafana (3000) running"
