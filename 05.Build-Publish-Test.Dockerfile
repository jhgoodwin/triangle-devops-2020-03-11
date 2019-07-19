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

FROM appbase as test
ENV PYTHONPATH "/app/site:/app/lib"
COPY test.requirements.txt ./
COPY tests tests
COPY *.sh ./
RUN pip install -r test.requirements.txt
RUN mkdir /app/testresults
RUN chmod +x *.sh
RUN ./run_tests.sh

FROM appbase as app
ENV PYTHONPATH "/app/site:/app/lib"
COPY --from=test /app/testresults /app/testresults
