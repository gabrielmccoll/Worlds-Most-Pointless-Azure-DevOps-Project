locals {
    azdostagefiles = fileset("${path.module}/../project_files/.pipelines/","**")  
    projterrfiles = fileset("${path.module}/../project_files/terraform/","*.tf")   
}