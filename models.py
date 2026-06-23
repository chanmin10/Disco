from datetime import timezone
from re import I

from sqlalchemy import CheckConstraint, Column, String, Integer, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import declarative_base
from sqlalchemy.sql import func
from sqlalchemy import Index
import uuid

Base = declarative_base()

class Theme(Base):
    __tablename__ = "themes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(Text, nullable=False)
    target_language = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class Session(Base):
    __tablename__ = "sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    theme_id = Column(UUID(as_uuid=True), ForeignKey("themes.id", ondelete="CASCADE"), nullable=False)
    title = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    
    __table_args__ = (
        Index('idx_session_theme', 'theme_id'),
    )

class VocabEntry(Base):
    __tablename__ = "vocab_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    theme_id = Column(UUID(as_uuid=True), ForeignKey("themes.id", ondelete="CASCADE"), nullable=False)
    session_id = Column(UUID(as_uuid=True), ForeignKey("sessions.id", ondelete="SET NULL"))
    word_native = Column(Text, nullable=False)
    word_target = Column(Text, nullable=False)
    source_engine = Column(Text, CheckConstraint("source_engine IN ('translation', 'gemini')"), nullable=False)
    language_pair = Column(Text, nullable=False)
    review_count = Column(Integer, nullable=False, default=0)
    last_reviewed_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        Index('idx_vocab_theme', 'theme_id'),
    )
