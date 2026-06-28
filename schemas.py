from pydantic import BaseModel
from uuid import UUID
from datetime import datetime

class TranslateRequest(BaseModel):
    text: str
    theme_id: UUID

class TranslateResponse(BaseModel):
    id: UUID
    word_native: str
    word_target: str
    created_at: datetime

    class Config:       # Inner class for Configuration
        from_attributes = True      # Allows the model to read data directly from SQLAlchemy
