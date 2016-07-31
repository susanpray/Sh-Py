#!/bin/bash
export PATH=/bin:/usr/sbin:/usr/bin:$PATH
if [ $# -ne 3 ]
then
        echo "Invalid parameter count!"
        echo "Usage: $0 paramNTPServer1 paramNTPServer2 paramNTPServer3"
        exit 1;
fi


setNtp()
{  
   #server num
   num=$#
   if [ $num -eq 0 ]
   then
      echo "ERR"
	  return 1
   elif [ $num -gt 3 ]
   then
       num=3
   fi
   
   server[0]="$1"
   server[1]="$2"
   server[2]="$3"
   
	#if [ "x$1$2$3" == "x" ]
	#then
	#      echo "ERR"
	#	  return 1
	#   fi
   
   
  file="/etc/ntp.conf"
  tmp_file="/tmp/pdntp_$$.ntp"
  
  cat /dev/null > ${tmp_file}  
  tag=0
  while read line
  do
    if [ "${line:0:6}" == "server"  ]
	then
	   if [ $tag -eq 0 ]
	   then
	      
		  for ((i = 0; i < num; i++))
		  do
		    if [ "x${server[$i]}" != "x" ]
			then
				echo "server ${server[$i]}" >> ${tmp_file}
			fi
		  done 
		  
		  tag=1
	   fi
	     
    else
	    echo $line  >> ${tmp_file}
	
	fi
	
		 
  done < "${file}"
	
  #update ntp server info if not found 
  if [ "${tag}" -eq 0  ]
  then
	  for ((i = 0; i < num; i++))
	  do
	    if [ "x${server[$i]}" != "x" ]
		then
			echo "server ${server[$i]}" >> ${tmp_file}
		fi
	  done 
  fi
  
  cat  ${tmp_file} > ${file}
  rm -rf ${tmp_file} &> /dev/null
   
  #service
  service ntp restart &> /dev/null
  
  echo "OK"
  return 0

}


setNtp "$1" "$2" "$3"
