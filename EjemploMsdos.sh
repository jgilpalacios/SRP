#!/bin/bash

DISK="/dev/sda"
WIN_PART="${DISK}2"
NEW_WIN_SIZE="150GB"
MAX_PART_START="150GB"
MAX_PART_END="250GB"
EXTENDED_START="250GB"
EXTENDED_END="100%"

# Redimensionar la partición de Windows a 150GB
ntfsresize --size $NEW_WIN_SIZE $WIN_PART

# Usar parted para redimensionar y crear la partición primaria MAX y la extendida
echo "Redimensionando partición de Windows y creando particiones..."
parted --script $DISK \
    resizepart 2 150GB \
    mkpart primary ext4 $MAX_PART_START $MAX_PART_END \
    mkpart extended $EXTENDED_START $EXTENDED_END

# Crear particiones lógicas dentro de la extendida
echo "Creando particiones lógicas..."
parted --script $DISK \
    mkpart logical linux-swap 250GB 254GB \
    mkpart logical ext4 254GB 256GB \
    mkpart logical ext4 256GB 456GB \
    mkpart logical ntfs 456GB 100%

# Formatear las nuevas particiones
mkfs.ext4 -L MAX ${DISK}3
mkswap -L SWAP ${DISK}5
mkfs.ext4 -L SRP ${DISK}6
mkfs.ext4 -L SRPBACKUP ${DISK}7
mkfs.ntfs -f -L DATOS ${DISK}8

echo "Proceso completado con éxito."
