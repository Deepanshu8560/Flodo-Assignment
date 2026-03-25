"""
Task Management API - Task Service

Business logic layer for task operations including validation,
circular dependency prevention, and simulated processing delay.
"""

import asyncio
from datetime import datetime
from typing import Optional

from fastapi import HTTPException

from app.models.task import Task
from app.repositories.task_repository import TaskRepository
from app.schemas.task import TaskCreate, TaskResponse, TaskUpdate


SIMULATED_DELAY_SECONDS = 2


class TaskService:
    """Service layer for task business logic."""

    def __init__(self, repository: TaskRepository):
        self.repository = repository

    async def create_task(self, task_data: TaskCreate) -> TaskResponse:
        """Create a new task with validation and simulated delay."""
        # Validate blocked_by reference exists
        if task_data.blocked_by:
            blocking_task = await self.repository.get_by_id(task_data.blocked_by)
            if not blocking_task:
                raise HTTPException(
                    status_code=400,
                    detail=f"Blocking task with ID '{task_data.blocked_by}' not found",
                )

        # Simulate processing delay
        await asyncio.sleep(SIMULATED_DELAY_SECONDS)

        task = Task(
            title=task_data.title,
            description=task_data.description,
            due_date=task_data.due_date,
            status=task_data.status,
            blocked_by=task_data.blocked_by,
        )

        created_task = await self.repository.create(task)
        return await self._to_response(created_task)

    async def get_all_tasks(self) -> list[TaskResponse]:
        """Get all tasks."""
        tasks = await self.repository.get_all()
        return [await self._to_response(task) for task in tasks]

    async def get_task(self, task_id: str) -> TaskResponse:
        """Get a single task by ID."""
        task = await self.repository.get_by_id(task_id)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")
        return await self._to_response(task)

    async def update_task(self, task_id: str, task_data: TaskUpdate) -> TaskResponse:
        """Update a task with validation, cycle detection, and simulated delay."""
        task = await self.repository.get_by_id(task_id)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        update_dict = task_data.model_dump(exclude_unset=True)

        # Validate blocked_by if being updated
        if "blocked_by" in update_dict and update_dict["blocked_by"] is not None:
            new_blocked_by = update_dict["blocked_by"]

            # Prevent self-referencing
            if new_blocked_by == task_id:
                raise HTTPException(
                    status_code=400, detail="A task cannot block itself"
                )

            # Validate blocking task exists
            blocking_task = await self.repository.get_by_id(new_blocked_by)
            if not blocking_task:
                raise HTTPException(
                    status_code=400,
                    detail=f"Blocking task with ID '{new_blocked_by}' not found",
                )

            # Check for circular dependencies
            await self._check_circular_dependency(task_id, new_blocked_by)

        # Simulate processing delay
        await asyncio.sleep(SIMULATED_DELAY_SECONDS)

        updated_task = await self.repository.update(task, update_dict)
        return await self._to_response(updated_task)

    async def delete_task(self, task_id: str) -> dict:
        """Delete a task."""
        task = await self.repository.get_by_id(task_id)
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        await self.repository.delete(task)
        return {"message": "Task deleted successfully", "id": task_id}

    async def _check_circular_dependency(
        self, task_id: str, new_blocked_by: str
    ) -> None:
        """
        Check if setting blocked_by would create a circular dependency.

        Traverses the dependency chain from new_blocked_by upward to see
        if it eventually reaches task_id.
        """
        chain = await self.repository.get_dependency_chain(new_blocked_by)
        if task_id in chain:
            raise HTTPException(
                status_code=400,
                detail="Circular dependency detected. This would create a cycle in the task dependency chain.",
            )

    async def _to_response(self, task: Task) -> TaskResponse:
        """Convert a Task model to a TaskResponse schema."""
        blocked_by_title = None
        if task.blocked_by:
            blocking_task = await self.repository.get_by_id(task.blocked_by)
            if blocking_task:
                blocked_by_title = blocking_task.title

        return TaskResponse(
            id=task.id,
            title=task.title,
            description=task.description or "",
            due_date=task.due_date,
            status=task.status,
            blocked_by=task.blocked_by,
            blocked_by_title=blocked_by_title,
            created_at=task.created_at,
            updated_at=task.updated_at,
        )
