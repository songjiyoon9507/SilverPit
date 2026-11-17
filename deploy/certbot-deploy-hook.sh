#!/bin/bash
# ============================================================
#  certbot 인증서 발급/갱신 직후 실행되는 deploy-hook
#  - Let's Encrypt PEM 인증서를 Spring Boot 용 PKCS12(.p12) 로 변환합니다.
#  - alias / 비밀번호는 application-prod.properties 의
#    server.ssl.key-alias / server.ssl.key-store-password 와 같아야 합니다.
#  - 설치: sudo cp certbot-deploy-hook.sh /etc/letsencrypt/renewal-hooks/deploy/silver.sh
#          sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/silver.sh
# ============================================================
set -e

DOMAIN="silverpt.o-r.kr"
SRC="/etc/letsencrypt/live/$DOMAIN"
P12="/home/ubuntu/silverfit.p12"
ALIAS="silverpit"
PASSWORD="silverpit"
OWNER="ubuntu"

openssl pkcs12 -export \
    -in "$SRC/fullchain.pem" \
    -inkey "$SRC/privkey.pem" \
    -out "$P12" \
    -name "$ALIAS" \
    -passout "pass:$PASSWORD"

chown "$OWNER:$OWNER" "$P12"
chmod 600 "$P12"

echo "[certbot-deploy-hook] $DOMAIN 인증서를 $P12 (alias=$ALIAS) 로 변환했습니다."
