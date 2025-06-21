# api-gateway/Dockerfile
FROM python:3.9-slim

WORKDIR /app

# تثبيت التبعيات
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# نسخ الملفات المطلوبة
COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY ./app /app/app
COPY ./start.sh /app/start.sh

# تعيين الأذونات
RUN chmod +x /app/start.sh

# المنفذ المكشوف
EXPOSE 8000

# أمر التشغيل
CMD ["/app/start.sh"]