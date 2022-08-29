# diagram.py
from diagrams import Diagram, Cluster, Edge
from diagrams.azure.devops import Pipelines, Repos
from diagrams.azure.network import Subnets

from diagrams.azure.storage import StorageAccounts

with Diagram("Useless", show=False):
    with Cluster("Azure"):
        with Cluster("Vnet - 10.0.0.0/16"):
            vnet = Subnets("Storage 10.0.0.0/24")
        storage = StorageAccounts("Storage Account")

    with Cluster("AzureDevops"):
        repo = Repos("project_files")
        with Cluster("Pipeline"):
            tfpipe = Pipelines("Deploy Terraform")
            sonarpipe = Pipelines("SonarCube Scan")
            sonarpipe >> tfpipe >> vnet
        repo >> sonarpipe
