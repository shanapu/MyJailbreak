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
spcomp MyJailbreak/armsrace.sp -o../plugins/MyJailbreak/armsrace.smx 
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
spcomp MyJailbreak/Add-ons/ratio_ctbans_addicted.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_addicted.smx 
spcomp MyJailbreak/Add-ons/ratio_ctbans_databomb.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_databomb.smx  
spcomp MyJailbreak/Add-ons/ratio_ctbans_r1ko.sp -o../plugins/MyJailbreak/disabled/ratio_ctbans_r1ko.smx  
spcomp MyJailbreak/Add-ons/ratio_teambans.sp -o../plugins/MyJailbreak/disabled/ratio_teambans.smx  
spcomp MyJailbreak/Add-ons/ratio_steamrep.sp -o../plugins/MyJailbreak/disabled/ratio_steamrep.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_mostactive.sp -o../plugins/MyJailbreak/disabled/myjailbreak_mostactive.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_teamgames.sp -o../plugins/MyJailbreak/disabled/myjailbreak_teamgames.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_steamgroups.sp -o../plugins/MyJailbreak/disabled/myjailbreak_steamgroups.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_stamm.sp -o../plugins/MyJailbreak/disabled/myjailbreak_stamm.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_reputation.sp -o../plugins/MyJailbreak/disabled/myjailbreak_reputation.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_rankme.sp -o../plugins/MyJailbreak/disabled/myjailbreak_rankme.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_kento_rankme.sp -o../plugins/MyJailbreak/disabled/myjailbreak_kento_rankme.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_sm-store_credits.sp -o../plugins/MyJailbreak/disabled/myjailbreak_sm-store_credits.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_zephstore_credits.sp -o../plugins/MyJailbreak/disabled/myjailbreak_zephstore_credits.smx  
spcomp MyJailbreak/Add-ons/myjailbreak_lvl_ranks.sp -o../plugins/MyJailbreak/disabled/myjailbreak_lvl_ranks.smx
spcomp MyJailbreak/Add-ons/warden_zephstore_paperclips.sp -o../plugins/MyJailbreak/disabled/warden_zephstore_paperclips.smx
pause