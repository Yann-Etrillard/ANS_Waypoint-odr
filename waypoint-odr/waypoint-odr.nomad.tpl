job "<%= @waypoint_runner_job_name %>" {
        datacenters = ["<%= @environment %>"]
        type = "service"
        update {
                stagger = "30s"
                max_parallel = 1
        }

        group "waypoint-runner" {
                count = "1"
                restart {
                        attempts = 3
                        delay = "60s"
                        interval = "1h"
                        mode = "fail"
                }
                task "runner" {
                        driver = "docker"
						vault {
							policies = ["waypoint"]
						}
                        config {
                                image = "ans/waypoint:<%= @waypoint_version %>-docker"
                                args = [
                                        "runner",
                                        "agent",
                                        "-vvv"
                                        ]
                                volumes = [
                                        "/var/run/docker.sock:/var/run/docker.sock",
                                ]
                                auth_soft_fail = false
                        }
                        template {
                                data        = <<EOH
WAYPOINT_SERVER_ADDR = "{{ range service "<%= @waypoint_server_job_name %>" }}{{ .Address }}:{{ .Port }}{{ end }}"
WAYPOINT_SERVER_TOKEN = "{{ with secret "waypoint/waypoint_runner" }}{{ .Data.data.token }}{{end}}"
WAYPOINT_SERVER_TLS = true
WAYPOINT_SERVER_TLS_SKIP_VERIFY = true
HTTP_PROXY = "<%= @ans_proxy_host %>:<%= @ans_proxy_port %>"
HTTPS_PROXY = "<%= @ans_proxy_host %>:<%= @ans_proxy_port %>"
NO_PROXY = "<%= @internal_network_mask %>"
NOMAD_ADDR="http://<%= @docker_platform_nomad_master_address[0] %>:4646"
EOH
                                destination = "secrets/file.env"
                                env         = true
                                change_mode = "restart"
                        }
                        template {
                                data = <<EOH
{
  "username": "{{ with secret "waypoint/waypoint_runner" }}{{ .Data.data.registry_user }}{{end}}",
  "password": "{{ with secret "waypoint/waypoint_runner" }}{{ .Data.data.registry_password }}{{end}}"
}
EOH
                                destination = "secrets/dockerAuth.json"
                        }
                        resources {
                                cpu = 2048
                                memory = <%= @waypoint_runner_resource_mem %>
                        }
                }
        }
}
