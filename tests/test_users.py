import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    response = await client.post("/users/", json={"name": "Test User"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Test User"
    assert "id" in data

@pytest.mark.asyncio
async def test_read_users(client: AsyncClient):
    await client.post("/users/", json={"name": "User1"})
    await client.post("/users/", json={"name": "User2"})
    response = await client.get("/users/")
    assert response.status_code == 200
    assert len(response.json()) >= 2

@pytest.mark.asyncio
async def test_read_user(client: AsyncClient):
    create_resp = await client.post("/users/", json={"name": "Single User"})
    user_id = create_resp.json()["id"]
    response = await client.get(f"/users/{user_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Single User"

@pytest.mark.asyncio
async def test_update_user(client: AsyncClient):
    create_resp = await client.post("/users/", json={"name": "Old Name"})
    user_id = create_resp.json()["id"]
    response = await client.patch(f"/users/{user_id}", json={"name": "New Name"})
    assert response.status_code == 200
    assert response.json()["name"] == "New Name"

@pytest.mark.asyncio
async def test_delete_user(client: AsyncClient):
    create_resp = await client.post("/users/", json={"name": "To Delete"})
    user_id = create_resp.json()["id"]
    
    delete_resp = await client.delete(f"/users/{user_id}")
    assert delete_resp.status_code == 200
    
    get_resp = await client.get(f"/users/{user_id}")
    assert get_resp.status_code == 404

@pytest.mark.asyncio
async def test_read_nonexistent_user(client: AsyncClient):
    response = await client.get("/users/99999")
    assert response.status_code == 404
