# Deployment (high level)

> Keep this page conceptual. Do not add hostnames, IP ranges, account IDs or network details to this public repository.

```mermaid
flowchart LR
    dev[Developer] -->|pull request| gh[GitHub]
    gh -->|GitHub Actions: build, test, scan| reg[(Container registry)]
    reg --> env1[Dev]
    env1 --> env2[Staging]
    env2 -->|manual approval| env3[Production]
```

## To decide
- Runtime platform (e.g. Kubernetes, managed containers)
- Environments and promotion rules
- Secrets management
