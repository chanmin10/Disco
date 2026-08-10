from fastapi import FastAPI, Depends, HTTPException, APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text, select
from database import get_db
from models import Theme, VocabEntry
from schemas import ThemeRequest, ThemeResponse, TranslateRequest, TranslateResponse, ClassifyRequest, ClassifyResponse, LLMRequest, LLMResponse, VocabResponse
from prompts import VOCAB_CLASSIFIER_PROMPT, GEMINI_TRANSLATE_PROMPT
import httpx
import os
import json
from uuid import UUID
from auth import get_current_user

app = FastAPI()
public_router = APIRouter()
private_router = APIRouter(dependencies=[Depends(get_current_user)])

# Health Check
@public_router.get("/health")
async def heath_check(db: AsyncSession = Depends(get_db)):      # Invokes depends() before execution
    await db.execute(text("SELECT 1"))
    return {"status": "ok"}

@private_router.post("/translate/quick", response_model=TranslateResponse)
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

@private_router.post("/translate/classify", response_model = ClassifyResponse)
async def classify(request: ClassifyRequest, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, request.theme_id)

    if theme is None:
        raise HTTPException(status_code=404, detail="Theme not found")

    gemini_key = os.environ["GEMINI_API_KEY"]
    prompt = VOCAB_CLASSIFIER_PROMPT\
            .replace("{{language_pair}}", f"ko-{theme.target_language}")\
            .replace("{{text_native}}", request.text_native)\
            .replace("{{text_target}}", request.text_target)

    async with httpx.AsyncClient(timeout=30.0) as client:
        gemini_response = await client.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={gemini_key}",
            json={
                "contents": [                        
                    {
                        "parts": [{"text": prompt}]
                    }
                ]
            }
        )
        
        response_text = gemini_response.json()["candidates"][0]["content"]["parts"][0]["text"]
        print(response_text)
        parsed = json.loads(response_text)

        if parsed["is_vocab"]:
            existing = await db.execute(
                select(VocabEntry).where(
                    VocabEntry.theme_id == request.theme_id,
                    VocabEntry.word_target == request.text_target
                )
            )
            existing_entry = existing.scalar_one_or_none()

            if existing_entry:
                pass
            else:
                entry = VocabEntry(
                    theme_id = request.theme_id,
                    word_native = request.text_native,
                    word_target = request.text_target,
                    source_engine = "translation",
                )
                db.add(entry)
                await db.commit()
                await db.refresh(entry)
        
        return ClassifyResponse(is_vocab = parsed["is_vocab"])

@private_router.post("/translate/ai", response_model=LLMResponse)
async def translate_ai(request: LLMRequest, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, request.theme_id)

    if theme is None:
        raise HTTPException(status_code=404, detail="Theme not found")

    gemini_key = os.environ["GEMINI_API_KEY"]
    prompt = GEMINI_TRANSLATE_PROMPT\
            .replace("{{title}}", theme.name)\
            .replace("{{native_language}}", "ko")\
            .replace("{{target_language}}", theme.target_language)\
            .replace("{{input}}", request.text)

    async with httpx.AsyncClient(timeout=30.0) as client:
        gemini_response = await client.post(
             f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={gemini_key}",
             json={
                 "contents": [
                     {
                         "parts": [{"text": prompt}]
                     }
                 ]
             }
        )
        response_text = gemini_response.json()["candidates"][0]["content"]["parts"][0]["text"]
        splited_text = response_text.split("```")
        parsed_text = splited_text[0]
        parsed_json = splited_text[1].replace("json\n", "", 1)
        converted_json = json.loads(parsed_json)

        if(converted_json["is_vocab"]):
            existing = await db.execute(
                select(VocabEntry).where(
                    VocabEntry.theme_id == request.theme_id,
                    VocabEntry.word_target == converted_json["word_target"]
                )
            )
            existing_entry = existing.scalar_one_or_none()

            if existing_entry:
                existing_entry.word_target = converted_json["word_target"]
                existing_entry.word_native = converted_json["word_native"]
                existing_entry.source_engine = "gemini"
                await db.commit()
            else:
                entry = VocabEntry(
                    theme_id = request.theme_id,
                    word_native = converted_json["word_native"],
                    word_target = converted_json["word_target"],
                    example_sentence = converted_json["example_sentence"],
                    source_engine = "gemini"
                )
                db.add(entry)
                await db.commit()
                await db.refresh(entry)

        return LLMResponse(text = parsed_text)

@private_router.post("/themes", response_model=ThemeResponse)
async def create_theme(request: ThemeRequest, db: AsyncSession = Depends(get_db)):
    theme = Theme(
        name = request.name,
        target_language = request.target_language
    )
    db.add(theme)
    await db.commit()
    await db.refresh(theme)

    return theme

@private_router.get("/themes", response_model=list[ThemeResponse])
async def get_themes(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Theme))
    themes = result.scalars().all()

    return themes

@private_router.get("/vocab", response_model=list[VocabResponse])
async def get_vocab(theme_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(VocabEntry).where(VocabEntry.theme_id == theme_id)
    )
    vocab = result.scalars().all()
    
    return vocab

@private_router.delete("/vocab/{entry_id}")
async def delete_vocab(entry_id: UUID, db: AsyncSession = Depends(get_db)):
    entry = await db.get(VocabEntry, entry_id)
    
    if entry is None:
        return {"message": "Entry not found"}

    await db.delete(entry)
    await db.commit()
    return {"message": "Entry deleted successfully"}

@private_router.delete("/themes/{theme_id}")
async def delete_theme(theme_id: UUID, db: AsyncSession = Depends(get_db)):
    theme = await db.get(Theme, theme_id)
    if theme is None:
        return {"message": "Theme not found"}

    await db.delete(theme)
    await db.commit()
    return {"message": "Theme deleted successfully"}

app.include_router(public_router)
app.include_router(private_router)
