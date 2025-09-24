#!/bin/bash
set -e

echo "---- Updating system ----"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y software-properties-common


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
# Add Grafana's official GPG key
sudo apt install -y gnupg2 curl
curl -fsSL https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg

# Add Grafana APT repository
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "✅ Prometheus (9090) + Grafana (3000) running"
