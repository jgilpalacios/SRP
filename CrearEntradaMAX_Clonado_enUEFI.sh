#!/bin/bash
# Script para crear una entrada UEFI para un Ubuntu clonado

# ---- CONFIGURACIÓN ----
EFI_PART="/dev/sdX1"          # Cambiar a tu partición EFI
ROOT_PART="/dev/sdX2"         # Cambiar a la partición raíz clonada
BOOT_LABEL="UbuntuClonado"    # Nombre de la entrada en UEFI, se cambiaría por MAX

# ---- MONTAJE ----
mkdir -p /mnt/efi
mount $EFI_PART /mnt/efi
if [ $? -ne 0 ]; then
    echo "Error montando EFI. ¿Es la partición correcta?"
    exit 1
fi

# Verificar que exista grubx64.efi
GRUB_PATH="/mnt/efi/EFI/ubuntu/grubx64.efi"
if [ ! -f "$GRUB_PATH" ]; then
    echo "No se encontró grubx64.efi en $GRUB_PATH"
    echo "Verifica la ruta dentro de la EFI"
    exit 1
fi

# ---- CREAR ENTRADA UEFI ----
sudo efibootmgr -c -d /dev/sdX -p 1 -L "$BOOT_LABEL" -l "\EFI\ubuntu\grubx64.efi"

# -d : disco EFI (sin número de partición)
/dev/sdX -> cambiar por el disco
# -p : número de partición EFI
# -L : etiqueta que aparecerá en el firmware
# -l : ruta EFI dentro de la partición (usa backslashes)

# ---- LISTAR ENTRADAS ----
echo "Entradas UEFI actuales:"
efibootmgr -v

echo "Entrada UEFI $BOOT_LABEL creada correctamente."
