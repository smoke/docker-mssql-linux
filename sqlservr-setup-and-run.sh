#!/bin/bash

ACCEPT_EULA=${ACCEPT_EULA:-}
SA_PASSWORD=${SA_PASSWORD:-}
configure=""
have_sa_password=""

# Check system memory
#
let system_memory="$(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024"

if [ $system_memory -lt 3250 ]; then
  echo "ERROR: This machine must have at least 3.25 gigabytes of memory to install Microsoft(R) SQL Server(R)."
  exit 1
fi

# Create system directories
#
mkdir -p /var/opt/mssql/data
mkdir -p /var/opt/mssql/etc
mkdir -p /var/opt/mssql/log

# Check the EULA
#
if [ "$ACCEPT_EULA" != "Y" ] && [ "$ACCEPT_EULA" != "y" ]; then
  echo "ERROR: You must accept the End User License Agreement before this container" > /dev/stderr
  echo "can start. The End User License Agreement can be found at " > /dev/stderr
  echo "http://go.microsoft.com/fwlink/?LinkId=746388." > /dev/stderr
  echo ""
  echo "Set the environment variable ACCEPT_EULA to 'Y' if you accept the agreement." > /dev/stderr
  exit 1
fi

# Configure SQL engine
#
if [ ! -f /var/opt/mssql/data/master.mdf ]; then
  configure=1

  if [ ! -z "$SA_PASSWORD" ]; then
    have_sa_password=1
  fi

  if [ -z "$have_sa_password" ]; then
    echo "ERROR: The system administrator password is not configured. You can set the" > /dev/stderr
    echo "password via environment variable (SA_PASSWORD)." > /dev/stderr
    exit 1
  fi
fi

# If we need to configure or reconfigure, run through configuration
# logic
#
if [ "$configure" == "1" ]; then
  echo 'Configuring Microsoft(R) SQL Server(R)...'
  /opt/mssql/bin/sqlservr-setup --accept-eula --set-sa-password
  echo "Configuration complete."
fi

# Start SQL Server
#
#gosu root /opt/mssql/bin/sqlservr $*
exec /opt/mssql/bin/sqlservr $*
