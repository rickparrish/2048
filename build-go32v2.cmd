@echo off
z:
cd \programming\2048\source
fpc -MObjFPC -Scghi -O1 -g -gl -vewnhi -Fi..\obj\i386-go32v2 -Fu..\..\RMDoor -Fu. -FU..\obj\i386-go32v2\ -l -FE..\bin\i386-go32v2\ -o2048.exe BBS2048.lpr
pause