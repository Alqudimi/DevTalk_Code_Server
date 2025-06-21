# api-gateway/app/core/utils.py
import os
import shutil
from pathlib import Path
from typing import Optional
from loguru import logger
from fastapi import UploadFile

def save_upload_file(upload_file: UploadFile, destination: Path) -> None:
    try:
        with destination.open("wb") as buffer:
            shutil.copyfileobj(upload_file.file, buffer)
    finally:
        upload_file.file.close()

def ensure_directory_exists(directory: Path) -> None:
    if not directory.exists():
        directory.mkdir(parents=True, exist_ok=True)

def get_project_directory(project_name: str) -> Path:
    projects_root = Path("/home/coder/project")
    project_dir = projects_root / project_name
    
    if not project_dir.exists():
        raise FileNotFoundError(f"Project directory {project_dir} does not exist")
    
    if not project_dir.is_dir():
        raise NotADirectoryError(f"Path {project_dir} is not a directory")
    
    return project_dir

def validate_file_extension(filename: str, allowed_extensions: list) -> bool:
    return "." in filename and filename.rsplit(".", 1)[1].lower() in allowed_extensions