#!/bin/bash
# api-gateway/start.sh

# انتظر حتى تصبح قاعدة البيانات جاهزة
while ! nc -z postgres 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

# تشغيل الخدمة
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload