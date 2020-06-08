#!/bin/bash

#############################
#
# Script name: cPanel Domain and Golbal Memory Checker
# Version: 0.3
# Latest update: 07 06 2020
# Made by: Daniel Torma
#
# To do list:
# -
#
#############################

ycl=$(tput setaf 2) 
ncl=$(tput sgr0)
echo

for each in inherit ea-php54 ea-php55 ea-php56 ea-php70 ea-php71 ea-php72 ea-php73
do 
	printf "##------------------------------------------##\n## ${ycl}memory_limit${ncl} for ${ycl}%s${ncl} " $each
	if [ "$each" == "inherit" ]
		then printf "(${ycl}%s${ncl}): %s\n" $(/usr/local/cpanel/bin/rebuild_phpconf --current | awk 'NR==1{print $3}') $(grep ^memory_limit /opt/cpanel/$(/usr/local/cpanel/bin/rebuild_phpconf --current | awk 'NR==1{print $3}')/root/etc/php.ini | cut -d= -f2)
	else 
		printf "version: [${ycl}%s${ncl}]\n" $(grep ^memory_limit /opt/cpanel/$each/root/etc/php.ini | cut -d= -f2)
	fi

	printf "## domains with ${ycl}%s${ncl} PHP Version: \n##------------------------------------------##\n" $each

	for every in $(whmapi1 php_get_vhosts_by_version version=$each | sed -n '/ vhosts:/,/metadata:/p' | tail -n +2 | head -n -1 | awk '{printf "%s\n",$2}')
	do 
		printf -- "   %s\n" $every
		if [[ $(find $(grep ^$every /etc/userdatadomains | cut -d= -f9) -maxdepth 1 \( -name php.ini -o -name .user.ini -o -name .htaccess \) -exec grep -H memory_limit {} \;) ]]
		then
			printf "   -> found separate ${ycl}memory_limit${ncl} for [${ycl}$every${ncl}], printing results: \n"
				find $(grep ^$every /etc/userdatadomains | cut -d= -f9) -maxdepth 1 \( -name php.ini -o -name .user.ini -o -name .htaccess \) -exec grep -H memory_limit {} \; | awk '{printf "      %s\n",$0}'
			echo
		fi
	done
	echo
done