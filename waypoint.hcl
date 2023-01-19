project = "Waypoint/Ondemandrunner"

app "waypoint-odr" {
  build {
    use "nomad" {}
    // registry {
    //   use "docker" {
    //     image = "nodejs-jobspec-web"
    //     tag   = "1"
    //     local = true
    //   }
    // }
  }

  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/waypoint-odr.nomad")
    }
  }

  release {
    use "nomad-jobspec-canary" {
      groups = [
        "app"
      ]
      fail_deployment = false
    }
  }
}