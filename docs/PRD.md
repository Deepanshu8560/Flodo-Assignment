# Product Requirements Document (PRD)
## Task Management Application

**Version**: 1.0
**Date**: 2026-03-25
**Author**: Product Manager Agent

---

## 1. Problem Statement

Teams and individuals struggle with managing tasks effectively, especially when tasks have dependencies. Existing tools either lack dependency management or are overly complex. This application provides a streamlined task management experience with dependency tracking, draft persistence, and intuitive UI states for blocked tasks.

## 2. Target Users

- **Individual contributors** managing personal task lists
- **Small teams** (2-10 people) coordinating dependent work items
- **Project managers** tracking task status and dependencies

## 3. Functional Requirements

### 3.1 Task Model

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Auto | Unique identifier |
| `title` | String | Yes | Task title (1-200 chars) |
| `description` | String | No | Detailed description |
| `due_date` | Date | No | Task deadline |
| `status` | Enum | Yes | "To-Do", "In Progress", "Done" |
| `blocked_by` | UUID (FK) | No | Reference to blocking task |
| `created_at` | DateTime | Auto | Creation timestamp |
| `updated_at` | DateTime | Auto | Last update timestamp |

### 3.2 Core Features

#### CRUD Operations
- **Create**: Add new tasks with all fields; 2-second simulated processing delay
- **Read**: List all tasks with pagination-ready design; view individual task details
- **Update**: Edit any field; 2-second simulated processing delay
- **Delete**: Remove task; cascade-update tasks blocked by deleted task (set `blocked_by` to null)

#### Search & Filter
- **Search**: Filter tasks by title substring (case-insensitive)
- **Filter**: Filter by status ("To-Do", "In Progress", "Done", "All")
- **Combined**: Search + filter can be applied simultaneously

#### Draft Persistence
- Auto-save form fields to local storage while creating/editing
- Recover unsaved input on app restart or navigation return
- Clear draft on successful submission

#### Blocked Task Behavior
- Visual differentiation: greyed out card, lock icon
- Display blocking task name on blocked task card
- Prevent status change to "Done" while blocked
- Allow editing other fields of blocked tasks

#### Non-blocking UI & Duplicate Prevention
- Loading overlay during 2-second API delay
- UI remains responsive (non-blocking)
- Submit button disabled during pending request
- Debounced search input (300ms delay)

## 4. User Flows

### 4.1 Create Task
1. User taps "Add Task" FAB
2. Create form opens (pre-filled with any saved draft)
3. User fills in title (required), description, due date, status, blocked_by
4. User taps "Save"
5. Submit button disables, loading indicator appears
6. After 2s delay, task is created
7. Draft is cleared, user returns to task list
8. New task appears in list

### 4.2 Edit Task
1. User taps a task card
2. Edit form opens with current values
3. User modifies fields
4. Changes auto-save to draft storage
5. User taps "Update"
6. Loading indicator for 2s, then updated
7. Draft cleared, return to list

### 4.3 Delete Task
1. User taps delete icon on task card
2. Confirmation dialog appears
3. On confirm, task is deleted
4. Any tasks blocked by this task get `blocked_by` set to null

### 4.4 Search & Filter
1. User types in search bar (top of list screen)
2. After 300ms debounce, results filter in real-time
3. Matching text highlighted in results
4. User can also select status filter dropdown
5. Filters combine: search text AND status

## 5. Edge Cases

### 5.1 Circular Dependencies
- **Prevention**: Backend validates that setting `blocked_by` does not create a cycle
- **Example**: If Task A is blocked by Task B, Task B cannot be set to blocked by Task A
- **Response**: Return 400 error with descriptive message

### 5.2 Deletion of Blocking Task
- When a blocking task is deleted, all tasks it blocks get `blocked_by` set to null
- Those tasks become unblocked and UI updates accordingly

### 5.3 Self-referencing
- A task cannot block itself. Backend rejects `blocked_by = self.id`

### 5.4 Network Errors
- Display error snackbar on API failure
- Retain form data (don't clear draft on failure)
- Allow retry

### 5.5 Empty States
- Show friendly empty state when no tasks exist
- Show "No results" when search/filter yields nothing

## 6. UX Requirements

### 6.1 Loading States
- Shimmer/skeleton loading on initial task list fetch
- Circular progress indicator on create/update (overlay, non-blocking)
- Pull-to-refresh on task list

### 6.2 Blocked Task UI
- Greyed-out card background
- Lock icon overlaid on card
- "Blocked by: [Task Title]" label
- Reduced opacity for blocked task content

### 6.3 Animations
- Smooth list item transitions on add/remove
- Form field focus animations
- Loading state transitions

### 6.4 Responsive Design
- Works on mobile and web (Flutter)
- Responsive layout adjustments

## 7. Non-functional Requirements

| Requirement | Target |
|------------|--------|
| API Response Time | < 3s (including 2s simulated delay) |
| App Startup | < 2s on modern devices |
| Draft Save Latency | < 100ms (local storage) |
| Search Debounce | 300ms |
| Concurrent Users | Support async operations (no blocking) |
| Code Quality | Clean Architecture, SOLID principles |
| Test Coverage | Unit + Integration tests for core features |

## 8. Stretch Goals

- [x] **Debounced search with highlighted matches** (included in MVP)
- [ ] Task sorting (by due date, status, creation date)
- [ ] Bulk status updates
- [ ] Dark mode toggle
- [ ] Task history/audit log

## 9. Acceptance Criteria

### Must Pass
- [ ] Create a task with all fields → appears in list
- [ ] Edit a task → changes reflected in list
- [ ] Delete a task → removed from list, blocked tasks unblocked
- [ ] Search by title → filtered results with highlights
- [ ] Filter by status → correct subset shown
- [ ] Set blocked_by → task shows blocked UI
- [ ] Circular dependency → rejected with error
- [ ] 2-second delay on create/update → loading indicator shown
- [ ] UI is non-blocking during delay
- [ ] Double-click submit → only one task created
- [ ] Close app mid-form → draft recovered on return
- [ ] Delete blocking task → blocked task becomes unblocked

### Should Pass
- [ ] Empty states display correctly
- [ ] Error handling shows user-friendly messages
- [ ] Animations are smooth
- [ ] Search + filter combine correctly
