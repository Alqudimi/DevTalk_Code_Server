# api-gateway/app/routers/extensions.py
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from httpx import AsyncClient
from loguru import logger
from app.core.config import settings
from app.core.security import get_current_user
from typing import List, Optional

router = APIRouter()

@router.get("/", response_model=List[dict])
async def list_extensions(current_user: dict = Depends(get_current_user)):
    """
    سرد جميع الإضافات المثبتة
    """
    try:
        async with AsyncClient() as client:
            response = await client.get(f"{settings.CODE_SERVER_URL}/api/extensions")
            return response.json()
    except Exception as e:
        logger.error(f"Error listing extensions: {e}")
        raise HTTPException(status_code=500, detail="Failed to list extensions")

@router.post("/install")
async def install_extension(
    extension_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    تثبيت إضافة جديدة
    """
    try:
        async with AsyncClient() as client:
            response = await client.post(
                f"{settings.CODE_SERVER_URL}/api/extensions/install",
                json={"id": extension_id}
            )
            return response.json()
    except Exception as e:
        logger.error(f"Error installing extension {extension_id}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to install extension {extension_id}"
        )

@router.delete("/uninstall")
async def uninstall_extension(
    extension_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    إزالة إضافة
    """
    try:
        async with AsyncClient() as client:
            response = await client.post(
                f"{settings.CODE_SERVER_URL}/api/extensions/uninstall",
                json={"id": extension_id}
            )
            return response.json()
    except Exception as e:
        logger.error(f"Error uninstalling extension {extension_id}: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Failed to uninstall extension {extension_id}"
        )
