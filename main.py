from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from database import get_db
from models import Theme, VocabEntry
from schemas import TranslateRequest, TranslateResponse, ClassifyRequest, ClassifyResponse
from prompts import VOCAB_CLASSIFIER_PROMPT, GEMINI_TRANSLATE_PROMPT
import httpx
import os
import json

app = FastAPI()

# Health Check
@app.get("/health")
async def heath_check(db: AsyncSession = Depends(get_db)):      # Invokes depends() before execution
    await db.execute(text("SELECT 1"))
    return {"status": "ok"}

@app.post("/translate/quick", response_model=TranslateResponse)
async def translate(request: TranslateRequest, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, request.theme_id)
    
    if theme is None:
        raise HTTPException(status_code=404, detail="Theme not found")

    translation_key = os.environ["GOOGLE_TRANSLATE_API_KEY"]

    async with httpx.AsyncClient() as client:
        response = await client.post(
                "https://translation.googleapis.com/language/translate/v2",
                params={"key": translation_key},
                json={
                    "q": request.text,
                    "target": theme.target_language,
                    "format": "text"
                }
            )

        result = response.json()["data"]["translations"][0]
        detectedSourceLanguage = result["detectedSourceLanguage"]
        translatedText = result["translatedText"]

        if detectedSourceLanguage == theme.target_language:
            response = await client.post(
                "https://translation.googleapis.com/language/translate/v2",
                params={"key": translation_key},
                json={
                    "q": request.text,
                    "source": theme.target_language,
                    "target": "ko",         # Sets user's native language to Korean for now
                    "format": "text"
                }
            )
            
            result = response.json()["data"]["translations"][0]
            detectedSourceLanguage = result["detectedSourceLanguage"]
            translatedText = result["translatedText"]

            text_native, text_target = translatedText, request.text 
            return TranslateResponse(
                        response = text_native,
                        text_native = text_native,
                        text_target = text_target
                    )
        else:
            text_native, text_target = request.text, translatedText
            return TranslateResponse(
                        response = text_target,
                        text_native = text_native,
                        text_target = text_target
                    )

@app.post("/translate/classify", response_model = ClassifyResponse)
async def classify(request: ClassifyRequest, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, request.theme_id)

    if theme is None:
        raise HTTPException(status_code=404, detail="Theme not found")

    gemini_key = os.environ["GEMINI_API_KEY"]
    prompt = VOCAB_CLASSIFIER_PROMPT\
            .replace("{{LANGUAGE_PAIR}}", f"ko-{theme.target_language}")\
            .replace("{{TEXT_NATIVE}}", request.text_native)\
            .replace("{{TEXT_TARGET}}", request.text_target)

    async with httpx.AsyncClient() as client:
        gemini_response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={gemini_key}",
            json={
                "contents": [                        
                    {
                        "parts": [{"text": prompt}]
                    }
                ]
            }
        )
        
        response_text = gemini_response.json()["candidates"][0]["content"]["parts"][0]["text"]
        parsed = json.loads(response_text)

        if parsed["is_vocab"]:
            entry = VocabEntry(
                theme_id = request.theme_id,
                word_native = request.text_native,
                word_target = request.text_target,
                source_engine = "translation",
            )
            db.add(entry)
            await db.commit()
            await db.refresh(entry)
        
        return ClassifyResponse(
                    is_vocab = parsed["is_vocab"]
                )

