#!/bin/bash

. /etc/profile

case $1 in
    "start")
        $PRODUCT_HAWK_ROOT/script/soc_control.sh $1;;
     "stop")
        $PRODUCT_HAWK_ROOT/script/soc_control.sh $1;;
   "restart")
        $PRODUCT_HAWK_ROOT/script/soc_control.sh $1;;
          *)
        echo "Usage:
                     service soc_service {start|stop|restart|status}"
        ;;
esac

#End Script
