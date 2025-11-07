Client-SelfHosted-Agent-PrivStorAcc/
├── providers.tf
├── backend.tf
├── variables.tf
├── outputs.tf
├── networking/
│   ├── hub_rg.tf
│   ├── hub_vnet.tf
│   ├── spoke_rg.tf
│   ├── spoke_vnet.tf
│   ├── vnet_peering.tf
│   └── nsg.tf
├── storage/
│   ├── storage_rg.tf
│   ├── storage_account.tf
│   └── private_endpoint.tf
├── compute/
│   ├── vm_rg.tf
│   ├── ubuntu_vm.tf
│   ├── vm_extension.tf
│   └── data_disks.tf
└── monitoring/
    ├── monitor_rg.tf
    └── diagnostics.tf