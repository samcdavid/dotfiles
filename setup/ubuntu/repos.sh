#!/bin/bash

# Adds every third-party apt repo/signing key that Aptfile depends on.
# Must run, then `apt update`, before Aptfile packages are installed.

set -e

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

CODENAME="$(lsb_release -cs)"

# --- GitHub CLI -------------------------------------------------------
fancy_echo "Adding GitHub CLI apt repo..."
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

# --- Docker (engine + Desktop's dependencies) --------------------------
fancy_echo "Adding Docker apt repo..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --yes --batch --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# --- PostgreSQL (PGDG — always tracks latest stable major) -------------
fancy_echo "Adding PostgreSQL (PGDG) apt repo..."
sudo install -d /usr/share/postgresql-common/pgdg
# NOTE: was a plain `curl -o` here — that directory is root-owned, so curl
# couldn't write to it as the invoking user (curl exit 23) and `set -e`
# silently killed the rest of this script, taking Google Cloud/1Password/
# VS Code/ngrok/NVIDIA's repo registration down with it. `sudo tee` fixes it.
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  | sudo tee /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc >/dev/null
echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $CODENAME-pgdg main" \
  | sudo tee /etc/apt/sources.list.d/pgdg.list >/dev/null

# --- Google Cloud CLI ----------------------------------------------------
fancy_echo "Adding Google Cloud CLI apt repo..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --yes --batch --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null

# --- 1Password ----------------------------------------------------------
fancy_echo "Adding 1Password apt repo..."
curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
  | sudo gpg --yes --batch --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
  | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
sudo install -d /etc/debsig/policies/AC2D62742012EA22/
curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol \
  | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
sudo install -d /usr/share/debsig/keyrings/AC2D62742012EA22
curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
  | sudo gpg --yes --batch --dearmor -o /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# --- VS Code --------------------------------------------------------------
fancy_echo "Adding VS Code apt repo..."
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | sudo gpg --yes --batch --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

# --- ngrok ------------------------------------------------------------
fancy_echo "Adding ngrok apt repo..."
curl -fsSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list >/dev/null

# --- NVIDIA CUDA keyring -------------------------------------------------
# NOTE: brand-new Ubuntu releases sometimes lag NVIDIA's repo by weeks/months.
# If $DISTRO_TAG below 404s, check https://developer.download.nvidia.com/compute/cuda/repos/
# for the closest supported release (e.g. ubuntu2404) and override DISTRO_TAG.
DISTRO_TAG="ubuntu$(lsb_release -rs | tr -d '.')"
fancy_echo "Adding NVIDIA CUDA apt repo ($DISTRO_TAG)..."
curl -fsSL -o /tmp/cuda-keyring.deb \
  "https://developer.download.nvidia.com/compute/cuda/repos/${DISTRO_TAG}/x86_64/cuda-keyring_1.1-1_all.deb"
sudo dpkg -i /tmp/cuda-keyring.deb
rm /tmp/cuda-keyring.deb

fancy_echo "Updating apt after adding repos..."
sudo apt update
