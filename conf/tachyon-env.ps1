#!/usr/bin/env bash

# This file contains environment variables required to run Tachyon. Copy it as tachyon-env.sh and
# edit that to configure Tachyon for your site. At a minimum,
# the following variables should be set:
#
# - JAVA_HOME, to point to your JAVA installation
# - TACHYON_MASTER_ADDRESS, to bind the master to a different IP address or hostname
# - TACHYON_UNDERFS_ADDRESS, to set the under filesystem address.
# - TACHYON_WORKER_MEMORY_SIZE, to set how much memory to use (e.g. 1000mb, 2gb) per worker
# - TACHYON_RAM_FOLDER, to set where worker stores in memory data


# Support for Multihomed Networks.
# You can specify a hostname to bind each of services. If a wildcard
# is applied, you should select one of network interfaces and use its hostname to connect the service.
# If no hostname is defined, Tachyon will automatically select an externally visible localhost name.
# The various possibilities shown in the following table:
#
# +--------------------+------------------------+---------------------+
# | TACHYON_*_HOSTNAME |  TACHYON_*_BIND_HOST   | Actual Connect Host |
# +--------------------+------------------------+---------------------+
# | hostname           | hostname               | hostname            |
# | not defined        | hostname               | hostname            |
# | hostname           | 0.0.0.0 or not defined | hostname            |
# | not defined        | 0.0.0.0 or not defined | localhost           |
# +--------------------+------------------------+---------------------+
#
# Configuration Examples:
#
# Environment variables for service bind
# TACHYON_MASTER_BIND_HOST=${TACHYON_MASTER_BIND_HOST:-$(hostname -A | cut -d" " -f1)}
# TACHYON_MASTER_WEB_BIND_HOST=${TACHYON_MASTER_WEB_BIND_HOST:-0.0.0.0}
# TACHYON_WORKER_BIND_HOST=${TACHYON_WORKER_BIND_HOST:-$(hostname -A | cut -d" " -f1)}
# TACHYON_WORKER_DATA_BIND_HOST=${TACHYON_WORKER_DATA_BIND_HOST:-$(hostname -A | cut -d" " -f1)}
# TACHYON_WORKER_WEB_BIND_HOST=${TACHYON_WORKER_WEB_BIND_HOST:-0.0.0.0}
#
# Environment variables for service connection
# TACHYON_MASTER_HOSTNAME=${TACHYON_MASTER_HOSTNAME:-$(hostname -A | cut -d" " -f1)}
# TACHYON_MASTER_WEB_HOSTNAME=${TACHYON_MASTER_WEB_HOSTNAME:-$(hostname -A | cut -d" " -f1)}
# TACHYON_WORKER_HOSTNAME=${TACHYON_WORKER_HOSTNAME:-$(hostname -A | cut -d" " -f1)}
# TACHYON_WORKER_DATA_HOSTNAME=${TACHYON_WORKER_DATA_HOSTNAME:-$(hostname -A | cut -d" " -f1)}
# TACHYON_WORKER_WEB_HOSTNAME=${TACHYON_WORKER_WEB_HOSTNAME:-$(hostname -A | cut -d" " -f1)}

# Uncomment this section to add a local installation of Hadoop to Tachyon's CLASSPATH.
# The hadoop command must be in the path to automatically populate the Hadoop classpath.
#
# if type "hadoop" > /dev/null 2>&1; then
#  export HADOOP_TACHYON_CLASSPATH=$(hadoop classpath)
# fi

$global:JAVA_HOME = $env:JAVA_HOME
$global:TACHYON_RAM_FOLDER = "$global:TACHYON_HOME/ram" <#TODO: imdisk mounted ram path #>

#TACHYON_JAVA_OPTS="-Djava.security.krb5.realm= -Djava.security.krb5.kdc="

$global:JAVA="$global:JAVA_HOME/java.exe"
$global:TACHYON_MASTER_ADDRESS = @{$true="localhost";$false=$global:TACHYON_MASTER_ADDRESS}[$global:TACHYON_MASTER_ADDRESS -eq $null]

$global:TACHYON_UNDERFS_ADDRESS = "/tmp"
$global:TACHYON_UNDERFS_ADDRESS = @{$true="hdfs://localhost:9000";$false=$global:TACHYON_UNDERFS_ADDRESS}[$global:TACHYON_UNDERFS_ADDRESS -eq $null]
$global:TACHYON_WORKER_MEMORY_SIZE = @{$true="1MB";$false=$global:TACHYON_WORKER_MEMORY_SIZE}[$global:TACHYON_WORKER_MEMORY_SIZE -eq $null]
$global:TACHYON_SSH_FOREGROUND = @{$true="yes";$false=$global:TACHYON_SSH_FOREGROUND}[$global:TACHYON_SSH_FOREGROUND -eq $null]
$global:TACHYON_WORKER_SLEEP = @{$true="0.02";$false=$global:TACHYON_WORKER_SLEEP}[$global:TACHYON_WORKER_SLEEP -eq $null]

# Prepend Tachyon classes before classes specified by TACHYON_CLASSPATH
# in the Java classpath.  May be necessary if there are jar conflicts
# $global:TACHYON_PREPEND_TACHYON_CLASSES = @{$true="yes";$false=$global:TACHYON_PREPEND_TACHYON_CLASSES}[$TACHYON_PREPEND_TACHYON_CLASSES -eq $null]

# Where log files are stored. $TACHYON_HOME/logs by default.
# $global:TACHYON_LOGS_DIR = @{$true="$global:TACHYON_HOME\logs";$false=$global:TACHYON_LOGS_DIR}[$TACHYON_LOGS_DIR -eq $null]

# Directory for log4j.properties file
$global:CONF_DIR = "C:/Users/tachyontest1/tachyon/conf"

#$global:TACHYON_JAVA_OPTS
$global:TACHYON_JAVA_OPTS_LOG4J = "-Dlog4j.configuration=file:/$global:CONF_DIR/log4j.properties"
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL_MAX = "-Dtachyon.worker.tieredstore.level.max=1"
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_ALIAS = "-Dtachyon.worker.tieredstore.level0.alias=MEM"
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_PATH = "-Dtachyon.worker.tieredstore.level0.dirs.path=$global:TACHYON_RAM_FOLDER"
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_QUOTA = "-Dtachyon.worker.tieredstore.level0.dirs.quota=$global:TACHYON_WORKER_MEMORY_SIZE"
$global:TACHYON_JAVA_OPTS_UNDERFS_ADDRESS = "-Dtachyon.underfs.address=$global:TACHYON_UNDERFS_ADDRESS"
$global:TACHYON_JAVA_OPTS_WORKER_MEMEORY_SIZE = "-Dtachyon.worker.memory.size=$global:TACHYON_WORKER_MEMORY_SIZE"
$global:TACHYON_JAVA_OPTS_MASTER_HOSTNAME = "-Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS"
$global:TACHYON_JAVA_OPTS_DISABLEJSR199 = "-Dorg.apache.jasper.compiler.disablejsr199=true"
$global:TACHYON_JAVA_OPTS_PREFERIPV4STACK = "-Djava.net.preferIPv4Stack=true"
#$global:TACHYON_JAVA_OPTS = "-Dlog4j.configuration=file:/$global:CONF_DIR/log4j.properties -Dtachyon.worker.tieredstore.level.max=1 -Dtachyon.worker.tieredstore.level0.alias=MEM -Dtachyon.worker.tieredstore.level0.dirs.path=$global:TACHYON_RAM_FOLDER -Dtachyon.worker.tieredstore.level0.dirs.quota=$global:TACHYON_WORKER_MEMORY_SIZE -Dtachyon.underfs.address=$global:TACHYON_UNDERFS_ADDRESS -Dtachyon.worker.memory.size=$global:TACHYON_WORKER_MEMORY_SIZE -Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS -Dorg.apache.jasper.compiler.disablejsr199=true -Djava.net.preferIPv4Stack=true"

# Master specific parameters. Default to TACHYON_JAVA_OPTS.
$global:TACHYON_MASTER_JAVA_OPTS = $global:TACHYON_JAVA_OPTS

# Worker specific parameters that will be shared to all workers. Default to TACHYON_JAVA_OPTS.
$global:TACHYON_WORKER_JAVA_OPTS = $global:TACHYON_JAVA_OPTS
