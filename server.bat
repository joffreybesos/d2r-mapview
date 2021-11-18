@echo off

@echo Run this from inside your Diablo 2 classic folder!

CALL docker pull joffreybesos/d2-mapserver:latest
CALL docker rmi joffreybesos/d2-mapserver:include

CALL del /f/q Dockerfile.lod.dockerfile
@echo If it can't find the Dockerfile.lod.dockerfile then that's ok
@echo FROM joffreybesos/d2-mapserver:latest >> Dockerfile.lod.dockerfile
@echo COPY . /app/game/ >> Dockerfile.lod.dockerfile
@echo CMD ["node", "build/server/server.js"] >> Dockerfile.lod.dockerfile
CALL md cache
CALL docker build -f Dockerfile.lod.dockerfile . -t joffreybesos/d2-mapserver:include
CALL docker run -v "cache:/app/cache" -p 3002:3002 -e PORT=3002 joffreybesos/d2-mapserver:include

