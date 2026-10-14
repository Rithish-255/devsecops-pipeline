FROM python:3.11-slim
WORKDIR /app
COPY app/hello.py .
CMD ["python", "hello.py"]
