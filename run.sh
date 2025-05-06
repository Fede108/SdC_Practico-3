#!/bin/bash

# Compilamos el archivo bootloader.asm
echo "Compilando bootloader.asm..."
nasm -f bin BootLoader/bootloader.asm -o bootloader.img

# Verificamos si la compilación fue exitosa
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación"
  exit 1
fi

# Ejecutamos con QEMU
echo "Ejecutando bootloader.img en QEMU..."
qemu-system-i386 -fda bootloader.img
