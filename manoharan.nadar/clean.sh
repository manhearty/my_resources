#!/bin/bash

#####################################################
#Author: MP Nadar                                   #
#Purpose: Clean Up Users home directory             #     
#Date: 14th Dec 2015                                # 
#####################################################

#VARIABLES
DATE=$(date +%Y%m%d)
#2APREVIEW='lcec/2apreview/...#0'
#2ACONTENT='lcec/2acontent/...#0'
#CONTN_SRC='lcec/content_source/...#0'
LOG_DIR="/var/log/chantcleanup"
DATE_DIR="${LOG_DIR}/${DATE}"

#CREATE NEW USER DB EVERYTIME
ls /home | egrep -v '(http)' > /home/manoharan.nadar/user.txt

counter=$(wc -l /home/manoharan.nadar/user.txt | awk '{ print $1}')


#CREATE HTML FILES
rm -f /lcec/share/main_body.html
cp /home/manoharan.nadar/bk_body.html /lcec/share/main_body.html
rm -f /lcec/share/status.txt

#MAIN

mkdir -p $DATE_DIR

   while read line
   do
    
    
    WORKSPACE="${line}-deves4lws02"
    USR_DIR="${DATE_DIR}/${line}"
    mkdir -p $USR_DIR
	
     if finger | grep $line > /dev/null
     then
	echo "User $line logged in. Cannot clean up!" >> ${DATE_DIR}/cannot_cleanup.log
        let counter--
        sed -i "50i <tr><td> `echo $counter` </td><td><b>$line</b></td><td><b>SKIPPED</b></td><td><b>SKIPPED</b></td></tr>" /lcec/share/main_body.html
	continue
     fi

      #SIZE BEFORE CLEAN UP	
      #echo -n "before:" 
      #du -sh /home/${line}  | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      #{ echo "Before:" ; du -sh /home/${line}; } | tr "\n" " " | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      bef=$(du -sh /home/${line} | awk '{print $1}' )
      if [ -z "${bef}" ]; then
         bef=0
      fi
      #echo " " | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      #passwd -l $line
      #echo "User $line account locked for clean up"  >>  ${USR_DIR}/cleanup.log

      echo " " >>  ${USR_DIR}/cleanup.log
      echo "Running clean up" >>  ${USR_DIR}/cleanup.log

      /sbin/runuser -l $line -c "/usr/local/bin/p4 sync -f //${WORKSPACE}/lcec/2apreview/...#0" >>  ${USR_DIR}/cleanup.log
      /sbin/runuser -l $line -c "/usr/local/bin/p4 sync -f //${WORKSPACE}/lcec/2acontent/...#0" >>  ${USR_DIR}/cleanup.log
      /sbin/runuser -l $line -c "/usr/local/bin/p4 sync -f //${WORKSPACE}/lcec/content_source/...#0" >>  ${USR_DIR}/cleanup.log

      #SIZE AFTER CLEAN UP
      #echo -n "after:"
      echo " " >>  ${USR_DIR}/cleanup.log
      #du -sh /home/${line} | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      #{ echo "After:" ; du -sh /home/${line}; } | tr "\n" " " | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      #echo " " | tee -a ${USR_DIR}/cleanup.log ${DATE_DIR}/diskutilization.log
      aft=$(du -sh /home/${line} | awk '{print $1}' )
      if [ -z "${aft}" ]; then
         aft=0
      fi
 

      sed -i "50i <tr><td> `echo $counter` </td><td><b>$line</b></td><td><b>$bef</b></td><td><b>$aft</b></td></tr>" /lcec/share/main_body.html

      let counter--
      #CLEAN-UP 30 Days old clean-up log
      find ${USR_DIR} -name '*.log' -mtime +30 -exec rm {} \;


    done < /home/manoharan.nadar/user.txt

echo "completed" > /lcec/share/status.txt


#END
