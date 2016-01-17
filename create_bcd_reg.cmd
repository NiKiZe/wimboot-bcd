@ECHO OFF
SET BCDSTORE=PXEBCD
SET regroot=HKCU\System\_BCD\
SET regObj=%regroot%Objects\
SET gid_bootmgr={9dea862c-5cdd-4e70-acc1-f32b344d4795}
SET gid_ramdisk={ae5534e0-a924-466c-b836-758539a3ee3a}
:: dyndef a random GUID
SET gid_dyndef={489fb83c-b74c-11e5-8269-ae6f2b48e753}
SET bin_ramdiskboot=00000000000000000000000000000000050000000000000048000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
SET bin_device=e03455ae24a96c46b836758539a3ee3a00000000010000009a000000000000000300000000000000000000000000000000000000000000000100000072000000050000000500000000000000480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005c0042006f006f0074005c0062006f006f0074002e00770069006d000000

:: Start clean
REG DELETE %regroot% /f

:: == bcdedit /createstore BCD
REG ADD %regroot%Description /v "KeyName" /t REG_SZ /d "BCD00000000" /f

:: == bcdedit /store BCD /create {bootmgr}
REG ADD %regObj%%gid_bootmgr%\Description /v "Type" /t REG_DWORD /d 0x10100002 /f

:: == bcdedit /store BCD /create {ramdiskoptions}
REG ADD %regObj%%gid_ramdisk%\Description /v "Type" /t REG_DWORD /d 0x30000000 /f

:: == bcdedit /store BCD /set {ramdiskoptions} ramdisksdidevice Boot
REG ADD %regObj%%gid_ramdisk%\Elements\31000003 /v "Element" /t REG_BINARY /d %bin_ramdiskboot% /f

:: == bcdedit /store BCD /set {ramdiskoptions} ramdisksdipath \Boot\boot.sdi
REG ADD %regObj%%gid_ramdisk%\Elements\32000004 /v "Element" /t REG_SZ /d "\Boot\boot.sdi" /f

:: == bcdedit /store BCD /create %gid_dyndef% /d "iPXE" /application osloader
REG ADD %regObj%%gid_dyndef%\Description /v "Type" /t REG_DWORD /d 0x10200003 /f
REG ADD %regObj%%gid_dyndef%\Elements\12000004 /v "Element" /t REG_SZ /d "iPXE" /f

:: == bcdedit /store BCD /default %gid_dyndef%
REG ADD %regObj%%gid_bootmgr%\Elements\23000003 /v "Element" /t REG_SZ /d "%gid_dyndef%" /f

:: == bcdedit /store BCD /set {default} systemroot \Windows
REG ADD %regObj%%gid_dyndef%\Elements\22000002 /v "Element" /t REG_SZ /d "\Windows" /f

:: == bcdedit /store BCD /set {default} detecthal Yes
REG ADD %regObj%%gid_dyndef%\Elements\26000010 /v "Element" /t REG_BINARY /d 01 /f

:: == bcdedit /store BCD /set {default} winpe Yes
REG ADD %regObj%%gid_dyndef%\Elements\26000022 /v "Element" /t REG_BINARY /d 01 /f

:: == bcdedit /store BCD /set {default} device ramdisk=[boot]\Boot\boot.wim,{ramdiskoptions}
REG ADD %regObj%%gid_dyndef%\Elements\11000001 /v "Element" /t REG_BINARY /d %bin_device% /f

:: == bcdedit /store BCD /set {default} osdevice ramdisk=[boot]\Boot\boot.wim,{ramdiskoptions}
REG ADD %regObj%%gid_dyndef%\Elements\21000001 /v "Element" /t REG_BINARY /d %bin_device% /f

:: Save the BCD by saving registry hive
REG SAVE %regroot% %BCDSTORE% /y
:: Cleanup
REG DELETE %regroot% /f

bcdedit /store %BCDSTORE% /enum all
bcdedit /store %BCDSTORE% /enum all /v
