from unittest.mock import ANY
import pytest

pytestmark = pytest.mark.asyncio

async def test_create_user(test_client):
    response = await test_client.post("/users/", json={"name": "John Doe"})
    assert response.status_code == 200
    assert response.json() == {"id": ANY, "name": "John Doe"}

async def test_read_users(test_client):
    await test_client.post("/users/", json={"name": "User1"})
    response = await test_client.get("/users/")
    assert response.status_code == 200
    assert len(response.json()) >= 1

async def test_read_user(test_client):
    create = await test_client.post("/users/", json={"name": "Single"})
    user_id = create.json()["id"]
    response = await test_client.get(f"/users/{user_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Single"

async def test_update_user(test_client):
    create = await test_client.post("/users/", json={"name": "Old"})
    user_id = create.json()["id"]
    response = await test_client.patch(f"/users/{user_id}", json={"name": "New"})
    assert response.status_code == 200
    assert response.json()["name"] == "New"

async def test_delete_user(test_client):
    create = await test_client.post("/users/", json={"name": "Delete"})
    user_id = create.json()["id"]
    delete = await test_client.delete(f"/users/{user_id}")
    assert delete.status_code == 200
    get = await test_client.get(f"/users/{user_id}")
    assert get.status_code == 404

async def test_read_nonexistent_user(test_client):
    response = await test_client.get("/users/99999")
    assert response.status_code == 404
