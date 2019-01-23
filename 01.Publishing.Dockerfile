FROM python:3.6
WORKDIR /app
ENV PYTHONPATH /app/lib
COPY app.py ./
COPY lib .
ENTRYPOINT ["python", "app.py"]