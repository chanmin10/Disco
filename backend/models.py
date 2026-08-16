# Standard Library
from datetime import timezone   # Required for timezone-aware datetime fields
from re import I                # Case-insensitive flag for Regular Expression
import uuid                     # Generates uuid

# SQLAlchemy Package - Parsing Class to PostgreSQL
from sqlalchemy import CheckConstraint, Column, String, Integer, DateTime, Text, ForeignKey, Date # Core components for defining table schemas
from sqlalchemy.dialects.postgresql import UUID             # PostgreSQL-specific UUID data type
from sqlalchemy.orm import declarative_base                 # Function to create the base class for ORM models
from sqlalchemy.sql import func                             # Provides built-in SQL functions
from sqlalchemy import Index                                # Required to create database indexes

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
    example_sentence = Column(Text)
    source_engine = Column(Text, CheckConstraint("source_engine IN ('translation', 'gemini')"), nullable=False)
    review_count = Column(Integer, nullable=False, default=0)
    last_reviewed_at = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    __table_args__ = (
        Index('idx_vocab_theme', 'theme_id'),    )

class Profile(Base):
    __tablename__ = "profiles"

    id = Column(UUID(as_uuid=True), primary_key=True)
    plan = Column(String, nullable=False, default="free")
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class ApiUsage(Base):
    __tablename__ = "api_usage"

    user_id = Column(UUID(as_uuid=True), ForeignKey("profiles.id", ondelete="CASCADE"), primary_key=True, nullable=False)
    date = Column(Date, primary_key=True, nullable=False)
    ai_count = Column(Integer, nullable=False, default=0)
    quick_count = Column(Integer, nullable=False, default=0)
