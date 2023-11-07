docker build . -t gftest   

docker run -p 8080:8080 -p 4848:4848 -d gftest:latest

docker ps -a | grep gftest

docker stop X

docker rm X
