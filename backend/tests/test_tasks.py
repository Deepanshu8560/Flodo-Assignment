import pytest
from httpx import AsyncClient, ASGITransport
import asyncio
from app.main import app

@pytest.fixture(scope="module")
def event_loop():
    """Create an instance of the default event loop for each test case."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture(scope="module")
async def async_client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        yield client

@pytest.mark.asyncio
async def test_health_check(async_client):
    response = await async_client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

@pytest.mark.asyncio
async def test_create_and_get_task(async_client):
    # Create task
    task_data = {
        "title": "Test Task",
        "description": "This is a test task",
        "status": "To-Do"
    }
    create_response = await async_client.post("/tasks", json=task_data)
    assert create_response.status_code == 201
    
    created_task = create_response.json()
    assert created_task["title"] == task_data["title"]
    task_id = created_task["id"]
    
    # Get all tasks
    get_response = await async_client.get("/tasks")
    assert get_response.status_code == 200
    tasks = get_response.json()
    assert any(t["id"] == task_id for t in tasks)

@pytest.mark.asyncio
async def test_circular_dependency(async_client):
    # Create Task A
    res_a = await async_client.post("/tasks", json={"title": "Task A", "status": "To-Do"})
    task_a = res_a.json()
    
    # Create Task B blocked by Task A
    res_b = await async_client.post("/tasks", json={
        "title": "Task B", 
        "status": "To-Do",
        "blocked_by": task_a["id"]
    })
    task_b = res_b.json()
    
    # Try to update Task A to be blocked by Task B (Circular dependency)
    res_update_a = await async_client.put(f"/tasks/{task_a['id']}", json={
        "title": "Task A Updated",
        "blocked_by": task_b["id"]
    })
    
    # Should get 400 Bad Request
    assert res_update_a.status_code == 400
    assert "circular dependency" in res_update_a.json()["detail"].lower()
