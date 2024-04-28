#!/bin/bash

# Set Minio credentials and endpoint
MINIO_ACCESS_KEY=""
MINIO_SECRET_KEY=""
MINIO_ENDPOINT=""
MINIO_BUCKET=""
BACKUP_FOLDER="backups/$(date +'%Y-%m-%d_%H-%M-%S')"

# Configure Minio client
mc alias set backup_minio ${MINIO_ENDPOINT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}

# Iterate over Docker volumes
for volume_name in $(docker volume ls -q)
do
    # Export volume data to temporary directory
    docker run --rm -v $volume_name:/data -v $(pwd)/backup:/backup --name backup alpine tar -czf /backup/${volume_name}.tar.gz -C /data .

    # Upload backup to Minio
    mc cp $(pwd)/backup/${volume_name}.tar.gz nosql_minio/${MINIO_BUCKET}/${BACKUP_FOLDER}/

    # Check if upload was successful
    if [ $? -eq 0 ]; then
        echo "Backup of volume ${volume_name} uploaded successfully."
        # Cleanup only if upload was successful
	docker rm -f backup
	rm $(pwd)/backup/${volume_name}.tar.gz
        echo "Backup of volume ${volume_name} deleted successfully."
    else
        echo "Failed to upload backup of volume ${volume_name}."
    fi
done
