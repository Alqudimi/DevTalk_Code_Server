# api-gateway/app/main.py
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from loguru import logger
from typing import Optional
import os

from app.routers import code_server, terminal, extensions, projects, auth
from app.core.config import settings
from app.core.security import verify_password
from app.models.schemas import UserInDB

app = FastAPI(
    title="Code Server API Gateway",
    description="API Gateway for managing all code-server APIs",
    version="1.0.0",
    openapi_url="/api/v1/openapi.json",
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc",
)

# إعداد CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# تضمين الراوترات
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(code_server.router, prefix="/api/v1/code-server", tags=["Code Server"])
app.include_router(terminal.router, prefix="/api/v1/terminal", tags=["Terminal"])
app.include_router(extensions.router, prefix="/api/v1/extensions", tags=["Extensions"])
app.include_router(projects.router, prefix="/api/v1/projects", tags=["Projects"])

@app.on_event("startup")
async def startup_event():
    logger.info("Starting API Gateway service...")
    # يمكنك إضافة أي إعدادات أولية هنا

@app.get("/api/v1/health", tags=["Health Check"])
async def health_check():
    return {"status": "healthy", "service": "code-server-api-gateway"}

@app.get("/", include_in_schema=False)
async def root():
    return {"message": "Code Server API Gateway is running"}
