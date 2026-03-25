"""
Task Management API - Pydantic Schemas

Request/response validation schemas for Task endpoints.
"""

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field, field_validator


VALID_STATUSES = {"To-Do", "In Progress", "Done"}


class TaskCreate(BaseModel):
    """Schema for creating a new task."""

    title: str = Field(..., min_length=1, max_length=200, description="Task title")
    description: str = Field(default="", description="Task description")
    due_date: Optional[date] = Field(default=None, description="Task due date")
    status: str = Field(default="To-Do", description="Task status")
    blocked_by: Optional[str] = Field(
        default=None, description="UUID of the blocking task"
    )

    @field_validator("status")
    @classmethod
    def validate_status(cls, v: str) -> str:
        if v not in VALID_STATUSES:
            raise ValueError(f"Status must be one of: {', '.join(VALID_STATUSES)}")
        return v


class TaskUpdate(BaseModel):
    """Schema for updating an existing task."""

    title: Optional[str] = Field(
        default=None, min_length=1, max_length=200, description="Task title"
    )
    description: Optional[str] = Field(default=None, description="Task description")
    due_date: Optional[date] = Field(default=None, description="Task due date")
    status: Optional[str] = Field(default=None, description="Task status")
    blocked_by: Optional[str] = Field(
        default=None, description="UUID of the blocking task"
    )

    @field_validator("status")
    @classmethod
    def validate_status(cls, v: str | None) -> str | None:
        if v is not None and v not in VALID_STATUSES:
            raise ValueError(f"Status must be one of: {', '.join(VALID_STATUSES)}")
        return v


class TaskResponse(BaseModel):
    """Schema for task responses."""

    id: str
    title: str
    description: str
    due_date: Optional[date]
    status: str
    blocked_by: Optional[str]
    blocked_by_title: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
