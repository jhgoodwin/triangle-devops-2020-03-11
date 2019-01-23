---
theme : "league"
transition: "fade"
highlightTheme: "darkula"
showNotes: false
---

# Docker Builds

## Jan 26

A Sane Build / Test / Release pipeline - attempt 3572

---

## Agenda

* Ideas / Outcomes
* Each revision
* Distinct outcomes
* Recommendation

---

## Context

node.js / python apps

Note: C# tests have more nuances worth a different talk

---

## Publishing Dockerfile

* Build external to the Dockerfile
* Copy files into Dockerfile only

---

### Example Build

```bash
pip install -r requirements.txt --target lib
docker build -t myapp -f 01.Publishing.Dockerfile .
```

---

### Example Dockerfile

```Dockerfile
FROM python:3.6
WORKDIR /app
ENV PYTHONPATH /app/lib
COPY app.py ./
COPY lib .
ENTRYPOINT ["python", "app.py"]
```

---

### Observations

* Implicit build agent dependencies
  * Same OS?
  * python version?
  * If not, when does it error?
  * Same behavior in heterogenous build pool?
* No tests

---

## Build / Publishing Dockerfile

* Build/resolve packages inside Dockerfile
* Ahead of Time vs Just in Time

---

### Example Build

```bash
docker build -t myapp -f 02.Build-Publishing.Dockerfile .
```

---

### Example Dockerfile

```Dockerfile
FROM python:3.6
WORKDIR /app
COPY app.py ./
COPY requirements.txt ./
RUN pip install -r requirements.txt
ENTRYPOINT ["python", "app.py"]
```

---

## Build docker compose, Publishing Dockerfile

* TODO - collapse this demo into the next one for build/test compose + publish dockerfile
* Volume mount points

---

### Example Build

```bash
docker-compose -f 03.docker-compose.yaml up
docker-compose -f 03.docker-compose.yaml down
# double check this - might be simpler syntax
```

---

### Example docker-compose

```docker-compose
... TODO
```

---

### Example Build Dockerfile

```Dockerfile
FROM python:3.6
WORKDIR /app
COPY app.py ./
COPY requirements.txt ./
RUN pip install -r requirements.txt --target lib
ENTRYPOINT ["pip", "install", "-r", "requirements.txt" ,"--target", "lib"]
```

---

## Build / test docker compose, Publishing Dockerfile

* Requires volume mount points
* Tests!
* Access to test artifacts
* File permissions require work

---

## Build / Publishing Dockerfile, docker run tests

* Requires volume mount points
* Tests!
* Access to test artifacts
* File permissions require work

---

## Build / Publishing / test multi-stage Dockerfile

* Intermediate layer caching
* Sensitive args not in final dockerfile
* How to get test artifacts?! Argh!
* No more volume mount points

---

## Build / Publishing Dockerfile + test Dockerfile

* Simpler build
* Simpler test wrapper
* No volume mount points required
* Remote builds possible
* Found a nice trick to get test artifacts

---

## Learning TTY

```bash
docker run -it ...

# vs

docker run -i ...
```

Note: this is when I ran into the difference between -i and -it. Basically, if you don't need the interactive terminal (like when running bash interactively), then leave off the t flag. Leaving it on can cause 

---

## Recommendation

* Single responsibility
* Simple as possible
* Command Chain

---

## Related / References

* https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-task

