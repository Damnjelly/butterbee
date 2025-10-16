# Set up butterbee in Github Actions

butterbee can be used in Github Actions to run tests in a browser. For this to work, you need
to have add firefox to the runner and run gleam test via xvfb.

### Firefox example
```yml
name: test

on:
  push:
    branches:
      - master
      - main
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./butterbee
    steps:
      - uses: actions/checkout@v4
      - uses: browser-actions/setup-firefox@v1
        with:
          firefox-version: "latest"
      - uses: erlef/setup-beam@v1
        with:
          otp-version: "27.1.2"
          gleam-version: "1.11.0"
          rebar3-version: "3"
      - run: gleam deps download
      - run: xvfb-run -a gleam test
      - run: gleam format --check src test
```
