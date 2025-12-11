#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
NATS_USER=""
NATS_PASSWORD=""
DOMAIN=""
INSTALL_DIR="/opt/takasecure"
OUTPUT_KEYFILE="keys.env"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}" >&2
    exit 1
fi

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check Debian version
DEBIAN_VERSION=$(lsb_release -rs | cut -d. -f1)
if [ "$DEBIAN_VERSION" -lt 10 ]; then
    echo -e "${RED}Error: This script requires Debian 10 (Buster) or newer${NC}" >&2
    exit 1
fi


# Function to display usage
usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  curl -sSL https://raw.githubusercontent.com/takasecure/repo/refs/heads/master/run.sh | bash -s -- install | uninstall | upgrade"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  install   - Install the application and all dependencies"
    echo "  uninstall - Remove the application and all its components"
    echo "  upgrade   - Upgrade the application to the latest version"
    exit 1
}

# Function to install Docker and Docker Compose
install_docker() {
    echo -e "${BLUE}Installing Docker and Docker Compose...${NC}"

    # Remove old versions
    apt-get remove -y docker docker-engine docker.io containerd runc

    # Install dependencies
    apt-get update
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker with Compose plugin
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Verify Docker installation
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker installation failed${NC}" >&2
        exit 1
    fi

    # Verify Docker Compose (from plugin)
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: Docker Compose plugin not working${NC}" >&2
        exit 1
    fi

    echo -e "${GREEN}Docker and Docker Compose installed successfully${NC}"
}

# Validation functions
validate_email() {
    local email=$1
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_port() {
    local port=$1
    if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
        return 0
    else
        return 1
    fi
}

# Function to get user input
get_credentials() {
    echo -e "${YELLOW}Please provide the following credentials:${NC}"

    # Optional Docker Hub login
    read -p "Using private Docker Hub (yes/no): " USE_PRIVATE_DOCKERHUB
    if [ "$USE_PRIVATE_DOCKERHUB" = "yes" ]; then
        while [ -z "$DOCKERHUB_USERNAME" ]; do
            read -p "Docker Hub username: " DOCKERHUB_USERNAME
            if [ -z "$DOCKERHUB_USERNAME" ]; then
                echo -e "${RED}Docker Hub username cannot be empty${NC}"
            fi
        done

        while [ -z "$DOCKERHUB_PASSWORD" ]; do
            read -sp "Docker Hub password: " DOCKERHUB_PASSWORD
            echo
            if [ -z "$DOCKERHUB_PASSWORD" ]; then
                echo -e "${RED}Docker Hub password cannot be empty${NC}"
            fi
        done

        # Perform Docker login
        echo -e "${BLUE}Logging into Docker Hub...${NC}"
        echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Docker login failed${NC}" >&2
            exit 1
        fi
        echo -e "${GREEN}Docker login successful${NC}"
    fi
    while [ -z "$NATS_USER" ]; do
        read -p "NATS username: " NATS_USER
        if [ -z "$NATS_USER" ]; then
            echo -e "${RED}NATS username cannot be empty${NC}"
        fi
    done
    while [ -z "$NATS_PASSWORD" ]; do
        read -sp "NATS password: " NATS_PASSWORD
        echo
        if [ -z "$NATS_PASSWORD" ]; then
            echo -e "${RED}NATS password cannot be empty${NC}"
        fi
    done
    while [ -z "$DOMAIN" ]; do
        read -p "Domain name for the website (e.g., example.com): " DOMAIN
        if [ -z "$DOMAIN" ]; then
            echo -e "${RED}Domain name cannot be empty${NC}"
        fi
    done
    while [ -z "$WEB_VERSION" ]; do
        read -p "Web Tag Spesific Version want installaded Ex: v1.35.2-uat " WEB_VERSION
        if [ -z "$WEB_VERSION" ]; then
            # --- BARIS INI SUDAH DIPERBAIKI ---
            echo -e "${RED}Web version cannot be empty${NC}"
        fi
    done
    while [ -z "$NATS_1" ]; do
        read -p "NATS Cluster with 3 node, type private IP Address for HOST 1" NATS_1
        if [ -z "$NATS_1" ]; then
            echo -e "${RED}IP Cluster NATS_1 can't empty${NC}"
        fi
    done
    while [ -z "$NATS_2" ]; do
        read -p "NATS Cluster with 3 node, type private IP Address for HOST 2" NATS_2
        if [ -z "$NATS_2" ]; then
            echo -e "${RED}IP Cluster NATS_2 can't empty${NC}"
        fi
    done
    while [ -z "$NATS_3" ]; do
        read -p "NATS Cluster with 3 node, type private IP Address for HOST 3" NATS_3
        if [ -z "$NATS_3" ]; then
            echo -e "${RED}IP Cluster NATS_3 can't empty${NC}"
        fi
    done
    while [ -z "$NATS_CONSUMER_NAME" ]; do
        read -p "NATS CONSUMER NAME" NATS_CONSUMER_NAME
        if [ -z "$NATS_CONSUMER_NAME" ]; then
            echo -e "${RED}NATS CONSUMER_NAME can't empty${NC}"
        fi
    done

    print_info "SMTP Configuration Setup"
    echo "════════════════════════════════════════════════════════"
    echo ""

    # SMTP Host
    while [ -z "$SMTP_HOST" ]; do
        read -p "SMTP Host (e.g., smtp.gmail.com): " SMTP_HOST
        if [ -z "$SMTP_HOST" ]; then
            print_error "SMTP Host cannot be empty"
        fi
    done

    # SMTP Port
    while [ -z "$SMTP_PORT" ]; do
        read -p "SMTP Port (default: 587): " SMTP_PORT
        SMTP_PORT=${SMTP_PORT:-587}
        if ! validate_port "$SMTP_PORT"; then
            print_error "Invalid port number (must be 1-65535)"
            SMTP_PORT=""
        fi
    done
    # SMTP Username (email)
    while [ -z "$SMTP_USERNAME" ]; do
        read -p "SMTP Username (email): " SMTP_USERNAME
        if [ -z "$SMTP_USERNAME" ]; then
            print_error "SMTP Username cannot be empty"
        elif ! validate_email "$SMTP_USERNAME"; then
            print_error "Invalid email format"
            SMTP_USERNAME=""
        fi
    done

    # SMTP Password
    while [ -z "$SMTP_PASSWORD" ]; do
        read -s -p "SMTP Password: " SMTP_PASSWORD
        echo ""
        if [ -z "$SMTP_PASSWORD" ]; then
            print_error "SMTP Password cannot be empty"
        fi
    done

    # Confirm password
    while [ -z "$SMTP_PASSWORD_CONFIRM" ] || [ "$SMTP_PASSWORD" != "$SMTP_PASSWORD_CONFIRM" ]; do
        read -s -p "Confirm SMTP Password: " SMTP_PASSWORD_CONFIRM
        echo ""
        if [ "$SMTP_PASSWORD" != "$SMTP_PASSWORD_CONFIRM" ]; then
            print_error "Passwords do not match"
            SMTP_PASSWORD_CONFIRM=""
        fi
    done

    # SMTP Sender
    while [ -z "$SMTP_SENDER" ]; do
        read -p "SMTP Sender Email (default: $SMTP_USERNAME): " SMTP_SENDER
        SMTP_SENDER=${SMTP_SENDER:-$SMTP_USERNAME}
        if ! validate_email "$SMTP_SENDER"; then
            print_error "Invalid email format"
            SMTP_SENDER=""
        fi
    done

    # SMTP Sender Name
    while [ -z "$SMTP_SENDER_NAME" ]; do
        read -p "SMTP Sender Name (e.g., [No-Reply] Company): " SMTP_SENDER_NAME
        if [ -z "$SMTP_SENDER_NAME" ]; then
            print_error "SMTP Sender Name cannot be empty"
        fi
    done

    print_info "JWT Secret Configuration"
    echo "════════════════════════════════════════════════════════"

    # Prompt for SERVICE_JWT_SECRET
    while [ -z "$SERVICE_JWT_SECRET" ]; do
        read -p "Enter SERVICE_JWT_SECRET: " SERVICE_JWT_SECRET
        if [ -z "$SERVICE_JWT_SECRET" ]; then
            print_error "JWT secret cannot be empty."
        elif [ ${#SERVICE_JWT_SECRET} -lt 50 ]; then
            print_warning "Warning: The JWT secret seems shorter than expected (${#SERVICE_JWT_SECRET} characters)."
            read -p "Are you sure you want to use it? (y/N): " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                SERVICE_JWT_SECRET=""
            fi
        fi
    done

    # Mask the JWT Secret for confirmation (show first and last 5 chars only)
    MASKED_SECRET="$(echo "$SERVICE_JWT_SECRET" | awk '{print substr($0,1,5)"...("length($0)" chars)... "substr($0,length($0)-5,6)}')"

    # Confirm the secret
    echo ""
    print_info "Preview (masked): $MASKED_SECRET"
    read -p "Confirm saving this JWT secret? (Y/n): " save_confirm
    save_confirm=${save_confirm:-Y}

    if [ "$save_confirm" != "Y" ] && [ "$save_confirm" != "y" ]; then
        print_info "Operation cancelled."
        exit 0
    fi
}
save_dockerfile_website() {
    echo -e "${BLUE}Creating Dockerfile for Website ...${NC}"
    cat > $INSTALL_DIR/Dockerfile <<EOF
FROM admintaka/website:latest
EOF
    echo -e "${GREEN}tls.crt created successfully${NC}"
}

save_dockerfile_website() {
    echo -e "${BLUE}Creating Dockerfile for Website ...${NC}"
    cat > $INSTALL_DIR/Dockerfile <<EOF
FROM admintaka/website:latest
EOF
    echo -e "${GREEN}Dockefile created successfully${NC}"
}

generate_aes_key() {
    openssl rand -base64 24 | tr -d '\n'
}

generate_encryption_key() {
    openssl rand -hex 32 | tr -d '\n'
}

generate_aes_key_api() {
    openssl rand -base64 24 | tr -d '/+=' | cut -c1-32 | tr -d '\n'
}
generate_keys() {
    # Generate only if file doesn't exist
    if [ -f "$OUTPUT_FILE" ]; then
        print_warning "Keys already exist in $OUTPUT_FILE"
        echo "Use existing keys or delete the file to regenerate"
        exit 1
    fi

    print_info "Generating encryption keys..."

    AES_KEY=$(generate_aes_key)
    ENCRYPTION_KEY=$(generate_encryption_key)
    AES_KEY_API=$(generate_aes_key_api)

    # Write to file - one key per line for easy copying
    cat > "$INSTALL_DIR/$OUTPUT_KEYFILE" << EOF
$AES_KEY
$ENCRYPTION_KEY
$AES_KEY_API
EOF

    print_success "Keys generated and saved to $OUTPUT_KEYFILE"
}

readarray -t KEYS < "$INSTALL_DIR/$OUTPUT_KEYFILE"
AES_KEY="${KEYS[0]}"
ENCRYPTION_KEY="${KEYS[1]}"
AES_KEY_API="${KEYS[2]}"

save_auth_service_env() {
    echo -e "${BLUE}Creating auth-service.env...${NC}"
    cat > $INSTALL_DIR/auth-service.env <<EOF
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=auth-service:3000
SERVICE_NAME=takakrypt-auth-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=auth-service:3000
GATEWAY_DOMAIN_URL=gw-$DOMAIN/
CRYPTO_SERVICE_HOST=crypto-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
MASKING_SERVICE_HOST=masking-service:3000
DISPATCHER_ADDR=dispatcher:3000
SMTP_HOST='$SMTP_HOST'
SMTP_PASSWORD='$SMTP_PASSWORD'
SMTP_USERNAME='$SMTP_USERNAME'
SMTP_PORT=$SMTP_PORT
SMTP_SENDER='$SMTP_SENDER'
SMTP_SENDER_NAME="$SMTP_SENDER_NAME"
SMTP_TLS=true
AES_KEY='$AES_KEY'
ENCRYPTION_KEY='$ENCRYPTION_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
ACCOUNT_VERIFICATION_URL='gw-$DOMAIN/api/v1/auth/user-verification/'
ACCESS_TOKEN_EXPIRATION=720
OTP_EXPIRATION=1
OTP_ACCOUNT_VERIFICATION_EXPIRATION=10
MAIL_HEADER_IMG=https://$DOMAIN/mail-header-img.png
OPEN_TELEMETRY_COLLECTOR_URL=''
VAULT_PATH='/opt/app/vault'
LOG_PATH='/opt/app/log'
LOG_LEVEL='error'
SEEDING_MASTER_DATA='true'
SYNC_ENABLED='false'
INSTANCE_ID='A'
GRPC_SYNC_PORT='9090'
DB_PATH='master'
SYNC_RETRY_MAX='3'
SYNC_RETRY_DELAY='2s'
SYNC_TIMEOUT='5s'
HEALTH_CHECK_FREQ='30s'
MONITORING_PORT='8090'
EOF
    echo -e "${GREEN}auth-service.env created successfully${NC}"
}

save_crypto_service_env() {
    echo -e "${BLUE}Creating crypto-service.env...${NC}"
    cat > $INSTALL_DIR/crypto-service.env <<EOF
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SMTP_HOST='$SMTP_HOST'
SMTP_PASSWORD='$SMTP_PASSWORD'
SMTP_USERNAME='$SMTP_USERNAME'
SMTP_PORT=$SMTP_PORT
SMTP_SENDER='$SMTP_SENDER'
SMTP_SENDER_NAME="$SMTP_SENDER_NAME"
SMTP_TLS=false
SERVICE_ADDRESS=crypto-service:3000
SERVICE_NAME=takakrypt-crypto-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=crypto-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
MASKING_SERVICE_HOST=masking-service:3000
DISPATCHER_ADDR=dispatcher:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=gw-$DOMAIN/
AES_KEY='$AES_KEY'
ENCRYPTION_KEY='$ENCRYPTION_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017/admin?authSource=admin&replicaSet=rs0'
OPEN_TELEMETRY_COLLECTOR_URL=''
JSON_STORAGE_PATH=/opt/app/json/db.json
VAULT_PATH='/opt/app/vault'
LOG_PATH='/opt/app/log'
SERVICE_ENV=production
LOG_LEVEL='error'
LOG_CAPACITY=53687091200
AUTO_ROTATE_KEY_INTERVAL=1 #hour
MAIL_HEADER_IMG=$DOMAIN/mail-header-img.png
KEY_EXPIRATION_CHECK_TIME=1
ENABLE_KEY_VERSION_MIGRATION=false
MIGRATION_TIMEOUT_SECONDS=1200
SYSLOG_ENABLED=false
SYSLOG_SERVER=10.10.50.104:514
SYSLOG_PROTOCOL=tcp      # TCP untuk message panjang
SYSLOG_TAG=takakrypt
SPLUNK_ENABLED=false
SPLUNK_HEC_URL=http://192.168.50.36:8088/services/collector
SPLUNK_HEC_TOKEN=dc6164d6-2a90-4243-891f-3694866d40bb
SPLUNK_SOURCE=takakrypt-local
SPLUNK_INDEX=main
FILE_STORAGE_PATH='/opt/app/migrate_data'
MAIL_HEADER_IMG=container.takasecure.io/mail-header-img.png
SYNC_ENABLED=true
INSTANCE_ID=A
SYNC_RETRY_MAX=3
SYNC_RETRY_DELAY=2s
SYNC_TIMEOUT=5s
HEALTH_CHECK_FREQ=30s
DB_PATH=master
APP_NAME=takakrypt-crypto-service
APP_VERSION=1.0.0
HTTP_PORT=8080
GRPC_SYNC_PORT=9092
SEEDING_MASTER_DATA=false
EOF
    echo -e "${GREEN}crypto-service.env created successfully${NC}"
}

save_gateway_service_env() {
    echo -e "${BLUE}Creating gateway-service.env...${NC}"
    cat > $INSTALL_DIR/gateway-service.env <<EOF
SERVICE_ADDRESS=gateway-service:3000
SERVICE_NAME=takakrypt-gateway-service
SERVICE_PORT=3000
SERVICE_VERSION=1.0.0
SERVICE_JWT_SECRET=$SERVICE_JWT_SECRET
SERVICE_ENV=production
SERVER_TYPE=graphql
SENTRY_ADDRESS=https://69af9c7e58084fe3a5792cc43442d2d1@o1213380.ingest.sentry.io/6352574
SENTRY_USERNAME=
SENTRY_PORT=
SENTRY_PASSWORD=
SENTRY_ENV=production
CACHE_ADDRESS=127.0.0.1
CACHE_DRIVER=redis
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=6379
GQL_QUERY_COMPLEXITY=
CRYPTO_SERVICE_HOST=crypto-service:3000
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=auth-service:3000
LOCK_SERVICE_HOST=lock-service:3000
MASKING_SERVICE_HOST=masking-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
FILE_SERVICE_HOST=file-service:3000
BACKUP_SERVICE_HOST=backup-service:3000
AES_KEY='$AES_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
APP_DOMAIN_URL='http://$DOMAIN/'
GQL_QUERY_DISABLE_INTROSPECTION=false
OPEN_TELEMETRY_COLLECTOR_URL=''
# TLS_CERT_PATH=/certs/gateway.crt
# TLS_KEY_PATH=/certs/gateway.key
# TLS_CA_PATH=/certs/ca.crt
EOF
    echo -e "${GREEN}gateway-service.env created successfully${NC}"
}

save_website_service_env() {
    echo -e "${BLUE}Creating website-service.env...${NC}"
    cat > $INSTALL_DIR/website-service.env <<EOF
# This file is for website environment, but most configs are now in nginx and gateway
EOF
    echo -e "${GREEN}website-service.env created successfully${NC}"
}

save_nats_cluster_config(){
    echo -e "${BLUE}Creating nats-cluster.conf...${NC}"
    cat > $INSTALL_DIR/nats.conf <<EOF
server_name: nats
port: 4222

jetstream {
  store_dir: "./data"
  max_mem: 1G
  max_file: 10G
}

cluster {
  name: supercluster
  listen: 0.0.0.0:6222
  routes = [
    nats-route://$NATS_2:6222
    nats-route://$NATS_3:6222
  ]
}
EOF
}

save_dispatch_env(){
    echo -e "${BLUE}Creating Env for Dispatch...${NC}"
    cat > $INSTALL_DIR/dispatch.env <<EOF
# Dispatcher A Configuration
DISPATCHER_ID=$NATS_CONSUMER_NAME
GRPC_PORT=9080
BACKEND_ADDR=localhost:9090

# NATS Configuration
NATS_URL_1=nats://$NATS_1:4222
NATS_URL_2=nats://$NATS_2:4222
NATS_URL_3=nats://$NATS_3:4222
STREAM_NAME=DATA_SYNC
SUBJECT=data.sync.*
CONSUMER_NAME=$NATS_CONSUMER_NAME

# Queue Configuration
QUEUE_DB_PATH=queue.db
MAX_QUEUE_SIZE=10000

# Retry Configuration
MAX_RETRIES=5
INITIAL_DELAY=1s
MAX_DELAY=30s
BACKOFF_FACTOR=2.0

# Health Configuration
HEALTH_CHECK_INTERVAL=30s
REQUEST_TIMEOUT=10s

# Logging
LOG_LEVEL=INFO
EOF
}
save_tokenize_env(){
    echo -e "${BLUE}Creating Env for Tokenize...${NC}"
    cat > $INSTALL_DIR/tokenize-service.env <<EOF
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=tokenize-service:3000
SERVICE_NAME=takakrypt-tokenize-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=auth-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
MASKING_SERVICE_HOST=masking-service:3000
DISPATCHER_ADDR=dispatcher:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=$DOMAIN/api/
SMTP_HOST='$SMTP_HOST'
SMTP_PASSWORD='$SMTP_PASSWORD'
SMTP_USERNAME='$SMTP_USERNAME'
SMTP_PORT=$SMTP_PORT
SMTP_SENDER='$SMTP_SENDER'
SMTP_SENDER_NAME="$SMTP_SENDER_NAME"
SMTP_TLS=true
AES_KEY='$AES_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017/admin?authSource=admin&replicaSet=rs0'
OPEN_TELEMETRY_COLLECTOR_URL='192.168.50.20:30345'
JSON_STORAGE_PATH=/opt/app/json/db.json
VAULT_PATH='/opt/app/vault'
LOG_PATH='/opt/app/log'
SERVICE_ENV=production
LOG_LEVEL=error
LOG_CAPACITY=53687091200
AUTO_ROTATE_KEY_INTERVAL=1 #hour
EOF
}
save_lock_env(){
    echo -e "${BLUE}Creating Env for Lock Service...${NC}"
    cat > $INSTALL_DIR/lock-service.env <<EOF
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=lock-service:3000
SERVICE_NAME=takakrypt-lock-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=lock-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
MASKING_SERVICE_HOST=masking-service:3000
DISPATCHER_ADDR=dispatcher:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=$DOMAIN/api/
SMTP_HOST='$SMTP_HOST'
SMTP_PASSWORD='$SMTP_PASSWORD'
SMTP_USERNAME='$SMTP_USERNAME'
SMTP_PORT=$SMTP_PORT
SMTP_SENDER='$SMTP_SENDER'
SMTP_SENDER_NAME="$SMTP_SENDER_NAME"
SMTP_TLS=true
AES_KEY='$AES_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017/admin?authSource=admin&replicaSet=rs0'
OPEN_TELEMETRY_COLLECTOR_URL='192.168.50.20:30345'
JSON_STORAGE_PATH=/opt/app/json/db.json
VAULT_PATH='/opt/app/vault'
LOG_PATH='/opt/app/log'
SERVICE_ENV=production
LOG_LEVEL=error
LOG_CAPACITY=53687091200
AUTO_ROTATE_KEY_INTERVAL=1 #hour
SYNC_ENABLED=true
INSTANCE_ID=A
SYNC_RETRY_MAX=3
SYNC_RETRY_DELAY=2s
SYNC_TIMEOUT=5s
HEALTH_CHECK_FREQ=30s
DB_PATH=master
APP_NAME=takakrypt-lock-service
APP_VERSION=1.0.0
HTTP_PORT=8080
GRPC_SYNC_PORT=9091
SEEDING_MASTER_DATA=false
KEY_EXPIRATION_CHECK_TIME=24
EOF
}
save_masking_env(){
    echo -e "${BLUE}Creating Env for Masking Service...${NC}"
    cat > $INSTALL_DIR/masking-service.env <<EOF
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=masking-service:3000
SERVICE_NAME=takakrypt-masking-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=lock-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
MASKING_SERVICE_HOST=masking-service:3000
DISPATCHER_ADDR=dispatcher:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=$DOMAIN/api/
SMTP_HOST='$SMTP_HOST'
SMTP_PASSWORD='$SMTP_PASSWORD'
SMTP_USERNAME='$SMTP_USERNAME'
SMTP_PORT=$SMTP_PORT
SMTP_SENDER='$SMTP_SENDER'
SMTP_SENDER_NAME="$SMTP_SENDER_NAME"
SMTP_TLS=true
AES_KEY='$AES_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017/admin?authSource=admin&replicaSet=rs0'
OPEN_TELEMETRY_COLLECTOR_URL=''
JSON_STORAGE_PATH=/opt/app/json/db.json
VAULT_PATH='/opt/app/vault'
LOG_PATH='/opt/app/log'
SERVICE_ENV=production
LOG_LEVEL=error
LOG_CAPACITY=53687091200
AUTO_ROTATE_KEY_INTERVAL=1 #hour
EOF
}
save_file_service_env() {
    echo -e "${BLUE}Creating file-service.env...${NC}"
    cat > $INSTALL_DIR/file-service.env <<EOF
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=file-service:3000
SERVICE_NAME=takakrypt-file-service
SERVICE_PORT=3000
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret
MICRO_CLIENT=grpc
BUCKET_DRIVER=s3
BUCKET_CONTAINER=
AUTH_SERVICE_HOST=auth-service:3000
MASTER_DATA_SERVICE_HOST=auth-service:3000
CRYPTO_SERVICE_HOST=crypto-service:3000
MASKING_SERVICE_HOST=masking-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=gw-$DOMAIN/
AES_KEY='$AES_KEY'
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017'
OPEN_TELEMETRY_COLLECTOR_URL=''
JSON_STORAGE_PATH='/opt/app/json/db.json'
VAULT_PATH='/opt/app/vault'
UPLOAD_PATH='/opt/app/uploads'
LOG_PATH='/var/log/takakrypt'
SERVICE_ENV=production
EOF
    echo -e "${GREEN}file-service.env created successfully${NC}"
}

save_backup_service_env() {
    echo -e "${BLUE}Creating backup-service.env...${NC}"
    cat > $INSTALL_DIR/backup-service.env <<EOF
# Konfigurasi untuk Backup Service (sesuaikan jika perlu)
CACHE_ADDRESS=
CACHE_DRIVER=
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=
BROKER_ADDRESS=nats
BROKER_DRIVER=nats
BROKER_USERNAME=$NATS_USER
BROKER_PASSWORD=$NATS_PASSWORD
BROKER_PORT=4222
DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=$PG_PASSWORD
DATABASE_PORT=5432
DATABASE_SSL_MODE=disable
DISCOVERY_ADDRESS=127.0.0.1
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500
SERVICE_ADDRESS=backup-service:3000
SERVICE_NAME=takakrypt-backup-service
SERVICE_PORT=3000
SERVICE_VERSION=1
MICRO_CLIENT=grpc
AUTH_SERVICE_HOST=auth-service:3000
FILE_SERVICE_HOST=file-service:3000
MASTER_DATA_SERVICE_HOST=auth-service:3000
CRYPTO_SERVICE_HOST=crypto-service:3000
MASKING_SERVICE_HOST=masking-service:3000
TOKENIZE_SERVICE_HOST=tokenize-service:3000
LOCK_SERVICE_HOST=lock-service:3000
GATEWAY_DOMAIN_URL=gw-$DOMAIN/
AES_KEY='$AES_KEY'
AES_KEY_API='$AES_KEY_API'
USER_KEY_EXPIRATION=24
# Path untuk menyimpan file backup di dalam kontainer
BACKUP_STORAGE_PATH='/opt/app/backups'
LOG_PATH='/var/log/takakrypt'
SERVICE_ENV=production
MONGO_CONNECTION='mongodb://root:$MONGO_PASSWORD@mongodb:27017'
OPEN_TELEMETRY_COLLECTOR_URL=''
JSON_STORAGE_PATH='/opt/app/json/db.json'
VAULT_PATH='/opt/app/vault'
UPLOAD_PATH='/opt/app/uploads'
LOG_LEVEL=error
LOG_CAPACITY=53687091200
CLEAR_BACKUP=true
EOF
    echo -e "${GREEN}backup-service.env created successfully${NC}"
}


save_general_service_env() {
    echo -e "${BLUE}Creating general-service.env...${NC}"
    cat > $INSTALL_DIR/general-service.env <<EOF
# Konfigurasi untuk General Service (sesuaikan jika perlu)
BROKER_ADDRESS=127.0.0.1
BROKER_DRIVER=nats
BROKER_USERNAME=nats
BROKER_PASSWORD=123321
BROKER_PORT=4222

CACHE_ADDRESS=127.0.0.1
CACHE_DRIVER=redis
CACHE_USERNAME=
CACHE_PASSWORD=
CACHE_PORT=6379

DATABASE_DRIVER=postgresql
DATABASE_NAME=postgres
DATABASE_ADDRESS=localhost
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=UqRw5iUg6T
DATABASE_PORT=50231
DATABASE_SSL_MODE=disable
MIGRATION_VERSION=1

DISCOVERY_ADDRESS=localhost
DISCOVERY_DRIVER=mdns
DISCOVERY_USERNAME=
DISCOVERY_PASSWORD=
DISCOVERY_PORT=8500

MONITORING_ADDRESS=
MONITORING_DRIVER=
MONITORING_USERNAME=
MONITORING_PASSWORD=
MONITORING_PORT=8080

SERVICE_ADDRESS=localhost
SERVICE_NAME=takakrypt-masking-service
SERVICE_PORT=8186
SERVICE_VERSION=1
SERVICE_JWT_SECRET=secret

SENTRY_ADDRESS=
SENTRY_USERNAME=
SENTRY_PORT=
SENTRY_PASSWORD=
SENTRY_ENV=development

MICRO_CLIENT=grpc

BUCKET_DRIVER=s3
BUCKET_CONTAINER=

MINIO_PORT=
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=
MINIO_REGION=
MINIO_ADDRESS=

S3_ADDRESS=
S3_ACCESS_KEY=
S3_SECRET_KEY=
S3_REGION=
S3_BUCKET=

SERVER_TYPE=graphql

LOCK_SERVICE_HOST=localhost:8185
TOKENIZE_SERVICE_HOST=localhost:8187
CRYPTO_SERVICE_HOST=localhost:8182
AUTH_SERVICE_HOST=localhost:8181
MASTER_DATA_SERVICE_HOST=localhost:8183
TRANSACTION_SERVICE_HOST=localhost:8184
MUSO_APP_DOMAIN_URL=http://localhost:8080/
# AES_KEY='FIqqTJAXb/FbwkXQL2WalL35L317aLQ='
GQL_QUERY_DISABLE_INTROSPECTION=false
OPEN_TELEMETRY_COLLECTOR_URL='192.168.50.20:30345'
MONGO_CONNECTION='mongodb://localhost:27017'

JAEGER_REPORTER_LOG_SPANS=true
JAEGER_SAMPLER_TYPE=const
JAEGER_SAMPLER_PARAM=1
JAEGER_SERVICE_NAME=xti-gateway-go
JAEGER_AGENT_HOST=localhost
JAEGER_AGENT_PORT=6831

APP_DOMAIN_URL=http://localhost:3000

AES_KEY='FIqqTJAXb/FbwkXQL2WalL35L317aLQ='
AES_KEY_API='7lw9cYvBy06SnVAk0nnBYnCTsRmRMOwO'
USER_KEY_EXPIRATION=24

CORS_ALLOW_ORIGINS=*

TWEAK_KEY_API=T9xQ2vLm

JSON_STORAGE_PATH=/opt/app/json/db.json
VAULT_PATH='./opt/app/vault'
LOG_PATH='./opt/app/log'

SERVICE_ENV=development
LOG_LEVEL=error
LOG_CAPACITY=53687091200

SYNC_ENABLED=true
INSTANCE_ID=B
DISPATCHER_ADDR=localhost:9080
SYNC_RETRY_MAX=3
SYNC_RETRY_DELAY=2s
SYNC_TIMEOUT=5s
HEALTH_CHECK_FREQ=30s
DB_PATH=master
APP_NAME=takakrypt-masking-service
APP_VERSION=1.0.0
HTTP_PORT=8080
GRPC_SYNC_PORT=9094
SEEDING_MASTER_DATA=false
KEY_EXPIRATION_CHECK_TIME=24

SMTP_HOST='smtp-mail.outlook.com'
SMTP_PASSWORD='H3lloWorld08!#'
SMTP_USERNAME='hi@takasecure.com'
SMTP_PORT=587
SMTP_SENDER='hi@takasecure.com'
SMTP_SENDER_NAME="[No-Reply] Taka Secure Indonesia"
SMTP_TLS=true

SEND_EMAIL=false
SCHEDULER_NOTIFIKASI=false

# IGNORE_LICENSE=true

RUN_MIGRATION=true
EOF
    echo -e "${GREEN}general-service.env created successfully${NC}"
}

# Function to create docker-compose file
create_docker_compose() {
    echo -e "${BLUE}Creating docker-compose.yml...${NC}"
    cat > $INSTALL_DIR/docker-compose.yml <<EOF

services:
  postgres:
    image: postgres:15-alpine
    container_name: postgres
    environment:
      POSTGRES_PASSWORD: "$PG_PASSWORD"
    volumes:
      - $INSTALL_DIR/data/postgresql:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - backend
    restart: unless-stopped

  mongodb:
    image: mongo:6
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: "root"
      MONGO_INITDB_ROOT_PASSWORD: "$MONGO_PASSWORD"
    volumes:
      - $INSTALL_DIR/data/mongo:/data/db
    networks:
      - backend
    restart: unless-stopped

  dispatcher:
    image: admintaka/dispatch-service:latest
    container_name: dispatcher
    volumes:
      - $INSTALL_DIR/dispatch.env:/.env
    networks:
      - backend
    restart: unless-stopped

  nats:
    image: nats:latest
    container_name: nats
    command: "-c /etc/nats/nats.conf --jetstream --user $NATS_USER --pass $NATS_PASSWORD"
    volumes:
      - $INSTALL_DIR/data/nats:/data
      - $INSTALL_DIR/nats.conf:/etc/nats/nats.conf
    networks:
      - backend
    restart: unless-stopped

  auth-service:
    image: admintaka/auth-service:latest
    container_name: auth-service
    depends_on:
      - postgres
      - nats
    env_file:
      - $INSTALL_DIR/auth-service.env
    volumes:
      - $INSTALL_DIR/data/auth:/opt/app
    networks:
      - backend
    restart: unless-stopped

  crypto-service:
    image: admintaka/crypto-service:latest
    container_name: crypto-service
    depends_on:
      - mongodb
      - nats
    env_file:
      - $INSTALL_DIR/crypto-service.env
    volumes:
      - $INSTALL_DIR/data/crypto:/opt/app
    networks:
      - backend
    restart: unless-stopped

  lock-service:
    image: admintaka/lock-service:latest
    container_name: lock-service
    depends_on:
      - mongodb
      - nats
      - postgres
      - auth-service
    env_file:
      - $INSTALL_DIR/lock-service.env
    volumes:
      - $INSTALL_DIR/data/lock:/opt/app
    networks:
      - backend
    restart: unless-stopped

  masking-service:
    image: admintaka/masking-service:latest
    container_name: masking-service
    depends_on:
      - mongodb
      - nats
      - postgres
      - auth-service
    env_file:
      - $INSTALL_DIR/masking-service.env
    volumes:
      - $INSTALL_DIR/data/masking:/opt/app
    networks:
      - backend
    restart: unless-stopped

  tokenize-service:
    image: admintaka/tokenize-service:latest
    container_name: tokenize-service
    depends_on:
      - mongodb
      - nats
      - auth-service
      - lock-service
    env_file:
      - $INSTALL_DIR/tokenize-service.env
    volumes:
      - $INSTALL_DIR/data/tokenize:/opt/app
    networks:
      - backend
    restart: unless-stopped

  file-service:
    image: admintaka/file-service:latest
    container_name: file-service
    depends_on:
      - postgres
      - mongodb
      - nats
      - auth-service
    env_file:
      - $INSTALL_DIR/file-service.env
    volumes:
      - $INSTALL_DIR/data/uploads:/opt/app/uploads
      - $INSTALL_DIR/data/file-service-logs:/var/log/takakrypt
    networks:
      - backend
    restart: unless-stopped

  backup-service:
    image: admintaka/backup-service:latest
    container_name: backup-service
    depends_on:
      - postgres
      - file-service
    env_file:
      - $INSTALL_DIR/backup-service.env
    volumes:
      - $INSTALL_DIR/data/backups:/opt/app/backups
      - $INSTALL_DIR/data/uploads:/opt/app/uploads
      - $INSTALL_DIR/data/backup-service-logs:/var/log/takakrypt
    networks:
      - backend
    restart: unless-stopped

  gateway-service:
    image: admintaka/gateway-service:latest
    container_name: gateway-service
    depends_on:
      - auth-service
      - crypto-service
      - file-service
      - backup-service
    env_file:
      - $INSTALL_DIR/gateway-service.env
    ports:
      - "8001:3000"
    networks:
      - backend
    restart: unless-stopped

  website:
    image: admintaka/website:$WEB_VERSION
    container_name: website
    depends_on:
      - gateway-service
    ports:
      - "8000:3000"
    networks:
      - backend
    restart: unless-stopped
  
  general-service:
    image: admintaka/general-service:latest
    container_name: general-service
    ports:
      - "8188:8188"
    restart: unless-stopped
    healthcheck:
      test:
        [
          "CMD",
          "wget",
          "--no-verbose",
          "--tries=1",
          "--spider",
          "http://localhost:8188/health",
        ]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    env_file:
      - $INSTALL_DIR/general-service.env
    volumes:
      # Mount host /proc for Linux host monitoring
      # Note: On macOS, this mounts the Docker VM's /proc, not macOS host
      # For macOS, use the macos-host-monitor.sh script to push host stats
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
    networks:
      - backend

networks:
  backend:
    driver: bridge
EOF
    echo -e "${GREEN}docker-compose.yml created successfully${NC}"
}
# Function to start services
start_services() {
    echo -e "${BLUE}Starting services...${NC}"

    cd $INSTALL_DIR
    docker compose up -d

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to start services${NC}" >&2
        exit 1
    fi

    echo -e "${GREEN}Services started successfully${NC}"
}

# Function to install application
install_app() {
    echo -e "${YELLOW}Starting installation...${NC}"

    # Update system
    apt-get update
    apt-get upgrade -y

    # Install required packages
    apt-get install -y curl gnupg lsb-release ca-certificates

    # Install Docker and Docker Compose
    install_docker

    # Get credentials
    get_credentials

    # Save configuration files
    save_auth_service_env
    save_crypto_service_env
    save_gateway_service_env
    save_website_service_env
    save_nats_cluster_config
    save_dispatch_env
    save_lock_env
    save_masking_env
    save_tokenize_env
    save_file_service_env    # <-- Ditambahkan
    save_backup_service_env  # <-- Ditambahkan
    save_general_service_env # <-- baru Ditambahkan


    # Create docker-compose file
    create_docker_compose

    # Start services
    start_services

    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${YELLOW}Access your website at: http://<server-ip>:8000${NC}"
}

# Function to uninstall application
uninstall_app() {
    echo -e "${YELLOW}Starting uninstallation...${NC}"

    # Stop and remove containers
    if [ -d "$INSTALL_DIR" ]; then
        cd $INSTALL_DIR
        docker compose down
    fi

    # Remove configuration files
    rm -f $INSTALL_DIR/docker-compose.yml
    rm -f $INSTALL_DIR/auth-service.env
    rm -f $INSTALL_DIR/crypto-service.env
    rm -f $INSTALL_DIR/gateway-service.env
    rm -f $INSTALL_DIR/website-service.env
    rm -f $INSTALL_DIR/nats.conf
    rm -f $INSTALL_DIR/file-service.env    # <-- Ditambahkan
    rm -f $INSTALL_DIR/backup-service.env  # <-- Ditambahkan
    rm -f $INSTALL_DIR/general-service.env # <-- baru Ditambahkan

    # Remove SSL certificates
    rm -rf $INSTALL_DIR/ssl

    # Remove Docker
    apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    rm -f /usr/local/bin/docker-compose

    # Remove data volumes
    docker volume prune -f


    # Remove installation directory
    rm -rf $INSTALL_DIR

    # Remove Docker files
    rm -rf /var/lib/docker
    rm -rf /etc/docker

    echo -e "${GREEN}Uninstallation completed successfully!${NC}"
}

# Function to upgrade application
upgrade_app() {
    echo -e "${YELLOW}Starting upgrade...${NC}"

    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "${RED}Error: Application is not installed${NC}" >&2
        exit 1
    fi

    # Pull new images
    cd $INSTALL_DIR
    docker compose pull

    # Restart services
    docker compose up -d --force-recreate

    echo -e "${GREEN}Upgrade completed successfully!${NC}"
}

# Main script
case "$1" in
    install)
        install_app
        ;;
    uninstall)
        uninstall_app
        ;;
    upgrade)
        upgrade_app
        ;;
    *)
        usage
        ;;
esac

exit 0

