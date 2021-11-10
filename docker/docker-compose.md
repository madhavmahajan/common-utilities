# Docker Compose

Reference: https://docs.docker.com/compose/

Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration.

Using Compose is basically a three-step process:
1.	Define your app’s environment with a `Dockerfile` so it can be reproduced anywhere.
2.	Define the services that make up your app in `docker-compose.yml` so they can be run together in an isolated environment.
3.	Run `docker compose up` and the Docker compose command starts and runs your entire app. You can alternatively run `docker-compose up` using the docker-compose binary.

Sample project to get started, reference: https://docs.docker.com/compose/gettingstarted/

1. Create a directory
```
# mkdir composetest
# cd compostest
```

2. Create a file `app.py`
```
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
```

3. Create a file `requirements.txt`
```
flask
redis
```

4. Create a `Dockerfile`
```
# syntax=docker/dockerfile:1
FROM python:3.7-alpine
WORKDIR /code
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
RUN apk add --no-cache gcc musl-dev linux-headers
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
EXPOSE 5000
COPY . .
CMD ["flask", "run"]
```

5. Create a `docker-compose.yaml`
```
version: "3.9"
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

6. Build and run the application
```
# docker-compose up
# docker-compose up -d  # To run app in detached mode
```
Compose pulls a Redis image, builds an image for your code, and starts the services you defined. In this case, the code is statically copied into the image at build time.

7. Test application by accessing `http://localhost:5000`

8. Run following commands to understand the appilication deployed

```
# docker image ls
REPOSITORY        TAG       IMAGE ID       CREATED        SIZE
composetest_web   latest    3816779086b0   30 hours ago   183MB
redis             alpine    e24d2b9deaec   3 weeks ago    32.3MB

# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED        STATUS        PORTS                    NAMES
5c4a8b7c9294   composetest_web   "flask run --port=50…"   30 hours ago   Up 30 hours   0.0.0.0:5001->5002/tcp   composetest-web-1
5a92bf8b5bc6   redis:alpine      "docker-entrypoint.s…"   30 hours ago   Up 30 hours   6379/tcp                 composetest-redis-1
```
Few more commands:
```
# docker-compose exec <service-name> sh
# docker-compose run <service-name> env
# docker-compose config

# docker logs <container-id>
# docker exec -it <container-id> sh
# docker inspect <container-id>
```

9. Stop the application
```
# docker-compose down
```

10. Edit the `docker-compose.yaml` with following information for `web` service
```
    volumes:
      - .:/code
    environment:
      FLASK_ENV: development
```
The new volumes key mounts the project directory (current directory) on the host to /code inside the container, allowing you to modify the code on the fly, without having to rebuild the image. The environment key sets the FLASK_ENV environment variable, which tells flask run to run in development mode and reload the code on change. This mode should only be used in development.

11. Re-build and run the application
```
# docker-compose up
```

12. Update the application by changing contents in `app.py`
13. Test the updated changes in the application

14. To bring down everything (services including the defualt volume and network created while deploying the app)
```
# docker-compose down --volumes
```
