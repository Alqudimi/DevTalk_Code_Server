# api-gateway/app/core/config.py
from pydantic import BaseSettings, AnyHttpUrl
from typing import List, Optional

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Code Server API Gateway"
    
    # إعدادات code-server
    CODE_SERVER_URL: str = "http://code-server:8080"
    CODE_SERVER_API_KEY: Optional[str] = None
    
    # إعدادات المصادقة
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # أسبوع
    
    # إعدادات قاعدة البيانات
    DATABASE_URL: str = "postgresql://user:password@postgres:5432/code_server_db"
    
    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
