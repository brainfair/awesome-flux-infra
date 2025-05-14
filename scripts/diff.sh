#!/bin/bash

# Set base clusters directory
CLUSTERS_DIR="./clusters"

current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Check if clusters directory exists
if [ ! -d "$CLUSTERS_DIR" ]; then
  echo "Directory $CLUSTERS_DIR does not exist."
  exit 1
fi

# Loop through each subdirectory inside clusters
for cluster_path in "$CLUSTERS_DIR"/*/; do
  # Remove trailing slash and get the cluster name
  cluster_name=$(basename "$cluster_path")

  echo "Processing cluster: $cluster_name new"

  # Navigate into the cluster directory
  cd "$cluster_path" || continue

  # Build and output to /tmp
  kustomize build . --load-restrictor LoadRestrictionsNone > "/tmp/${cluster_name}-new.yaml"

  # Return to original directory
  cd - > /dev/null
done

git checkout -f main &> /dev/null

for cluster_path in "$CLUSTERS_DIR"/*/; do
  # Remove trailing slash and get the cluster name
  cluster_name=$(basename "$cluster_path")

  echo "Processing cluster: $cluster_name main"

  # Navigate into the cluster directory
  cd "$cluster_path" || continue

  # Build and output to /tmp
  kustomize build . --load-restrictor LoadRestrictionsNone > "/tmp/${cluster_name}-main.yaml"

  # Return to original directory
  cd - > /dev/null
done

git checkout -f "$current_branch" &> /dev/null

diff -u -U20  --suppress-common-lines /tmp/${cluster_name}-new.yaml /tmp/${cluster_name}-main.yaml
# rm -f /tmp/*-new.yaml
# rm -f /tmp/*-main.yaml
