# Azure DevOps Agent VM Provisioning

Complete solution for provisioning Azure VMs with Azure DevOps agents.

#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl
  - wget
  - git
  - unzip
  - jq
  - docker.io

runcmd:
  - usermod -aG docker devopsagent
  - mkdir -p /opt/azure-devops-agents
  - chown devopsagent:devopsagent /opt/azure-devops-agents
  - sudo -u devopsagent bash -c "cd /opt/azure-devops-agents && wget -q https://vstsagentpackage.azureedge.net/agent/3.227.2/vsts-agent-linux-x64-3.227.2.tar.gz"
  - |
    for i in {1..10}; do
      sudo -u devopsagent mkdir -p /opt/azure-devops-agents/agent-$i
      sudo -u devopsagent tar -zxvf /opt/azure-devops-agents/vsts-agent-linux-x64-3.227.2.tar.gz -C /opt/azure-devops-agents/agent-$i
      sudo -u devopsagent chmod +x /opt/azure-devops-agents/agent-$i/*.sh
    done


**Clone the repository**
   ```bash
   git clone <your-repo>
   cd azure-devops-agent-vm



## **Deployment Workflow**

1. **Terraform** creates the VM infrastructure
2. **Cloud-init** installs basic prerequisites during VM creation
3. **Bash scripts** complete the agent setup
4. **Systemd** ensures agents auto-start on boot

## **Key Features:**

- ✅ **Modular design** - each script has a single responsibility
- ✅ **Configurable** - easily adjust agent count, VM size, etc.
- ✅ **Idempotent** - scripts can be run multiple times safely
- ✅ **Automated** - minimal manual intervention required
- ✅ **Production-ready** - includes proper error handling and logging

This solution provides a complete, reusable pipeline for deploying Azure DevOps agent pools! 🚀