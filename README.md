### Nixenv: containerized and nixified dev environment.

Build:

```bash
podman build -t nixenv https://github.com/infraflakes/devenv.git
```

Start with:

```bash
podman run -it --network=host docker.io/infraflakes/nixenv:latest
```
