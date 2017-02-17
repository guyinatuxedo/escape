Dump of assembler code for function main:
   0x0804840b <+0>:	lea    ecx,[esp+0x4]
   0x0804840f <+4>:	and    esp,0xfffffff0
   0x08048412 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:	push   ebp
   0x08048416 <+11>:	mov    ebp,esp
   0x08048418 <+13>:	push   ecx
   0x08048419 <+14>:	sub    esp,0x4
   0x0804841c <+17>:	sub    esp,0xc
   0x0804841f <+20>:	push   0x80484c0
   0x08048424 <+25>:	call   0x80482e0 <puts@plt>
   0x08048429 <+30>:	add    esp,0x10
   0x0804842c <+33>:	mov    eax,0x0
   0x08048431 <+38>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x08048434 <+41>:	leave  
   0x08048435 <+42>:	lea    esp,[ecx-0x4]
   0x08048438 <+45>:	ret    
End of assembler dump.

