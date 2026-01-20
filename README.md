# Asset Helpdesk (SQL Server)

A learning project for Microsoft SQL Server: asset inventory (devices) + a simple helpdesk system (tickets and comments).
The database is deployed via SQL scripts and is intended for practicing SQL, schema design, and typical reporting queries.

## Features

* Reference data: departments and users
* Devices: AssetTag, type, hostname, serial number, IP/MAC, status
* Device assignments: who a device is assigned to (history)
* Helpdesk: tickets and ticket comments
* Example workflow: create a ticket, add comments, move to InProgress, close the ticket

## Requirements

* Microsoft SQL Server (Developer/Express/Standard)
* Any SQL client, for example:

  * SSMS (SQL Server Management Studio), or
  * JetBrains DataGrip

## Repository Structure

* `sql/` — all SQL scripts for the project
* `docs/` — design notes / documentation

## Quick Start (Deployment)

Run the scripts in order against the same database.

1. Create database:

* `sql/01_create_database.sql`

2. Create schema (tables/constraints):

* `sql/02_schema.sql`

3. Insert test data (optional):

* `sql/03_seed.sql`

4. Basic verification queries:

* `sql/04_queries.sql`

5. Device assignment history:

* `sql/06_assignments.sql`

6. Helpdesk tables + demo ticket:

* `sql/07_tickets.sql`

7. Ticket workflow (InProgress → comment → Closed):

* `sql/08_ticket_workflow.sql`

## Security Notes

* Do not store passwords, real connection strings, or private IP addresses in the repository.
* If you need a login/user script, use a template (for example `sql/05_security_template.sql`) and fill the password locally.

## Next Improvements

* Least-privilege roles (instead of `db_owner`)
* Ticket categories and SLA/overdue reporting
* Device audit log (history of changes)
* Views for reporting
* API layer (e.g., FastAPI/.NET) on top of this schema

## License

Learning project. You can add a license later (for example MIT).
