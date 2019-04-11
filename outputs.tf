output zones_available {
  description = "Output gc zones having free space."
  value       = "{data.google_compute_zones.available.names}"
}
