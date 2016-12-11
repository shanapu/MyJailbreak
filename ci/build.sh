#!/bin/bash
set -ev

BID=$6
FILE=MyJB-$2-$BID.zip
LATEST=MyJB-$2-latest.zip
HOST=$3
USER=$4
PASS=$5


echo "Download und extract sourcemod"
wget -q "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
# wget "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Set plugins version"
for file in addons/sourcemod/scripting/include/myjailbreak.inc
do
  sed -i "s/<COMMIT>/$BID/g" $file > output.txt
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

echo "Compile MyJailbreak Add-ons"
for file in addons/sourcemod/scripting/MyJailbreak/Add-ons/*.sp
do
  addons/sourcemod/scripting/spcomp -E -v0 $file
done

echo "Remove plugins folder if exists"
if [ -d "addons/sourcemod/plugins" ]; then
  rm -r addons/sourcemod/plugins
fi

echo "Create clean plugins folder"
mkdir addons/sourcemod/plugins
mkdir addons/sourcemod/plugins/MyJailbreak
mkdir addons/sourcemod/plugins/MyJailbreak/disabled

echo "Move all MyJB binary files to plugins folder"
for file in *.smx
do
  mv $file addons/sourcemod/plugins/MyJailbreak
done

echo "Move all other binary files to plugins folder"
  mv addons/sourcemod/plugins/MyJailbreak/myjailbreak_teamgames.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_ctban.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_kento_rankme.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_rankme.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_reputation.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_teambans.smx addons/sourcemod/plugins/MyJailbreak/disabled
  mv addons/sourcemod/plugins/MyJailbreak/ratio_stamm.smx addons/sourcemod/plugins/MyJailbreak/disabled

echo "Remove build folder if exists"
if [ -d "build" ]; then
  rm -r build
fi

echo "Create clean build & sub folder"
mkdir build
mkdir build/gameserver
mkdir build/fastDL

echo "Move addons, materials and sound folder"
mv addons cfg materials models sound build/gameserver

echo "Move FastDL folder"
mv fastDL/materials fastDL/models fastDL/sound build/fastDL

echo "Move license to build"
mv install.txt license.txt downloads.txt CHANGELOG.md build/

echo "Remove sourcemod folders"
rm -r build/gameserver/addons/metamod
rm -r build/gameserver/addons/sourcemod/bin
rm -r build/gameserver/addons/sourcemod/configs/geoip
rm -r build/gameserver/addons/sourcemod/configs/sql-init-scripts
rm -r build/gameserver/addons/sourcemod/configs/*.txt
rm -r build/gameserver/addons/sourcemod/configs/*.ini
rm -r build/gameserver/addons/sourcemod/configs/*.cfg
rm -r build/gameserver/addons/sourcemod/data
rm -r build/gameserver/addons/sourcemod/extensions
rm -r build/gameserver/addons/sourcemod/gamedata
rm -r build/gameserver/addons/sourcemod/scripting
rm -r build/gameserver/addons/sourcemod/translations
rm -r build/gameserver/cfg/sourcemod
rm build/gameserver/addons/sourcemod/*.txt

echo "Remove placeholder files"
rm -r build/gameserver/addons/sourcemod/logs/MyJailbreak/.gitkeep
rm -r build/gameserver/cfg/MyJailbreak/EventDays/.gitkeep


echo "Create clean translation folder"
mkdir build/gameserver/addons/sourcemod/translations

echo "Download und unzip translations files"
wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/178/download/MyJailbreak.Warden.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/179/download/MyJailbreak.War.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/231/download/MyJailbreak.HUD.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/180/download/MyJailbreak.Menu.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/196/download/MyJailbreak.Request.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/197/download/MyJailbreak.LastGuard.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/201/download/MyJailbreak.Ratio.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/200/download/MyJailbreak.DealDamage.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/190/download/MyJailbreak.CowBoy.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/182/download/MyJailbreak.SuicideBomber.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/181/download/MyJailbreak.PlayerTags.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/183/download/MyJailbreak.Ffa.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/192/download/MyJailbreak.FreeDay.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/183/download/MyJailbreak.Hide.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/183/download/MyJailbreak.Torch.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/191/download/MyJailbreak.Drunk.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/189/download/MyJailbreak.Zeus.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/198/download/MyJailbreak.NoScope.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/193/download/MyJailbreak.HEbattle.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/184/download/MyJailbreak.Zombie.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/188/download/MyJailbreak.Weapons.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/186/download/MyJailbreak.DuckHunt.translations.zip
unzip -qo translations.zip -d build/gameserver/


wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/188/download/MyJailbreak.KnifeFight.translations.zip
unzip -qo translations.zip -d build/gameserver/

wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/186/download/MyJailbreak.Catch.translations.zip
unzip -qo translations.zip -d build/gameserver/

echo "Clean root folder"
rm sourcemod.tar.gz
rm translations.zip

echo "Go to build folder"
cd build

echo "Compress directories and files"
zip -9rq $FILE gameserver fastDL install.txt license.txt downloads.txt CHANGELOG.md

echo "Upload file"
lftp -c "set ftp:ssl-allow no; set ssl:verify-certificate no; open -u $USER,$PASS $HOST; put -O MyJailbreak/downloads/SM$1/$2/ $FILE"

echo "Add latest build"
mv $FILE $LATEST

echo "Upload latest build"
lftp -c "set ftp:ssl-allow no; set ssl:verify-certificate no; open -u $USER,$PASS $HOST; put -O MyJailbreak/downloads/SM$1/ $LATEST"

echo "Build done"
