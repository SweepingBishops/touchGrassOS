```
nasm -fbin src/boot0.s -o boot0.bin
nasm -fbin src/boot1.s -o boot1.bin
cat boot0.bin boot1.bin > boot.bin
qemu-system-x86_64 boot.bin
```
