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
