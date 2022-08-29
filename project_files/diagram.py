# diagram.py
from diagrams import *
from diagrams.azure.devops import *
from diagrams.azure.network import (
    VirtualNetworks,
    Subnets,
    NetworkSecurityGroupsClassic,
)

with Diagram("Useless", show=False):
    with Cluster("AzureDevops"):
        pipelines = [Pipelines("terraform"), Pipelines("app code")]
        Repos("useless") >> Edge(color="red", style="dashed") >> pipelines

    graph_attr = {"class": "VirtualNetworks"}
    with Cluster("Azure", graph_attr=graph_attr):
        VirtualNetworks("vnet") >> Subnets("snet1")
