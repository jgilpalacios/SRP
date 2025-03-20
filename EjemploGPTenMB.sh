#!/bin/bash

DISK="/dev/sda"
WIN_PART="${DISK}3"
NEW_WIN_SIZE="153600M"  # 150GB en MB

# Redimensionar la partición de Windows a 150GB (153600MB)
ntfsresize --size $NEW_WIN_SIZE $WIN_PART

# Usar parted para redimensionar y crear nuevas particiones en MB
echo "Redimensionando partición de Windows y creando nuevas particiones..."
parted --script $DISK \
    resizepart 3 153600MB \
    mkpart primary ext4 153600MB 256000MB \
    mkpart primary linux-swap 256000MB 260096MB \
    mkpart primary ext4 260096MB 262144MB \
    mkpart primary ext4 262144MB 467968MB \
    mkpart primary ntfs 467968MB 100%

# Formatear las nuevas particiones
mkfs.ext4 -L MAX ${DISK}5
mkswap -L SWAP ${DISK}6
mkfs.ext4 -L SRP ${DISK}7
mkfs.ext4 -L SRPBACKUP ${DISK}8
mkfs.ntfs -f -L DATOS ${DISK}9

echo "Proceso completado con éxito."
