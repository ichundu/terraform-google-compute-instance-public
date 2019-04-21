output "zones_available" {
  description = "Output gc zones having free space."
  value       = "{data.google_compute_zones.available.names}"
}

output "instances_self_links" {
  description = "Output self_link of created instances."
  value       = "${google_compute_instance.instances.*.self_link}"
}

output "instances_tags" {
  description = "Output tags of created instances."
  value       = "${google_compute_instance.instances.*.tags[0]}"
}
