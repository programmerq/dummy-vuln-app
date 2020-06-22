FROM debian:stretch
RUN apt update && apt install python-pip python-numpy openssh-server -y && rm -rf /var/lib/apt
RUN pip install flask
COPY app.py /app.py
RUN echo WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCoK | base64 -d > /test.txt # eicar
EXPOSE 5000 22
ENTRYPOINT ["python", "./app.py"]
