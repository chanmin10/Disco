from pydantic import BaseModel
from uuid import UUID
from typing import Optional

class TranslateRequest(BaseModel):
    theme_id: UUID
    text: str

class TranslateResponse(BaseModel):
    response: str
    text_native: str
    text_target: str

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "response": "*Hello*의 뜻은 *안녕하세요*라는 뜻입니다.",
                    "text_native": "안녕하세요",
                    "text_target": "Hello"
                }
            ]
        }
    }

class ClassifyRequest(BaseModel):
    theme_id: UUID
    text_native: str
    text_target: str

class ClassifyResponse(BaseModel):
    is_vocab: bool

class LLMRequest(BaseModel):
    theme_id: UUID
    text: str

class LLMResponse(BaseModel):
    text: str

class ThemeRequest(BaseModel):
    name: str
    target_language: str

class ThemeResponse(BaseModel):
    id: UUID
    name: str 
    target_language: str

    class Config:
        from_attributes = True

class VocabResponse(BaseModel):
    id: UUID
    theme_id: UUID
    word_native: str
    word_target: str
    example_sentence: Optional[str] = None

    class Config:
        from_attributes = True
