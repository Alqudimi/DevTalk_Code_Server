FROM codercom/code-server:latest

# إعداد مجلد العمل
WORKDIR /home/coder/project

# فتح البورت الذي يدعمه Render
EXPOSE 8080

# تعيين كلمة المرور عبر متغير بيئة
CMD ["code-server", "--auth", "password", "--bind-addr", "0.0.0.0:8080"]
