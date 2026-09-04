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
# Updated: September 2026 - Environment variables for AEM Dispatcher Docker
# This file configures the Dispatcher container for local development
#

# -----------------------------------------------------------------------------
# Dispatcher Identification
# -----------------------------------------------------------------------------
# Unique identifier for this dispatcher instance
# Used in cache directory names and log file names
DISP_ID=docker

# -----------------------------------------------------------------------------
# AEM Author Instance Configuration
# -----------------------------------------------------------------------------
# Author instance connection details
# For Mac with Docker Desktop, use host.docker.internal to connect to host machine
AUTHOR_IP=host.docker.internal    # Docker special hostname for Mac/Windows
AUTHOR_PORT=4502                  # Default AEM Author port
AUTHOR_DEFAULT_HOSTNAME=author.docker.local  # Hostname for Author virtual host
AUTHOR_DOCROOT=/mnt/var/www/author  # Document root for Author cache

# -----------------------------------------------------------------------------
# AEM Publish Instance Configuration
# -----------------------------------------------------------------------------
# Publish instance connection details
PUBLISH_IP=host.docker.internal    # Docker special hostname for Mac/Windows
PUBLISH_PORT=4503                  # Default AEM Publish port
PUBLISH_DEFAULT_HOSTNAME=publish.docker.local  # Hostname for Publish virtual host
PUBLISH_DOCROOT=/mnt/var/www/html  # Document root for Publish cache

# -----------------------------------------------------------------------------
# AEM LiveCycle (Forms) Configuration (Optional)
# -----------------------------------------------------------------------------
# Uncomment and configure if using AEM Forms/LiveCycle
# LIVECYCLE_IP=127.0.0.1
# LIVECYCLE_PORT=8080
# LIVECYCLE_DEFAULT_HOSTNAME=aemforms-exampleco-dev.adobecqms.net
# LIVECYCLE_DOCROOT=/mnt/var/www/lc

# -----------------------------------------------------------------------------
# SSL/TLS Configuration
# -----------------------------------------------------------------------------
# Force SSL redirects (0=off, 1=on)
# Set to 1 in production, 0 for local development
PUBLISH_FORCE_SSL=0
AUTHOR_FORCE_SSL=0

# -----------------------------------------------------------------------------
# Security Settings
# -----------------------------------------------------------------------------
# CRXDE access control (allow/deny)
# In production environments, this should always be "deny"
# Only set to "allow" for local development and debugging
CRX_FILTER=allow

# Dispatcher flush security
# WARNING: Only set to "allow" on local development environments
# In production, this should be restricted to specific IP addresses
DISPATCHER_FLUSH_FROM_ANYWHERE=allow

# -----------------------------------------------------------------------------
# Performance and Logging Settings
# -----------------------------------------------------------------------------
# Dispatcher log level (0-4, where 4=trace/debug)
# Lower values for production (1-2), higher for debugging (3-4)
DISP_LOG_LEVEL=4

# Cache configuration
# Enable/disable dispatcher caching (0=disabled, 1=enabled)
DISP_CACHE_ENABLED=1

# -----------------------------------------------------------------------------
# Docker-Specific Settings for Mac M1/M2/M3/M4
# -----------------------------------------------------------------------------
# Special configuration for Apple Silicon Macs
# Docker Desktop on Mac provides special hostname resolution
DOCKER_HOST_ALIAS=host.docker.internal

# Timezone configuration (optional)
# TZ=America/Los_Angeles

# -----------------------------------------------------------------------------
# Project-Specific Configuration
# -----------------------------------------------------------------------------
# Uncomment and customize for project-specific settings
# PROJECT_ENV=dev
# PROJECT_NAME=my-project
# PROJECT_VERSION=1.0.0

# -----------------------------------------------------------------------------
# Health Check Configuration
# -----------------------------------------------------------------------------
# Health check endpoint (used by HAProxy and monitoring)
HEALTH_CHECK_PATH=/content/we-retail/language-masters/en.html
HEALTH_CHECK_TIMEOUT=5

# -----------------------------------------------------------------------------
# Export all variables (Docker will source this file)
# -----------------------------------------------------------------------------
# Note: Docker --env-file does not support multi-line export statements
# These variables are automatically available to the container via --env-file