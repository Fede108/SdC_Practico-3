# SdC_Practico-3
# Compilación y Ejecución de un Bootloader con NASM y QEMU

Este documento describe el procedimiento para compilar un archivo `bootloader.asm` utilizando el ensamblador **NASM** y ejecutar la imagen resultante mediante **QEMU**, un emulador de hardware de código abierto.

---

## 📦 Requisitos

Antes de comenzar, asegúrese de tener instaladas las siguientes herramientas:

- **NASM** (Netwide Assembler): para compilar el código ensamblador.
- **QEMU**: para emular una arquitectura x86 y ejecutar el bootloader.

## Instalación en sistemas basados en Debian/Ubuntu

```bash
sudo apt update
sudo apt install nasm qemu-system-x86
```

## Ejecutar run.sh
En la raiz del proyecto ejecute 
```bash
./run.sh
```
Este script de bash se encargara de compilar el archivo bootloader.asm con nasm y de ejecutar qemu utilizando la imagen generada. 

 El detalle de su implemetación se encuentra a continuación.
 
### 🛠️  Paso 1: Compilar el archivo bootloader.asm

Compile el código fuente del bootloader utilizando el siguiente comando:

```bash
nasm -f bin bootloader.asm -o bootloader.img
```

###### 📌 Descripción del comando:

**-f bin:** genera una salida binaria plana (formato bin).

**bootloader.asm:** archivo fuente en ensamblador.

**-o bootloader.img:** nombre de la imagen de salida.

### 🚀 Paso 2: Ejecutar la imagen con QEMU
Finalmente una vez generada la imagen bootloader.img, puede emular su ejecución con QEMU usando:

```bash
qemu-system-i386 -fda bootloader.img
```
##### 📌 Descripción del comando:

**qemu-system-i386:** ejecuta el emulador QEMU para la arquitectura x86 de 32 bits.

**-fda bootloader.img:** monta la imagen como si fuera una disquetera.
