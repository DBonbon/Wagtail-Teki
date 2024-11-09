[![Test cookiecutter scaffolder](https://github.com/Frojd/Wagtail-Pipit/actions/workflows/main.yml/badge.svg)](https://github.com/Frojd/Wagtail-Pipit/actions/workflows/main.yml)

# Pipit
Pipit is a [Wagtail CMS](https://wagtail.io/) boilerplate which aims to provide an easy and modern developer workflow with a React-rendered frontend.

## Features
- Hybrid static and server rendered React using [Next.js](https://nextjs.org/)
- Page scaffolding
- [12-Factor App](https://12factor.net/) compliant
- Docker development environment
- Deploy scripts via [Ansistrano](https://github.com/ansistrano)
- Orchestration using [Ansible](https://github.com/ansible/ansible)
- Local SSL for development
- Error reporting with [Sentry](https://sentry.io/)
- CI integration via [Circle CI](https://circleci.com/) with Slack notifications
- Data-sync between environments
- [Storybook](https://storybook.js.org/) for rapid component development

## Installation
1. Make sure you have [cookiecutter](https://github.com/audreyr/cookiecutter/blob/master/docs/index.rst) installed. If not run `pip install cookiecutter` (or via brew)
2. Run cookiecutter:
```
cookiecutter https://github.com/Frojd/Wagtail-Pipit.git
```

3. Fill in the questions and you are done!

## Documentation – Where to go from here?
We recommend you to start by checking out the [Getting Started Guide](/docs/getting-started-guide.md). Otherwise, you can read up any of the following topics:
- [Frontend Developer Guide](/docs/frontend-developer-guide.md)
- [Backend Developer Guide](/docs/backend-developer-guide.md)
- [Provision and configure a webserver for hosting](/docs/provisioning-servers-for-hosting.md)
- [Setting up deployment on CircleCI](/docs/setting-up-deployment-with-circleci.md)
- [Adding Slack notifications to CircleCI](/docs/adding-slack-notifications-to-circleci.md)
- [Sync data between environments](/docs/sync-data-between-environments.md)
- [Running python locally](/docs/running-python-locally.md)
- [Using static site generation](/docs/using-static-site-generation.md)
- [Working with Wagtail's routable pages](/docs/working-with-wagtails-routable-pages.md)
- [Serving custom content type data through Next.js](/docs/serving-custom-content-type-data-through-nextjs.md)
- [Adding multi language support](/docs/adding-multi-language-support.md)
- [Adding wagtail-2fa support](/docs/adding-wagtail-2fa-support.md)
- [Adding Sentry](/docs/adding-sentry.md)
- [Handling CSRF Tokens](/docs/handling-csrf-tokens.md)
- [Publish storybook](/docs/publish-storybook.md)
- [Scaffolding](/docs/scaffolding.md)


## Contribute
If you have ideas for improvement, please share your thoughts through an issue. We also welcome PR's

- Issue Tracker: [https://github.com/Frojd/Wagtail-Pipit/issues](https://github.com/Frojd/Wagtail-Pipit/issues)
- Source Code: [https://github.com/Frojd/Wagtail-Pipit](https://github.com/Frojd/Wagtail-Pipit)
- Discussions: You can find us on the [Wagtail slack](https://wagtail.io/slack/) under the channel `#pipit`

## Security
If you believe you have found a security issue with any of our projects please email us at [security@frojd.se](security@frojd.se).

## Support
If you have any issues, please submit an issue and we will do our best to help you out.
