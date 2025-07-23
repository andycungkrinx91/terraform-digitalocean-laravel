
# 🚀 Terraform DigitalOcean Laravel & Percona Stack
<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/terraform/terraform-original.svg" width="50" alt="Terraform">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/digitalocean/digitalocean-original.svg" width="50" alt="DigitalOcean">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/laravel/laravel-original.svg" width="50" alt="Laravel">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/mysql/mysql-original.svg" width="50" alt="Percona/MySQL">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nginx/nginx-original.svg" width="50" alt="Nginx">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/php/php-original.svg" width="50" alt="PHP">&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/ubuntu/ubuntu-original.svg" width="50" alt="Ubuntu">
</p>

A fully automated, **production-ready infrastructure** for deploying Laravel on DigitalOcean. This project sets up a **secure two-tier architecture** using Terraform and `cloud-init`:

- 🖥️ Laravel web server (Nginx + PHP-FPM)  
- 🛢️ Percona database server (with persistent volume)  
- 🔐 Secure VPC networking & firewall rules

---

## 📐 Architecture Overview

### 🔧 System Diagram

```
                               +------------------+
                               |   Public Internet|
                               +--------+---------+
                                        |
                                        | (HTTPS/SSH)
                                        |
  +-------------------------------------|-------------------------------------+
  |                                     |                                     |
  |      DigitalOcean Cloud             |                                     |
  |                                     |                                     |
  |  +----------------------------[ Firewall ]-------------------------------+ |
  |  |                                   |                                   | |
  |  |  +--------------------------[ VPC Network ]--------------------------+ | |
  |  |  |                            (10.10.10.0/24)                        | | |
  |  |  |                                                                   | | |
  |  |  |  +------------------+      (Private Network)      +-------------+ | | |
  |  |  |  |   Laravel Web    |<--------------------------->|   Percona   | | | |
  |  |  |  | (Nginx, PHP-FPM) |                             |  DB Server  | | | |
  |  |  |  +------------------+                             +-------------+ | | |
  |  |  |                                                         |         | | |
  |  |  |                                                    +----------+   | | |
  |  |  |                                                    |  Volume  |   | | |
  |  |  |                                                    +----------+   | | |
  |  |  +-------------------------------------------------------------------+ | |
  |  +------------------------------------------------------------------------+ |
  +-----------------------------------------------------------------------------+
```

<table align="center">
  <tr>
    <td align="center"><b>Terraform Final Output</b></td>
    <td align="center"><b>VPC</b></td>
  </tr>
  <tr>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/tf-final-output.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/tf-final-output.png" width="400px" alt="Terraform Final Output Screenshot"/></a></td>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/vpc.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/vpc.png" width="400px" alt="VPC Screenshot"/></a></td>
  </tr>
  <tr>
    <td align="center"><b>Firewall</b></td>
    <td align="center"><b>Droplet Server</b></td>
  </tr>
  <tr>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/firewall.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/firewall.png" width="400px" alt="Firewall Screenshot"/></a></td>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/droplet-server.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/droplet-server.png" width="400px" alt="Droplet Server Screenshot"/></a></td>
  </tr>
  <tr>
    <td align="center"><b>Data Disk</b></td>
    <td align="center"><b>Public Access</b></td>
  </tr>
  <tr>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/data-disk.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/data-disk.png" width="400px" alt="Data Disk Screenshot"/></a></td>
    <td><a href="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/public-access.png" target="_blank"><img src="https://raw.githubusercontent.com/andycungkrinx91/terraform-digitalocean-laravel/master/screenshot/public-access.png" width="400px" alt="Public Access Screenshot"/></a></td>
  </tr>
</table>

---

## 📁 Project Structure

```
.
├── modules/
│   ├── database/         # Percona DB server & storage
│   ├── firewall/         # DO firewall rules
│   ├── vpc/              # Virtual Private Cloud
│   └── webserver/        # Laravel web server (Nginx, PHP)
├── templates/
│   ├── database/
│   │   └── setup-percona.tpl.sh
│   └── webserver/
│       └── setup-laravel.tpl.sh
├── .gitignore
├── main.tf               # Terraform orchestrator
├── outputs.tf            # Deployment outputs
├── terraform.tfvars.example
├── variables.tf          # Root variables
└── README.md             # You're reading it!
```

---

## 📦 Modular Design

This project embraces a **modular architecture** using Terraform best practices. All infrastructure logic is split into reusable modules:

- **VPC Module** – Isolated, private networking  
- **Firewall Module** – Strict rules for public access  
- **Database Module** – Percona droplet with persistent block storage  
- **Webserver Module** – Laravel-ready droplet with `cloud-init`

Everything is orchestrated via `main.tf` — making the stack **maintainable**, **extensible**, and **clear**.

---

## ✨ Features

- ✅ **Secure by Default**: via VPC and firewall  
- ⚙️ **Automated Provisioning**: `cloud-init` installs everything  
- 📈 **Scalable Architecture**: separate web and DB layers  
- 💾 **Persistent Storage**: block volume for Percona  
- 🛡️ **Idempotent & Robust**: re-runnable provisioning  
- 📤 **Human-Friendly Outputs**: easy post-deploy details

---

## 🔧 Prerequisites

Ensure the following are installed:

1. [Terraform ≥ 1.0.0](https://developer.hashicorp.com/terraform/install)
2. DigitalOcean account with billing enabled
3. DigitalOcean **Personal Access Token**
4. SSH key pair (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)

---

## ⚙️ Setup & Configuration

### 1. Clone the repository

```bash
git clone https://github.com/yourname/terraform-do-laravel.git
cd terraform-do-laravel
```

### 2. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Required variables:

- `do_token`
- `db_root_password`
- `db_password`

Optional:

- `allowed_ssh_ips` (recommended to restrict access)

---

## 🚀 Deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Preview the plan

```bash
terraform plan
```

### 3. Apply the configuration

```bash
terraform apply
```

Takes a few minutes. It waits for server provisioning and config via `cloud-init`.

---

## ✅ Post-Deployment Output

You'll see output like:

```
Outputs:

deployment_summary = <<EOT

  ========================================================================
  ✅ Your Laravel application has been successfully deployed!
  ========================================================================

  Application URL:
    http://192.0.2.123

  Access Your Servers:
    - Web Server SSH:   ssh -i ~/.ssh/id_rsa root@192.0.2.123
    - Database SSH:     ssh -i ~/.ssh/id_rsa root@192.0.2.124

  Database Connection Details (from web server):
    - DB Host:          10.10.10.5
    - DB Name:          laravel
    - DB User:          laravel_user

  Key Server Paths:
    - Laravel Root:     /var/www/laravel
    - Nginx Config:     /etc/nginx/sites-available/laravel
    - MySQL Config:     /etc/mysql/percona-server.conf.d/
    - MySQL Data Dir:   /mnt/mysql/data

  ========================================================================
EOT
```

---

## 💣 Destroy Infrastructure

To remove everything:

```bash
terraform destroy
```