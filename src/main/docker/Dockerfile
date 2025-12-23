# ──────────────────────────────────────────────────────────────
# 1. Build Cantaloupe (only when dev or when release not cached)
# ──────────────────────────────────────────────────────────────
FROM docker.io/library/maven:3-eclipse-temurin-21 AS cantaloupe-builder

ENV CANTALOUPE_RELEASES="https://github.com/cantaloupe-project/cantaloupe/releases/download"

ARG cantaloupe_version=5.0.7
ARG cantaloupe_commit_ref=
ARG cantaloupe_apply_patchfiles=false

WORKDIR /build

# Pre-install JAI jars once (they never change)
RUN --mount=type=cache,target=/root/.m2 \
    curl -sL https://nexus.geomatys.com/repository/geotoolkit/javax/media/jai_codec/1.1.3/jai_codec-1.1.3.jar -o /tmp/jai_codec.jar && \
    curl -sL https://nexus.geomatys.com/repository/geotoolkit/javax/media/jai_core/1.1.3/jai_core-1.1.3.jar -o /tmp/jai_core.jar && \
    curl -sL https://nexus.geomatys.com/repository/geotoolkit/javax/media/jai_imageio/1.1/jai_imageio-1.1.jar -o /tmp/jai_imageio.jar && \
    mvn install:install-file -Dfile=/tmp/jai_codec.jar    -DgroupId=javax.media -DartifactId=jai_codec    -Dversion=1.1.3 -Dpackaging=jar && \
    mvn install:install-file -Dfile=/tmp/jai_core.jar     -DgroupId=javax.media -DartifactId=jai_core     -Dversion=1.1.3 -Dpackaging=jar && \
    mvn install:install-file -Dfile=/tmp/jai_imageio.jar  -DgroupId=javax.media -DartifactId=jai_imageio  -Dversion=1.1   -Dpackaging=jar

# Copy patches early so layer is cached when they don't change
COPY patches ./patches

RUN --mount=type=cache,target=/root/.m2 \
    if [ "$cantaloupe_version" = "dev" ]; then \
        git clone https://github.com/cantaloupe-project/cantaloupe.git . && \
        [ -n "$cantaloupe_commit_ref" ] && git checkout "$cantaloupe_commit_ref" || true; \
        [ "$cantaloupe_apply_patchfiles" = "true" ] && git apply patches/*.patch || true; \
        mvn -B -DskipTests clean package && \
        mv target/cantaloupe-*.zip /Cantaloupe.zip; \
    else \
        curl -L -o /Cantaloupe.zip \
        "${CANTALOUPE_RELEASES}/v${cantaloupe_version}/cantaloupe-${cantaloupe_version}.zip"; \
    fi

# ──────────────────────────────────────────────────────────────
# 2. Build Kakadu native libs (optional, only when requested)
# ──────────────────────────────────────────────────────────────
FROM docker.io/library/ubuntu:24.04 AS kakadu-builder
ARG kakadu_version=""

# Always create directories (empty if no build) to avoid COPY glob failures
RUN mkdir -p /kakadu/lib /kakadu/bin

RUN if [ -n "$kakadu_version" ]; then \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            openjdk-17-jdk-headless gcc make libtiff-dev build-essential ca-certificates && \
        rm -rf /var/lib/apt/lists/*; \
    fi

COPY kakadu /kakadu
RUN if [ -n "$kakadu_version" ]; then \
        cd "/kakadu/$kakadu_version/make" && \
        make -f Makefile-Linux-x86-64-gcc && \
        cp ../lib/Linux-x86-64-gcc/*.so /kakadu/lib/ && \
        cp ../bin/Linux-x86-64-gcc/kdu_* /kakadu/bin/; \
    fi

# ──────────────────────────────────────────────────────────────
# 3. Final runtime image – small & fast
# ──────────────────────────────────────────────────────────────
FROM docker.io/library/eclipse-temurin:21-jre-alpine AS final

ARG cantaloupe_version=5.0.7

RUN mkdir -p /opt/libjpeg-turbo/lib && \
    apk add --no-cache \
        libturbojpeg \
        openjpeg-tools \
        ffmpeg \
        perl \
        tiff \
        bash \
        curl \
        python3 \
        tini \
    && ln -s /usr/lib/libturbojpeg.so.0 /opt/libjpeg-turbo/lib/libturbojpeg.so

RUN addgroup -g 1000 cantaloupe && \
    adduser -D -u 1000 -G cantaloupe cantaloupe

COPY --from=kakadu-builder /kakadu/lib/. /usr/lib/jni/
COPY --from=kakadu-builder /kakadu/bin/. /usr/local/bin/

RUN chown -R cantaloupe:cantaloupe /usr/lib/jni /usr/local/bin || true

ENV LD_LIBRARY_PATH=/usr/lib/jni:${LD_LIBRARY_PATH}

# Conditionally configure for Kakadu if files exist (mirrors original logic)
RUN touch /etc/environment && \
    if [ "$(ls -A /usr/lib/jni)" ]; then \
        echo "CANTALOUPE_MANUAL_PROCESSOR_JP2=KakaduNativeProcessor" >> /etc/environment && \
        echo "CANTALOUPE_PROCESSOR_SELECTION_STRATEGY=ManualSelectionStrategy" >> /etc/environment; \
    fi && \
    chown cantaloupe:cantaloupe /etc/environment

COPY --from=cantaloupe-builder /Cantaloupe.zip /tmp/
RUN unzip -q /tmp/Cantaloupe.zip -d /usr/local && \
    mv /usr/local/cantaloupe-* /usr/local/cantaloupe && \
    rm /tmp/Cantaloupe.zip && \
    rm -rf /usr/local/cantaloupe/deps

COPY "configs/cantaloupe.properties.tmpl-${cantaloupe_version}" /etc/cantaloupe/cantaloupe.properties.tmpl
COPY "configs/cantaloupe.properties.default-${cantaloupe_version}" /etc/cantaloupe/cantaloupe.properties.default

COPY docker-entrypoint.sh /usr/local/bin/
COPY scripts/run_cantaloupe.sh /usr/local/bin/

# Patch entrypoint for Python 3 compatibility (no source file changes)
RUN sed -i 's/python2/python3/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/import os,string,ConfigParser,StringIO;/import os\nimport string\nfrom configparser import ConfigParser\nfrom io import StringIO;/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/StringIO.StringIO/StringIO/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/ConfigParser.ConfigParser/ConfigParser/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/readfp/read_file/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/config_parser = ConfigParser()/config_parser = ConfigParser(interpolation=None)/g' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/-XX:MaxRAMPercentage="${HEAP_PERCENTAGE}"//g' /usr/local/bin/run_cantaloupe.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/run_cantaloupe.sh

# Directories owned by cantaloupe
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe /imageroot && \
    chown -R cantaloupe:cantaloupe /var/log/cantaloupe /var/cache/cantaloupe /etc/cantaloupe /usr/local/cantaloupe

# Logging env vars
ENV CONFIG_FILE="/etc/cantaloupe/cantaloupe.properties"
ENV CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_PATHNAME=/var/log/cantaloupe/application.log
ENV CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_PATHNAME=/var/log/cantaloupe/error.log
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -XX:+ExitOnOutOfMemoryError"

EXPOSE 8182
VOLUME /imageroot

USER cantaloupe
WORKDIR /home/cantaloupe

ENTRYPOINT ["tini", "--", "docker-entrypoint.sh"]
CMD ["sh", "-c", "exec run_cantaloupe.sh"]
