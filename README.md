# Camel K Tools Action

[![](https://github.com/container-tools/camel-k-action/workflows/Test/badge.svg?branch=main)](https://github.com/container-tools/camel-k-action/actions)

A GitHub Action for installing and using Camel K.

## Usage

### Pre-requisites

Create a workflow YAML file in your `.github/workflows` directory. An [example workflow](#example-workflow) is available below.
For more information, reference the GitHub Help Documentation for [Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file).

### Inputs

For more information on inputs, see the [API Documentation](https://developer.github.com/v3/repos/releases/#input)

- `version`: The Camel K version to use (default: `latest`)

### Example Workflow

Create a workflow (eg: `.github/workflows/create-cluster.yml`):

```yaml
name: Camel K

on: pull_request

jobs:
  camel-k:
    runs-on: ubuntu-latest
    steps:
      - name: Camel K CLI
        uses: container-tools/camel-k-action@v1
```

This uses [@container-tools/camel-k-action](https://www.github.com/container-tools/camel-k-action) GitHub Action to install the Camel K CLI binaries.
