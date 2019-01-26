FROM python:3.6
WORKDIR /app
COPY site site
COPY requirements.txt ./
RUN pip install -r requirements.txt
ENTRYPOINT ["python", "site/app.py"]