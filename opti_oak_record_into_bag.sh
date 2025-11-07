#!/bin/bash

# Create a new tmux session
session_name="record_bag_$(date +%s)"
tmux new-session -d -s $session_name

# Split the window into three panes
tmux selectp -t 0    # select the first (0) pane
tmux splitw -v -p 50 # split it into two halves
tmux selectp -t 0
tmux splitw -h -p 50
tmux selectp -t 1
tmux splitw -h -p 50
tmux selectp -t 3
tmux splitw -h -p 50
tmux selectp -t 3
tmux splitw -h -p 50


# Run the optitrack node
tmux select-pane -t 0
tmux send-keys "useros1" Enter
tmux send-keys "source /home/rocon/catkin_ws_optitrack/devel/setup.bash" Enter
tmux send-keys "roslaunch mocap_optitrack mocap.launch" Enter

# Run the rosaria node
tmux select-pane -t 1
tmux send-keys "useros1" Enter
tmux send-keys "source /home/rocon/catkin_ws/devel/setup.bash" Enter
tmux send-keys "rosrun rosaria RosAria --sonar false" Enter

# Run the ros1_bridge on the last panel
tmux select-pane -t 2
tmux send-keys "useros1" Enter
tmux send-keys "useros2" Enter
# tmux send-keys "export ROS_MASTER_URI=http://localhost:11311" Enter
tmux send-keys "ros2 run ros1_bridge dynamic_bridge --bridge-all-topics" Enter

tmux select-pane -t 3
tmux send-keys "distrobox enter example-nvidia-toolkit" Enter
tmux send-keys "ros2 launch depthai_ros_driver camera.launch.py config:=/home/rocon/.local/distrobox/home/cuda/oak_record_calib.yaml" Enter # This line will not be run...

# Run the teleop.py script
tmux select-pane -t 4
tmux send-keys "useros1" Enter
tmux send-keys "rosrun teleop_twist_keyboard teleop_twist_keyboard.py /cmd_vel:=/RosAria/cmd_vel" Enter

tmux select-pane -t 5
tmux send-keys "useros2" Enter
today=$(date +"%Y_%m_%d"_%H_%M_%S)
# tmux send-keys "ros2 bag record -o oak_opti_cam_imu_c24_${today} --all" # Enter
tmux send-keys "ros2 bag record -o oak_opti_cam_imu_c24_${today} /Robot_1/pose /RosAria/cmd_vel /oak/imu/data /oak/rgb/camera_info /oak/rgb/image_raw /oak/left/camera_info /oak/left/image_raw /oak/right/camera_info /oak/right/image_raw /tf" # Enter

tmux select-pane -t 4

# Attach to the tmux session
tmux -2 attach-session -t $session_name

#### To kill it from another terminal run: tmux kill-server