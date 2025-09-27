#!/bin/bash
set -e

echo "---- Updating system ----"
sudo yum update -y || sudo dnf update -y

echo "---- Detecting OS ----"
source /etc/os-release
if [[ "$ID" == "amzn" && "$VERSION_ID" == "2" ]]; then
    echo "Amazon Linux 2 detected"
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
elif [[ "$ID" == "amzn" && "$VERSION_ID" == "2023" ]]; then
    echo "Amazon Linux 2023 detected"
    sudo dnf install -y docker

    echo "---- Installing Docker Compose v2 ----"
    sudo mkdir -p /usr/local/lib/docker/cli-plugins
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 \
        -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
elif [[ "$ID" == "centos" || "$ID" == "rhel" ]]; then
    echo "CentOS/RHEL detected"
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
else
    echo "Unsupported OS ($ID $VERSION_ID). Please install Docker manually."
    exit 1
fi

echo "---- Starting Docker ----"
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

echo "---- Installing Docker Compose ----"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "---- Creating ELK stack ----"
mkdir -p ~/elk && cd ~/elk

cat <<EOF > docker-compose.yml
version: '3'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    ports:
      - "5044:5044"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    ports:
      - "5601:5601"
EOF

cat <<EOF > logstash.conf
input {
  beats { port => 5044 }
}
output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "nginx-logs-%{+YYYY.MM.dd}"
  }
}
EOF

echo "---- Starting ELK stack ----"
docker-compose up -d
echo "✅ ELK running on ports 9200, 5044, 5601"
