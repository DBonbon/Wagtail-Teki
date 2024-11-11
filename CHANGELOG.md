# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## 10.0.0 - 2024-11-11
### Changed
- Add Cookiecutter documentation folder under docs. 
  - With project structure
  - 

## [9.1.1] - 2024-07-24
### Changed
- Upgrade storybook to 8.2.5

### Fixed
- Upgrade Next.js to 14.2.5
- Upgrade Django to 5.0.7
- Upgrade wagtail to 6.1.3
- Upgrade whitenoise to 6.7.0
- Upgrade pytest to 8.3.1
- Upgrade wagtail-factories to 4.2.1
- Replace deprecated ruff <path> with ruff check <path>
- Upgrade django-stubs to 5.0.2
- Upgrade mypy to 1.11.0
- Upgrade djangorestframework-stubs to 3.15.0
- Upgrade psycopg to 3.2.1
- Upgrade sentry_sdk to 2.10.0
- Upgrade prettier to 3.3.3
- Upgrade husky to 9.1.1
- Upgrade i18next to 23.12.2
- Upgrade next-i18next to 15.3.0
- Upgrade eslint-config-next to 14.2.5
- Upgrade sentry/nextjs to 8.19.0
- Fix storybook crash in HomePage when seo robots are undefined
- Upgrade testing-library/jest-dom to 6.4.8
- Upgrade testing-library/react to 16.0.0

## [9.1.0] - 2024-06-02
### Changed
- Upgrade Wagtail to 6.1.2
- Upgrade Next.js to 14.2.3
- Use pascal case file name when generating file in new_page command
- Drop possible Page suffix from name argument in new_page
- Clarify db collation on provisioning (@DBonbon)

### Fixed
- Fix issue with canonical link not properly exposed with fallback (@marteinn)
- Default port to 443 to avoid broken site resolve from API (@rinti)
- Ignore venv dirs named .venv
- Make utils.env look for envfiles in ./src folder (@mikaelengstrom)
- Upgrade django to 5.0.6
- Upgrade pytest to 8.2.0
- Upgrade wagtail-meta-preview to 4.1.0
- Upgrade psycopg to 3.1.18
- Upgrade gunicorn to 22.0.0
- Upgrade mypy to 1.10.0
- Upgrade gevent to 24.2.1
- Upgrade sentry_sdk to 2.3.1
- Upgrade husky to 9.0.11
- Upgrade prettier to 3.3.0
- Upgrade @swc/jes to 0.2.36
- Upgrade react to 18.3.1
- Upgrade i18next to 23.11.5
- Upgrade sentry for js to 8.7.0
- Upgrade wagtail_headless_preview to 0.8.0

### Removed
- Drop deprecated version key from docker-compose

## [9.0.0-beta] - 2024-02-04

### Added
- Add experimental app router support (@marteinn)
- Add production ready python docker image with gunicorn (@mikaelengstrom)
- Add container for Next.js frontend (@mikaelengstrom)
