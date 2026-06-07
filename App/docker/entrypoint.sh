#!/bin/sh
set -e

echo "================================================================================"
echo " Starting BankPro Application Container"
echo " Active Profile : ${SPRING_PROFILES_ACTIVE}"
echo " Java Options   : ${JAVA_OPTS}"
echo "================================================================================"

# Execute Java with specified JVM arguments and pass application arguments
exec java ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom -jar app.jar "$@"
