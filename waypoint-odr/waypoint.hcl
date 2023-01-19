project = "waypoint/odr"

app "waypoint-odr" {
  build {
    use "nomad" {
      image = "ans/waypoint:0.10.3-docker"
      tag   = "1"
      local = true
    }
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