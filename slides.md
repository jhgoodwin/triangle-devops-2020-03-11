---
theme : "default"
class : "invert"
transition: "fade"
highlightTheme: "darkula"
showNotes: false
marp: true
---

# Docker Builds

## March 11, 2020

A Sane Build / Test / Release pipeline - attempt 3572

---

## Presenter

* John Goodwin
* john@jjgoodwin.com
* <http://johngoodwin.com/>

Principal Software Engineer, Metabolon, Inc
<https://metabolon.com/>

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

## 01 - Publish Dockerfile

* Build external to the Dockerfile
* Copy files into Dockerfile only

---

### 01 - Example Build

```bash
pip install -r requirements.txt --target lib
docker build -t myapp -f 01.Publish.Dockerfile .
```

---

### 01 - Example Dockerfile

```Dockerfile
FROM python:3.6
WORKDIR /app
ENV PYTHONPATH /app/lib
COPY site site
COPY lib lib
ENTRYPOINT ["python", "app.py"]
```

---

### 01 - Observations

* Implicit build agent dependencies
  * Same OS?
  * python version?
  * If not, when does it error?
  * Same behavior in heterogenous build pool?
* No tests

---

## 02 - Build / Publish Dockerfile

* Build/resolve packages inside Dockerfile
* Ahead of Time vs Just in Time

---

### 02 - Example Build

```bash
docker build -t myapp -f 02.Build-Publish.Dockerfile .
```

---

### 02 - Example Dockerfile

```Dockerfile
FROM python:3.6
WORKDIR /app
COPY site site
COPY requirements.txt ./
RUN pip install -r requirements.txt
ENTRYPOINT ["python", "app.py"]
```

---

### 02 - Observations

* Build environment now controlled
* Container might have extras for building
* No tests

---

## 03 - Build / Publish Dockerfile, docker run tests

* Tests!
* Access to test artifacts

---

### 03 - Example Test Command

```bash
mkdir -p testresults
docker run --rm -i \
    --entrypoint sh \
    -e PYTHONPATH="/app/site" \
    -v $(pwd)/test.requirements.txt:/app/test.requirements.txt \
    -v $(pwd)/testresults:/app/testresults \
    -v $(pwd)/tests:/app/tests \
    myapp -c "pip install -r test.requirements.txt \
      && pytest --junitxml testresults/test-results.xml \
      --cov site \
      --cov-report=xml:testresults/coverage.xml \
      --cov-report=html:testresults/coverage-report \
      -v tests"
```

---

### 03 - Observations

* Tests!
* Test modules separate from publish container
* Need volume mounts - ugh
* pycache behavior finnicky
* File permissions can get messed up

---

## 04 - Build / Publish Dockerfile, Test docker-compose

* Removed for brevity
* Similar to prior, but uses compose syntax

---

## 05 - Build / Publish / test multi-stage Dockerfile

* Intermediate layer caching
* Sensitive args not in final dockerfile
* No more volume mount points
* Build cache easier to remove from publish

---

### 05 - Example Dockerfile - Part 1

```Dockerfile
FROM python:3.6 as build
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt --target lib

FROM python:3.6 as appbase
WORKDIR /app
COPY site site
COPY requirements.txt ./
COPY --from=build /app/lib /app/lib
ENTRYPOINT ["python", "site/app.py"]
```

---

### 05 - Example Dockerfile - Part 2

```Dockerfile
FROM appbase as test
ENV PYTHONPATH "/app/site:/app/lib"
COPY test.requirements.txt ./
COPY tests tests
COPY *.sh ./
RUN pip install -r test.requirements.txt
RUN mkdir /app/testresults
RUN chmod +x *.sh
RUN run_tests.sh
```

---

### 05 - Example Dockerfile - Part 3

```Dockerfile
FROM appbase as app
ENV PYTHONPATH "/app/site:/app/lib"
COPY --from=test /app/testresults /app/testresults
```

---

### 05 - Observations

* How to get test artifacts?! Argh!
* Docker file is much more complex

---

## 06 - Build / Publish Dockerfile + test Dockerfile

* Simpler build
* Simpler test wrapper
* No volume mount points required
* Remote builds possible
* Found a nice trick to get test artifacts

---

### 06 - Example Build/Publish Dockerfile

```Dockerfile
FROM python:3.6 as build
WORKDIR /app
COPY requirements.txt ./
RUN pip install -r requirements.txt --target lib

FROM python:3.6 as appbase
WORKDIR /app
ENV PYTHONPATH "/app/site:/app/lib"
COPY site site
COPY requirements.txt ./
COPY --from=build /app/lib /app/lib
ENTRYPOINT ["python", "site/app.py"]

FROM appbase as app
```

---

### 06 - Example Test Dockerfile

```Dockerfile
ARG IMGBASE
FROM ${IMGBASE}
ENV PYTHONPATH "/app/site:/app/lib"
COPY test.requirements.txt ./
COPY tests tests
COPY *.sh ./
RUN chmod +x *.sh
RUN pip install -r test.requirements.txt

ENTRYPOINT ["/app/run_tests_docker.sh"]
```

---

### run_tests_docker.sh

```bash
#!/usr/bin/env bash
# folder for the test results
TESTRESULTS="testresults"
mkdir -p $TESTRESULTS
./run_tests.sh > $TESTRESULTS/stdout.log 2> $TESTRESULTS/stderr.log

EXIT_CODE=$?

tar cf - "$TESTRESULTS" | cat
exit $EXIT_CODE
```

---

### run_tests_ci.sh

```bash
#!/usr/bin/env bash
: "${TEST_IMAGE_NAME:?Name of test image to run}"

docker run --rm -i \
    $TEST_IMAGE_NAME \
    | tar -xf - && EXIT_CODE=${PIPESTATUS[0]} && cat testresults/stdout.log && cat testresults/stderr.log 1>&2

exit $EXIT_CODE
```

---

### Learning TTY

```bash
docker run -it ...

# vs

docker run -i ...
```

Note: this is when I ran into the difference between -i and -it. Basically, if you don't need the interactive terminal (like when running bash interactively), then leave off the t flag. Leaving it on can cause extra carriage return characters in your datastream. This will corrupt the output from tar

---

## Recommendation

* Single responsibility
* Simple as possible
* Command Chain

---

## Related / References

* [Docker Docs](https://docs.docker.com/)
* [Katacoda](https://katacoda.com/)
* [Dive docker image tool](https://github.com/wagoodman/dive)
* [Workshop material for Triangle Devops 2020-03-11 Next Level Docker Builds](https://github.com/jhgoodwin/triangle-devops-2020-03-11)
* [Containers from Scratch - Eric Chiang, CoreOS](https://www.youtube.com/watch?v=wyqoi52k5jM)
* [Minimal Containers - Brian 'Red Beard'](https://github.com/brianredbeard/minimal_containers)
* [Sysdig and CoreOS Meetup Jul '15: Best Practices For Container Environments](https://www.youtube.com/watch?v=gMpldbcMHuI)
* [Marp CLI markdown slide converter](https://github.com/marp-team/marp-cli/)
