FROM python:3.6
WORKDIR /app
ENV PYTHONPATH "/app/site:/app/lib"
COPY site site
COPY lib lib
ENTRYPOINT ["python", "site/app.py"]