#!/bin/bash
set -eo pipefail

# Configuration
LOG_DIR="/var/log/terraform"
MAX_LOG_DAYS=30  # Auto-delete logs older than 30 days
LOG_LEVELS=("TRACE" "DEBUG" "INFO" "WARN" "ERROR")

# Create timestamp-based log directory
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CURRENT_LOG_DIR="${LOG_DIR}/${TIMESTAMP}"
mkdir -p "${CURRENT_LOG_DIR}"

# Configure Terraform logging
export TF_LOG="TRACE"  # Capture all levels
export TF_LOG_PATH="${CURRENT_LOG_DIR}/combined.log"

# Run Terraform command (modify as needed)
echo "Starting Terraform execution..."
terraform apply -auto-approve 2>&1 | tee "${CURRENT_LOG_DIR}/console_output.log"

# Split logs by severity level
for level in "${LOG_LEVELS[@]}"; do
  echo "Processing ${level} logs..."
  grep -E "\[${level}\]" "${TF_LOG_PATH}" > "${CURRENT_LOG_DIR}/${level}.log"
  
  # Create compressed version for production
  gzip "${CURRENT_LOG_DIR}/${level}.log"
done

# Create index file with metadata
echo "Creating metadata index..."
{
  echo "Timestamp: ${TIMESTAMP}"
  echo "Terraform Version: $(terraform version | head -n1)"
  echo "Command: $0 $*"
  echo "Exit Code: $?"
} > "${CURRENT_LOG_DIR}/metadata.txt"

# Log rotation and cleanup
echo "Applying log rotation policy..."
find "${LOG_DIR}" -type d -mtime +${MAX_LOG_DAYS} -exec rm -rf {} \;

echo "Logs stored in: ${CURRENT_LOG_DIR}"
```
