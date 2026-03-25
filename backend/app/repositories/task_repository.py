"""
Task Management API - Task Repository

Data access layer for Task CRUD operations using async SQLAlchemy.
"""

from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.task import Task


class TaskRepository:
    """Repository for Task database operations."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, task: Task) -> Task:
        """Create a new task."""
        self.db.add(task)
        await self.db.flush()
        await self.db.refresh(task)
        return task

    async def get_all(self) -> list[Task]:
        """Get all tasks."""
        result = await self.db.execute(select(Task).order_by(Task.created_at.desc()))
        return list(result.scalars().all())

    async def get_by_id(self, task_id: str) -> Optional[Task]:
        """Get a task by ID."""
        result = await self.db.execute(select(Task).where(Task.id == task_id))
        return result.scalar_one_or_none()

    async def update(self, task: Task, update_data: dict) -> Task:
        """Update a task with the given data."""
        for key, value in update_data.items():
            if value is not None:
                setattr(task, key, value)
        await self.db.flush()
        await self.db.refresh(task)
        return task

    async def delete(self, task: Task) -> None:
        """Delete a task and unblock any tasks blocked by it."""
        # Unblock tasks that are blocked by this task
        result = await self.db.execute(
            select(Task).where(Task.blocked_by == task.id)
        )
        blocked_tasks = result.scalars().all()
        for blocked_task in blocked_tasks:
            blocked_task.blocked_by = None

        await self.db.delete(task)
        await self.db.flush()

    async def get_dependency_chain(self, task_id: str) -> set[str]:
        """Get the full chain of blocking dependencies for cycle detection."""
        chain = set()
        current_id = task_id

        while current_id:
            if current_id in chain:
                break
            chain.add(current_id)
            task = await self.get_by_id(current_id)
            if task is None:
                break
            current_id = task.blocked_by

        return chain
