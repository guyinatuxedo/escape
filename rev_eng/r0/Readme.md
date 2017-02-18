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

Let's set a breakpoint for right after the call to puts, so we can see what it is about to print out
```
gdb-peda$ b *0x08048429
Breakpoint 1 at 0x8048429
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r0/r0 
```

Another wall of text later...

Now since looking at the assembly, right before puts is called there are two sub instructions directed at the esp register. Since arguments are pushed onto the stack prior to a function call, the string might be in that register. Let's take a look
```
gdb-peda$ x/20x $esp
0xffffd030:	0x080484c0	0xffffd0f4	0xffffd0fc	0x08048461
0xffffd040:	0xf7fb43dc	0xffffd060	0x00000000	0xf7e1a637
0xffffd050:	0xf7fb4000	0xf7fb4000	0x00000000	0xf7e1a637
0xffffd060:	0x00000001	0xffffd0f4	0xffffd0fc	0x00000000
0xffffd070:	0x00000000	0x00000000	0xf7fb4000	0xf7ffdc04
```

So we can see a memory address at 0x080484c0 in the register. This appears to be a static memory address. Let's see examine the contents of it as a string.

```
gdb-peda$ x/s 0x080484c0
0x80484c0:	"Hello World!"
```

So it is safe to say that the string it prints out is "Hello World!". Let's run the program to see if it matches this.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0$ ./r0
Hello World!
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0$ 
```

So just like that, we reversed the binary.
 
