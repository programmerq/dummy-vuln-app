FROM python:3-alpine
RUN apk --no-cache add openssh-server 
RUN pip install flask
COPY app.py /app.py
EXPOSE 5000 22
ENTRYPOINT ["python", "./app.py"]
