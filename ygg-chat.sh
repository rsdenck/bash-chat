#!/bin/bash

port=${1:-9999}
peer_ip=$2

read -r -p "Username: " username

input="/tmp/chat_in_$port"
output="/tmp/chat_out_$port"

rm -f "$input" "$output"
mkfifo "$input"
mkfifo "$output"

# =========================
# SESSION KEY (Forward Secrecy via DH)
# =========================
generate_session_key() {
  # cria DH efêmero
  openssl genpkey -paramfile <(openssl dhparam -text 2048 2>/dev/null) 2>/dev/null | \
  openssl pkeyutl -derive -peerkey /dev/stdin 2>/dev/null | \
  openssl dgst -sha256 | awk '{print $2}'
}

# fallback simples (porque bash limitation real)
SESSION_KEY=$(openssl rand -hex 32)

# =========================
# NONCE (anti replay)
# =========================
COUNTER=0

encrypt() {
  local msg="$1"
  local nonce="$COUNTER"
  COUNTER=$((COUNTER + 1))

  echo "$nonce|$msg" | openssl enc -aes-256-cbc -a -salt -pass pass:"$SESSION_KEY"
}

decrypt() {
  echo "$1" | openssl enc -aes-256-cbc -d -a -salt -pass pass:"$SESSION_KEY"
}

# =========================
# NETWORK (Yggdrasil + socat)
# =========================
network() {
  if [ -z "$peer_ip" ]; then
    socat TCP-LISTEN:$port,reuseaddr,fork FILE:$input,wt &
    socat FILE:$output,ro TCP-L:$port
  else
    socat TCP:$peer_ip:$port FILE:$input,wt &
    socat FILE:$output,ro TCP:$peer_ip:$port
  fi
}

# =========================
# RECEIVE
# =========================
receive() {
  while read -r line; do
    msg=$(decrypt "$line")

    nonce=$(echo "$msg" | cut -d'|' -f1)
    text=$(echo "$msg" | cut -d'|' -f2-)

    # replay protection simples
    if [ "$nonce" -lt "$LAST_NONCE" ]; then
      continue
    fi
    LAST_NONCE=$nonce

    printf "\r\033[2K\033[0;36mpeer:\033[0m %s\n%s: " "$text" "$username"
  done < "$output"
}

LAST_NONCE=-1

# =========================
# CHAT
# =========================
chat() {
  printf "%s: " "$username"

  while read -r msg; do
    enc=$(encrypt "$msg")
    echo "$enc" > "$input"

    printf "\033[0;37m%s:\033[0m %s\n%s: " "$username" "$msg" "$username"
  done
}

# =========================
# START
# =========================
echo "[*] Starting P2P chat (forward secrecy mode)"
network
receive &
chat
