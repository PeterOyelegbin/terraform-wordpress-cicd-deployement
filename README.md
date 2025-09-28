# Automated Web Stack Deployment with CI/CD, Logging & Monitoring
This project demonstrates a complete DevOps workflow:
- Automated Deployment of a WordPress site using a LAMP/LEMP stack on AWS with GitHub Actions.
- Centralized Logging & Monitoring using the ELK Stack, Prometheus, and Grafana to track logs, metrics, and application health.
By combining automation, CI/CD, observability, and cloud infrastructure, this project showcases essential DevOps practices for real-world applications.


## 🛠️ Technologies Used
- CI/CD: GitHub Actions
- OS: Ubuntu (Web + Prometheus/Grafana), CentOS (ELK Stack)
- Web Servers: Nginx
- Databases: MySQL (AWS RDS)
- Monitoring & Logging:
    - ELK Stack (Elasticsearch, Logstash, Kibana)
    - Prometheus + Grafana
- Security: SSL/TLS via Let’s Encrypt (Certbot)
- Infrastructure: AWS EC2, AWS RDS


## 🏗 Architecture Diagram
                 ┌─────────────────────────┐
                 │      GitHub Repo        │
                 │  (Code + CI/CD via GA)  │
                 └───────────┬─────────────┘
                             │
                             ▼
                ┌───────────────────────────┐
                │    EC2 (Ubuntu) Web App   │
                │  - Nginx/Apache + PHP     │
                │  - WordPress              │
                │  - Filebeat + NodeExporter│
                └───────────┬───────────────┘
                            │
                            │
         ┌──────────────────┴───────────────────┐
         │                                      │
         ▼                                      ▼
┌───────────────────────┐          ┌──────────────────────────┐
│   ELK Stack (CentOS)  │          │ Prometheus + Grafana     │
│ - Elasticsearch :9200 │          │ (Ubuntu) :9090, :3000    │
│ - Logstash :5044      │          │ Scrapes NodeExporter     │
│ - Kibana :5601        │          │ Visualizes Metrics       │
└───────────────────────┘          └──────────────────────────┘

                   ┌─────────────────────┐
                   │     AWS RDS MySQL   │
                   │   Database Backend  │
                   └─────────────────────┘


## 🚀 Project Setup
1. Infrastructure Setup
    - Launch an EC2 instance (Ubuntu) for the web server (t2.micro).
    - Launch an EC2 instance (CentOS) for the ELK server (t2.medium).
    - Launch an EC2 instance (Ubuntu) for the Grafana/Prometheus server (t2.medium).
    - Create an AWS RDS MySQL database (db.t2.micro). Note endpoint, username, password.
    - Open Security Group ports:
        - Web Server: 22 (SSH), 80 (HTTP), 443 (HTTPS)
        - ELK: 22 (SSH), 80 (HTTP), 443 (HTTPS), 9200, 5044, 5601 (restricted to your IP)
        - Grafana/Prometheus: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000, 9090 (restricted to your IP)

2.  Web Server Setup using Infrastructure as Code (Automation Script)
    - Create server_setup.sh to automate:
        - System updates
        - Nginx/PHP installation
        - WordPress deployment
        - Configuration of virtual host

    - Create a filebeat_node_exporter_setup.sh to automate:
        - Filebeat installation
        - Configure Filebeat to send logstash to ELK (port 5044)
        - Install Node Exporter

3.  ELK Server Setup using Infrastructure as Code (Automation Script)
    - Create elk_setup.sh to automate:
        - System updates
        - Install Docker and Docker Compose
        - Install Elasticsearch, Logstash, Kibana via Docker.
        - Configure Logstash to accept logs from Filebeat (port 5044).

4.  Grafana/Prometheus Server Setup using Infrastructure as Code (Automation Script)
    - Create prometheus_grafana_setup.sh to automate:
        - System updates
        - Install Prometheus and Grafana.
        - Configure Prometheus to scrape from Web Server.
        - Configure Prometheus to accept logs from node_exporter (port 9100).

5. CI/CD Pipeline (GitHub Actions)
    - .github/workflows/deploy.yml
    - Trigger: Push to main branch
    - Steps:
        - Checkout code
        - Connect to EC2 via ssh-action using secrets (WEB_HOST, EC2_SSH_KEY)
        - Run server_setup.sh
        - Run filebeat_node_exporter_setup.sh
        - Connect to EC2 via ssh-action using secrets (ELK_HOST, EC2_SSH_KEY)
        - Run elk_setup.sh
        - Connect to EC2 via ssh-action using secrets (PG_HOST, EC2_SSH_KEY)
        - Run prometheus_grafana_setup.sh

    - Secrets to configure in repo:
        - WEB_HOST, ELK_HOST, PG_HOST, EC2_SSH_KEY
        - RDS_ENDPOINT, RDS_USER, RDS_PASSWORD


## ✅ Testing & Verification
- Push a code change → GitHub Actions → Setup servers and deploys WordPress site updates automatically.
- Visit Kibana (http://<elk-ip>:5601) → Logs from Nginx appear.
- Visit Prometheus (http://<pg-ip>:9090) → Execute command to view grapg metrics.
- Visit Grafana (http://<pg-ip>:3000) → Add Prometheus to Grafana as a data source.
- Create dashboards for CPU, Memory, Disk, and Requests.
- View CPU/Memory/Web Requests metrics update in real-time.


## 📂 Repository Structure
.
├── .github/
│   └── workflows/
│       └── deploy.yml                      # GitHub Actions workflow
├── scripts/
│   ├── elk_setup.sh                        # Web server automation script
│   ├── filebeat_node_exporter_setup.sh     # Web server automation script
│   ├── prometheus_grafana_setup.sh         # Web server automation script
│   ├── server_setup.sh                     # Web server automation script
├── index.php                               # Test PHP file
├── wordpress/                              # WordPress source files
└── README.md                               # Project documentation


## 🌟 Key DevOps Skills Demonstrated
- CI/CD Automation: Continuous deployment via GitHub Actions.
- Infrastructure as Code: Automated setup with Bash scripts.
- Observability: Centralized logging with ELK, metrics with Prometheus/Grafana.
- Cloud Services: AWS EC2, RDS, Security Groups.
- Security: HTTPS via Let’s Encrypt.
- Cross-Platform: Ubuntu + CentOS for diverse OS experience.


## ⚙️ TODO
- Use terraform to setup infrastructure
- Install SSL via Certbot
