docker build -t lifeeka/cli:latest .

docker push lifeeka/cli:latest

docker container run -it  -v "$(pwd)":/app lifeeka/cli:latest bash serve.sh
