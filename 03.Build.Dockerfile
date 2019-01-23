FROM python:3.6
WORKDIR /app
COPY app.py ./
COPY requirements.txt ./
RUN pip install -r requirements.txt --target lib
ENTRYPOINT ["pip", "install", "-r", "requirements.txt" ,"--target", "lib"]