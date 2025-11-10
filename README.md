# mocap_optitrack

This repository is a fork of 
[https://github.com/ros-drivers/mocap_optitrack](https://github.com/ros-drivers/mocap_optitrack), i.e.
[https://wiki.ros.org/mocap_optitrack](https://wiki.ros.org/mocap_optitrack).

This is a setup, which works for us. it uses [Commit 7723217](https://github.com/ros-drivers/mocap_optitrack/commit/7723217bf63b71d1272832901305a4e6f60c22b2), because the used Motive version 1.8, which is not compatible with newer versions. Ros1-Bridge also works with this solution, including the bash file, which opens a tmux terminal for ease of use.

Further documentation:

# Setting up OptiTrack in C24 (Host machine running Windows) 

The license of the setup is too old, and it does not function with the latest Motive versions from the official website. You have to use an older version: 1.8.0.  

* Be sure that the following packages are installed to avoid missing .dll errors. The installers are already downloaded as ‘vcredist_x64.exe’, ‘vc_redist.x64.exe’, and ‘dxwebsetup.exe’), or download them from: 

* Microsoft Visual C++ 2010 Redistributable: [https://www.microsoft.com/en-us/download/details.aspx?id=26999](https://www.microsoft.com/en-us/download/details.aspx?id=26999) 

* Microsoft Visual C++ 2015 - 2022 Redistributable: [https://www.microsoft.com/en-us/download/details.aspx?id=48145](https://www.microsoft.com/en-us/download/details.aspx?id=48145)  

* DirectX9: [https://www.microsoft.com/en-us/download/details.aspx?id=35](https://www.microsoft.com/en-us/download/details.aspx?id=35) 

* You need OptiTrack USB Drivers and National Instruments Software, which are not installable standalone: Install the latest version of Motive from [https://optitrack.com/support/downloads/motive.html](https://optitrack.com/support/downloads/motive.html) 

* During install try to allow everything (as long as the software seems related to OptiTrack, Motive, or National Instruments) 

* After this, you can go to Control Panel and Delete ‘Motive’ (or just Delete the ‘Motive’ folder from the installation location). If you are uninstalling Motive from Control Panel, be sure that you are not uninstalling other software 

* Copy the ‘Motive’ folder to the ‘Program Files’ folder on your windows computer. 

* Copy the ‘OptiTrack’ folder to the ‘ProgramData’ folder.  

* Plug in the OptiTrack hardware key into your machine 

* Plug in the Optitrack cameras into your machine and power on the OptiTrack cameras 

* Run from ‘C:Program Files/Motive/Motive.exe’ 

* The Motive application should open, and the license should be activated (I had problems with running it from a desktop shortcut, make sure that the license is activated when running the exe directly from the ‘Motive’ folder) 

* In Motive, ‘File’->’Open...’ --> ‘patiMotive.ttp’, take this project as the start for every project you start 

* Your markers should be visible 

* The markers' coordinates are then published on the localhost, and you need a C# program to capture them and redistribute to your application. Or NatNet (see Data Streaming section) 

License Information – should not be needed, writing them here just in case (if you copy the files they are not needed, and they seem to not be present in the Motive online database, since they are so old): 

> License Serial Number: MVCL1827
>
> License Hash Code: 2329-189B-CA3F-364C
>
> Hardware Key: 104992 

 
Data Streaming onto Linux: 

* In Motive enable streaming to another computer by clicking on the ‘Streaming Pane’ (an icon around the top bar, hover the cursor until you find it). Set ‘Local Interface’ to an IP address instead of ‘local’. 

* Download NatNet onto the client machine (choose the adequate installer. For Cuda and other systems with Ubuntu18.04 I tested 4.0 works, 4.3 does not – between I do not know): https://optitrack.com/support/downloads/developer-tools.html 

* Unzip the tar file. 

* Follow the instructions in the ‘samples/SampleClient/ReadMe.txt’ 

* e.g. using v4.0:  

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/cuda/Downloads/NatNet_SDK_4.0_ubuntu/lib/

cd Downloads/NatNet_SDK_4.0_ubuntu/samples/SampleClient/build/ 

./SampleClient 
```

## Rigid Body 

See also [https://docs.optitrack.com/motive-ui-panes/properties-pane/properties-pane-rigid-body](https://docs.optitrack.com/motive-ui-panes/properties-pane/properties-pane-rigid-body) to learn more on how to configure rigid bodies. 

## Optitrack with ROS 

We have a quite old Motive version (1.8), therefore we cannot really use the official [MoCap4ROS2 Plugin](https://docs.optitrack.com/robotics/mocap4ros2-setup). We have to use the older packages. 

First install mocap_optitrack. (a basic doc is [https://wiki.ros.org/mocap_optitrack](https://wiki.ros.org/mocap_optitrack), however it might not work): We have to get the source, and revert to a previous commit (you might be able to experiment with different commits, this is what worked for me): do this, or clone the existing repo:

```
mkdir -p ~/catkin_ws_optitrack/src/ 

cd catkin_ws_optitrack/src/ 

git clone https://github.com/ros-drivers/mocap_optitrack.git 

cd mocap_optitrack 

git checkout 7723217bf63b71d1272832901305a4e6f60c22b2

cd ../../

catkin_make
```

Or clone directly this repo:

```
mkdir -p ~/catkin_ws_optitrack/src/ 

cd catkin_ws_optitrack/src/ 

git clone https://github.com/molnarszilard/mocap_optitrack.git

cd ../

catkin_make
```

Modify `~/catkin_ws_optitrack/src/mocap_optitrack/config/mocap.yaml`, so it looks something like this (modify your `<RIGID_BODY_ID>`, e.g. ‘8’, and the topic names, depending on what would you like to have. Leave the optitrack_configs like this, and make sure, that they are the same in the Motive as well): 

```
rigid_bodies:
       '<RIGID_BODY_ID>':
              pose: Robot_1/pose 
              pose2d: Robot_1/ground_pose
              odom: Robot_1/Odom
              tf: tf
              child_frame_id: Robot_1/base_link
              parent_frame_id: world
optitrack_config:
       multicast_address: 239.255.42.99
       command_port: 1510
       data_port: 1511
       enable_optitrack: true
```

Then source it and launch it:

``` 
source ~/catkin_ws_optitrack/devel/setup.bash 

roslaunch mocap_optitrack mocap.launch
```

This will launch the node that will publish the topics. You can see them using `rostopic list`

> [!Note] If you want to use ROS2 (you might try the same mocap_optitrack repo to see if there is an implementation or not, but it is not likely), you either use the official plugin with a newer Motive version (you can try to use it with V1.8) or setup a ros1_bridge. 

## Setting up a ros1_bridge 

The Ros1Bridge is found here [https://github.com/ros2/ros1_bridge](https://github.com/ros2/ros1_bridge). You will need a system where both ROS1 and ROS2 works (Noetic+Foxy is the most safe options, but noetic and Humble also works, maybe other combinations as well). On Xavier AGX, Noetic is installed from apt repos, while Humble is installed from source in `~/ros2_humble`, here is also the ros1_bridge source. (a few other elements are installed at `~/ros2_humble_extra`) On the AGX, in .bashrc, there are two alieses: 

```
alias useros1="source /opt/ros/noetic/setup.bash"
alias useros2="source /home/rocon/ros2_humble/install/local_setup.bash && source /home/rocon/ros2_humble_extra/install/local_setup.bash" 
```

To install Ros1Bridge (start a new terminal, where ROS1 is NOT sourced):

```
cd ~/ros2_humble/src

git clone https://github.com/ros2/ros1_bridge.git

cd ..

colcon build --symlink-install --packages-skip ros1_bridge

useros1

useros2

colcon build --symlink-install --packages-select ros1_bridge --cmake-force-configure
```

None of the ROS versions is sourced by default (can cause a problem in a few cases). 

After you starte the ROS1 node, software, you can start the ros1_bridge: 

```
useros1 

useros2 

ros2 run ros1_bridge dynamic_bridge --bridge-all-topics 
```

You can also use a bash script, which sets up the required nodes using tmux:
`optitrack_ros1_bridge_tmux.sh`

Setting up this on one computer (e.g., AGX), the ROS2 topic will be visible for all other computers on the same network, also running ROS2 (preferably Humble). Please check this file, because some paths might not be set correctly.

## Pioneer P3-AT

For this robot you need to install rosaria (preferably on ROS1):

```
sudo apt install aria2 libaria-dev
```

Build [rosaria](https://github.com/amor-ros-pkg/rosaria#):

```
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
git clone https://github.com/amor-ros-pkg/rosaria.git
cd ~/catkin_ws
catkin_make
```

## Oak D-Lite camera

Follow the instructions from [https://docs.luxonis.com/software/ros/depthai-ros/](https://docs.luxonis.com/software/ros/depthai-ros/) to install the depthai-ros-drivers. You can install them on ROS Noetic and Humble (or Iron) using (building from source is not recommended) - This project was done using Humble:

`sudo apt install ros-<distro>-depthai-ros`

There might be a problem with the arguments of the camera (see also [arguments](https://docs.luxonis.com/software/ros/depthai-ros/driver)), in this case follow modifications in [depthai_files](depthai_files): the `camera.launch.py` is located at `/opt/ros/humble/share/depthai_ros_driver/launch/camera.launch.py`. Here you might want to modify the file around Line 173. This is almost hardcoding the values in `tf_params`:

```
   tf_params = {   
        "camera": {   
               "i_pipeline_type":'RGBStereo',   
               "i_nn_type": 'none',   
       },  
       "pipeline_gen": {   
               "i_enable_imu": True,   
       },   
       "left": {   
               "i_fps": 20.0,   
               "i_synced": False,   
       },   
       "right": {   
               "i_fps": 20.0,   
               "i_synced": False,   
       },   
       "rgb": {   
               "i_fps": 20.0,   
               "i_synced": False,   
       },   
       "imu": {   
               "i_rot_cov": -1.0,   
               "i_gyro_cov": 0.0,   
               "i_mag_cov": 0.0,
       },   
   }
```

You can launch the camera using:

```
ros2 launch depthai_ros_driver camera.launch.py
```

> [!Note] This api should also work in ROS Noetic, however, when I tested, I did not get any data in the imu topic (the topic was present, but not active). However, the arguments can be modified using a config file, instead of `camera.i_pipeline_type` (as in ROS2), in ROS1 you should use `camera_i_pipeline_type`, etc.

## Entire Pipeline

To run the entire pipeline on the AGX: Oak D-Lite camera: image, imu, optitrack with rosbag record:
`opti_oak_record_into_bag.sh`

Please check this file, because some paths might not be set correctly.

A few commands are not run by default, you have to press Enter, when yo uare ready. (You can navigate between tmux terminals using <Ctrl+b> then `ArrowKey`. To kill the entire server from another terminal run: `tmux kill-server`)

> [!Note] You are also able to use the Full HD Up camera instead of the oak (although, you will only get the P3 odometry instead of an IMU), byt using a different `.sh` file.

 

 

 
