Let's take a look at the assembly code...

```
   0x0804840b <+0>:     lea    ecx,[esp+0x4]
   0x0804840f <+4>:     and    esp,0xfffffff0
   0x08048412 <+7>:     push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:    push   ebp
   0x08048416 <+11>:    mov    ebp,esp
   0x08048418 <+13>:    push   ecx
   0x08048419 <+14>:    sub    esp,0x4
   0x0804841c <+17>:    sub    esp,0xc
   0x0804841f <+20>:    push   0x80484c0
   0x08048424 <+25>:    call   0x80482e0 <puts@plt>
   0x08048429 <+30>:    add    esp,0x10
   0x0804842c <+33>:    mov    eax,0x0
   0x08048431 <+38>:    mov    ecx,DWORD PTR [ebp-0x4]
   0x08048434 <+41>:    leave  
   0x08048435 <+42>:    lea    esp,[ecx-0x4]
   0x08048438 <+45>:    ret
```

So looking through the assembly code, a couple of things stick out. The first is the function call it makes.

```
   0x08048424 <+25>:    call   0x80482e0 <puts@plt>
```

So looking at that, it is fairly obvious that it calls the function puts() which is a low level function used by printf (or puts could be present in the C code). So with this we know the the program is probably printing something out.

Looking through the rest of the assembly code, nothing else big jumps out. There are no other call instructions, and no cmp, jmp, or jle instructions. So there really shouldn't be anything else to this program other than that it prints something. Let's find out what it prints using gdb.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0$ gdb ./r0
```

One wall of text later...

```
gdb-peda$ b *0x08048424
Breakpoint 1 at 0x8048424
gdb-peda$ r
```

 
