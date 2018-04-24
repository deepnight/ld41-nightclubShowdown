@echo off

del NightclubShowdown\hlboot.dat
del *.zip
del *.swf
del *.js

cd ..
echo HL...
haxe hl.hxml

echo Flash...
haxe flash.hxml

echo JS...
haxe js.hxml

echo Copying...
copy bin\client.hl redist\NightclubShowdown\hlboot.dat
copy bin\client.swf redist
copy bin\client.js redist
