"""
Task Management API - Task Routes

REST API endpoints for task CRUD operations.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.repositories.task_repository import TaskRepository
from app.schemas.task import TaskCreate, TaskResponse, TaskUpdate
from app.services.task_service import TaskService

router = APIRouter(prefix="/tasks", tags=["Tasks"])


def get_task_service(db: AsyncSession = Depends(get_db)) -> TaskService:
    """Dependency injection for TaskService."""
    repository = TaskRepository(db)
    return TaskService(repository)


@router.post("/", response_model=TaskResponse, status_code=201)
async def create_task(
    task_data: TaskCreate,
    service: TaskService = Depends(get_task_service),
):
    """Create a new task."""
    return await service.create_task(task_data)


@router.get("/", response_model=list[TaskResponse])
async def get_tasks(
    service: TaskService = Depends(get_task_service),
):
    """Get all tasks."""
    return await service.get_all_tasks()


@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(
    task_id: str,
    service: TaskService = Depends(get_task_service),
):
    """Get a single task by ID."""
    return await service.get_task(task_id)


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: str,
    task_data: TaskUpdate,
    service: TaskService = Depends(get_task_service),
):
    """Update an existing task."""
    return await service.update_task(task_id, task_data)


@router.delete("/{task_id}")
async def delete_task(
    task_id: str,
    service: TaskService = Depends(get_task_service),
):
    """Delete a task."""
    return await service.delete_task(task_id)
