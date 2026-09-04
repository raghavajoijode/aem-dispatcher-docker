
# AEM Dispatcher Docker (Modernized - September 2026)

## Quick Start

### For Mac with Apple Silicon (M1/M2/M3/M4)

```bash
# 1. Create and use buildx builder (first time only)
docker buildx create --use

# 2. Build for ARM64 (Apple Silicon)
docker buildx build --load -t dispatcher --platform=linux/arm64 .

# 3. Verify the image was created
docker images | grep dispatcher

# 4. Run the container
docker run -p 80:8080 -p 443:8443 -itd --rm \
  --mount type=bind,src=$(pwd)/logs,dst=/var/log/httpd \
  --env-file scripts/env.sh \
  --name dispatcher \
  dispatcher

# 5. Verify container is running
docker container ps

# 6. Access container shell
docker exec -it dispatcher /bin/bash
```

### For Intel/AMD Systems

```bash
# Build for x86_64
docker buildx build --load -t dispatcher --platform=linux/amd64 .
```

## What's New (September 2026 Update)

This project has been modernized with:

- **Base Image**: Upgraded from CentOS 7 (EOL) to AlmaLinux 9 (supported until 2032)
- **ARM64 Support**: Full compatibility with Apple Silicon Macs (M1/M2/M3/M4)
- **Security**: Modern SSL/TLS configuration (Mozilla v5.7), security headers, HSTS
- **Dispatcher**: Updated configuration with detailed comments
- **Documentation**: Clear, executable commands with explanations
- **Performance**: Optimized HAProxy and Apache settings


## About This Project

This is an Adobe Managed Services (AMS) compatible dispatcher Docker image, forked from Adobe's original implementation and modernized for 2026.

### Key Features

- **AMS Compatibility**: Uses standard AMS 2.6 dispatcher configuration patterns
- **Modern Base**: AlmaLinux 9 (RHEL-compatible, supported until 2032)
- **Multi-Architecture**: Supports both x86_64 and ARM64 (Apple Silicon)
- **SSL/TLS**: Modern cipher suites with HAProxy SSL termination
- **Security**: Hardened configuration with security headers
- **Local Development**: Optimized for Mac, Windows, and Linux development

### Architecture

```
[Client Browser] 
    → [HAProxy (SSL Termination on 8443)] 
        → [Apache HTTPD with Dispatcher Module]
            → [AEM Author (4502) / AEM Publish (4503)]
```

### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `Dockerfile` | Container definition with detailed comments | Root directory |
| `scripts/env.sh` | Environment variables and connection settings | `scripts/` |
| `haproxy/haproxy.cfg` | SSL termination and load balancing | `haproxy/` |
| `ams/2.6/etc/httpd/` | Default AMS dispatcher configuration | `ams/2.6/etc/httpd/` |
| `ams/2.6/project/src/` | Project-specific configuration (optional) | `ams/2.6/project/src/` |

## Getting Started

## Building the Docker Image

### Prerequisites

- Docker Desktop 4.12+ (with Buildx support)
- For Mac users: Docker Desktop for Apple Silicon
- 2GB+ free disk space
- Network access to download dispatcher module

### Build Commands

#### For Apple Silicon Mac (M1/M2/M3/M4)
```bash
# Create buildx builder (first time only)
docker buildx create --use --name multiarch-builder

# Build for ARM64
docker buildx build --load -t dispatcher --platform=linux/arm64 .

# Alternative: Build and push to registry
# docker buildx build --push -t yourregistry/dispatcher:latest --platform=linux/arm64,linux/amd64 .
```

#### For Intel/AMD Systems
```bash
# Build for x86_64
docker buildx build --load -t dispatcher --platform=linux/amd64 .
```

#### Multi-Platform Build (Advanced)
```bash
# Build for both architectures (requires registry push)
docker buildx build --push -t yourregistry/dispatcher:latest \
  --platform=linux/arm64,linux/amd64 .
```

### Build Options Explained

| Option | Purpose | Example Value |
|--------|---------|---------------|
| `--platform` | Target CPU architecture | `linux/arm64` (Apple Silicon), `linux/amd64` (Intel) |
| `--load` | Load image into local Docker | Always use for local development |
| `--push` | Push to registry | Use for CI/CD or sharing |
| `-t` | Image tag name | `dispatcher:latest`, `myproject/dispatcher:v1.0` |

### Verifying the Build

```bash
# Check built images
docker images | grep dispatcher

# Expected output:
# dispatcher   latest    abc123def456   2 minutes ago   850MB

# Inspect image architecture
docker inspect dispatcher:latest | grep Architecture

# Expected for Apple Silicon:
# "Architecture": "arm64"
```

## Checking the created image

```shell
$ docker images
REPOSITORY   TAG      IMAGE ID       CREATED        SIZE
dispatcher   latest   6b4b91a23c06   1 minute ago   725MB
```

## Running the Container

### Basic Usage (Default Configuration)

```bash
# Create logs directory (if it doesn't exist)
mkdir -p logs

# Run with default AMS configuration
docker run -p 80:8080 -p 443:8443 -itd --rm \
  --mount type=bind,src=$(pwd)/logs,dst=/var/log/httpd \
  --env-file scripts/env.sh \
  --name dispatcher \
  dispatcher
```

### Docker Run Options Explained

| Option | Purpose | Recommended Value |
|--------|---------|-------------------|
| `-p 80:8080` | Map host port 80 → container port 8080 (HTTP) | Use `-p 8080:8080` if port 80 is busy |
| `-p 443:8443` | Map host port 443 → container port 8443 (HTTPS) | Use `-p 8443:8443` for testing |
| `-itd` | Interactive, TTY, Detached mode | Always use for background services |
| `--rm` | Auto-remove container on exit | Recommended for development |
| `--env-file` | Environment variables file | `scripts/env.sh` |
| `--name` | Container name | `dispatcher` or project-specific |
| `--mount` | Bind mount for logs | `type=bind,src=$(pwd)/logs,dst=/var/log/httpd` |

### Port Mapping Scenarios

```bash
# Scenario 1: Standard ports (requires sudo on Linux)
docker run -p 80:8080 -p 443:8443 ... dispatcher

# Scenario 2: Alternative ports (no privileges needed)
docker run -p 8080:8080 -p 8443:8443 ... dispatcher

# Scenario 3: Custom port mapping
docker run -p 30080:8080 -p 30443:8443 ... dispatcher
```

### Verifying Container Status

```bash
# Check running containers
docker container ps

# Check container logs
docker logs dispatcher

# Check container health
docker inspect dispatcher | grep -A 5 -B 5 Health

# Access container shell
docker exec -it dispatcher /bin/bash

# Stop the container
docker stop dispatcher

# Remove stopped containers
docker container prune
```

## Configuration Methods

You can use this container in three different ways:

### 1. Default Configuration (Quick Start)
- Uses built-in AMS 2.6 configuration
- No local file dependencies
- Rebuild required for configuration changes
- **Best for**: Initial testing, demos, learning

### 2. Mounted Configuration (Recommended for Development)
- Mount local configuration files
- Instant configuration updates (no rebuild)
- Use provided helper scripts
- **Best for**: Active development, testing changes

### 3. Custom Docker Image (Production)
- Create derivative Dockerfile
- Bundle project-specific configuration
- Push to container registry
- **Best for**: Production deployments, team sharing

## Checking the container's current state

```shell
$ docker container ps
CONTAINER ID   IMAGE        COMMAND                  CREATED              STATUS              PORTS                                                          NAMES
8c345d523ff2   dispatcher   "/bin/bash /launch.sh"   About a minute ago   Up About a minute   80/tcp, 443/tcp, 0.0.0.0:80->8080/tcp, 0.0.0.0:443->8443/tcp   dispatcher
```

## Testing your AEM installation

The dispatcher maps `publish.docker.local` to the local publisher instance on port 4503. 
Run the publisher and navigate to [http://publish.docker.local/content/we-retail/language-masters/en.html](http://publish.docker.local/content/we-retail/language-masters/en.html)

## Environment Configuration

### Host Configuration

For local development, add these entries to your `/etc/hosts` file:

```bash
# macOS/Linux: Edit /etc/hosts (requires sudo)
sudo nano /etc/hosts

# Add these lines:
127.0.0.1       author.docker.local
127.0.0.1       publish.docker.local
127.0.0.1       host.docker.internal

# Windows: Edit C:\Windows\System32\drivers\etc\hosts
# Add the same three lines
```

### Environment Variables (`scripts/env.sh`)

The `scripts/env.sh` file contains all environment-specific settings:

```bash
# Review and customize these settings:
DISP_ID=docker                          # Unique dispatcher identifier
AUTHOR_IP=host.docker.internal          # AEM Author instance
AUTHOR_PORT=4502                        # Author port
PUBLISH_IP=host.docker.internal         # AEM Publish instance  
PUBLISH_PORT=4503                       # Publish port
CRX_FILTER=deny                         # Security: deny CRXDE access
DISPATCHER_FLUSH_FROM_ANYWHERE=allow    # Local dev: allow flush from any IP
DISP_LOG_LEVEL=4                        # Debug logging (4=trace, 1=error)
```

### AEM Instance Configuration

| Environment | AEM Author | AEM Publish | Notes |
|-------------|------------|-------------|-------|
| Local Dev | `localhost:4502` | `localhost:4503` | Default setup |
| Docker Network | `host.docker.internal:4502` | `host.docker.internal:4503` | Cross-container |
| Remote | `author.example.com:4502` | `publish.example.com:4503` | Production |

### Testing Your Setup

```bash
# Test AEM Author connection
curl -I http://author.docker.local:4502

# Test AEM Publish connection  
curl -I http://publish.docker.local:4503

# Test through dispatcher (HTTP)
curl -I http://publish.docker.local/content/we-retail/language-masters/en.html

# Test through dispatcher (HTTPS)
curl -k -I https://publish.docker.local/content/we-retail/language-masters/en.html
```

# Using your own dispatcher config

There are several options to use this container with your own configuration:

1. Remote web server ([dispatcher-remote](dispatcher-remote))
   - Copy the configuration you are working on into the container with `docker cp`
   - Log into the container and restart apache
   - A disadvantage with `docker cp` is that it only copies and does not sync the directory contents and will require manual intervention if files were deleted locally.
2. Mount a local directory ([dispatcher-mount](dispatcher-mount))
   - A local dispatcher project module is mounted read-only into the container at startup.
   - After each change, restart the current container or SIGHUP the httpd process.
3. Create a separate docker image
   - This is useful if you have a separate team working on multiple dispatcher configurations and you have access to a container repository to distribute pre-built images

## Remote web server

### Start dispatcher in container

```shell
docker run -p 80:8080 -p 443:8443 -itd --rm --name dispatcher --env-file scripts/env.sh dispatcher
```

### Copy files to docker container

```shell
cd _your_project_/dispatcher/etc/httpd
docker cp . dispatcher:/etc/httpd/
```

### Connecting to the Dispatcher terminal

You can run shell commands inside the dispatcher container.

```shell
docker exec -it dispatcher /bin/bash
```

### Reloading the Dispatcher

You can reload the dispatcher with following command:

```shell
kill -HUP `cat /run/httpd/httpd.pid`
```

### Inspecting the logs

While connected to dispatcher, you can view the logs in `/var/log/httpd`

```shell
$ ll /var/log/httpd/
total 36
-rw-r--r-- 1 root root 14779 May 20 10:04 access_log
-rw-r--r-- 1 root root 15295 May 20 10:04 dispatcher.log
-rw-r--r-- 1 root root   739 May 20 10:03 error_log
-rw-r--r-- 1 root root     0 May 20 10:03 healthcheck_access_log
```

## Mount a local directory

### Start Dispatcher with local folders mapped  

We are assuming you have your Dispatcher configuration stored in a folder "dispatcher" in your project:

```shell
cd _your_project_/dispatcher
mkdir logs

docker run -p 80:8080 -p 443:8443 -itd --rm --name dispatcher --env-file scripts/env.sh \
  --mount type=bind,src=$(pwd)/src/conf,dst=/etc/httpd/conf,readonly=true \
  --mount type=bind,src=$(pwd)/src/conf.d,dst=/etc/httpd/conf.d,readonly=true \
  --mount type=bind,src=$(pwd)/src/conf.dispatcher.d,dst=/etc/httpd/conf.dispatcher.d,readonly=true \
  --mount type=bind,src=$(pwd)/src/conf.modules.d,dst=/etc/httpd/conf.modules.d,readonly=true \
  --mount type=bind,src=$(pwd)/logs,dst=/var/log/httpd \
  --mount type=tmpfs,dst=/tmp \
  dispatcher
```

| Quick Reference |                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| --mount type=bind,src=$(pwd)/src/conf,dst=/etc/httpd/conf,readonly=true | Binds the folder `src/conf` in the host's current working directory to /etc/httpd/conf in a read-only fashion |
| --mount type=tmpfs,dst=/tmp                                  | Uses a memory based filesystem for temporary data to (slighly) improve the performance |

This is a lot to type. We had to mount each folder individually, as the Dispatcher Docker image also contains the `/modules`  folder in `/etc` and mounting `/etc`would make them unavailable.

Alternatively, you can use the convenience script

```shell
./dispatcher-mount
```

in this distribution. The script assumes that the "src/conf" folder is in the current directory and terminates with an error if it can't find it.

## Restarting the container

You can restart the container by calling

```shell
docker restart -t0 dispatcher
```

| Quick Reference |                                                              |
| --------------- | ------------------------------------------------------------ |
| -t0             | Kills the container after 0 seconds and does not wait for the Apache to shut down. This is safe, as the container does not preserve any crucial data. |

Or - if you are lazy - just call the shell-scripts:

```shell
./dispatcher-kill 
./dispatcher-mount
```

# Create your own image

You can also use this image as a base image, and add your configuration on top of it with similar Dockerfile

```Dockerfile
FROM dispatcher

COPY yourproject/dispatcher/src/conf /etc/httpd
COPY yourproject/dispatcher/src/conf.d /etc/httpd
COPY yourproject/dispatcher/src/conf.dispatcher.d /etc/httpd
COPY yourproject/dispatcher/src/conf.modules.d /etc/httpd
COPY yourproject/dispatcher/cert.pem /etc/ssl/docker/haproxy.pem 

# Start container
ENTRYPOINT ["/bin/bash","/launch.sh"]
```

# Immutable files

Certain files on AMS hosted dispatchers are immutable, and cannot be changed. This is achieved on filesystem level by using extended attributes. Docker does not support such functionality which means that any changes to the dispatcher configuration will be reflected in your docker image, but may not be applied on an AMS environment after deployment.

Those files are:

```text
/etc/httpd/conf/httpd.conf
/etc/httpd/conf.d/available_vhosts/aem_author.vhost
/etc/httpd/conf.d/available_vhosts/aem_publish.vhost
/etc/httpd/conf.d/available_vhosts/aem_flush.vhost
/etc/httpd/conf.d/available_vhosts/aem_health.vhost
/etc/httpd/conf.d/available_vhosts/000_unhealthy_author.vhost
/etc/httpd/conf.d/available_vhosts/000_unhealthy_publish.vhost
/etc/httpd/conf.d/available_vhosts/aem_flush_author.vhost
/etc/httpd/conf.d/available_vhosts/ams_lc.vhost
/etc/httpd/conf.d/rewrites/base_rewrite.rules
/etc/httpd/conf.d/rewrites/xforwarded_forcessl_rewrite.rules
/etc/httpd/conf.d/whitelists/000_base_whitelist.rules
/etc/httpd/conf.d/variables/ootb.vars
/etc/httpd/conf.d/dispatcher_vhost.conf
/etc/httpd/conf.d/logformat.conf
/etc/httpd/conf.d/security.conf
/etc/httpd/conf.d/mimetypes3d.conf
/etc/httpd/conf.d/remoteip.conf
/etc/httpd/conf.d/000_init_ootb_vars.conf
/etc/httpd/conf.d/001_init_ams_vars.conf
/etc/httpd/conf.modules.d/02-dispatcher.conf
/etc/httpd/conf.dispatcher.d/available_farms/000_ams_catchall_farm.any
/etc/httpd/conf.dispatcher.d/available_farms/001_ams_author_flush_farm.any
/etc/httpd/conf.dispatcher.d/available_farms/001_ams_publish_flush_farm.any
/etc/httpd/conf.dispatcher.d/available_farms/002_ams_author_farm.any
/etc/httpd/conf.dispatcher.d/available_farms/002_ams_lc_farm.any
/etc/httpd/conf.dispatcher.d/available_farms/002_ams_publish_farm.any
/etc/httpd/conf.dispatcher.d/cache/ams_author_cache.any
/etc/httpd/conf.dispatcher.d/cache/ams_author_invalidate_allowed.any
/etc/httpd/conf.dispatcher.d/cache/ams_publish_cache.any
/etc/httpd/conf.dispatcher.d/cache/ams_publish_invalidate_allowed.any
/etc/httpd/conf.dispatcher.d/clientheaders/ams_author_clientheaders.any
/etc/httpd/conf.dispatcher.d/clientheaders/ams_publish_clientheaders.any
/etc/httpd/conf.dispatcher.d/clientheaders/ams_common_clientheaders.any
/etc/httpd/conf.dispatcher.d/clientheaders/ams_lc_clientheaders.any
/etc/httpd/conf.dispatcher.d/filters/ams_author_filters.any
/etc/httpd/conf.dispatcher.d/filters/ams_publish_filters.any
/etc/httpd/conf.dispatcher.d/filters/ams_lc_filters.any
/etc/httpd/conf.dispatcher.d/renders/ams_author_renders.any
/etc/httpd/conf.dispatcher.d/renders/ams_lc_renders.any
/etc/httpd/conf.dispatcher.d/renders/ams_publish_renders.any
/etc/httpd/conf.dispatcher.d/vhosts/ams_author_vhosts.any
/etc/httpd/conf.dispatcher.d/vhosts/ams_publish_vhosts.any
/etc/httpd/conf.dispatcher.d/vhosts/ams_lc_vhosts.any
/etc/httpd/conf.dispatcher.d/dispatcher.any
```

# Troubleshooting

## Inspecting log files

By default, the `DISP_LOG_LEVEL` is set to "4" (trace) in the file `ams_default.vars` (This setting is used in `dispatcher_vhost.conf`).

Log into the remote dispatcher and view the log files call

```shell
./dispatcher-login
```

and navigate into `/var/log/httpd/`

```shell
cd /var/log/httpd/
```

> **TIP** If you mounted the logs directory, you can just inspect the logs files directly on your machine.
