# Set up butterbee in Github Actions

butterbee can be used in Github Actions to run tests in a browser. For this to work, you need
to have the browsers to the runner and run gleam test via xvfb.

NOTE: to use chromium in github actions, you need to add the following to your `gleam.toml` file:

```toml
[tools.butterbee.capabilities.always_match]
webSocketUrl = true
"goog:chromeOptions" = { args = ["--no-sandbox"] }
```

### github actions example
```yml
name: test

on:
  push:
    branches:
      - master
      - main
  pull_request:
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./butterbee
    steps:
      - uses: actions/checkout@v4
      - name: Remove pre-installed Chrome
        run: |
          sudo apt-get remove -y google-chrome-stable
          sudo apt-get autoremove -y
      - uses: browser-actions/setup-firefox@v1
        with:
          firefox-version: "latest"
      - uses: browser-actions/setup-chrome@v1
        with:
          install-chromedriver: true
      - uses: erlef/setup-beam@v1
        with:
          otp-version: "latest"
          gleam-version: "latest"
          rebar3-version: "latest"
      - run: gleam deps download
      - run: xvfb-run -a gleam test
      - run: gleam format --check src test
```
