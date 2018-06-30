#!/usr/bin/env bash

#################################
#     ISPProtect Web Scanner    #
# (c) 2015-2016 by John Modica  #
#        @ CybernetiX S3C       #
#      all rights reserved      #
#################################

CDIR="$PWD" ;
SELF=`readlink $0` ;
if [[ "$SELF" == "" ]] ; then
	SELF="$0" ;
fi
SYSTYPE=`uname` ;
if [[ "$SYSTYPE" == "FreeBSD" ]] ; then
	DIR=$(realpath $(dirname ${SELF})) ;
else
	DIR=`readlink -e $(dirname ${SELF})` ;
fi
ARCH=`uname -m` ;
if [[ "$ARCH" == "amd64" ]] ; then
	ARCH="x86_64" ; 
fi
IODIR="${DIR}/ioncube" ;

FIRSTARG="$1"

NO_ROOT="0"
NO_OUT="0"
NO_IONCUBE="0"
for tmpv in "$@" ; do
	if [[ "$tmpv" == "--update" || "$tmpv" == "--version" || "$tmpv" == "--json-out" ]] ; then
		NO_OUT="1" ;
	elif [[ "$tmpv" == "--no-root" ]] ; then
		NO_ROOT="1" ;
	elif [[ "$tmpv" == "--no-ioncube" ]] ; then
		NO_IONCUBE="1" ;
	fi
done

ISPPVER="1.24.9"

if [[ "$NO_OUT" != "1" ]] ; then

echo "       _____  _____ _____  _____           _            _       " ;
echo "      |_   _|/ ____|  __ \|  __ \         | |          | |      " ;
echo "        | | | (___ | |__) | |__) | __ ___ | |_ ___  ___| |_     " ;
echo "        | |  \___ \|  ___/|  ___/ '__/ _ \| __/ _ \/ __| __|    " ;
echo "       _| |_ ____) | |    | |   | | | (_) | ||  __/ (__| |_     " ;
echo "      |_____|_____/|_|    |_|   |_|  \___/ \__\___|\___|\__|    " ;
echo " __          __  _        _____                                 " ;
echo " \ \        / / | |      / ____|                                " ;
echo "  \ \  /\  / /__| |__   | (___   ___ __ _ _ __  _ __   ___ _ __ " ;
echo "   \ \/  \/ / _ \ '_ \   \___ \ / __/ _\` | '_ \| '_ \ / _ \ '__|" ;
echo "    \  /\  /  __/ |_) |  ____) | (_| (_| | | | | | | |  __/ |   " ;
echo "     \/  \/ \___|_.__/  |_____/ \___\__,_|_| |_|_| |_|\___|_|   " ;
echo "                                                                " ;
echo "                                              Version ${ISPPVER}    " ;
echo "" ;
echo "                 (c) 2015-$(date +%Y) by John Modica            " ;
echo "                        @ CybernetiX S3C                        " ;
echo "                       all rights reserved                      " ;
echo "" ;
echo "" ;

fi

if [[ "$PHP" == "" ]] ; then
	PHP=`which php` ;
	if [[ "$PHP" == "" ]] ; then
		if [[ "$NO_OUT" != "1" ]] ; then
			echo "Missing PHP binary!" ;
		fi
		exit 1;
	fi
fi

CLAM=`which clamscan` ;
if [[ "$CLAM" != "" || "$@" =~ "--no-malware-scan" ]] ; then
	if [[ "$NO_OUT" != "1" ]] ; then
		echo -n "";
	fi
else
	if [[ "$NO_OUT" != "1" ]] ; then
		echo "Please install clamav (clamscan binary)!" ;
	fi
	exit 1;
fi

if [[ "$NO_ROOT" != "1" && "$(id -u)" != "0" ]] ; then
	if [[ "$NO_OUT" != "1" ]] ; then
		echo "Please run ISPProtect Web Scanner as root.";
	fi
	exit 1;
fi

PHPVERSION=`$PHP -v 2>/dev/null | head -n 1 | awk '{print $2}' | awk -F'.' '{print $1"."$2}'` ;

if [[ "$PHPVERSION" == "" ]] ; then
	if [[ "$NO_OUT" != "1" ]] ; then
		echo "Could not get PHP version.";
	fi
	exit 1;
fi

rm -f ${DIR}/ispp_php.ini ;

SSLCHK=$($PHP -i | grep -E -i 'OpenSSL[[:space:]]+support.+enabled');

echo "disable_functions=" >> ${DIR}/ispp_php.ini
echo "max_execution_time=0" >> ${DIR}/ispp_php.ini
echo "memory_limit=2048M" >> ${DIR}/ispp_php.ini

IONCHK=$($PHP -n -c ${DIR}/ispp_php.ini -q -v | grep -E -i 'ionCube.+Loader');
TSCHK=$($PHP -n -c ${DIR}/ispp_php.ini -i | grep -E -i 'Thread[[:space:]]+safety.+enabled');
if [[ "$SSLCHK" != "" ]] ; then
	SSLCHK=$($PHP -n -c ${DIR}/ispp_php.ini -i | grep -E -i 'OpenSSL[[:space:]]+support.+enabled');
	if [[ "$SSLCHK" == "" ]] ; then
		echo "extension=openssl.so" >> ${DIR}/ispp_php.ini
	fi
fi

for M in "curl" "json" "mcrypt" "mysqlnd" "mysqli" "simplexml" "mbstring" "zlib" ; do
	SUPP="" ;
	if [[ "$M" == "mbstring" ]] ; then
		SUPP="${M}[[:space:]]+extension" ;
	elif [[ "$M" != "mysqlnd" ]] ; then
		SUPP="${M}[[:space:]]+support.+enabled" ;
	else
		SUPP="${M}[[:space:]]+.+enabled" ;
	fi
	
	MODCHK=$($PHP -i 2>/dev/null | grep -E -i "${SUPP}");
	if [[ "$MODCHK" != "" ]] ; then
		MODCHK=$($PHP -n -c ${DIR}/ispp_php.ini -i 2>/dev/null | grep -E -i "${SUPP}");
		if [[ "$MODCHK" == "" ]] ; then
			echo "extension=${M}.so" >> ${DIR}/ispp_php.ini
		fi
	fi
done

SYSVER="" ;

if [[ "${IONCHK}" == "" && "${NO_IONCUBE}" != "1" ]] ; then
	USETS="";
	if [[ "$TSCHK" != "" ]] ; then
		USETS="_ts" ;
	fi
	if [[ "$SYSTYPE" == "FreeBSD" ]] ; then
		IOFILE="${IODIR}/ioncube_loader_fre_${PHPVERSION}${USETS}.so" ;
	else
		IOFILE="${IODIR}/ioncube_loader_lin_${PHPVERSION}${USETS}.so" ;
	fi
	
	if [[ ! -d "$IODIR" || ! -f "$IOFILE" ]] ; then
		if [[ "$NO_OUT" != "1" ]] ; then
			echo "Downloading ionCube Loader for your system."
		fi
		if [[ "$SYSTYPE" == "FreeBSD" ]] ; then
			SYSVER=`uname -r` ;
			SYSVER="${SYSVER%%.*}" ;
			
			if [[ "$ARCH" == "x86_64" ]] ; then
				wget -o /dev/null -O ${DIR}/ioncube.tar.gz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_fre_${SYSVER}_x86-64.tar.gz" ;
			else
				wget -o /dev/null -O ${DIR}/ioncube.tar.gz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_fre_${SYSVER}_x86.tar.gz" ;
			fi
		else
			if [[ "$ARCH" == "x86_64" ]] ; then
				wget -o /dev/null -O ${DIR}/ioncube.tar.gz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" ;
			else
				wget -o /dev/null -O ${DIR}/ioncube.tar.gz "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz" ;
			fi
		fi
		cd ${DIR} ;
		tar xzf ioncube.tar.gz ;
		rm -f ioncube.tar.gz ;
		cd ${CDIR} ;
	fi
	
	if [[ ! -e "$IOFILE" ]] ; then
		if [[ "$NO_OUT" != "1" ]] ; then
			echo "The needed ionCube Loader for PHP ${PHPVERSION} could not be found in ${IODIR}.";
			echo "Please check that ${IOFILE} is there." ;
		fi
		exit 1 ;
	else
		if [[ "$NO_OUT" != "1" ]] ; then
			echo "ionCube Check succeeded." ; 
		fi
	fi

	echo "zend_extension=${IOFILE}" >> ${DIR}/ispp_php.ini
	if [[ -e "${DIR}/ispp_php.ini.local" ]] ; then
		echo "" >> ${DIR}/ispp_php.ini
		cat "${DIR}/ispp_php.ini.local" >> ${DIR}/ispp_php.ini
	fi
else
	if [[ -e "${DIR}/ispp_php.ini.local" ]] ; then
		echo "" >> ${DIR}/ispp_php.ini
		cat "${DIR}/ispp_php.ini.local" >> ${DIR}/ispp_php.ini
	fi
	IONVCHK=$($PHP -n -c ${DIR}/ispp_php.ini -q -r "print (function_exists('ioncube_loader_version') && version_compare(ioncube_loader_version(), '6.0', '>=') ? '1' : '0');");
	if [[ "${IONCHK}" != "" && "$NO_OUT" != "1" ]] ; then
		echo "ionCube already active in PHP." ; 
	fi

	if [[ "$IONVCHK" != "1" ]] ; then
		if [[ "$NO_OUT" != "1" ]] ; then
			echo "ionCube version missing or outdated. Please install ionCube >= 6.0" ; 
			exit 1;
		fi
	fi
fi

LEGACY="" ;
if [[ "$PHPVERSION" == "7.1" ]] ; then
	LEGACY="/v71" ;
elif [[ "$PHPVERSION" == "7.0" || "$PHPVERSION" == "5.6" ]] ; then
	LEGACY="/v56" ;
elif [[ "$PHPVERSION" == "5.5" ]] ; then
	LEGACY="/v55" ;
elif [[ "$PHPVERSION" == "5.4" ]] ; then
	LEGACY="/v54" ;
elif [[ "$PHPVERSION" == "5.3" ]] ; then
	LEGACY="/v53" ;
else
	echo "You are using an unsupported PHP version (${PHPVERSION})." ;
	exit 1;
fi

if [[ "$COLUMNS" == "" && -e "/usr/bin/tput" && "$TERM" != "" ]] ; then
	COLUMNS=`tput cols 2>/dev/null`;
fi

export COLUMNS ;

if [[ "$FIRSTARG" == "--system-report" ]] ; then
	REPFILE="${DIR}/system_report.txt" ;
	echo "[ispprotect]" > $REPFILE ;
	echo "install.path = ${DIR}" >> $REPFILE ;
	echo "install.ioversion = ${LEGACY}" >> $REPFILE ;
	echo "install.version = ${ISPPVER}" >> $REPFILE ;
	echo "[system]" >> $REPFILE ;
	echo "system.kernel = $(uname -a)" >> $REPFILE ;
	echo "system.architecture = ${ARCH}" >> $REPFILE ;
	echo "[php]" >> $REPFILE ;
	echo "php.binary = ${PHP}" >> $REPFILE ;
	echo "[ioncube]" >> $REPFILE ;
	$PHP -n -c ${DIR}/ispp_php.ini -q -v | grep -E -i 'ionCube.+Loader' >> $REPFILE ;
	echo "[phpinfo]" >> $REPFILE ;
	$PHP -n -c ${DIR}/ispp_php.ini -q -i >> $REPFILE ;
	echo "Report dumped to $REPFILE";
	exit 0;
fi

if [[ "$COLUMNS" == "" && -e "/bin/stty" ]] ; then COLUMNS=$(stty size 2>/dev/null | awk '{print $2}' 2>/dev/null) ; fi
export COLUMNS ;

$PHP -n -c ${DIR}/ispp_php.ini -q ${DIR}${LEGACY}/ispp_scan.php "$@";
RET=$? ;

cd $CDIR ;
exit $RET ;
