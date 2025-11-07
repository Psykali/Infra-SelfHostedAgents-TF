Client-SelfHosted-Agent-PrivStorAcc//
├── providers.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── scripts/
│   ├── setup_devops_agent.sh
│   └── run_local_exec.sh
├── networking/
│   ├── hub_rg.tf
│   ├── hub_vnet.tf
│   ├── spoke_rg.tf
│   ├── spoke_vnet.tf
│   ├── vnet_peering.tf
│   └── nsg.tf
├── compute/
│   ├── vm_rg.tf
│   ├── ubuntu_vm.tf
│   ├── vm_extension.tf
│   └── data_disks.tf
└── monitoring/
    ├── monitor_rg.tf
    └── diagnostics.tf
└── state-storage/
    ├── providers.tf
    ├── variables.tf
    ├── storage.tf
    └── private-endpoint.tf