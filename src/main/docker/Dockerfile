
# We do a multi-stage build; the first stage builds the Cantaloupe code
FROM maven:3.6.3-jdk-11 AS MAVEN_TOOL_CHAIN

# Where we find the stable Cantaloupe Jar file
ENV CANTALOUPE_RELEASES="https://github.com/cantaloupe-project/cantaloupe/releases/download"

# All this JAI stuff is never going to change
ENV JAI_JAR="jai_codec-1.1.3.jar"
ENV JAI_CORE_JAR="jai_core-1.1.3.jar"
ENV JAI_IMAGEIO_JAR="jai_imageio-1.1.jar"
ENV JAI_VERSION="1.1.3"
ENV JAI_IMAGEIO_VERSION="1.1"

# It's not great to use a third party repo but we pick a reputable one if we have to
ENV JAI_REPO="https://nexus.geomatys.com/repository/geotoolkit/javax/media"

WORKDIR /build/cantaloupe
COPY patches /build/cantaloupe-patches
RUN if [ "${cantaloupe.version}" = "dev" ] ; then \
      git clone --quiet https://github.com/cantaloupe-project/cantaloupe.git . && \
      \
      # We can supply a particular commit ref as a defense against a broken upstream
      if [ -n "${cantaloupe.commit.ref}" -a "${cantaloupe.commit.ref}" != "latest" ] ; then \
        git fetch --all ; \
        git checkout -b "${cantaloupe.commit.ref}" "${cantaloupe.commit.ref}" ; \
      fi && \
      \
      # We can also supply a patchfile as a defense against a broken upstream
      if [ -n "${cantaloupe.patchfiles.dir}" ] ; then \
        if [ $(ls -la /build/cantaloupe-patches/**.patch | wc -l) -gt 0 ] ; then \
          git apply $(ls /build/cantaloupe-patches/**.patch) ; \
        else \
          echo "Warning: could not find patchfiles in \"${cantaloupe.patchfiles.dir}\"" ; \
        fi ; \
      fi && \
      \
      # Janky, but third party repos and transitive dependences... what can you do?
      curl -s "${JAI_REPO}/jai_codec/${JAI_VERSION}/${JAI_JAR}" > "/tmp/${JAI_JAR}" && \
      curl -s "${JAI_REPO}/jai_core/${JAI_VERSION}/${JAI_CORE_JAR}" > "/tmp/${JAI_CORE_JAR}" && \
      curl -s "${JAI_REPO}/jai_imageio/${JAI_IMAGEIO_VERSION}/${JAI_IMAGEIO_JAR}" > "/tmp/${JAI_IMAGEIO_JAR}" && \
      \
      mvn -q install:install-file -Dfile="/tmp/${JAI_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_codec" -Dversion="$JAI_VERSION" -Dpackaging="jar" && \
      mvn -q install:install-file -Dfile="/tmp/${JAI_CORE_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_core" -Dversion="$JAI_VERSION" -Dpackaging="jar" && \
      mvn -q install:install-file -Dfile="/tmp/${JAI_IMAGEIO_JAR}" -DgroupId="javax.media" \
        -DartifactId="jai_imageio" -Dversion="$JAI_IMAGEIO_VERSION" -Dpackaging="jar" && \
      \
      mvn -DskipTests=true -Djar.phase=package -q clean package && \
      mv target/cantaloupe-*.zip "/build/Cantaloupe.zip" ; \
    else \
      curl -o "../Cantaloupe.zip" -s -L \
        "${CANTALOUPE_RELEASES}/v${cantaloupe.version}/Cantaloupe-${cantaloupe.version}.zip" ; \
    fi

# The second stage of our multi-stage build builds the kakadu libraries and binaries
FROM ubuntu:${ubuntu.tag} AS KAKADU_TOOL_CHAIN

ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

COPY kakadu /build/kakadu/
RUN if [ ! -z "${kakadu.version}" ]; then \
      cd /build/kakadu/"${kakadu.version}"/make && \
      apt-get update -qq && \
      DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
        openjdk-11-jdk-headless=${openjdk.version}\
        gcc=${gcc.version} \
        make=${make.version} \
        libtiff-tools=${libtiff.version} \
        libtiff5=${libtiff.version} \
        libtiff5-dev=${libtiff.version} \
        build-essential=${build.essential.version} && \
      make -f Makefile-Linux-x86-64-gcc && \
      mkdir /build/kakadu/lib && \
      mkdir /build/kakadu/bin && \
      cp ../lib/Linux-x86-64-gcc/*.so /build/kakadu/lib && \
      cp ../bin/Linux-x86-64-gcc/kdu_compress /build/kakadu/bin && \
      cp ../bin/Linux-x86-64-gcc/kdu_expand /build/kakadu/bin && \
      cp ../bin/Linux-x86-64-gcc/kdu_jp2info /build/kakadu/bin ; \
    else \
      mkdir -p /build/kakadu/lib && \
      mkdir -p /build/kakadu/bin && \
      touch /build/kakadu/lib/placeholder.so && \
      touch /build/kakadu/bin/kdu_placeholder ; \
    fi

# The third and final stage of our multi-stage build pulls all the pieces together
FROM ubuntu:${ubuntu.tag}

# The location of the Cantaloupe config file
ENV CONFIG_FILE="/etc/cantaloupe.properties"

# We're using a percentage of available RAM
ENV HEAP_PERCENTAGE="80"

# Use this to pass any additional JVM options to the start script
ENV JAVA_OPTS=""

# The port we expose the Cantaloupe service on
EXPOSE 8182

# The container's file system location for images
VOLUME /imageroot

# Update packages and install tools
#  Removing /var/lib/apt/lists/* prevents using `apt` unless you do `apt update` first
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -qq --no-install-recommends \
    libtiff-tools=${libtiff.version}  \
    libtiff5=${libtiff.version}  \
    libtiff5-dev=${libtiff.version}  \
    libopenjp2-tools=${libopenjp2.version} \
    libturbojpeg=${libturbojpeg.version} \
    openjdk-11-jre-headless=${openjdk.version} \
    unzip=${unzip.version} \
    zip=${zip.version} \
    curl=${curl.version} \
    ffmpeg=${ffmpeg.version} \
    python2=${python2.version} \
    < /dev/null > /dev/null && \
    mkdir -p /opt/libjpeg-turbo/lib && \
    ln -s /usr/lib/x86_64-linux-gnu/libturbojpeg.so.0 /opt/libjpeg-turbo/lib/libturbojpeg.so && \
    rm -rf /var/lib/apt/lists/*

# Run Cantaloupe non-privileged
RUN adduser --system cantaloupe

# Copy work product from the Cantaloupe build into our image
WORKDIR /tmp
COPY --from=MAVEN_TOOL_CHAIN "/build/Cantaloupe.zip" "/tmp/Cantaloupe.zip"

WORKDIR /usr/local
RUN unzip -qq "/tmp/Cantaloupe.zip" && \
    ln -s cantaloupe-?.* cantaloupe && \
    rm -rf "/tmp/Cantaloupe-${cantaloupe.version}" && \
    rm "/tmp/Cantaloupe.zip" && \
    rm -rf "/usr/local/cantaloupe-${cantaloupe.version}/deps"

# Put our Kakadu libs in a directory that's in the LD_LIBRARY_PATH
WORKDIR /usr/lib/jni
COPY --from=KAKADU_TOOL_CHAIN /build/kakadu/lib/* /usr/lib/jni/

# Put our Kakadu bins in the local bin directory
WORKDIR /usr/local/bin
COPY --from=KAKADU_TOOL_CHAIN /build/kakadu/bin/* /usr/local/bin/

# Cantaloupe is aware of '/usr/lib/jni' but the system is not
ENV LD_LIBRARY_PATH="/usr/lib/jni:${LD_LIBRARY_PATH}"

# Clean up the placeholder files if we built without kakadu; else configure Cantaloupe for Kakadu
RUN if [ -z "${kakadu.version}" ]; then \
      rm -rf /usr/local/lib/placeholder.so && \
      rm -rf /usr/local/bin/kdu_placeholder ; \
    else \
      echo "CANTALOUPE_MANUAL_PROCESSOR_JP2=KakaduNativeProcessor" >> /etc/environment && \
      echo "CANTALOUPE_PROCESSOR_SELECTION_STRATEGY=ManualSelectionStrategy" >> /etc/environment ; \
    fi

# Set up our config file (and config file override) components
COPY docker-entrypoint.sh /usr/local/bin/
COPY "configs/cantaloupe.properties.tmpl-${cantaloupe.version}" /etc/cantaloupe.properties.tmpl
COPY "configs/cantaloupe.properties.default-${cantaloupe.version}" /etc/cantaloupe.properties.default

# Set up a script to run Cantaloupe
COPY --chown=cantaloupe:users scripts/run_cantaloupe.sh /usr/local/bin/

RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe && \
    touch "$CONFIG_FILE" && \
    chown -R cantaloupe -L /var/log/cantaloupe /var/cache/cantaloupe "$CONFIG_FILE" \
      /usr/local/bin/docker-entrypoint.sh /usr/local/cantaloupe/

# Install grok JPEG-2000 library and tools
WORKDIR /tmp
ARG GROK_RELEASES="https://github.com/GrokImageCompression/grok/releases"
RUN curl -sL ${GROK_RELEASES}/download/v${grok.version}/grok-v${grok.version}-linux-amd64.tar.gz > grok.tar.gz && \
    tar zxfv grok.tar.gz && \
    cp ./grok-v${grok.version}-linux-amd64/bin/grk_* /usr/bin && \
    cp ./grok-v${grok.version}-linux-amd64/lib/*libgrok* /usr/lib && \
    cp -r ./grok-v${grok.version}-linux-amd64/include/grok* /usr/include && \
    rm -rf /tmp/grok-v${grok.version}-linux-amd64 grok-v${grok.version}-linux-amd64.tar.gz

# Set up logging, keeping a separate log for just the errors (in addition to the full log)
ENV CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_PATHNAME=/var/log/cantaloupe/application.log
ENV CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_PATHNAME=/var/log/cantaloupe/error.log

# Wrap things up with the entrypoint and command that the container runs
USER cantaloupe
WORKDIR /home/cantaloupe
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "sh", "-c", "exec /usr/local/bin/run_cantaloupe.sh" ]
