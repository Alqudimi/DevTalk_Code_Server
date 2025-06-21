# api-gateway/app/routers/terminal.py
from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from httpx import AsyncClient
from loguru import logger
from app.core.config import settings
from app.core.security import get_current_user
import asyncio

router = APIRouter()

@router.websocket("/ws")
async def websocket_terminal(
    websocket: WebSocket,
    shell: str = "zsh",
    current_user: dict = Depends(get_current_user)
):
    """
    اتصال WebSocket للطرفية التفاعلية
    """
    await websocket.accept()
    try:
        async with AsyncClient() as client:
            # إنشاء جلسة طرفية جديدة
            term_resp = await client.post(
                f"{settings.CODE_SERVER_URL}/api/terminal",
                json={"shell": shell}
            )
            term_id = term_resp.json().get("id")
            
            if not term_id:
                raise HTTPException(status_code=500, detail="Failed to create terminal")
            
            # الاتصال بالطرفية عبر WebSocket
            async with client.stream(
                "GET",
                f"{settings.CODE_SERVER_URL}/api/terminal/{term_id}/ws"
            ) as response:
                async for chunk in response.aiter_bytes():
                    await websocket.send_bytes(chunk)
                
                async for message in websocket.iter_bytes():
                    # إعادة توجيه البيانات إلى طرفية code-server
                    await client.post(
                        f"{settings.CODE_SERVER_URL}/api/terminal/{term_id}/write",
                        content=message
                    )
    except WebSocketDisconnect:
        logger.info("Terminal WebSocket disconnected")
    except Exception as e:
        logger.error(f"Terminal error: {e}")
        await websocket.close(code=1011)