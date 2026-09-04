#
# Copyright (c) 2023 Adobe Systems Incorporated. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Updated: September 2026 - Modernized for ARM64 Mac (M2/M4) and AlmaLinux 9
#

# Use AlmaLinux 9 as base image (CentOS 7 replacement with ARM64 support)
# AlmaLinux is a 1:1 binary compatible RHEL replacement, maintained until 2032
FROM --platform=$TARGETPLATFORM almalinux:9

# Set environment variables for better caching and security
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    HTTPD_PREFIX=/etc/httpd \
    HTTPD_CONF_DIR=/etc/httpd/conf \
    HTTPD_CONF_D_DIR=/etc/httpd/conf.d \
    HTTPD_CONF_DISPATCHER_DIR=/etc/httpd/conf.dispatcher.d \
    HTTPD_MODULES_DIR=/etc/httpd/modules

# Install required packages with detailed comments
# - httpd: Apache web server (version 2.4)
# - mod_ssl: SSL/TLS support for Apache
# - procps: Process monitoring tools
# - haproxy: Load balancer for SSL termination
# - iputils: Network diagnostic tools (ping, etc.)
# - tree: Directory listing utility
# - telnet: Network testing tool
# - dos2unix: Line ending conversion (Windows to Unix)
# - curl: HTTP client for downloading dispatcher
# - ca-certificates: SSL certificates for secure downloads
RUN dnf -y update && \
    dnf -y install --allowerasing httpd mod_ssl procps haproxy iputils tree telnet dos2unix curl ca-certificates && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Remove default AlmaLinux Apache configuration files
# These will be replaced with Adobe AMS dispatcher configuration
RUN rm -rf /etc/httpd/conf/* && \
    rm -rf /etc/httpd/conf.d/* && \
    rm -rf /etc/httpd/conf.modules.d/*

# -----------------------------------------------------------------------------
# Copy Adobe AMS Dispatcher Configuration
# -----------------------------------------------------------------------------
# By default, copy the standard AMS 2.6 configuration
# This includes Apache configuration, virtual hosts, dispatcher farms, etc.
COPY ams/2.6/etc/httpd /etc/httpd

### PROJECT-SPECIFIC CONFIGURATION START ###
# If you have project-specific dispatcher configuration, uncomment the line below
# This will overwrite the default AMS configuration with your custom configuration
# Ensure your project configuration is located at: ams/2.6/project/src/
#
# To use project configuration:
# 1. Create your dispatcher configuration in ams/2.6/project/src/
# 2. Uncomment the line below
# 3. Rebuild the Docker image
#
# COPY ams/2.6/project/src /etc/httpd
### PROJECT-SPECIFIC CONFIGURATION END ###

# Set up enabled virtual hosts using symbolic links
# This follows AMS pattern where available_vhosts contains all vhosts
# and enabled_vhosts contains symlinks to active vhosts
RUN rm -rf /etc/httpd/conf.d/enabled_vhosts && \
    mkdir -p /etc/httpd/conf.d/enabled_vhosts && \
    ln -sf /etc/httpd/conf.d/available_vhosts/aem_author.vhost /etc/httpd/conf.d/enabled_vhosts/aem_author.vhost && \
    ln -sf /etc/httpd/conf.d/available_vhosts/aem_flush_author.vhost /etc/httpd/conf.d/enabled_vhosts/aem_flush_author.vhost && \
    ln -sf /etc/httpd/conf.d/available_vhosts/aem_publish.vhost /etc/httpd/conf.d/enabled_vhosts/aem_publish.vhost && \
    ln -sf /etc/httpd/conf.d/available_vhosts/aem_flush.vhost /etc/httpd/conf.d/enabled_vhosts/aem_flush.vhost && \
    ln -sf /etc/httpd/conf.d/available_vhosts/aem_health.vhost /etc/httpd/conf.d/enabled_vhosts/aem_health.vhost

### PROJECT START ####
# Uncomment for additional virtual hosts (e.g., LiveCycle or project-specific)
# RUN ln -sf /etc/httpd/conf.d/available_vhosts/aem_lc.vhost /etc/httpd/conf.d/enabled_vhosts/aem_lc.vhost
# RUN ln -sf /etc/httpd/conf.d/available_vhosts/project.vhost /etc/httpd/conf.d/enabled_vhosts/project.vhost
### PROJECT END ####

# Set up enabled dispatcher farms using symbolic links
# Similar pattern to virtual hosts: available_farms contains all farms
# enabled_farms contains symlinks to active farms
RUN rm -rf /etc/httpd/conf.dispatcher.d/enabled_farms && \
    mkdir -p /etc/httpd/conf.dispatcher.d/enabled_farms && \
    ln -sf /etc/httpd/conf.dispatcher.d/available_farms/000_ams_catchall_farm.any /etc/httpd/conf.dispatcher.d/enabled_farms/000_ams_catchall_farm.any && \
    ln -sf /etc/httpd/conf.dispatcher.d/available_farms/001_ams_author_flush_farm.any /etc/httpd/conf.dispatcher.d/enabled_farms/001_ams_author_flush_farm.any && \
    ln -sf /etc/httpd/conf.dispatcher.d/available_farms/001_ams_publish_flush_farm.any /etc/httpd/conf.dispatcher.d/enabled_farms/001_ams_publish_flush_farm.any && \
    ln -sf /etc/httpd/conf.dispatcher.d/available_farms/002_ams_author_farm.any /etc/httpd/conf.dispatcher.d/enabled_farms/002_ams_author_farm.any && \
    ln -sf /etc/httpd/conf.dispatcher.d/available_farms/002_ams_publish_farm.any /etc/httpd/conf.dispatcher.d/enabled_farms/002_ams_publish_farm.any

### PROJECT START ####
# Uncomment for project-specific dispatcher farms
# RUN ln -sf /etc/httpd/conf.dispatcher.d/available_farms/project.any /etc/httpd/conf.dispatcher.d/enabled_farms/project.any
### PROJECT END ####

# Install Adobe Dispatcher module
# TARGETARCH is automatically set by Docker Buildx based on build platform
# Valid values: amd64 (x86_64), arm64 (Apple M1/M2/M3/M4, AWS Graviton)
ARG TARGETARCH

# Copy and execute dispatcher installation script
COPY scripts/setup.sh /
RUN dos2unix /setup.sh && \
    chmod +x /setup.sh && \
    ./setup.sh && \
    rm -f /setup.sh

# Create default document roots with proper permissions
# These directories store cached content from AEM instances
RUN mkdir -p /mnt/var/www/html && \
    chown apache:apache /mnt/var/www/html && \
    mkdir -p /mnt/var/www/default && \
    chown apache:apache /mnt/var/www/default && \
    mkdir -p /mnt/var/www/author && \
    chown apache:apache /mnt/var/www/author

# Generate self-signed SSL certificates for local development
# These certificates are used by HAProxy for SSL termination
# Note: For production, replace with proper certificates from your CA
RUN mkdir -p /etc/ssl/docker && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=US/ST=California/L=San Jose/O=Adobe Systems Incorporated/CN=localhost" \
        -keyout /etc/ssl/docker/localhost.key \
        -out /etc/ssl/docker/localhost.crt && \
    cat /etc/ssl/docker/localhost.key /etc/ssl/docker/localhost.crt > /etc/ssl/docker/haproxy.pem && \
    chmod 644 /etc/ssl/docker/*

# Copy HAProxy configuration for SSL termination
# HAProxy handles SSL connections and proxies to Apache
COPY haproxy/haproxy.cfg /etc/haproxy

# Copy container launch script and make it executable
COPY scripts/launch.sh /
RUN dos2unix /launch.sh && \
    chmod +x /launch.sh

# Copy license and notice files as required by Adobe
COPY LICENSE /
COPY NOTICE /

# Expose standard HTTP (8080) and HTTPS (8443) ports
# Note: These are container ports, mapped to host ports at runtime
EXPOSE 8080 8443

# Set the entrypoint to the launch script
# This script starts HAProxy for SSL termination, then Apache with dispatcher
ENTRYPOINT ["/bin/bash", "/launch.sh"]
