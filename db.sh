#!/bin/bash
path=/backup2/db
date=$(date +%m%d%Y)
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`
bold=`tput bold`

echo "${bold}Backup started @ $(date)"
echo " "
echo "Create a list of all active mysql databases.${reset}"
mysql -u root --execute='show databases;' > /tmp/db_list
sed '1d' /tmp/db_list > /tmp/db_list2
cat /tmp/db_list2 |\
while read name
do
if [ $name == "performance_schema" ]; then
echo ${yellow}$name ... skip..
elif [ $name == "information_schema" ]; then
echo $name ... skip..${reset}
else
mkdir -p $path/sql
echo -n ${bold} Backup database $name to ${reset} $path/sql/$name.sql ...
mysqldump -u root $name > $path/sql/$name.sql
echo ${green}done!${reset}
fi
done
#echo " "
#echo -n "${bold}Copy to AWS ..... ${reset}"
#echo " "
#/root/s3cmd-1.6.1/s3cmd --access_key=AKIAIWESRGSK25YB6TDQ --secret_key=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 sync $path/sql/ s3://vps10rackspace/db/
#echo " ${green}Done!${reset}"
echo " "
echo -n "${bold}Compressing ..... ${reset}"
tar -zcf $path/$date.tgz -P $path/sql
echo "${green}done!${reset}"
echo -n "${bold}Deleting temp files ... ${reset}"
rm -Rf $path/sql
echo "${green}done!${reset}"
echo " "
##delete old backup files
cd $path && find . -type f -ctime +4 -exec rm -f {} \;

echo "${bold}Backup finished @ $(date)${reset}"
