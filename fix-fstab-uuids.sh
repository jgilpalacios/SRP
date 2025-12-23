#!/bin/bash
set -e

# ==============================
# CONFIGURACIÓN (AJUSTAR)
# ==============================

PART_ROOT="/dev/sdX2"   # Partición raíz del Ubuntu clonado
PART_EFI="/dev/sdX1"    # Partición EFI (vfat)
PART_SWAP=""            # Opcional: /dev/sdX3 o dejar vacío

# ==============================
# COMPROBACIONES
# ==============================

if [ ! -b "$PART_ROOT" ]; then
    echo "ERROR: PART_ROOT no existe"
    exit 1
fi

echo "Montando sistema clonado..."
mount "$PART_ROOT" /mnt

if [ -n "$PART_EFI" ]; then
    mkdir -p /mnt/boot/efi
    mount "$PART_EFI" /mnt/boot/efi
fi

# ==============================
# BACKUP DE FSTAB
# ==============================

echo "Creando copia de seguridad de fstab..."
cp /mnt/etc/fstab /mnt/etc/fstab.bak

# ==============================
# OBTENER UUIDS REALES
# ==============================

UUID_ROOT=$(blkid -s UUID -o value "$PART_ROOT")
UUID_EFI=$(blkid -s UUID -o value "$PART_EFI" 2>/dev/null || true)

if [ -n "$PART_SWAP" ]; then
    UUID_SWAP=$(blkid -s UUID -o value "$PART_SWAP")
fi

# ==============================
# ACTUALIZAR FSTAB
# ==============================

echo "Actualizando UUIDs en fstab..."

# Raíz
sed -i "s|UUID=[a-zA-Z0-9-]*[[:space:]]\+/|UUID=$UUID_ROOT /|" /mnt/etc/fstab

# EFI
if [ -n "$UUID_EFI" ]; then
    sed -i "s|UUID=[a-zA-Z0-9-]*[[:space:]]\+/boot/efi|UUID=$UUID_EFI /boot/efi|" /mnt/etc/fstab
fi

# Swap
if [ -n "$UUID_SWAP" ]; then
    sed -i "s|UUID=[a-zA-Z0-9-]*[[:space:]]\+swap|UUID=$UUID_SWAP swap|" /mnt/etc/fstab
fi

# ==============================
# VALIDACIÓN
# ==============================

echo "Validando fstab con mount -a..."

for dir in /dev /dev/pts /proc /sys /run; do
    mount --bind "$dir" "/mnt$dir"
done

chroot /mnt mount -a

for dir in /run /sys /proc /dev/pts /dev; do
    umount "/mnt$dir"
done

umount /mnt/boot/efi 2>/dev/null || true
umount /mnt

echo "fstab corregido correctamente ✔"
echo "Backup en /etc/fstab.bak"
