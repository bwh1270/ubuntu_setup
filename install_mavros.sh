#! /bin/bash

WS="$1"

if [[ -z ${WS} ]]; then
	echo "There is no argument of workspace name"
	echo "Please put the argument of workspace name"
	exit 1
fi

sudo apt install python3-catkin-tools python3-rosinstall-generator python3-osrf-pycommon -y

# 1. Create the workspace: unneeded if you already has workspace
mkdir -p ~/${WS}/src
cd ~/${WS}
catkin init
wstool init src

# 2. Install MAVLink
#    we use the Kinetic reference for all ROS distros as it's not distro-specific and up to date
catkin build
source devel/setup.bash
rosinstall_generator --rosdistro kinetic mavlink | tee /tmp/mavros.rosinstall

# 3. Install MAVROS: get source (upstream - released)
rosinstall_generator --upstream mavros | tee -a /tmp/mavros.rosinstall

# 4. Create workspace & deps
wstool merge -t src /tmp/mavros.rosinstall
# command below: mavros and mavlink will be installed
wstool update -t src -j4   
rosdep install --from-paths src --ignore-src -y

# 5. Install GeographicLib datasets:
sudo ./src/mavros/mavros/scripts/install_geographiclib_datasets.sh

# 6. Build source
catkin build

# 7. Make sure that you use setup.bash or setup.zsh from workspace.
#    Else rosrun can't find nodes from this workspace.
cd ~/${WS}
source devel/setup.bash

echo "ROS workspace and MAVROS/MAVLink packages are installed successfully" 