# TaskFlow

TaskFlow is a Ruby on Rails application for managing projects, project memberships, and assigned tasks with
role-based authorization.

## Features

- Public landing page with Devise registration and authentication
- Dashboard showing projects and tasks assigned to the signed-in user
- Dashboard task filtering by `todo`, `in_progress`, or `done` status
- Project creation and management
- Project-level manager and member roles
- Task assignment restricted to members of the task's project
- Status-only task updates for assigned members
- Administrative user and role management
- Pundit authorization and policy scopes

## Roles and permissions

| Role | Permissions |
| --- | --- |
| Admin | View all projects and tasks, create/update/delete projects, manage project members and tasks, and manage users |
| Manager | Create projects; manage projects they created; view projects they joined |
| Project manager | Manage members and tasks in the joined project, but cannot edit or delete a project they did not create |
| Member | View joined projects and tasks; update only the status of tasks assigned to them |

`manager` and `member` are application-level user roles. A project membership separately records whether a user is a
project `manager` or `member`.

## Technology

- Ruby 4.0.6
- Rails 8.1.3
- PostgreSQL
- Devise authentication
- Pundit authorization
- Hotwire with Turbo, Stimulus, and import maps
- Propshaft asset pipeline
- Tailwind CSS loaded from its CDN
- Solid Cache, Solid Queue, and Solid Cable for production infrastructure
- RSpec and SimpleCov

## Setup

Install Ruby 4.0.6, clone the repository, and run:

```bash
bin/setup --skip-server
```

This installs the bundle, prepares the PostgreSQL database, and clears old logs and temporary files. PostgreSQL must
be running locally with a role that can create the development and test databases.

To reset the database during setup:

```bash
bin/setup --reset --skip-server
```

## Running the application

Start the Rails server:

```bash
bin/dev
```

Then open [http://localhost:3000](http://localhost:3000).

The health endpoint is available at [http://localhost:3000/up](http://localhost:3000/up).

## Seed accounts

Load the development seed accounts with:

```bash
bin/rails db:seed
```

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@taskflow.com` | `Password123!` |
| Manager | `manager@taskflow.com` | `Password123!` |
| Member | `member@taskflow.com` | `Password123!` |

These credentials are development data and should not be used in production.

## Testing

Run the complete RSpec suite:

```bash
bundle exec rspec
```

Specs cover models, request behavior, authorization policies, validation failures, and access-control paths. SimpleCov
enforces a minimum of 90% line coverage and 80% branch coverage. The generated report is written to
`coverage/index.html` and is excluded from version control.

Running only part of the suite can fall below the project-wide SimpleCov threshold even when those selected examples
pass. Use the complete command above for the authoritative coverage result.

## Quality checks

Run Ruby formatting and lint checks:

```bash
bin/rubocop
```

Run the same local CI workflow configured by the project:

```bash
bin/ci
```

The GitHub workflow also runs RuboCop, Brakeman, Bundler Audit, Importmap Audit, and the RSpec coverage suite.

## Main routes

| Path | Purpose |
| --- | --- |
| `/` | Public landing page |
| `/dashboard` | Signed-in user's dashboard |
| `/projects` | Projects available through the user's policy scope |
| `/projects/:project_id/tasks` | Tasks within an authorized project |
| `/users` | Admin-only user management |
| `/up` | Rails health check |
