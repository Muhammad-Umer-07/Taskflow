# TaskFlow — Collaborative Task Management System

TaskFlow is a state-of-the-art Ruby on Rails 8.1 collaborative task management application. It features strict role-based access control, relational database consistency, query optimizations, and a premium modern front-end layout styled with Tailwind CSS.

---

## Technical Stack & Dependencies

* **Framework**: Ruby on Rails 8.1.3 (Ruby 3.2+)
* **Database**: PostgreSQL
* **Authentication**: Devise
* **Authorization**: Pundit
* **Front-end / Styling**: Tailwind CSS, Google Fonts (Outfit & Inter), HTML5 / ERB.

---

## Architectural Breakdown

### 1. Models & Associations

* **`User`** (`app/models/user.rb`)
  * Managed by Devise for authentication.
  * Roles defined dynamically via an ActiveRecord enum: `admin` (0), `manager` (1), `member` (2).
* **`Project`** (`app/models/project.rb`)
  * Belongs to a single creator (`User`).
  * Has many project memberships and workspace tasks.
  * Validates that project titles must be unique scoped to their creator.
  * Uses a callback to automatically insert the project creator as the first `manager` in the membership list.
* **`ProjectMembership`** (`app/models/project_membership.rb`)
  * Establishes the relationship between users and projects.
  * Roles: `manager` (0) and `member` (1).
  * Validates unique user/project combinations to block double-entry.
* **`Task`** (`app/models/task.rb`)
  * Belongs to a project and an optional assignee (`User`).
  * Enums for execution status: `todo` (0), `in_progress` (1), `done` (2).
  * Enforces custom validation (`assignee_must_be_project_member`) ensuring that a task is only assigned to registered project members.

### 2. Authorization Scopes (Pundit Policies)

Authorization is managed via strict Pundit policy files:
* **`ProjectPolicy`** (`app/policies/project_policy.rb`)
  * **Scopes**: Admins list all projects, Managers list their owned/joined projects, and Members list only projects they collaborate on.
  * **Actions**: Only Admins and the Project Creator can update or destroy a project.
* **`TaskPolicy`** (`app/policies/task_policy.rb`)
  * **Permissions**: Members can view tasks that belong to projects they reside on but cannot construct or destroy them.
  * **Permitted Attributes**: Allows dynamic strong parameters check block using `permitted_attributes`:
    * Admins and Project Managers can modify all fields (`title`, `description`, `assignee_id`, `status`).
    * Members assigned to a task can **only** update its execution status (`status`).
    * Other members cannot modify task parameters.

### 3. Controllers & Query Optimizations

* **`DashboardController`** (`app/controllers/dashboard_controller.rb`)
  * Optimizes database accesses using `.includes(:project, :assignee)` on assigned tasks to eliminate N+1 queries.
  * Provides quick filter methods to scope task queries relative to their status.
* **`TasksController`** (`app/controllers/tasks_controller.rb`)
  * Uses Pundit's strong parameters pattern (i.e. `permitted_attributes`) to selectively process updates based on security roles.

### 4. Views & Premium UI

* **Modern Layout Shell** (`app/views/layouts/application.html.erb`): Integrated standard Tailwind CSS, glowing header navigation, and micro-animated alert notices.
* **Landing Page** (`app/views/home/index.html.erb`): Role explanation block outlining Admin, Manager, and Member permissions.
* **Workspace Dashboard** (`app/views/dashboard/index.html.erb`): Showcases quick status counters (Projects count, Done tasks, Todo tasks) alongside status pill selectors.
* **Workspaces & Kanban Views** (`app/views/projects/show.html.erb`, `app/views/tasks/index.html.erb`): Clean tables listing collaborator addresses, inline membership removal forms, and task edit grids.

---

## Getting Started

### Installation
1. Install project dependencies:
   ```bash
   bundle install
   ```
2. Setup the database and migrate the schema:
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```
3. Load seed data (if any):
   ```bash
   bundle exec rails db:seed
   ```

### Execution
Spawn the Rails development server:
```bash
bin/rails server
```
Then visit the application page locally at `http://localhost:3000`.

---

## Running the Test Suite

Execute the unit test and policy suite using standard minitest engines:
```bash
bundle exec rails test
```
The test suite validates model uniqueness constraints, Devise session variables, and Pundit capability checks.

