@echo off
echo Starting local test server...

curl -s --head http://127.0.0.1:5500/content/ | findstr "HTTP/1.[01] [23].." > nul
if errorlevel 1 (
    echo ERROR: sv_downloadurl is not reachable. We recommend you locally host the content folder for faster downloads.
    exit /b 1
)

echo Starting SRCDS...

srcds.exe -console -game garrysmod +maxplayers 20 +gamemode experiment-redux +map rp_c18_v2 +host_workshop_collection 3215035081
