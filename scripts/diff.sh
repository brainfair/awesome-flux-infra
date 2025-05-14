#!/bin/bash

# Set base clusters directory
CLUSTERS_DIR="./clusters"

current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Check if clusters directory exists
if [ ! -d "$CLUSTERS_DIR" ]; then
  echo "Directory $CLUSTERS_DIR does not exist."
  exit 1
fi

if [ -n "$GITHUB_SHA" ] && [ -n "$GITHUB_REF" ] && [[ "$GITHUB_REF" == "refs/pull/"* ]]; then
  PR_NUMBER=$(echo "$GITHUB_REF" | sed 's/refs\/pull\/\([0-9]*\)\/merge/\1/')
  echo "Running in a GitHub PR Action. PR Number: $PR_NUMBER"
  IS_GITHUB_PR=true
else
  echo "Not running in a GitHub PR Action."
  IS_GITHUB_PR=false
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

for cluster_path in "$CLUSTERS_DIR"/*/; do
  cluster_name=$(basename "$cluster_path")

  diff -u --suppress-common-lines /tmp/${cluster_name}-new.yaml /tmp/${cluster_name}-main.yaml > /dev/null
  if ! [ $? -eq 0 ]; then
    echo "diff found in ${cluster_name}"
    if [ "$IS_GITHUB_PR" = true ]; then
      DIFF=$(diff -u --suppress-common-lines /tmp/${cluster_name}-new.yaml /tmp/${cluster_name}-main.yaml)
      curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
          -d "{\"body\": \"### Diff between cluster '${cluster_name}' '$current_branch' and main:\n\n\`\`\`diff\n$DIFF\n\`\`\`\"}" \
          "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments"
    fi
  fi

done

# rm -f /tmp/*-new.yaml
# rm -f /tmp/*-main.yaml
