#!/bin/bash

# Function to trim whitespace
trim() {
    echo "$1" | xargs
}

# Prompt for the context name (cluster ID)
read -p "Enter the context name (cluster ID): " context_name_input

# Trim leading and trailing whitespace from the input
context_name=$(trim "${context_name_input}")

echo "Updating kubeconfig for context '${context_name}'..."

# Get current user under the context
current_user=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '${context_name}')].context.user}")

if [ -z "${current_user}" ]; then
  echo "Failed to retrieve current user for context '${context_name}'. Aborting."
  exit 1
fi

# Update aws-iam-authenticator command for the context
kubectl config set-credentials "${current_user}" \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=aws-iam-authenticator \
  --exec-arg="token" \
  --exec-arg="-i" \
  --exec-arg="${context_name}"

# Set the context in kubeconfig
kubectl config use-context "${context_name}"

echo "Kubeconfig updated. Current context is '${context_name}'."