##
# This area is used to define the hubs and spokes. Changes to these settings 
# are part of normal operations to onboard, configure, and deprovision 
# applications and services.
#
# All applications and their environments are defined in `local.applications`.
# They are flattened and denormalized into `local.application_environments`.
# From there, they are used to create all the boilerplate resources that allow
# application self-service.
##

locals {
  ##
  # Statically determines if local resources marked as `cold_resource` should be 
  # provisioned.
  ##
  cold_are_provisioned = false

  ##
  # This area is used to define the applications and environments. It is created 
  # at the request of the application owners and updated as they need additional 
  # environments or metadata about the applicaiton changes.
  ##
  applications = {
    exampleapp1 = {
      cost_center = "47216" # default cost center for all environments
      owner       = "jdoe@example.com"
      source      = "tf-demo-exampleapp1"

      environments = {
        development = {
          name = "Example Application 1 Development"
        }
        test = {
          cost_center = "47217" # special cost center for test environment
          name        = "Example Application 1 Test"
        }
      }
    }
  }

  ##
  # This area is used to define the services and environments. It is created 
  # at the request of the service owners and updated as they need additional 
  # environments or metadata about the service changes.
  ##
  services = {
    authentication = {
      cost_center = "88149"
      owner       = "bill.q.service@example.com"
      name        = "Authentication Service"
      environments = {
        development = {
        }
        test = {
        }
        production = {
          # overrides default hubs to deploy to all active producion hubs
          hubs = [for key, value in local.hubs.production : key]
        }
      }
    }
  }

  hubs = {
    development = {
      active_primary = {
        azure_location = "eastus"
      }
    }
    test = {
      active_primary = {
        azure_location = "eastus"
      }
      active_secondary = {
        azure_location = "westus"
      }
    }
    production = {
      active_primary = {
        azure_location = "eastus"
      }
      active_secondary = {
        azure_location = "westus"
      }
      active_tertiary = {
        azure_location = "centralus"
      }
      disaster_primary = {
        azure_location = "eastus2"
        cold_resource  = true
      }
    }
  }

  ##
  # This area is used to define the defaults for applications and environments. If 
  # not specified at the application or environment level, these become the values 
  # used. Environment > Application > Environment Default > Application Default
  ##
  application_defaults = {
    terraform_version = "1.4.6"
    environments = {
      development = {
        branch = "main"
        hubs   = ["active_primary"]
      }
      test = {
        branch = "test"
        hubs   = ["active_primary"]
      }
      production = {
        branch = "production"
        hubs   = ["active_primary", "disaster_primary"]
      }
    }
  }

  ##
  # This area is used to merge the applications with defaults and put it in a format 
  # more easily consumable by Terraform resources.
  ##
  application_environments = { for ae in flatten([
    for appk, appv in local.applications : [
      # application-environment > application > application-environment defaults > application defaults
      for envk, envv in appv.environments : merge(local.application_defaults, local.application_defaults.environments[envk], appv, envv, {
        app          = appk
        env          = envk
        environments = null # an environment should not have visibility to the other environments of its app
      })
    ]
  ]) : "${ae.app}-${ae.env}" => ae }

  application_environment_hubs = { for aeh in flatten([
    for appk, appv in local.applications : [
      for envk, envv in appv.environments : [
        for hubk, hubv in try(envv.hubs, local.hubs[envk]) : merge(local.application_defaults, local.application_defaults.environments[envk], appv, envv, hubv, {
          app          = appk
          env          = envk
          hub          = hubk
          environments = null # an environment should not have visibility to the other environments of its app
        })
      ]
    ]
  ]) : "${aeh.app}-${aeh.env}-${aeh.hub}" => aeh }
}

# resource group created by master; used for zone-specific resources
data "azurerm_resource_group" "zone" {
  name = var.zone_resource_group_name
}
