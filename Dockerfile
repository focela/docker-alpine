#-----------------------------------------------------------------------------
# BASE IMAGE & BUILD ARGUMENTS
#-----------------------------------------------------------------------------
# Alpine Linux base image with configurable version
ARG ALPINE_VERSION=3.21
FROM docker.io/alpine:${ALPINE_VERSION}

# Maintainer and source information
LABEL maintainer="Focela Labs (https://www.focela.com)"

# Build-time version arguments for all compiled components
ARG GOLANG_VERSION=1.21.13
ARG DOAS_VERSION
ARG FLUENTBIT_VERSION
ARG S6_OVERLAY_VERSION
ARG YQ_VERSION
ARG ZABBIX_VERSION

#-----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
#-----------------------------------------------------------------------------
# Set default versions for all components if not provided at build time
ENV FLUENTBIT_VERSION=${FLUENTBIT_VERSION:-"3.1.10"} \
  S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:-"3.2.0.3"} \
  YQ_VERSION=${YQ_VERSION:-"v4.44.2"} \
  ZABBIX_VERSION=${ZABBIX_VERSION:-"7.2.6"} \
  DOAS_VERSION=${DOAS_VERSION:-"v6.8.2"}

# Container runtime configuration
ENV DEBUG_MODE=FALSE \
  TIMEZONE=Etc/GMT \
  IMAGE_NAME="focela/alpine" \
  IMAGE_REPO_URL="https://github.com/focela/docker-alpine/"

# Service enablement flags
ENV CONTAINER_ENABLE_SCHEDULING=TRUE \
  CONTAINER_SCHEDULING_BACKEND=cron \
  CONTAINER_ENABLE_MESSAGING=TRUE \
  CONTAINER_MESSAGING_BACKEND=msmtp \
  CONTAINER_ENABLE_MONITORING=TRUE \
  CONTAINER_MONITORING_BACKEND=zabbix \
  CONTAINER_ENABLE_LOGSHIPPING=FALSE

# S6-overlay configuration for process supervision
ENV S6_GLOBAL_PATH=/command:/usr/bin:/bin:/usr/sbin:sbin:/usr/local/bin:/usr/local/sbin \
  S6_KEEP_ENV=1 \
  S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

#-----------------------------------------------------------------------------
# VERSION DETECTION & COMPATIBILITY LOGIC
#-----------------------------------------------------------------------------
# Complex Alpine version detection and feature flag setup
# This section determines which packages and build methods to use based on Alpine version
RUN case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2)" in \
      "3.5" | "3.6" ) no_upx=true ;; \
      *) busybox_extras="busybox-extras" ;; \
    esac ; \
    \
    # Determine if Fluent Bit should be built from source (newer Alpine versions)
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.11 | 3.12 | 3.13 | 3.14 | 3.15 | 3.16 | 3.17* | 3.18* | 3.19* | 3.20* | 3.21* | 3.22* | edge ) \
        fluentbit_make=true ; echo "** Building Fluent Bit" ;; \
      *) : ;; \
    esac ; \
    \
    # Determine Zabbix Agent 2 support (requires newer Alpine and Golang)
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.15 | 3.16 | 3.17* | 3.18* | 3.19* | 3.20* | 3.21* | 3.22* | edge ) \
        zabbix_args=" --enable-agent2 " ; zabbix_agent2=true ; echo "** Building Zabbix Agent 2" ;; \
      *) : ;; \
    esac ; \
    \
    # Set appropriate Golang version for older Alpine releases
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.11 | 3.12 | 3.13 | 3.14 ) export GOLANG_VERSION=1.19.5 ; yq=false ;; \
      *) : ;; \
    esac ; \
    \
    # Determine YQ availability (not available on older Alpine versions)
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.5 | 3.6 | 3.7 | 3.8 | 3.9 | 3.10 | 3.11 | 3.12 | 3.13 | 3.14 | 3.15 | 3.16 ) yq=false ;; \
      *) : ;; \
    esac ; \
    \
    # Set FTS (File Tree Search) library based on Alpine version
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.5 | 3.6 | 3.7 | 3.8 | 3.9 | 3.10 | 3.11 | 3.12 | 3.13 | 3.14 | 3.15 | 3.16 ) fts=fts ;; \
      3.17 | 3.18* | 3.19* | 3.20* | 3.21* ) fts=musl-fts ;; \
      *) : ;; \
    esac ; \
    \
    # Set SSL library based on Alpine version (LibreSSL vs OpenSSL)
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2 | cut -d _ -f 1)" in \
      3.5 | 3.6 | 3.7 | 3.8 | 3.9 | 3.10 | 3.11 | 3.12 | 3.13 | 3.14 | 3.15 | 3.16 ) alpine_ssl=libressl ;; \
      3.17* | 3.18* | 3.19* | 3.20* | 3.21* ) alpine_ssl=openssl ;; \
      *) : ;; \
    esac ; \
    \
    # Determine UPX availability (compression tool, x86_64 only)
    apkArch="$(apk --print-arch)" ; \
    case "$apkArch" in \
      x86_64) upx=upx ;; \
      *) : ;; \
    esac ; \
    \
    # Disable UPX for older Alpine versions
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2)" in \
      "3.5" | "3.6") upx="" ;; \
    esac ; \
    \
    # Determine Doas build requirement (older versions need source build)
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2)" in \
      "3.5" | "3.6" | "3.7" | "3.8" ) build_doas=true ;; \
      *) doas_package="doas" ;; \
    esac ; \
    \
    # Set ZSTD package availability
    case "$(cat /etc/os-release | grep VERSION_ID | cut -d = -f 2 | cut -d . -f 1,2)" in \
      "3.5" | "3.8" ) zstd_package="" ;; \
      *) zstd_package=zstd ;; \
    esac ; \
    \
#-----------------------------------------------------------------------------
# PACKAGE INSTALLATION
#-----------------------------------------------------------------------------
    # Update package repository and upgrade existing packages
    set -ex && \
    apk update && \
    apk upgrade && \
    \
    # Install core runtime dependencies
    apk add -t .base-rundeps \
      acl \
      ${alpine_ssl} \
      bash \
      bc \
      ${busybox_extras} \
      curl \
      ${doas_package} \
      fail2ban \
      ${fts} \
      git \
      grep \
      iptables \
      iputils \
      jq \
      less \
      libgcc \
      $(apk search libssl1* -q) \
      logrotate \
      msmtp \
      nano \
      pcre \
      s6 \
      sudo \
      tzdata \
      yaml \
      ${zstd_package} \
      && \
    \
    # Install Golang build dependencies
    apk add -t .golang-build-deps \
      go \
      musl-dev \
      && \
    \
    # Install Zabbix compilation dependencies
    apk add -t .zabbix-build-deps \
      alpine-sdk \
      autoconf \
      automake \
      binutils \
      coreutils \
      g++ \
      openssl-dev \
      make \
      pcre-dev \
      zlib-dev \
      ${additional_packages} \
      ${upx} \
      && \
    \
    # Install Fluent Bit compilation dependencies
    apk add -t .fluentbit-build-deps \
      bison \
      cmake \
      flex \
      ${fts}-dev \
      linux-headers \
      openssl-dev \
      snappy-dev \
      yaml-dev \
      && \
    \
#-----------------------------------------------------------------------------
# SYSTEM CONFIGURATION
#-----------------------------------------------------------------------------
    # Install envsubst utility for environment variable substitution
    apk add gettext && \
    mv /usr/bin/envsubst /usr/local/bin/envsubst && \
    \
    # Configure timezone based on environment variable
    cp -R /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    \
    # Configure sudo to disable core dumps for security
    echo "Set disable_coredump false" > /etc/sudo.conf && \
    \
#-----------------------------------------------------------------------------
# DOAS COMPILATION (for older Alpine versions)
#-----------------------------------------------------------------------------
    # Build OpenDoas from source if package not available
    if [ "$build_doas" = "true" ] ; then \
      mkdir -p /usr/src/doas ; \
      curl -sSL https://github.com/Duncaen/OpenDoas/archive/${DOAS_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/doas ; \
      cd /usr/src/doas ; \
      ./configure --prefix=/usr \
        --enable-static \
        --without-pam ; \
      make ; \
      make install ; \
    fi ; \
    \
#-----------------------------------------------------------------------------
# GOLANG INSTALLATION (for Zabbix Agent 2)
#-----------------------------------------------------------------------------
    # Install Golang from source if Zabbix Agent 2 is enabled
    if [ "$zabbix_agent2" = "true" ] ; then \
      mkdir -p /usr/src/golang ; \
      curl -sSL https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz | tar xvfz - --strip 1 -C /usr/src/golang ; \
      cd /usr/src/golang/src/ ; \
      ./make.bash 1>/dev/null ; \
      export GOROOT=/usr/src/golang/ ; \
      export PATH="/usr/src/golang/bin:$PATH" ; \
    fi ; \
    \
#-----------------------------------------------------------------------------
# YQ COMPILATION (YAML processor)
#-----------------------------------------------------------------------------
    # Build YQ from source for YAML processing capabilities
    if [ "$yq" != "false" ] ; then \
      git clone https://github.com/mikefarah/yq /usr/src/yq ; \
      cd /usr/src/yq ; \
      git checkout ${YQ_VERSION} ; \
      go build ; \
      cp -R yq /usr/local/bin ; \
    fi ; \
    \
#-----------------------------------------------------------------------------
# ZABBIX INSTALLATION & COMPILATION
#-----------------------------------------------------------------------------
    # Create Zabbix user and directory structure
    addgroup -g 10050 zabbix && \
    adduser -S -D -H -h /dev/null -s /sbin/nologin -G zabbix -u 10050 zabbix && \
    mkdir -p /etc/zabbix && \
    mkdir -p /etc/zabbix/zabbix_agentd.conf.d && \
    mkdir -p /var/lib/zabbix && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    mkdir -p /var/lib/zabbix/run && \
    mkdir -p /var/log/zabbix && \
    \
    # Set appropriate permissions for Zabbix directories
    chown --quiet -R zabbix:root /etc/zabbix && \
    chown --quiet -R zabbix:root /var/lib/zabbix && \
    chown --quiet -R zabbix:root /var/log/zabbix && \
    chmod -R 770 /var/lib/zabbix/run && \
    \
    # Compile Zabbix from source
    mkdir -p /usr/src/zabbix && \
    curl -sSL https://github.com/zabbix/zabbix/archive/${ZABBIX_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/zabbix && \
    cd /usr/src/zabbix && \
    ./bootstrap.sh 1>/dev/null && \
    \
    # Configure compilation with security flags
    export CFLAGS="-fPIC -pie -Wl,-z,relro -Wl,-z,now" && \
    sed -i "s|CGO_CFLAGS=\"\${CGO_CFLAGS}\"| CGO_CFLAGS=\"-D_LARGEFILE64_SOURCE \${CGO_CFLAGS}\"|g" /usr/src/zabbix/src/go/Makefile.am && \
    \
    # Configure Zabbix build with appropriate features
    ./configure \
      --prefix=/usr \
      --silent \
      --sysconfdir=/etc/zabbix \
      --libdir=/usr/lib/zabbix \
      --datadir=/usr/lib \
      --enable-agent ${zabbix_args} \
      --enable-ipv6 \
      --with-openssl \
      && \
    \
    # Compile and install Zabbix binaries
    make -j"$(nproc)" -s 1>/dev/null && \
    cp src/zabbix_agent/zabbix_agentd /usr/sbin/zabbix_agentd && \
    cp src/zabbix_get/zabbix_get /usr/sbin/zabbix_get && \
    cp src/zabbix_sender/zabbix_sender /usr/sbin/zabbix_sender && \
    if [ "$zabbix_agent2" = "true" ] ; then cp src/go/bin/zabbix_agent2 /usr/sbin/zabbix_agent2 ; fi ; \
    \
    # Strip and compress binaries to reduce size
    strip /usr/sbin/zabbix_agentd && \
    strip /usr/sbin/zabbix_get && \
    strip /usr/sbin/zabbix_sender && \
    if [ "$zabbix_agent2" = true ] ; then strip /usr/sbin/zabbix_agent2 ; fi ; \
    \
    # Apply UPX compression if available and appropriate
    if [ "$apkArch" = "x86_64" ] && [ "$no_upx" != "true" ]; then upx /usr/sbin/zabbix_agentd ; fi ; \
    if [ "$apkArch" = "x86_64" ] && [ "$no_upx" != "true" ]; then upx /usr/sbin/zabbix_get ; fi ; \
    if [ "$apkArch" = "x86_64" ] && [ "$no_upx" != "true" ]; then upx /usr/sbin/zabbix_sender ; fi ; \
    if [ "$apkArch" = "x86_64" ] && [ "$zabbix_agent2" = "true" ] && [ "$no_upx" != "true" ]; then upx /usr/sbin/zabbix_agent2 ; fi ; \
    \
    # Clean up Zabbix source
    rm -rf /usr/src/zabbix && \
    \
#-----------------------------------------------------------------------------
# FLUENT BIT COMPILATION
#-----------------------------------------------------------------------------
    # Download and patch Fluent Bit source code
    mkdir -p /usr/src/fluentbit && \
    curl -sSL https://github.com/fluent/fluent-bit/archive/v${FLUENTBIT_VERSION}.tar.gz | tar xfz - --strip 1 -C /usr/src/fluentbit && \
    cd /usr/src/fluentbit && \
    \
    # Apply Alpine-specific patches for compatibility
    curl -sSL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/testing/fluent-bit/chunkio-static-lib-fts.patch | patch -p1 && \
    curl -sSL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/testing/fluent-bit/exclude-luajit.patch | patch -p1 && \
    curl -sSL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/testing/fluent-bit/musl-strerror_r.patch | patch -p1 && \
    \
    # Configure Fluent Bit build with minimal feature set for container logging
    cmake \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_BUILD_TYPE=None \
      -DFLB_AWS=No \
      -DFLB_BACKTRACE=No \
      -DFLB_CORO_STACK_SIZE=24576 \
      -DFLB_DEBUG=No \
      -DFLB_EXAMPLES=No \
      -DFLB_FILTER_AWS=No \
      -DFLB_FILTER_ECS=No \
      -DFLB_FILTER_NIGHTFALL=No \
      -DFLB_FILTER_GEOIP2=No \
      -DFLB_FILTER_KUBERNETES=No \
      -DFLB_FILTER_TENSORFLOW=No \
      -DFLB_FILTER_WASM=No \
      -DFLB_HTTP_SERVER=Yes \
      -DFLB_IN_CALYPTIA_FLEET=No \
      -DFLB_IN_COLLECTD=No \
      -DFLB_IN_CPU=No \
      -DFLB_IN_DISK=No \
      -DFLB_IN_DOCKER=No \
      -DFLB_IN_DOCKER_EVENTS=No \
      -DFLB_IN_EMITTER=Yes \
      -DFLB_IN_EXEC=Yes \
      -DFLB_IN_EXEC_WASI=No \
      -DFLB_IN_ELASTICSEARCH=No \
      -DFLB_IN_HEALTH=No \
      -DFLB_IN_KAFKA=No \
      -DFLB_IN_KMSG=No \
      -DFLB_IN_KUBERNETES_EVENTS=No \
      -DFLB_IN_MEM=No \
      -DFLB_IN_MQTT=No \
      -DFLB_IN_NETIF=No \
      -DFLB_IN_NGINX_EXPORTER_METRICS=No \
      -DFLB_IN_NODE_EXPORTER_METRICS=No \
      -DFLB_IN_OPENTELEMETRY=No \
      -DFLB_IN_PODMAN_METRICS=No \
      -DFLB_IN_PROCESS_EXPORTER_METRICS=No \
      -DFLB_IN_PROC=No \
      -DFLB_IN_PROMETHEUS_REMOTE_WRITE=Yes \
      -DFLB_IN_PROMETHEUS_SCRAPE=No \
      -DFLB_IN_SERIAL=No \
      -DFLB_IN_SPLUNK=No \
      -DFLB_IN_STATSD=No \
      -DFLB_IN_SYSTEMD=No \
      -DFLB_IN_SYSLOG=No \
      -DFLB_IN_TCP=No \
      -DFLB_IN_UDP=No \
      -DFLB_IN_UNIX_SOCKET=No \
      -DFLB_IN_THERMAL=No \
      -DFLB_IN_WINLOG=No \
      -DFLB_IN_WINDOWS_EXPORTER_METRICS=No \
      -DFLB_IN_WINSTAT=No \
      -DFLB_JEMALLOC=Yes \
      -DFLB_LUAJIT=No \
      -DFLB_PROCESSOR_OPENTELEMETRY_ENVELOPE=No \
      -DFLB_PROCESSOR_SQL=No \
      -DFLB_OUT_AZURE=No \
      -DFLB_OUT_AZURE_BLOB=No \
      -DFLB_OUT_AZURE_KUSTO=No \
      -DFLB_OUT_AZURE_LOGS_INGESTION=No \
      -DFLB_OUT_BIGQUERY=No \
      -DFLB_OUT_CALYPTIA=No \
      -DFLB_OUT_CHRONICLE=No \
      -DFLB_OUT_CLOUDWATCH_LOGS=No \
      -DFLB_OUT_COUNTER=No \
      -DFLB_OUT_DATADOG=No \
      -DFLB_OUT_ES=No \
      -DFLB_OUT_FLOWCOUNTER=No \
      -DFLB_OUT_GELF=No \
      -DFLB_OUT_INFLUXDB=No \
      -DFLB_OUT_KAFKA=No \
      -DFLB_OUT_KAFKA_REST=No \
      -DFLB_OUT_KINESIS_FIREHOSE=No \
      -DFLB_OUT_KINESIS_STREAMS=No \
      -DFLB_OUT_LIB=No \
      -DFLB_OUT_LOGDNA=No \
      -DFLB_OUT_NATS=No \
      -DFLB_OUT_NRLOGS=No \
      -DFLB_OUT_OPENSEARCH=No \
      -DFLB_OUT_ORACLE_LOG_ANALYTICS=No \
      -DFLB_OUT_OPENTELEMETRY=No \
      -DFLB_OUT_PROMETHEUS_EXPORTER=No \
      -DFLB_OUT_PROMETHEUS_REMOTE_WRITE=No \
      -DFLB_OUT_PGSQL=No \
      -DFLB_OUT_PLOT=No \
      -DFLB_OUT_S3=No \
      -DFLB_OUT_SKYWALKING=No \
      -DFLB_OUT_SLACK=No \
      -DFLB_OUT_SPLUNK=No \
      -DFLB_OUT_STACKDRIVER=No \
      -DFLB_OUT_TCP=No \
      -DFLB_OUT_TD=No \
      -DFLB_OUT_UDP=No \
      -DFLB_OUT_VIVO_EXPORTER=No \
      -DFLB_OUT_WEBSOCKET=No \
      -DFLB_RELEASE=Yes \
      -DFLB_SHARED_LIB=No \
      -DFLB_SIGNV4=No \
      -DFLB_SMALL=Yes \
      -DFLB_TLS=Yes \
      -DFLB_WASM=No \
      . \
      && \
    \
    # Build and install Fluent Bit if enabled
    if [ "$fluentbit_make" = "true" ] ; then \
      if [ "$apkArch" = "x86_64" ] ; then \
        make -j"$(nproc)" ; \
        make install ; \
        mv /usr/etc/fluent-bit /etc/fluent-bit ; \
        mkdir -p /etc/fluent-bit/parsers.d ; \
        mkdir -p /etc/fluent-bit/conf.d ; \
        strip /usr/bin/fluent-bit ; \
        if [ "$apkArch" = "x86_64" ] && [ "$no_upx" != "true" ]; then upx /usr/bin/fluent-bit ; fi ; \
      fi ; \
    fi ; \
    \
#-----------------------------------------------------------------------------
# FAIL2BAN CONFIGURATION
#-----------------------------------------------------------------------------
    # Configure Fail2ban for container security
    addgroup -g 65500 fail2ban && \
    addgroup zabbix fail2ban && \
    \
    # Set up Fail2ban runtime directory with proper permissions
    rm -rf /var/run/fail2ban && \
    mkdir -p /var/run/fail2ban && \
    chown -R root:fail2ban /var/run/fail2ban && \
    setfacl -d -m g:fail2ban:rwx /var/run/fail2ban && \
    \
    # Clean up default Fail2ban configuration (keep only iptables actions)
    find /etc/fail2ban/action.d/ -type f -not -name 'iptables*.conf' -delete && \
    rm -rf /etc/fail2ban/filter.d && \
    mkdir -p /etc/fail2ban/filter.d && \
    rm -rf /etc/fail2ban/fail2ban.d && \
    rm -rf /etc/fail2ban/jail.d/* && \
    rm -rf /etc/fail2ban/paths* && \
    \
#-----------------------------------------------------------------------------
# CLEANUP & OPTIMIZATION
#-----------------------------------------------------------------------------
    # Create required directories
    mkdir -p /etc/logrotate.d && \
    mkdir -p /etc/doas.d && \
    \
    # Remove build dependencies to reduce image size
    apk del --purge \
      .fluentbit-build-deps \
      .golang-build-deps \
      .zabbix-build-deps \
      gettext \
      && \
    \
    # Clean up configuration files and temporary data
    rm -rf /etc/*.apk.new && \
    rm -rf /etc/logrotate.d/* && \
    rm -rf /etc/doas.conf /etc/doas.d/* && \
    rm -rf /root/.cache && \
    rm -rf /root/go && \
    rm -rf /tmp/* && \
    rm -rf /usr/src/* && \
    rm -rf /var/cache/apk/* && \
    \
#-----------------------------------------------------------------------------
# S6 OVERLAY INSTALLATION
#-----------------------------------------------------------------------------
    # Determine architecture for S6 overlay installation
    apkArch="$(apk --print-arch)" && \
    case "$apkArch" in \
      x86_64) s6Arch='x86_64' ;; \
      armv7) s6Arch='armhf' ;; \
      armhf) s6Arch='armhf' ;; \
      aarch64) s6Arch='aarch64' ;; \
      *) echo >&2 "Error: unsupported architecture ($apkArch)"; exit 1 ;; \
    esac ; \
    \
    # Install S6 overlay components for process supervision
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar xvpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${s6Arch}.tar.xz | tar xvpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz | tar xvpfJ - -C / && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz | tar xvpfJ - -C / && \
    \
    # Create S6 service directories
    mkdir -p /etc/cont-init.d && \
    mkdir -p /etc/cont-finish.d && \
    mkdir -p /etc/services.d && \
    \
    # Set proper permissions for S6 directories
    chown -R 0755 /etc/cont-init.d && \
    chown -R 0755 /etc/cont-finish.d && \
    chmod -R 0755 /etc/services.d && \
    \
    # Customize S6 overlay behavior for quieter operation
    sed -i "s|echo|: # echo |g" /package/admin/s6-overlay/etc/s6-rc/scripts/cont-init && \
    sed -i "s|echo|: # echo |g" /package/admin/s6-overlay/etc/s6-rc/scripts/cont-finish && \
    sed -i "s|echo ' (no readiness notification)'|: # echo ' (no readiness notification)'|g" /package/admin/s6-overlay/etc/s6-rc/scripts/services-up && \
    sed -i "s|s6-echo -n|: # s6-echo -n|g" /package/admin/s6-overlay/etc/s6-rc/scripts/services-up && \
    sed -i "s|v=2|v=1|g" /package/admin/s6-overlay/etc/s6-linux-init/skel/rc.init && \
    sed -i "s|v=2|v=1|g" /package/admin/s6-overlay/etc/s6-linux-init/skel/rc.shutdown

#-----------------------------------------------------------------------------
# CONTAINER CONFIGURATION
#-----------------------------------------------------------------------------
# Set shell to Bash for improved scripting support
SHELL ["/bin/bash", "-c"]

# Expose ports for Fluent Bit HTTP server and Zabbix agent
EXPOSE 2020/TCP 10050/TCP

# Set S6 overlay as the container entrypoint
ENTRYPOINT ["/init"]

#-----------------------------------------------------------------------------
# APPLICATION FILES
#-----------------------------------------------------------------------------
# Copy application files and configurations from build context
COPY install/ /
