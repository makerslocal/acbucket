#!/bin/bash

# This script manages ac_mon.py

# Set local directory variable
if [ ! -d "$LOCAL_DIR" ]; then
	LOCAL_DIR="$( dirname "$( readlink -f "$0" )" )"
fi

#. $LOCAL_DIR/config

# Collect api keys
. $LOCAL_DIR/keys

# Setup virtualenv
#. $LOCAL_DIR/venv/bin/activate
#RET=$(python $LOCAL_DIR/ac_mon.py)
#echo "Return status: $RET"

sudo sh -c "echo 27 > /sys/class/gpio/export"
sudo sh -c "echo in > /sys/class/gpio/gpio27/direction"
VAL=$(sudo cat /sys/class/gpio/gpio27/value)
RET=$?
sudo sh -c "echo 27 > /sys/class/gpio/unexport"

echo "GPIO Value: ${VAL}, Return Value: ${RET}"

if [ $RET -eq 0 ] && [ $VAL -eq 0 ]; then
	MSG="Sensors indicate the Fabrication Laboratory's condensed humidity reservior has reached maximum capacity."
	curl --request POST \
	--url https://crump.space/rq-dev/api/v1.0/messages \
	--header 'content-type: application/json' \
	--data "{\"type\":\"command\",\"key\":\"${RQ_ML_KEY}\",\"destination\":\"rqirc\",\"data\":{\"channel\":\"##rqtest\",\"isaction\":false,\"message\":\"${MSG}\"}}"
fi

#write_msg "RQ" "$MSG"

#deactivate

function check_port {
echo "Checking $AVR_DEV against"
# Check that the right serial port is available
python -m serial.tools.list_ports | while read -r port
do
    echo "$port"
    if [ "$AVR_DEV" = "$port" ]; then
        # The right device exists, check's good
        python $LOCAL_DIR/ac_mon.py
        deactivate
        exit
    fi
done
}


