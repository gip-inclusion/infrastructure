scw_region = "fr-par"
scw_zone   = "fr-par-1"

database_engine                    = "PostgreSQL-17"
database_node_type                 = "DB-PLAY2-NANO"
database_is_ha_cluster             = true
database_volume_size_in_gb         = 20
database_backup_schedule_retention = 30

database_environments = ["integration", "production"]
