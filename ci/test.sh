#!/bin/bash

set -ev

echo "Download und extract sourcemod"
wget -q "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
# wget "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Set plugins version"
for file in addons/sourcemod/scripting/include/myjailbreak.inc
do
  sed -i "s/<ID>/$BID/g" $file > output.txt
  rm output.txt
done

echo "get basecom myjb 1.7"
wget -q -O addons/sourcemod/scripting/include/basecomm.inc https://raw.githubusercontent.com/shanapu/MyJailbreak/master/addons/sourcemod/scripting/include/basecomm.inc

echo "Move Modules folder for compile"
mkdir addons/sourcemod/scripting/MyJailbreak/MyJailbreak/
mv addons/sourcemod/scripting/MyJailbreak/Modules addons/sourcemod/scripting/MyJailbreak/MyJailbreak/

echo "Compile MyJailbreak plugins"
for file in addons/sourcemod/scripting/MyJailbreak/*.sp
do
  addons/sourcemod/scripting/spcomp -E -v0 $file
done
