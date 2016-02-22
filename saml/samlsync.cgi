#!/bin/bash
#Author: M.P Nadar
#Date: 08th Sep 2015
#Purpose: SAML Metadata Publish



echo "Content-type: text/html"
echo ""
#echo "<html><head><title>Welcome</title></head>"
#echo "<body>"
#echo "Welcome to SAML Metadata Publish"

echo "<html>"
echo "<head><title>LRN SAML Metadata Publish</title></head>"
echo "<body>"
echo "<blockquote>"
echo "<table width="90%" border=0>"
echo "<tr>"
  echo "<td align="left" valign="middle"><img src="lrn.gif" border=0></td>"
  echo "<td align="right" valign="middle"><img src="saml.gif"></td>"
echo "</tr>"
echo "</table>"
echo "<hr>"

if ps ax | grep -v grep | grep sshtunnel > /dev/null
then
    :
else
    
    ssh -L 9124:10.101.2.124:22 -L 9125:10.101.2.125:22 sshtunnel@10.1.102.171 -N&
fi

PARTNER=$(echo "$QUERY_STRING" | sed -n 's/^.*partnername=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" )
ENVIRON=$(echo "$QUERY_STRING" | sed -n 's/^.*environ=\([^&]*\).*$/\1/p' | sed "s/%20/ /g" )

if [ -z $PARTNER ]
then
	echo "Partner Name cannot be empty"
	exit
fi

echo "[root@laxco5srv01 ~]# /usr/local/bin/p4 sync //depot/lcec/saml_idp_metadata/prod/$PARTNER/metadata.xml"
echo "<br>"
SAML1=$(ssh -tt -i /var/tmp/id_rsa -p9124 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null sshtunnel@127.0.0.1 "sudo /usr/local/bin/p4 sync //depot/lcec/saml_idp_metadata/prod/$PARTNER/metadata.xml" )

echo "$SAML1"

echo "<br><br>"

echo "[root@laxco5srv02 ~]# /usr/local/bin/p4 sync //depot/lcec/saml_idp_metadata/prod/$PARTNER/metadata.xml"

SAML2=$(ssh -tt -i /var/tmp/id_rsa -p9125 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null sshtunnel@127.0.0.1 "sudo /usr/local/bin/p4 sync //depot/lcec/saml_idp_metadata/prod/$PARTNER/metadata.xml" )

echo "<br>"

echo "$SAML2"

echo "<br><br><br>"

echo "MP Nadar - LRN"
echo "</body>"

echo "</html>"
