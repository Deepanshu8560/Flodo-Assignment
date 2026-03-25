# Task Management Application

A production-ready, full-stack Task Management Application featuring a Flutter frontend and a FastAPI backend with SQLite.

## Overview

This application allows users to manage tasks with full CRUD operations. It supports dependency tracking (tasks can block other tasks), draft persistence for unsaved input, real-time search, and status filtering. It also implements localized UI states to reflect tasks that are blocked, and gracefully handles network simulated delays without blocking the UI.

### Key Features
- **Task Management**: Create, Read, Update, and Delete tasks.
- **Dependency Tracking**: Tasks can be blocked by another task. The system prevents circular dependencies (e.g., A blocks B, B blocks A).
- **Blocked UI State**: Blocked tasks appear visually distinct (greyed out, lock icon, lower opacity) in the UI. 
- **Draft Persistence**: Unfinished task creations/edits are auto-saved to local storage and restored when reopening the form.
- **Debounced Search**: Performant real-time search with highlighted text matches.
- **Status Filtering**: Filter tasks by "To-Do", "In Progress", or "Done".
- **Responsive UI**: Built with Clean Architecture principles in Flutter, leveraging Riverpod for state management.
- **Backend Delay Simulation**: All write operations (Create/Update) simulate a 2-second delay, with the frontend properly managing non-blocking loading states.

## Tech Stack

### Backend
- **Framework**: FastAPI (Python 3.9+)
- **Database**: SQLite (via `aiosqlite` for async operations)
- **ORM**: SQLAlchemy
- **Validation**: Pydantic
- **Testing**: Pytest, HTTPX

### Frontend
- **Framework**: Flutter (Dart)
- **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Networking**: `http`
- **Local Storage**: `shared_preferences`

---

## Setup Instructions

### 1. Backend Setup (FastAPI)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the server:
   ```bash
   uvicorn app.main:app --reload
   ```
   *The server will start on `http://127.0.0.1:8000`.*
   *API Documentation (Swagger UI) is available at `http://127.0.0.1:8000/docs`.*

### 2. Frontend Setup (Flutter)

1. Ensure the backend is running locally.
2. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
3. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```
   *Note: Ensure your emulator or physical device has network access to `localhost:8000` (or update `ApiConstants.baseUrl` in `lib/core/constants/app_constants.dart` if testing on a physical Android device to `http://10.0.2.2:8000`).*

---

## Architecture & Code Structure

The project strictly follows separation of concerns:

### Backend Structure
- `app/models/`: SQLAlchemy database models
- `app/schemas/`: Pydantic models for request/response validation
- `app/repositories/`: Data access layer handling database queries
- `app/services/`: Business logic layer (handles circular dependency checks, cascading unblocks, and the 2-second delay)
- `app/routes/`: API endpoint definitions

### Frontend Structure (Clean Architecture)
- `lib/core/`: App-wide utilities, constants, theme, and network services
- `lib/features/tasks/domain/`: Entities and Repository interfaces
- `lib/features/tasks/data/`: Remote data sources, API models, and Repository implementations
- `lib/features/tasks/presentation/`: Screens, widgets, and Riverpod state notifiers

---

## Testing

### Backend Tests
Navigate to the `backend/` directory and run:
```bash
pytest
```

### Frontend Tests
Navigate to the `frontend/` directory and run:
```bash
flutter test
```

---

## Commit History

This project was built simulating a real-world agile team with atomic, meaningful commits spanning 4 phases:
1. **Setup & Planning**: PRD creation and initial structure setup.
2. **Backend**: Models, API routes, and Business Logic.
3. **Frontend**: Clean Architecture foundation, UI states, draft persistence, debounced search.
4. **Testing & Polish**: Automated tests, code formatting, and final documentation.

*View the commit history to see the incremental development process.*
