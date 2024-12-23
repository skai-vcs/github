locals {
  teams = {
    global-teamleads = {
      privacy = "closed"
      acces_for_repos = {
        infrastructure = {
          permissions = "push"
        },
        github = {
          permissions = "push"
        },
        ops-actions-workflows = {
          permissions = "push"
        },
        ops-actions-components = {
          permissions = "push"
        }
      }
    }
    global-devops = {
      privacy = "closed"
      acces_for_repos = {
        infrastructure = {
          permissions = "push"
        },
        github = {
          permissions = "push"
        },
        ops-actions-workflows = {
          permissions = "push"
        },
        ops-actions-components = {
          permissions = "push"
        }
      }
    }
    global-developers = {
      privacy = "closed"
    }
  }


  users = {
    volodymyr-lytvynenko = {
      teams = [
        "global-devops"
      ]
    },
    alexandr-kipkalo = {
      teams = [
        "global-devops", 
        "global-teamleads"
      ]
    }
  }
}