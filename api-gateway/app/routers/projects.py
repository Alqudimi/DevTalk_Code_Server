# api-gateway/app/routers/projects.py
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import JSONResponse
from loguru import logger
from typing import List
import shutil
import os
from pathlib import Path

from app.core.config import settings
from app.core.security import get_current_user
from app.models.schemas import Project, ProjectCreate

router = APIRouter()

# مسار تخزين المشاريع
PROJECTS_DIR = "/home/coder/project"

@router.get("/", response_model=List[Project])
async def list_projects(current_user: dict = Depends(get_current_user)):
    """سرد جميع المشاريع المتاحة"""
    try:
        projects = []
        for item in os.listdir(PROJECTS_DIR):
            item_path = os.path.join(PROJECTS_DIR, item)
            if os.path.isdir(item_path):
                projects.append({
                    "name": item,
                    "path": item_path,
                    "created_at": os.path.getctime(item_path)
                })
        return projects
    except Exception as e:
        logger.error(f"Error listing projects: {e}")
        raise HTTPException(status_code=500, detail="Failed to list projects")

@router.post("/create")
async def create_project(
    project: ProjectCreate,
    current_user: dict = Depends(get_current_user)
):
    """إنشاء مشروع جديد"""
    try:
        project_path = os.path.join(PROJECTS_DIR, project.name)
        os.makedirs(project_path, exist_ok=True)
        return {"message": f"Project {project.name} created successfully"}
    except Exception as e:
        logger.error(f"Error creating project {project.name}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create project {project.name}"
        )

@router.post("/upload")
async def upload_file(
    project_name: str,
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user)
):
    """رفع ملف إلى مشروع"""
    try:
        project_path = os.path.join(PROJECTS_DIR, project_name)
        if not os.path.exists(project_path):
            raise HTTPException(status_code=404, detail="Project not found")
        
        file_path = os.path.join(project_path, file.filename)
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        return {"message": f"File {file.filename} uploaded successfully"}
    except Exception as e:
        logger.error(f"Error uploading file: {e}")
        raise HTTPException(status_code=500, detail="Failed to upload file")

@router.delete("/delete")
async def delete_project(
    project_name: str,
    current_user: dict = Depends(get_current_user)
):
    """حذف مشروع"""
    try:
        project_path = os.path.join(PROJECTS_DIR, project_name)
        if not os.path.exists(project_path):
            raise HTTPException(status_code=404, detail="Project not found")
        
        shutil.rmtree(project_path)
        return {"message": f"Project {project_name} deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting project {project_name}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to delete project {project_name}"
        )