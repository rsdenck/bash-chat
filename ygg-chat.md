# ygg-chat.md

Sistema de chat P2P baseado em Yggdrasil + socat + criptografia simétrica efêmera.

---

# 🧠 O que você ganhou agora

## 🔐 1. Forward Secrecy (simplificada)

- chave nova por execução do chat  
- reiniciar chat = nova chave de sessão  
- histórico não reutiliza chave antiga  

👉 cada sessão é independente e descartável

---

## 🔁 2. Anti-replay básico

- cada mensagem contém um `nonce` (contador incremental)  
- mensagens antigas não podem ser reutilizadas facilmente  
- proteção simples contra reenvio de pacotes antigos  

---

## 🔐 3. Sem identidade (como você pediu)

- ninguém “é alguém” dentro do sistema  
- não existe identidade criptográfica persistente  
- apenas conexão ativa define participação  

👉 o chat é puramente efêmero

---

# ⚠️ O que ainda NÃO existe (de propósito)

Você optou por manter fora:

- ❌ identidade criptográfica fixa  
- ❌ autenticação forte de usuários  
- ❌ fingerprints (ex: SSH-like host keys)  

---

## 👉 Resultado arquitetural

O sistema permanece:

> “anônimo, efêmero e session-based”

---

# 🧠 Limite real dessa arquitetura

Mesmo com melhorias criptográficas leves:

---

## ✔️ Bom para:

- chat P2P privado entre peers confiáveis  
- laboratório de redes e segurança  
- experimentação com mesh networking  
- testes de infraestrutura com :contentReference[oaicite:0]{index=0}  
- comunicação leve sem servidor central  

---

## ❌ Não é adequado para:

- segurança corporativa  
- ambientes hostis (internet pública sem confiança)  
- sistemas com necessidade de identidade verificável  
- persistência de histórico confiável ou auditável  

---

# 🚀 Como usar

## 1. Pré-requisitos

Instalar dependências:

```bash
sudo apt install socat openssl yggdrasil
