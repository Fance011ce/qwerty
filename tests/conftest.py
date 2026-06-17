import pytest_asyncio
from httpx import AsyncClient
from src.main import app
from src.database import Base, get_db
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

# Тестовая БД в памяти
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

test_engine = create_async_engine(TEST_DATABASE_URL, echo=False)
TestingSessionLocal = sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)

async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session

@pytest_asyncio.fixture(autouse=True)
async def setup_db():
    # Создаем таблицы
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Подменяем зависимость
    app.dependency_overrides[get_db] = override_get_db
    yield
    app.dependency_overrides.clear()

@pytest_asyncio.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client
