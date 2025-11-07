Client-SelfHosted-Agent-PrivStorAcc/
├── stages/
│   ├── 01-storage/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── storage.tf
│   │   ├── private_endpoint.tf
│   │   └── outputs.tf
│   ├── 02-networking-vm/
│   │   ├── providers.tf
│   │   ├── variables.tf
│   │   ├── networking.tf
│   │   ├── vm.tf
│   │   ├── private_endpoint_vm.tf
│   │   └── outputs.tf
│   └── 03-ado-agent/
│       ├── providers.tf
│       ├── variables.tf
│       ├── ado_setup.tf
│       └── outputs.tf
├── scripts/
│   ├── setup_agent.sh
│   └── create_ado_resources.py
└── terraform.tfvars