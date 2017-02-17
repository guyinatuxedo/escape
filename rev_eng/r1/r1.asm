Dump of assembler code for function main:
   0x0804840b <+0>:	lea    ecx,[esp+0x4]
   0x0804840f <+4>:	and    esp,0xfffffff0
   0x08048412 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:	push   ebp
   0x08048416 <+11>:	mov    ebp,esp
   0x08048418 <+13>:	push   ecx
   0x08048419 <+14>:	sub    esp,0x14
   0x0804841c <+17>:	mov    DWORD PTR [ebp-0xc],0x1
   0x08048423 <+24>:	cmp    DWORD PTR [ebp-0xc],0x0
   0x08048427 <+28>:	je     0x8048439 <main+46>
   0x08048429 <+30>:	sub    esp,0xc
   0x0804842c <+33>:	push   0x80484d0
   0x08048431 <+38>:	call   0x80482e0 <puts@plt>
   0x08048436 <+43>:	add    esp,0x10
   0x08048439 <+46>:	mov    eax,0x0
   0x0804843e <+51>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x08048441 <+54>:	leave  
   0x08048442 <+55>:	lea    esp,[ecx-0x4]
   0x08048445 <+58>:	ret    
End of assembler dump.

