# CC Escalation — sanitized source

This repository contains a sanitized source snapshot of a SQLPage escalation component and a React operator dashboard.

Client contacts, private endpoints, organization identifiers, database names, branding assets, and operational recovery records have been replaced with examples or omitted. Contact fixtures are synthetic and contain no phone numbers.

This snapshot requires private configuration and application dependencies before deployment. Placeholder endpoints use the reserved `example.invalid` domain; database identifiers use `ApplicationDb` placeholders. Do not run database scripts without adapting and reviewing them for the intended environment.

## Source layout

- Root SQL, JavaScript, and CSS: escalation pages and quick-log support.
- `unique escalation/`: escalation-list management and CRM linking.
- `unique escalation/newui/`: React and Vite operator dashboard.
- `database/`: database migration templates with environment-specific names removed.
- `tests/`: source checks and synthetic escalation fixtures.

## Checks

Run `node --test tests/client-escalation.test.cjs` from this directory. Quick-log integration tests also require the parent application's private sibling modules. The offline SQL parser requires the `SQL_SCRIPTDOM_ASSEMBLY` environment variable.

See the dashboard README for frontend setup. Environment files, SQLPage connection configuration, database files, local output, dependency folders, and generated build files are excluded from version control.

## Publishing

Publish only reviewed, sanitized copies. The operational application directory contains private runtime information and must not be pushed directly. Keep private contacts, branding, operational data, and deployment configuration outside this repository.
