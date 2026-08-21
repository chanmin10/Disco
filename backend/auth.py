from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from supabase import create_client
from dotenv import load_dotenv
import os
from datetime import date
from models import ApiUsage
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

AI_LIMIT = 20
QUICK_LIMIT = 100

load_dotenv()

supabase = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_KEY"]
)

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        user = supabase.auth.get_user(token)
        return user
    except Exception:
        raise HTTPException(
            status_code = status.HTTP_401_UNAUTHORIZED,
            detail = "Invalid or expired token"
        )

async def check_and_increment(
        limit_type: str,
        user,
        db: AsyncSession
        ):
    user_id = user.user.id
    today = date.today()

    result = await db.execute(
        select(ApiUsage).where(
            ApiUsage.user_id == user_id,
            ApiUsage.date == today
        )
    )
    usage = result.scalar_one_or_none()

    if usage is None:
        usage = ApiUsage(
            user_id = user_id,
            date = today,
            ai_count = 0,
            quick_count = 0
        )
        db.add(usage)
        await db.flush()

    if limit_type == "ai":
        if usage.ai_count >= AI_LIMIT:
            raise HTTPException(
                status_code=429,
                detail=f"AI 번역 하루 한도({AI_LIMIT}회)를 초과했습니다."
            )
        usage.ai_count += 1
        
    elif limit_type == "quick":
        if usage.quick_count >= QUICK_LIMIT:
            raise HTTPException(
                status_code=429,
                detail=f"빠른 번역 하루 한도({QUICK_LIMIT}회)를 초과했습니다."
            )
        usage.quick_count += 1

    await db.commit()

