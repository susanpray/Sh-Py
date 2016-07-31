#!/bin/bash

. /etc/profile

${PRODUCT_HAWK_ROOT}/restapi/bin/polydata_api.sh restart

${PRODUCT_HAWK_ROOT}/service/apt_gui.sh restart




