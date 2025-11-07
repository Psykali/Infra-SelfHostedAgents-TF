terraform/
├── providers.tf
├── variables.tf
├── outputs.tf
├── networking/
│   ├── hub_rg.tf
│   ├── hub_vnet.tf
│   ├── spoke_rg.tf
│   ├── spoke_vnet.tf
│   ├── vnet_peering.tf
│   └── nsg.tf
├── compute/
│   ├── vm_rg.tf
│   ├── ubuntu_vms.tf
│   ├── windows_vm.tf
│   ├── vm_extensions.tf
│   └── data_disks.tf
└── monitoring/
    ├── monitor_rg.tf
    └── diagnostics.tf