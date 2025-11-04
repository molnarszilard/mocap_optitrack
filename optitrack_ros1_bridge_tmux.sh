#!/bin/bash

# Create a new tmux session
session_name="optitrack_$(date +%s)"
tmux new-session -d -s $session_name

# Split the window into three panes
tmux selectp -t 0    # go back to the first pane
tmux splitw -h -p 50 # split it into two halves

# Run the teleop.py script in the second pane
tmux select-pane -t 0
tmux send-keys "useros1" Enter
tmux send-keys "source /home/rocon/catkin_ws_optitrack/devel/setup.bash" Enter
tmux send-keys "roslaunch mocap_optitrack mocap.launch" Enter

# Run the ros1_bridge on the last panel
tmux select-pane -t 1
tmux send-keys "useros1" Enter
tmux send-keys "useros2" Enter
# tmux send-keys "export ROS_MASTER_URI=http://localhost:11311" Enter
tmux send-keys "ros2 run ros1_bridge dynamic_bridge --bridge-all-topics" Enter

tmux select-pane -t 0

# Attach to the tmux session
tmux -2 attach-session -t $session_name

#### To kill it from another terminal run: tmux kill-server