#!/bin/bash

echo "NOTE: to detach again use CTRL + B followed by D"

# When you've reattached, do not use CTRL + C, because that will kill the server.
# Instead use CTRL + B followed by D to detach from the server again.
tmux attach -t srcds
