@echo off
echo.
echo MyJailbreak compile script
echo.
echo.
echo.
echo Compile: MyJailbreak Core
echo.
spcomp MyJailbreak/myjailbreak.sp -o../plugins/MyJailbreak/myjailbreak.smx
echo.
echo.
echo.
echo Compile: MyJailbreak Plugins
echo.
spcomp MyJailbreak/catch.sp -o../plugins/MyJailbreak/catch.smx 
spcomp MyJailbreak/duckhunt.sp -o../plugins/MyJailbreak/duckhunt.smx 
spcomp MyJailbreak/ffa.sp -o../plugins/MyJailbreak/ffa.smx 
spcomp MyJailbreak/freeday.sp -o../plugins/MyJailbreak/freeday.smx 
spcomp MyJailbreak/hebattle.sp -o../plugins/MyJailbreak/hebattle.smx 
spcomp MyJailbreak/hide.sp -o../plugins/MyJailbreak/hide.smx 
spcomp MyJailbreak/suicide.sp -o../plugins/MyJailbreak/suicide.smx 
spcomp MyJailbreak/knife.sp -o../plugins/MyJailbreak/knife.smx 
spcomp MyJailbreak/menu.sp -o../plugins/MyJailbreak/menu.smx 
spcomp MyJailbreak/noscope.sp -o../plugins/MyJailbreak/noscope.smx 
spcomp MyJailbreak/lastguard.sp -o../plugins/MyJailbreak/lastguard.smx 
spcomp MyJailbreak/playertags.sp -o../plugins/MyJailbreak/playertags.smx 
spcomp MyJailbreak/war.sp -o../plugins/MyJailbreak/war.smx 
spcomp MyJailbreak/warden.sp -o../plugins/MyJailbreak/warden.smx 
spcomp MyJailbreak/weapons.sp -o../plugins/MyJailbreak/weapons.smx 
spcomp MyJailbreak/zeus.sp -o../plugins/MyJailbreak/zeus.smx 
spcomp MyJailbreak/cowboy.sp -o../plugins/MyJailbreak/cowboy.smx 
spcomp MyJailbreak/drunk.sp -o../plugins/MyJailbreak/drunk.smx 
spcomp MyJailbreak/torch.sp -o../plugins/MyJailbreak/torch.smx 
spcomp MyJailbreak/zombie.sp -o../plugins/MyJailbreak/zombie.smx 
spcomp MyJailbreak/request.sp -o../plugins/MyJailbreak/request.smx 
spcomp MyJailbreak/dealdamage.sp -o../plugins/MyJailbreak/dealdamage.smx 
spcomp MyJailbreak/hud.sp -o../plugins/MyJailbreak/hud.smx 
spcomp MyJailbreak/ratio.sp -o../plugins/MyJailbreak/ratio.smx 
spcomp MyJailbreak/icons.sp -o../plugins/MyJailbreak/icons.smx 
spcomp MyJailbreak/ghosts.sp -o../plugins/MyJailbreak/ghosts.smx 
echo.
echo.
echo.
echo Compile: MyJailbreak  Add-ons
echo.
spcomp MyJailbreak/Add-ons/ratio_ctban.sp -o../plugins/MyJailbreak/disabled/ratio_ctban.smx 
spcomp MyJailbreak/Add-ons/ratio_stamm.sp -o../plugins/MyJailbreak/disabled/ratio_stamm.smx  
spcomp MyJailbreak/Add-ons/ratio_teambans.sp -o../plugins/MyJailbreak/disabled/ratio_teambans.smx  
spcomp MyJailbreak/Add-ons/ratio_reputation.sp -o../plugins/MyJailbreak/disabled/ratio_reputation.smx  
spcomp MyJailbreak/Add-ons/ratio_rankme.sp -o../plugins/MyJailbreak/disabled/ratio_rankme.smx  
spcomp MyJailbreak/Add-ons/ratio_steamrep.sp -o../plugins/MyJailbreak/disabled/ratio_steamrep.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_teamgames.sp -o../plugins/MyJailbreak/disabled/myjailbreak_teamgames.smx  
pause