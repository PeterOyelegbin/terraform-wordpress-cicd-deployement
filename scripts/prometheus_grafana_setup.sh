#!/bin/bash
set -e

echo "---- Updating system ----"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y software-properties-common


echo "---- Installing Prometheus ----"
cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/v2.55.0/prometheus-2.55.0.linux-amd64.tar.gz
sudo mkdir -p /opt/prometheus
sudo tar -xvzf prometheus-2.55.0.linux-amd64.tar.gz -C /opt/prometheus --strip-components=1

cat <<EOF | sudo tee /opt/prometheus/prometheus.yml
global:
  # How frequently to scrape targets by default.
  scrape_interval: 15s

# A list of scrape configurations.
scrape_configs:
  # The job name assigned to scraped metrics by default.
  - job_name: "node_exporter"
    static_configs:
      - targets: ["${WEB_SERVER_IP}:9100"]
EOF

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=nobody
WorkingDirectory=/opt/prometheus
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /opt/prometheus/data
sudo chown -R nobody:nogroup /opt/prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl restart prometheus

echo "---- Installing Grafana ----"
# Add Grafana's official GPG key
sudo apt install -y gnupg2 curl
curl -fsSL https://packages.grafana.com/gpg.key | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/grafana-archive-keyring.gpg

# Add Grafana APT repository
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "✅ Prometheus (9090) + Grafana (3000) running"
