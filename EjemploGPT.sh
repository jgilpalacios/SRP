#!/bin/bash

DISK="/dev/sda"
WIN_PART="${DISK}3"
NEW_WIN_SIZE="150GB"

# Redimensionar la partición de Windows a 150GB
ntfsresize --size $NEW_WIN_SIZE $WIN_PART

# Usar parted para redimensionar y crear nuevas particiones
echo "Redimensionando partición de Windows y creando nuevas particiones..."
parted --script $DISK \
    resizepart 3 150GB \
    mkpart primary ext4 150GB 250GB \
    mkpart primary linux-swap 250GB 254GB \
    mkpart primary ext4 254GB 256GB \
    mkpart primary ext4 256GB 456GB \
    mkpart primary ntfs 456GB 100%

# Formatear las nuevas particiones
mkfs.ext4 -L MAX ${DISK}5
mkswap -L SWAP ${DISK}6
mkfs.ext4 -L SRP ${DISK}7
mkfs.ext4 -L SRPBACKUP ${DISK}8
mkfs.ntfs -f -L DATOS ${DISK}9

echo "Proceso completado con éxito."
