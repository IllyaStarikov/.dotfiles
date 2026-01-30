#!/usr/bin/env zsh

# ssh.zsh - SSH connection and key management utilities
# Provides functions for SSH operations, key management, and remote execution

# SSH configuration
typeset -g SSH_CONFIG_FILE="${HOME}/.ssh/config"
typeset -g SSH_KNOWN_HOSTS="${HOME}/.ssh/known_hosts"
typeset -g SSH_KEY_DIR="${HOME}/.ssh"
typeset -g SSH_DEFAULT_PORT=22
typeset -g SSH_DEFAULT_USER="${USER}"
typeset -g SSH_TIMEOUT=10

# Check if SSH key exists
ssh_key_exists() {
  local key_name="${1:-id_rsa}"
  local key_path="${SSH_KEY_DIR}/${key_name}"

  [[ -f "$key_path" ]] || [[ -f "${key_path}.pub" ]]
}

# Generate SSH key pair
ssh_generate_key() {
  local key_name="${1:-id_rsa}"
  local key_type="${2:-rsa}"
  local key_bits="${3:-4096}"
  local comment="${4:-${USER}@$(hostname)}"
  local passphrase="${5:-}"

  local key_path="${SSH_KEY_DIR}/${key_name}"

  if ssh_key_exists "$key_name"; then
  echo "SSH key already exists: $key_path" >&2
  return 1
  fi

  # Create SSH directory if it doesn't exist
  mkdir -p "$SSH_KEY_DIR"
  chmod 700 "$SSH_KEY_DIR"

  # Generate key
  if [[ -n "$passphrase" ]]; then
  ssh-keygen -t "$key_type" -b "$key_bits" -f "$key_path" -C "$comment" -N "$passphrase"
  else
  ssh-keygen -t "$key_type" -b "$key_bits" -f "$key_path" -C "$comment" -N ""
  fi

  # Set proper permissions
  chmod 600 "$key_path"
  chmod 644 "${key_path}.pub"

  echo "SSH key generated: $key_path"
}

# Copy SSH key to remote host
ssh_copy_key() {
  local host="$1"
  local key_name="${2:-id_rsa}"
  local port="${3:-$SSH_DEFAULT_PORT}"
  local user="${4:-$SSH_DEFAULT_USER}"

  local key_path="${SSH_KEY_DIR}/${key_name}.pub"

  if [[ ! -f "$key_path" ]]; then
  echo "SSH public key not found: $key_path" >&2
  return 1
  fi

  ssh-copy-id -i "$key_path" -p "$port" "${user}@${host}"
}

# List SSH keys
ssh_list_keys() {
  local format="${1:-simple}" # simple, detailed, fingerprint

  echo "SSH Keys in $SSH_KEY_DIR:"
  echo "========================="

  for key in "$SSH_KEY_DIR"/*.pub; do
  [[ -f "$key" ]] || continue

  local key_name="${key%.pub}"
  key_name="${key_name##*/}"

  case "$format" in
  detailed)
    echo
    echo "Key: $key_name"
    ssh-keygen -l -f "$key"
    if [[ -f "${key%.pub}" ]]; then
    echo "  Private key: Present"
    else
    echo "  Private key: Missing"
    fi
    ;;
  fingerprint)
    ssh-keygen -l -f "$key"
    ;;
  *)
    echo "  $key_name"
    ;;
  esac
  done
}

# Add SSH key to agent
ssh_add_key() {
  local key_name="${1:-id_rsa}"
  local key_path="${SSH_KEY_DIR}/${key_name}"

  if [[ ! -f "$key_path" ]]; then
  echo "SSH private key not found: $key_path" >&2
  return 1
  fi

  # Start ssh-agent if not running
  if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
  fi

  ssh-add "$key_path"
}

# Remove SSH key from agent
ssh_remove_key() {
  local key_name="${1:-id_rsa}"
  local key_path="${SSH_KEY_DIR}/${key_name}"

  ssh-add -d "$key_path" 2>/dev/null
}

# List keys in SSH agent
ssh_agent_list() {
  ssh-add -l 2>/dev/null || echo "No keys in agent or agent not running"
}

# Clear all keys from SSH agent
ssh_agent_clear() {
  ssh-add -D
}

# Test SSH connection
ssh_test_connection() {
  local host="$1"
  local port="${2:-$SSH_DEFAULT_PORT}"
  local user="${3:-$SSH_DEFAULT_USER}"
  local timeout="${4:-$SSH_TIMEOUT}"

  ssh -o ConnectTimeout="$timeout" \
  -o BatchMode=yes \
  -o StrictHostKeyChecking=no \
  -p "$port" \
  "${user}@${host}" \
  "echo 'SSH connection successful'" 2>/dev/null
}

# Execute command on remote host
ssh_exec() {
  local host="$1"
  local command="$2"
  local port="${3:-$SSH_DEFAULT_PORT}"
  local user="${4:-$SSH_DEFAULT_USER}"

  ssh -p "$port" "${user}@${host}" "$command"
}

# Execute command on multiple hosts
ssh_exec_multi() {
  local command="$1"
  shift
  local hosts=("$@")

  for host in "${hosts[@]}"; do
  echo "Executing on $host:"
  echo "===================="
  ssh_exec "$host" "$command"
  echo
  done
}

# Copy file to remote host
ssh_copy_to() {
  local source="$1"
  local host="$2"
  local dest="${3:-}"
  local port="${4:-$SSH_DEFAULT_PORT}"
  local user="${5:-$SSH_DEFAULT_USER}"

  if [[ -z "$dest" ]]; then
  dest="~/"
  fi

  scp -P "$port" "$source" "${user}@${host}:${dest}"
}

# Copy file from remote host
ssh_copy_from() {
  local host="$1"
  local source="$2"
  local dest="${3:-.}"
  local port="${4:-$SSH_DEFAULT_PORT}"
  local user="${5:-$SSH_DEFAULT_USER}"

  scp -P "$port" "${user}@${host}:${source}" "$dest"
}

# Sync directory with remote host
ssh_sync() {
  local source="$1"
  local host="$2"
  local dest="$3"
  local port="${4:-$SSH_DEFAULT_PORT}"
  local user="${5:-$SSH_DEFAULT_USER}"
  local options="${6:--avz}"

  rsync "$options" -e "ssh -p $port" "$source" "${user}@${host}:${dest}"
}

# Create SSH tunnel
ssh_tunnel() {
  local local_port="$1"
  local remote_host="$2"
  local remote_port="$3"
  local jump_host="$4"
  local jump_port="${5:-$SSH_DEFAULT_PORT}"
  local jump_user="${6:-$SSH_DEFAULT_USER}"

  ssh -N -L "${local_port}:${remote_host}:${remote_port}" \
  -p "$jump_port" \
  "${jump_user}@${jump_host}"
}

# Create reverse SSH tunnel
ssh_reverse_tunnel() {
  local remote_port="$1"
  local local_host="$2"
  local local_port="$3"
  local remote_host="$4"
  local ssh_port="${5:-$SSH_DEFAULT_PORT}"
  local ssh_user="${6:-$SSH_DEFAULT_USER}"

  ssh -N -R "${remote_port}:${local_host}:${local_port}" \
  -p "$ssh_port" \
  "${ssh_user}@${remote_host}"
}

# Add host to SSH config
ssh_config_add_host() {
  local host_alias="$1"
  local hostname="$2"
  local user="${3:-$SSH_DEFAULT_USER}"
  local port="${4:-$SSH_DEFAULT_PORT}"
  local key_name="${5:-id_rsa}"

  local key_path="${SSH_KEY_DIR}/${key_name}"

  # Check if host already exists
  if grep -q "^Host $host_alias$" "$SSH_CONFIG_FILE" 2>/dev/null; then
  echo "Host $host_alias already exists in SSH config" >&2
  return 1
  fi

  # Append to SSH config
  cat >>"$SSH_CONFIG_FILE" <<EOF

Host $host_alias
  HostName $hostname
  User $user
  Port $port
  IdentityFile $key_path
  IdentitiesOnly yes
EOF

  echo "Host $host_alias added to SSH config"
}

# Remove host from SSH config
ssh_config_remove_host() {
  local host_alias="$1"

  if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
  echo "SSH config file not found" >&2
  return 1
  fi

  # Create backup
  cp "$SSH_CONFIG_FILE" "${SSH_CONFIG_FILE}.bak"

  # Remove host block
  awk "/^Host $host_alias\$/{flag=1} /^Host /{if(flag && !/^Host $host_alias\$/){flag=0}} !flag" \
  "$SSH_CONFIG_FILE" >"${SSH_CONFIG_FILE}.tmp"

  mv "${SSH_CONFIG_FILE}.tmp" "$SSH_CONFIG_FILE"
  echo "Host $host_alias removed from SSH config"
}

# List hosts in SSH config
ssh_config_list_hosts() {
  if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
  echo "SSH config file not found" >&2
  return 1
  fi

  echo "Hosts in SSH config:"
  echo "==================="
  grep "^Host " "$SSH_CONFIG_FILE" | awk '{print "  " $2}'
}

# Get host details from SSH config
ssh_config_get_host() {
  local host_alias="$1"

  if [[ ! -f "$SSH_CONFIG_FILE" ]]; then
  echo "SSH config file not found" >&2
  return 1
  fi

  awk "/^Host $host_alias\$/{flag=1} /^Host /{if(flag && !/^Host $host_alias\$/){exit}} flag" \
  "$SSH_CONFIG_FILE"
}

# Clean known hosts
ssh_clean_known_hosts() {
  local host="$1"

  ssh-keygen -R "$host" 2>/dev/null
}

# Check if host is in known hosts
ssh_host_known() {
  local host="$1"

  ssh-keygen -F "$host" >/dev/null 2>&1
}

# Get host key fingerprint
ssh_host_fingerprint() {
  local host="$1"
  local port="${2:-$SSH_DEFAULT_PORT}"

  ssh-keyscan -p "$port" "$host" 2>/dev/null | ssh-keygen -lf -
}

# Check SSH agent status
ssh_agent_status() {
  if ssh-add -l >/dev/null 2>&1; then
  echo "SSH agent is running"
  echo "Keys loaded: $(ssh-add -l | wc -l)"
  return 0
  else
  echo "SSH agent is not running or has no keys"
  return 1
  fi
}

# Start SSH agent if not running
ssh_agent_start() {
  if ! ssh-add -l >/dev/null 2>&1; then
  echo "Starting SSH agent..."
  eval "$(ssh-agent -s)"
  echo "SSH agent started with PID $SSH_AGENT_PID"
  else
  echo "SSH agent is already running"
  fi
}

# Stop SSH agent
ssh_agent_stop() {
  if [[ -n "$SSH_AGENT_PID" ]]; then
  kill "$SSH_AGENT_PID"
  unset SSH_AGENT_PID
  unset SSH_AUTH_SOCK
  echo "SSH agent stopped"
  else
  echo "SSH agent is not running"
  fi
}

# SOCKS proxy via SSH
ssh_socks_proxy() {
  local host="$1"
  local local_port="${2:-1080}"
  local port="${3:-$SSH_DEFAULT_PORT}"
  local user="${4:-$SSH_DEFAULT_USER}"

  echo "Starting SOCKS proxy on localhost:$local_port via $host..."
  ssh -D "$local_port" -C -N -p "$port" "${user}@${host}"
}

# Mount remote filesystem via SSHFS
ssh_mount() {
  local host="$1"
  local remote_path="${2:-/}"
  local mount_point="$3"
  local port="${4:-$SSH_DEFAULT_PORT}"
  local user="${5:-$SSH_DEFAULT_USER}"

  if [[ -z "$mount_point" ]]; then
  mount_point="${HOME}/mnt/${host}"
  fi

  # Create mount point if it doesn't exist
  mkdir -p "$mount_point"

  # Mount
  sshfs -p "$port" "${user}@${host}:${remote_path}" "$mount_point"

  echo "Mounted ${host}:${remote_path} at $mount_point"
}

# Unmount SSHFS mount
ssh_unmount() {
  local mount_point="$1"

  if [[ -z "$mount_point" ]]; then
  echo "Mount point required" >&2
  return 1
  fi

  if mountpoint -q "$mount_point" 2>/dev/null || mount | grep -q "$mount_point"; then
  if command -v fusermount >/dev/null 2>&1; then
    fusermount -u "$mount_point"
  else
    umount "$mount_point"
  fi
  echo "Unmounted $mount_point"
  else
  echo "$mount_point is not mounted" >&2
  return 1
  fi
}
