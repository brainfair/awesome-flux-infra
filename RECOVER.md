1. Regenerate github token for access
2. bootstrap https://github.com/brainfair/awesome-flux-head?tab=readme-ov-file#bootstrap-fluxcd-example
3. Regenerate github token for promotion and create secret
```
kubectl -n flux-system create secret generic github-token \
--from-literal=token=${GITHUB_TOKEN}
```
4.
