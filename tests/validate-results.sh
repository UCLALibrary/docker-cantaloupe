#! /bin/bash

# Color hints for alerts and messages
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

# An informational message in case a test fails
die () {
  local message=$1
  echo ""
  printf "${RED}Tests failed!${NC}\n"
  echo ""
  echo "$message" >&2

  if [ "$TRAVIS" != 'true' ]; then
    printf "  ${GREEN}To clean up the testing container, run:${NC}\n"
    echo "    docker rm -f \"$container_id\""
    echo ""
    printf "  ${GREEN}To clean up all system containers, run:${NC}\n"
    echo "    docker rm -f \$(docker ps -a -q)"
    echo ""
  fi

  exit $2
}

# These are the actual tests we run

container_id="$(cat $1)"
echo "starting tests with container_id=${container_id} ..."

#smoke test, this will die if the container doesn't start up or if /etc/cantaloupe.properties doesn't exist in the container
echo "smoke test..."
if docker exec --tty "${container_id}" env TERM=xterm ls /etc/cantaloupe.properties > /dev/null 2>&1
then
  echo "...passed"
else
  die "container id $container_id failed to start" "$?"
fi

# verify that port 8182 is exposed in the container, NOTE this doesn't guarantee anything is listening
echo "is port 8182 exposed on container_id=${container_id} ?..."
exposed_ports="$(docker inspect --format='{{range $p, $conf := .Config.ExposedPorts}} {{$p}} {{end}}' $container_id)"
if [[ "${exposed_ports}" =~ '8182' ]]
then
  echo "...passed"
else
  die "port 8182 is not exposed in container_id $container_id" "$?"
fi

echo "is port 8182 listening on localhost ?..."
portListeningLocalhost=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8182)
# verify port 8182 is listening on the host
echo "portListeningLocalhost=$portListeningLocalhost"
if [ "${portListeningLocalhost}" == "200" ]
then
  echo "...passed"
else
  die "port 8182 is not listening on localhost" "$?"
fi


printf "${GREEN}Tests ran successfully!${NC}\n"
