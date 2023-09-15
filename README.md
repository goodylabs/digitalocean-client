# digitalocean-client

## Installation

### 1. Install dependencies

Install [Shell Proteins](https://github.com/grzegorzblaszczyk/shell-proteins]) first:

```
\curl -sSL https://raw.githubusercontent.com/grzegorzblaszczyk/shell-proteins/master/setup.sh | bash
```

### 2. Setup access to DigitalOcean API

Copy `.digitalocean_credentials.sample` file to `.digitalocean_credentials` and modify the `DIGITALOCEAN_TOKEN` line with your API token.


## Usage

Get the latest invoice and show total costs per project

```
./fetch_costs_from_invoice_by_project.sh
```

or 

```
./fetch_costs_from_invoice_by_project.sh [invoice_id]
```

when you want to use specific invoice.
