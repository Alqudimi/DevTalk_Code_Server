# api-gateway/app/routers/code_server.py
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from httpx import AsyncClient
from loguru import logger
from app.core.config import settings
from app.core.security import get_current_user

router = APIRouter()

@router.get("/status")
async def get_code_server_status(current_user: dict = Depends(get_current_user)):
    """
    الحصول على حالة code-server
    """
    try:
        async with AsyncClient() as client:
            response = await client.get(f"{settings.CODE_SERVER_URL}/health")
            return response.json()
    except Exception as e:
        logger.error(f"Error checking code-server status: {e}")
        raise HTTPException(status_code=503, detail="Code-server is not available")

@router.get("/workspace")
async def get_workspace_info(current_user: dict = Depends(get_current_user)):
    """
    الحصول على معلومات مساحة العمل
    """
    try:
        async with AsyncClient() as client:
            response = await client.get(f"{settings.CODE_SERVER_URL}/api/workspace")
            return response.json()
    except Exception as e:
        logger.error(f"Error getting workspace info: {e}")
        raise HTTPException(status_code=500, detail="Failed to get workspace info")

@router.post("/command")
async def execute_vscode_command(
    request: Request,
    current_user: dict = Depends(get_current_user)
):
    """
    تنفيذ أمر في VS Code
    """
    try:
        command_data = await request.json()
        async with AsyncClient() as client:
            response = await client.post(
                f"{settings.CODE_SERVER_URL}/api/command",
                json=command_data
            )
            return response.json()
    except Exception as e:
        logger.error(f"Error executing VS Code command: {e}")
        raise HTTPException(status_code=500, detail="Failed to execute command")

# يمكنك إضافة المزيد من النقاط هنا حسب الحاجة