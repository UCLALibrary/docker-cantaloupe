#!/usr/bin/env bash

# Define locations of our container's property values
PROPERTIES_TMPL=/etc/cantaloupe/cantaloupe.properties.tmpl
PROPERTIES_DEFAULT=/etc/cantaloupe/cantaloupe.properties.default

# Define location of centralized maven repository
MAVEN_REPO="https://repo1.maven.org/maven2"

# Find the python application on our system
PYTHON=$(which python2)

# Load /etc/environment properties so they're also included in our properties file
for env in $(cat /etc/environment); do export $(echo $env | sed -e 's/"//g'); done

# Create properties file from defaults and environment
read -d '' SCRIPT <<- EOT
import os,string,ConfigParser,StringIO;
template=string.Template(open('$PROPERTIES_TMPL').read());
config = StringIO.StringIO()
config.write('[cantaloupe]\n')
config.write(open('$PROPERTIES_DEFAULT').read())
config.seek(0, os.SEEK_SET)
config_parser = ConfigParser.ConfigParser()
config_parser.optionxform = str
config_parser.readfp(config)
properties = dict(config_parser.items('cantaloupe'))
properties.update(os.environ)
print(template.safe_substitute(properties))
EOT

# Write our merged properties file to /etc directory
$PYTHON -c "$SCRIPT" >> $CONFIG_FILE

# If we have a DELEGATE_URL, grab it and copy it to the container for us to use
if [[ -v DELEGATE_URL && ! -z DELEGATE_URL ]]; then
  if [[ "${DELEGATE_URL}" == *rb ]]; then
    curl -s "${DELEGATE_URL}" > /usr/local/cantaloupe/delegates.rb
    chown cantaloupe /usr/local/cantaloupe/delegates.rb
  elif [[ "${DELEGATE_URL}" == *jar ]]; then
    curl -s "${DELEGATE_URL}" > /usr/local/cantaloupe/delegate.jar
  fi
fi

# If LOGBACK_URL is defined, download and insert logback.xml file into war file
if [[ ! -z "${LOGBACK_URL}" ]]; then
  zip -qd /usr/local/cantaloupe/cantaloupe-*.*ar WEB-INF/classes/logback.xml
  cd /tmp
  mkdir -p WEB-INF/classes WEB-INF/lib
  curl -so WEB-INF/classes/logback.xml ${LOGBACK_URL}

  # Package up the logback file and dependent jars
  zip -qur /usr/local/cantaloupe/cantaloupe-*.*ar WEB-INF

  # Clean up scratch space
  rm -rf /tmp/WEB-INF
fi

# Replaces parent process so signals are processed correctly
exec "$@"
