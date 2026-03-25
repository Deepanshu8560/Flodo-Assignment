"""
Task Management API - FastAPI Application Entry Point

Initializes the FastAPI app with CORS middleware and router includes.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler - creates DB tables on startup."""
    await init_db()
    yield


app = FastAPI(
    title="Task Management API",
    description="REST API for managing tasks with dependency tracking",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS middleware for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "version": "1.0.0"}
