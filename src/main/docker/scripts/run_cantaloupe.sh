#! /bin/bash

if [ -f /usr/local/cantaloupe/delegate.jar ]; then
  DELEGATE_JAR=":/usr/local/cantaloupe/delegate.jar"
fi

CANTALOUPE_JAR=$(ls /usr/local/cantaloupe/cantaloupe-*.jar)

# A Cantaloupe startup script that uses ENV properties to configure the application
java -Dcantaloupe.config="${CONFIG_FILE}" -XX:MaxRAMPercentage="${HEAP_PERCENTAGE}" \
  -cp "${CANTALOUPE_JAR}${DELEGATE_JAR}" edu.illinois.library.cantaloupe.StandaloneEntry
