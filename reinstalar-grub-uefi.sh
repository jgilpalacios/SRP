#!/bin/bash
set -e

# ==============================
# CONFIGURACIÓN (AJUSTAR)
# ==============================

DISCO_EFI="/dev/sdX"     # Disco donde está la EFI (ej: /dev/sda)
PART_EFI="/dev/sdX1"     # Partición EFI
PART_ROOT="/dev/sdX2"    # Partición raíz de Ubuntu clonado
BOOTLOADER_ID="ubuntu"  # Nombre que aparecerá en el firmware

# ==============================
# COMPROBACIONES
# ==============================

if [ ! -d /sys/firmware/efi ]; then
    echo "ERROR: El Live NO está arrancado en modo UEFI"
    exit 1
fi

echo "Arranque UEFI detectado ✔"

# ==============================
# MONTAJES
# ==============================

echo "Montando sistema clonado..."

mount "$PART_ROOT" /mnt
mount "$PART_EFI" /mnt/boot/efi

for dir in /dev /dev/pts /proc /sys /run; do
    mount --bind "$dir" "/mnt$dir"
done

# ==============================
# CHROOT + GRUB
# ==============================

echo "Entrando en chroot e instalando GRUB..."

chroot /mnt /bin/bash << EOF
set -e

grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot/efi \
  --bootloader-id=$BOOTLOADER_ID \
  --recheck

update-grub
EOF

# ==============================
# LIMPIEZA
# ==============================

echo "Desmontando..."

for dir in /run /sys /proc /dev/pts /dev; do
    umount "/mnt$dir"
done

umount /mnt/boot/efi
umount /mnt

echo "GRUB UEFI reinstalado correctamente ✔"
echo "Puedes reiniciar el sistema."
