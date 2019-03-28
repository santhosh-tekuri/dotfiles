export JDEBUG='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address'
export JSUSPEND='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address'

function java_home(){
	/usr/libexec/java_home -v $1
}

if /usr/libexec/java_home -v 1.6 >/dev/null 2>&1; then
    export JAVA6_HOME=`/usr/libexec/java_home -v 1.6`
fi
if /usr/libexec/java_home -v 1.7 >/dev/null 2>&1; then
    export JAVA7_HOME=`/usr/libexec/java_home -v 1.7`
    export JAVA_HOME=$JAVA7_HOME
fi
if /usr/libexec/java_home -v 1.8 >/dev/null 2>&1; then
    export JAVA8_HOME=`/usr/libexec/java_home -v 1.8`
fi

function java6(){
    export JAVA_HOME=$JAVA6_HOME
}

function java7(){
    export JAVA_HOME=$JAVA7_HOME
}

function java8(){
    export JAVA_HOME=$JAVA8_HOME
}

