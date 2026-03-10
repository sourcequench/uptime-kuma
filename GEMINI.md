# GEMINI.md - home

## Project Overview
This directory, `home`, serves as a shared workspace for collaboration and information exchange. It is currently in an initial state, intended to house documentation, notes, or code as the project evolves.

## Directory Structure & Key Files
The workspace currently contains:

- `GEMINI.md`: This file, providing instructional context and an overview of the directory's purpose.
- `ansible/`: Contains Ansible playbooks and configuration for managing the `kubernetes` host group.
  - `ansible.cfg`: Disables host key checking, specifies the inventory file, and configures `ssh_args` to use the `ryan` user certificate (`id_rsa-cert.pub`).
  - `hosts`: Defines the `kubernetes` host group with five Debian machines.
  - `setup_ssh_ca.yml`: Configures SSH User CA in `sshd_config` and reloads `sshd`.
  - `setup_host_certs.yml`: Fetches remote host ECDSA keys, signs them locally with the Host CA, pushes back the certificate, and configures `sshd_config` to use them.
  - `remove_authorized_keys.yml`: Empties the `~/.ssh/authorized_keys` file for the `ryan` user to enforce certificate-based authentication.
- `gcert`: A tool in `/usr/local/bin` for users to sign their own SSH public keys for their own identities (valid for one week).
- `migration/`: Directory for service migration manifests and scripts.
  - `k8s-manifests/`: Contains Kubernetes manifests (PVC, Deployment, Service, IngressRoute) for migrated services.
  - `migrate-data.sh`: Script to transfer local data to Longhorn volumes in the k3s cluster.

## Recent Progress
### Storage Maintenance (2026-03-06)
- **Reclaimed ~6GB** of disk space on `/var` by cleaning up the APT package cache (`apt-get clean`). Usage reduced from 93% to 22%.

### Service Migration (2026-03-06)
- **Actual Budget:** Successfully migrated from a local Docker container to the Kubernetes cluster.
  - **Storage:** Data transferred to a 2Gi Longhorn volume (`actual-budget-pvc`).
  - **Networking:** Configured Traefik `IngressRoute` for secure external access.
  - **URL:** [https://budget.sourcequench.org](https://budget.sourcequench.org)
  - **Local Cleanup:** Stopped the local `actual_budget` container to avoid duplication.

## Usage & Conventions
- **Security Mandate (History Protection):** If you ever run a command that includes a secret (API key, password, token) on the command line, **MUST** prepend the command with a leading space (e.g., `  export API_KEY=...`) to prevent it from being recorded in the shell history (`HISTCONTROL=ignoreboth` or `ignorespace`).
- **Security Mandate (No Hardcoded Secrets):** NEVER bake secrets, passwords, or API keys directly into environment files (`.env`), Kubernetes ConfigMaps, or Ansible playbooks. All sensitive values must be handled via Ansible Vault, Kubernetes Secrets (not tracked in Git), or secure environment variables provided at runtime.
- **Collaboration:** Use this directory to stage files intended for review or collaborative editing.
- **Infrastructure as Code:** Ansible playbooks are used to manage server configurations. The `kubernetes` group is configured to trust SSH User Certificates signed by the CA at `/etc/ssh/ssh_user_ca`.
- **Host Certificates:** Remote hosts are also configured with signed host certificates using the Host CA at `/etc/ssh/ssh_host_ca`.
- **SSH Authentication:** User certificates are generated with a one-week lifetime. Users can use the `gcert` tool to sign their own public keys.
- **Documentation:** Prioritize clear filenames and internal documentation to ensure seamless handoffs.
- **Organization:** As the volume of content grows, consider organizing files into logical subdirectories (e.g., `docs/`, `src/`, `notes/`).

## TODOs
- [x] Populate the directory with initial documents or project assets. ✅ 2026-02-23
