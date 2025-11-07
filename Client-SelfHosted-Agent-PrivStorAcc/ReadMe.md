Client-SelfHosted-Agent-PrivStorAcc/
├── stages/
│   ├── 01-storage/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── storage.tf
│   │   └── outputs.tf
│   ├── 02-networking-vm/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── networking.tf
│   │   ├── vm.tf
│   │   ├── private_endpoint.tf
│   │   └── outputs.tf
│   ├── 03-ado-agent/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── ado_setup.tf
│   │   └── outputs.tf
│   ├── 04-storage-container/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── container.tf
│   │   └── outputs.tf
│   └── 05-test-resources/
│       ├── providers.tf
│       ├── variables.tf
│       ├── test.tf
│       └── outputs.tf
├── scripts/
│   └── setup_agent.sh
└── terraform.tfvars