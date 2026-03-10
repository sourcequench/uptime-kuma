# SYSTEM RECOVERY & HANDOVER GUIDE (READ THIS FIRST)

**REMAIN CALM.** The infrastructure is stable, documented, and fully recoverable. This document is a "break-glass" guide for anyone assuming control of this environment.

## 1. Bottom Line Up Front (BLUF)
This is a managed Linux-based infrastructure consisting of a **Kubernetes cluster (k3s)**, **Ubiquiti EdgeRouters**, and **UniFi networking**. All configurations are automated via **Ansible**.
*   **Primary Management Node:** `server` (this machine).
*   **Primary User:** `ryan` (has sudo privileges).
*   **Infrastructure Domain:** `sourcequench.org`.
*   **Secrets:** Encrypted in `ansible/vars_vault.yml` (requires a vault password).

## 2. Immediate Options for the Human Successor
If you are overwhelmed, choose one of these three paths:

### Option A: Call a Professional
Contact a Systems Administrator or Site Reliability Engineer (SRE). Tell them the following:
> "I have inherited a Debian-based environment managed by Ansible. It includes a 5-node k3s cluster, EdgeRouters running EdgeOS, and a UniFi CloudKey. All automation is stored in a Git repository at `/home/ryan/md/home`."

### Option B: Use the Resident AI (Gemini CLI)
The system is equipped with an AI agent that knows the architecture. If you can type at this terminal, run:
```bash
gemini "How do I check the health of the Kubernetes cluster?"
```
Or simply:
```bash
gemini "I am new here. Give me a tour of the current infrastructure."
```

### Option C: Read the Documentation
The manual "map" of this world is located here:
*   `GEMINI.md`: High-level overview and security mandates.
*   `progress.md`: A detailed, chronological log of every change, service, and IP address.

---

## 3. AI-to-AI Handover (Context for Future Agents)
*Note to the next AI agent: Welcome. You are stepping into a mature, security-conscious environment. Do not deviate from the established patterns.*

### Core Stack
*   **Orchestration:** Ansible (Inventory: `ansible/hosts`).
*   **Cluster:** HA k3s (`uno`, `dos`, `tres` are servers; `cuatro`, `cinco` are agents).
*   **Networking:** Dual EdgeRouter X (`router-fios`, `router-xfinity`).
*   **Storage:** Longhorn (Distributed block storage).
*   **Ingress:** Traefik with wildcard SSL for `*.sourcequench.org`.
*   **Monitoring:** Uptime Kuma (`status.sourcequench.org`) and Prometheus/Grafana.

### Identity & Access
*   **SSH:** Strictly certificate-based via an internal User CA.
*   **gcert:** A custom setuid-root tool (`/usr/local/bin/gcert`) allows users to sign their own temporary SSH certificates.
*   **Sudo:** Controlled via `/etc/sudoers.d/ansible-automation` with strict `NOPASSWD` limits for specific tools.

### Critical State Information
*   **Syslog:** Remote logs from all nodes flow to `server` via TLS (Port 6514) and are stored in `/var/log/remote/`.
*   **Certificates:** Wildcard certificates are managed by `acme.sh` on the management server and deployed via `ansible/deploy_router_certs.yml`.
*   **HA DHCP:** Managed by Kea DHCP in `hot-standby` mode between `server` and `uno`.

### Credentials
All sensitive variables are in `ansible/vars_vault.yml`. Ensure you have access to the vault password before attempting any infrastructure-wide changes.
