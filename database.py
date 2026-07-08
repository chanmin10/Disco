from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession,  async_sessionmaker
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.environ["DATABASE_URL"]

engine = create_async_engine(
        DATABASE_URL,
        connect_args={"statement_cache_size": 0}
)

AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False      # Prevents database objects from expiring after a commit
)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
