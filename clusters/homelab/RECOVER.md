# Recovery or Initialization Guide for Homelab Cluster

### Steps:

0. **Disable Custom Resources in Kustomize**
   This helps prevent dependency conflicts during initialization.

1. **Regenerate GitHub Token for Access**
   Generate a new GitHub token for accessing repositories.

2. **Bootstrap FluxCD**
   Use the [FluxCD bootstrap example](https://github.com/brainfair/awesome-flux-head?tab=readme-ov-file#bootstrap-fluxcd-example) to set up FluxCD. Follow the instructions carefully to ensure proper bootstrapping.

3. **Regenerate GitHub Token for Promotion Workflow**
   Create a Kubernetes secret with the new token:
   ```bash
   kubectl -n flux-system create secret generic github-token \
     --from-literal=token=${GITHUB_TOKEN}
   ```

4. **Generate or Reuse a Wildcard TLS Certificate**
   If needed, generate a wildcard TLS certificate using [this guide](https://gist.github.com/brainfair/d43c52c635f8a84a176b9a047fec1349). Alternatively, reuse previous certificate files. Then, create the secret:
   ```bash
   kubectl -n istio-ingress create secret tls localhost-direct \
     --key=domain.key --cert=domain.crt
   ```

5. **Re-enable Custom Resources**
   After resolving dependencies and ensuring proper setup, re-enable custom resources in Kustomize.
