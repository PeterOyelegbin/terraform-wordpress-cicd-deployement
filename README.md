# terraform-wordpress-cicd-deployement
This project focuses on automating the deployment of a classic web application stack, integrating your OS, Web Server, Database, and CI/CD skills.

# Project 2: Centralized Logging & Monitoring
This repository automates the deployment of a full monitoring stack for a WordPress-based web application.

## 📦 Components
- **Web Server** (Ubuntu) → WordPress + Nginx + PHP
- **ELK Stack** (CentOS) → Elasticsearch, Logstash, Kibana
- **Monitoring** (Ubuntu) → Prometheus + Grafana

## 🏗 Architecture

```mermaid
graph TD
    A[Users] -->|HTTP/HTTPS| B[Nginx + WordPress Server]
    B -->|Filebeat Logs| C[Logstash]
    C --> D[Elasticsearch]
    D --> E[Kibana]

    B -->|Node Exporter Metrics| F[Prometheus]
    F --> G[Grafana]
