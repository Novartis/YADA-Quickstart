#!/bin/bash 
#
# Copyright 2016 Novartis Institutes for BioMedical Research Inc.
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


#set -x

DEPLOY_USER=${deploy.user}
DEPLOY_PASS=${deploy.pass}
DEPLOY_HOST=${deploy.host}
DEPLOY_PORT=${deploy.port}
DEPLOY_URL=${deploy.url}
BUILD_DIR=${project.build.directory}
CONTEXT=${project.build.finalName}
WAR=${CONTEXT}.war
USER=${deploy.unix.user}
KEYFILE=${keyfile}
LOGIN="-i ${KEYFILE} ${USER}@${DEPLOY_HOST}"
ENV=${env}
HOME=${deploy.app.base}/${env}
TOMCAT_HOME=${HOME}/tomcat
TOMCAT_LOGS=${TOMCAT_HOME}/logs
TOMCAT_BIN=${TOMCAT_HOME}/bin
DATE=`date +%Y-%m-%d`
TMPFILE=/tmp/probe.out
TIME=0
STATUS=0

RESTART=script   # alt: service   
DEPLOY=psiprobe  # alt: scp, cp
SUDO=''          # alt: true      

while getopts r:d:s OPT
do
  case $OPT in
  r)
    RESTART=$OPTARG;
    echo "RESTART=$RESTART"
    ;;
  d)
    DEPLOY=$OPTARG;
    echo "DEPLOY=$DEPLOY"
    ;;
  s)
    SUDO='sudo ';
    echo "SUDO=true"
    ;;
  *)
    exit;
    ;;
  esac
done

# deploy the app via psiprobe and monitor completion
psiprobeDeploy() {
  printf "\nRedeploying webapp via psiprobe..."
  if [ -e ${TMPFILE} ]; then
   rm ${TMPFILE}
  fi

  curl -s --basic -u ${DEPLOY_USER}:${DEPLOY_PASS} \
-F "war=@${BUILD_DIR}/${WAR};filename=${WAR}" \
-F "context=/ROOT" \
-F "update=yes" \
-F "discard=yes" \
-F "compile=yes" \
${DEPLOY_URL} > ${TMPFILE} &

  while [ ! -s ${TMPFILE} ]
  do
    printf .
    sleep 1
  done

  if [ -s ${TMPFILE} ] && [ `grep -c "has been deployed" ${TMPFILE}` -eq 1 ]; then
    printf ""
    STATUS=1
  else
    printf "\nThere was a problem deploying the webapp. Maybe try again?\n"
    exit 1
  fi
}

scpDeploy() {
  scp -i ${KEYFILE} ${BUILD_DIR}/${WAR} ${USER}@${DEPLOY_HOST}:${TOMCAT_HOME}/webapps
  STATUS=1
}

cpDeploy() {
  ${SUDO}cp ${BUILD_DIR}/${WAR} ${TOMCAT_HOME}/webapps
  STATUS=1
}

scriptRestart() {
  set -f
  CMD_ENV=local
  CMD_SHUTDOWN="${SUDO}${TOMCAT_BIN}/shutdown.sh"
  CMD_PGREP="${SUDO}pgrep -f -u $USER catalina.*${HOME}"
  CMD_PKILL="${SUDO}pkill -f -u $USER catalina.*${HOME}"
  CMD_STARTUP="${SUDO}${TOMCAT_BIN}/startup.sh"
  
  CMD_LOG=${TOMCAT_LOGS}/catalina.${DATE}.log
  CMD_GREP="grep -c \"Server startup in .* ms\""
  CMD_TAILGREP="${SUDO}tail -1 ${CMD_LOG}|${CMD_GREP}"
  
  if [ 'localhost' != ${DEPLOY_HOST} ]; then
    CMD_ENV=remote
    CMD_SHUTDOWN="ssh ${LOGIN} ${CMD_SHUTDOWN}"
    CMD_PGREP="ssh ${LOGIN} ${CMD_PGREP}"
    CMD_PKILL="ssh ${LOGIN} ${CMD_PKILL}"
    CMD_STARTUP="ssh ${LOGIN} ${CMD_STARTUP}"
    CMD_TAILGREP="ssh ${LOGIN} ${CMD_TAILGREP}"
  fi
  
  # execute shutdown
  printf "\nShutting down ${CMD_ENV} tomcat..."
  if [ 0 -lt 0`${CMD_PGREP}` ]; then 
    ${CMD_SHUTDOWN}
  fi
  
  # wait for shutdown
  while [ 0 -lt 0`${CMD_PGREP}` ]
  do 
    printf .
    sleep 1
    TIME=$((TIME+1))
    # kill the process after 1 minute
    if [ 59 -lt ${TIME} ]; then 
      printf "\nWaited 1 minute. Killing proc..."
      ${CMD_PKILL}
    fi
  done
  
  # execute startup
  printf "\nStarting ${CMD_ENV} tomcat..."
  ${CMD_STARTUP}
  
  # wait for startup
  while [ $(eval ${CMD_TAILGREP}) -ne 1 ] 
  do 
    printf .
    sleep 1
  done
  printf "\nStartup complete.\n\n"
  set +f
}


serviceRestart() {
  set -f
  CMD_ENV=local
  CMD_RESTART="${SUDO}service tomcat7 restart"
  CMD_GREP="grep -c \"OK\""
  STATUS="${SUDO}service tomcat7 status"
  if [ 'localhost' != ${DEPLOY_HOST} ]; then
    CMD_ENV=remote
    CMD_RESTART="ssh ${LOGIN} ${CMD_RESTART}" 
    STATUS="ssh ${LOGIN} ${STATUS}"
  fi
  CMD_STATGREP="${STATUS}|${CMD_GREP}"
  
  printf "\nRestarting ${CMD_ENV} tomcat..."
  eval ${CMD_RESTART}
  while [ $(eval ${CMD_STATGREP}) -ne 1 ]; do
     printf .
  done
  printf "\nStartup complete.\n\n"
  set +f
}


if [ 'psiprobe' == "$DEPLOY" ]; then
  psiprobeDeploy
else 
  if [ 'localhost' == "${DEPLOY_HOST}" ]; then
    cpDeploy
  else
    scpDeploy     
  fi
fi

if [ "${STATUS}" -eq 1 ]; then
	if [ 'script' == "${RESTART}" ]; then
	  scriptRestart
	else
	  serviceRestart
  fi
fi