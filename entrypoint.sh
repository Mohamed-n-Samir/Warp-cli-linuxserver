#!/bin/bash

(
# 1. First, just wait for the daemon to wake up and respond to a basic status check
while ! warp-cli --accept-tos status > /dev/null 2>&1; do
	sleep 1
	>&2 echo "Awaiting warp-svc to become online..."
done

# 2. Check if we actually need a new registration
if warp-cli --accept-tos status | grep -q "Registration missing"; then
	echo "No registration found. Registering new device..."
	warp-cli --accept-tos registration new
	
	if [ "$LICENSE" != "" ]; then
		warp-cli --accept-tos registration license "$LICENSE"
	fi
else
	echo "Device is already registered. Skipping setup."
fi

# 3. Apply standard settings and connect
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40001
warp-cli --accept-tos connect

# 4. Start the port forwarder
socat TCP-LISTEN:40000,fork TCP:localhost:40001
) &

exec warp-svc

