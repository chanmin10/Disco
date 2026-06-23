from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from database import get_db
from models import Theme, VocabEntry
from schemas import TranslateRequest, TranslateResponse
import httpx
import os

app = FastAPI()

@app.get("/health")
async def heath_check(db: AsyncSession = Depends(get_db)):
    await db.execute(text("SELECT 1"))
    return {"status": "ok"}

@app.post("/translate", response_model=TranslateResponse)
async def translate(request: TranslateRequest, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, request.theme_id)
    
    if theme is None:
        raise HTTPException(status_code=404, detail="Theme not found")

    api_key = os.environ["GOOGLE_TRANSLATE_API_KEY"]

    async with httpx.AsyncClient() as client:
        response = await client.post(
                "https://translation.googleapis.com/language/translate/v2",
                params={"key": api_key},
                json={
                    "q": request.text,
                    "target": theme.target_language,
                    "format": "text"
                }
            )

    result = response.json()["data"]["translations"][0]
    translatedText = result["translatedText"]
    detectedSourceLanguage = result["detectedSourceLanguage"]
    
    if detectedSourceLanguage == theme.target_language:
        text_native = translatedText 
        text_target  = request.text 
    else:
        text_native = request.text
        text_target = translatedText

    entry = VocabEntry(
        theme_id = request.theme_id,
        word_native = text_native,
        word_target = text_target,
        source_engine = "translation",
        language_pair = f"ko-{theme.target_language}"
    )
    db.add(entry)
    await db.commit()
    await db.refresh(entry)

    return entry
