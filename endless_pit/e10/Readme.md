This writeup is essentially just documentaion for using gcc andthe Pwnableharness project which was made by c0deh4h4cker to make ctf challenges. I had/have no hand in it's creation or maitenance. If you want to, you can check out the project here.

```
https://github.com/C0deH4cker/PwnableHarness
```

First using gcc.

```
flags of interest:
-o                      Designate where you want the binary, and what it is to be called
-m32                    Designate you want the binary to be 32 bit
-m64                    Designate you want the binary to be 64 bit
-fno-stack-protector    Desingate you want the binary to not have a stack canary
-z execstack            Designate you want the binary to have an executable stack
-z norelro              Designate you want the binary to have no relro enabled
```

Now for examples with gcc. Here is my challenge (b0 from buf_ovf).

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    g = 0;
    gets(buffer);
    if(g)
    {
        printf("Wait aren't you supposed to be researching? Level Cleared!\n");
    }

}
```

Let's say I wanted to compile it as a 32 bit binary without a stack canary, this would be the syntax for it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0 (master)$ gcc b0.c -o b0 -m32 -fno-stack-protector
b0.c: In function ‘main’:
b0.c:9:5: warning: implicit declaration of function ‘gets’ [-Wimplicit-function-declaration]
     gets(buffer);
     ^
/tmp/ccVJ2ymn.o: In function `main':
b0.c:(.text+0x26): warning: the `gets' function is dangerous and should not be used.
```

As you can see, it gives a warning about the insecure gets function. Now for an example where I want to compile it as a 64 bit binary with an executable stack, no relro or stack canary.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0 (master)$ gcc b0.c -o b0_64 -m64 -fno-stack-protector -z execstack -z norelro
b0.c: In function ‘main’:
b0.c:9:5: warning: implicit declaration of function ‘gets’ [-Wimplicit-function-declaration]
     gets(buffer);
     ^
/tmp/ccZF9si9.o: In function `main':
b0.c:(.text+0x22): warning: the `gets' function is dangerous and should not be used.
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0 (master)$ pwn checksec b0_64[*] '/Hackery/escape/buf_ovf/b0/b0_64'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE
```

As you can see, we were able to compile the binary as we wanted to. Now onto Pwnableharness from c0deh4cker (which uses gcc).

This challenge is a bit different. Here we are going to make a ctf pwn challenge. CTF pwn challenges will typically run on a remote server, that is accessible via a network connection (usually through netcat). For this, we will be using a project called Pwnableharness made by c0deh4cker which will compile, and run the code automatically. In addition to that we will also setup all of the challenges to run in a docker instance for added security. Docker is a tool that will virtualize applications, and run them in a container. This is beneficial to us, since we can treat that container as a sandbox enviornment, unable to interact with the host OS. This way theoritically if someone were to try to attack the Server through one of the challenges, they couldn't because they would be stuck in the sandbox enviornment (however that doesn't stop everyone). 

First we will need to clone the Pwnableharness project from c0deh4cker, and install Docker-Enginer.

```
$	git clone https://github.com/C0deH4cker/PwnableHarness.git 
Cloning into 'PwnableHarness'...
remote: Counting objects: 167, done.
remote: Total 167 (delta 0), reused 0 (delta 0), pack-reused 167
Receiving objects: 100% (167/167), 42.58 KiB | 0 bytes/s, done.
Resolving deltas: 100% (92/92), done.
Checking connectivity... done.
```

This should create a folder in your current directory titled "PwnableHarness".

```
$	ls
backups  cr@ck_th3_c0de  double  PwnableHarness  shellcode  try
core     ctf             escape  pwnablekr       sun_chals
$	cd PwnableHarness
PwnableHarness$	ls
Build.mk    LICENSE.txt  Makefile           pwnable_harness.h  stack0
Dockerfile  Macros.mk    pwnable_harness.c  README.md
$ sudo apt-get install docker-engine
```

This folder already contains a fully functional challenge "stack0" that you can use as a reference. Now in order to make and run a challenge in docker with PwnableHarness, we need three things. The first is the code, which we will be using a modified version of the challenge b0 from buf_ovf (It will just be changed to print out a flag from a file when solved). The second thing is a "Build.mk" file which Pwnableharness will use to build the binary. The last thing is a "Dockerfile" file, which Docker will need in order to properly run the Docker Container. Now all of these things will need to be stored in a folder withing PwnableHarness.

```
PwnableHarness$ mkdir b0
PwnableHarness$ cd b0
```
Now we will start off with the C code for the binary. Here is the source code from the b0.c before we modified it.

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    g = 0;
    gets(buffer);
    if(g)
    {
        printf("Wait aren't you supposed to be researching? Level Cleared!\n");
    }

}
```

Here is it modified.

```
PwnableHarness/b0$ cat b0.c
#include <stdio.h>
#include <stdlib.h>
#include "pwnable_harness.h"

static void handle_connection(int sock)
{
    char buffer[489];
    int g;
    g = 0;
    gets(buffer);
    if(g)
    {
        FILE* flag;
	char rflag[50];
	flag = fopen("flag.txt", "r");
	while (fgets(rflag, sizeof(rflag), flag))
	{
		printf("%s", rflag);
	}
    }

}

int main(int argc, char** argv)
{
	server_options opts = {
		.user = "ctf_b0",
		.chrooted = true,
		.port = 41236,
		.time_limit_seconds = 30
	};
	
	return server_main(argc, argv, opts, &handle_connection);
}
```

As you can see, we changed the main function to handle_connection. The reason for this is when the application is running, it will be listening for connections. When it recieves a connection, then it will run the challenge. This way the challenge doesn't have to be restarted every time it runs, and can handle multiple connections at once. The second thing you'll notice is that I added an include for "pwnableharness.h". That will just had the program import PwnableHarness so it can use it's code. The last thing you will notice is I changed what happens when you win, from printing out a string to reading out of a file. Most ctf pwn challenges I've seen will do this, to prevent people from just reversing the application itself (which they usually get a copy of). Now that the C code is made, let's move on to the Build.mk file.

```
PwnableHarness/b0$ cat Build.mk
#Specify the binary which will be compiled
TARGET := b0

#Specify the Docker Image which this will be running as
DOCKER_IMAGE := guyinatuxedo/b0

#Specify additional files that will be loaded into the docker container
FLAG := $(patsunst $(DIR)/%,%,$(wildcard $(DIR)/flag.txt))
ARG_FLAG := $(if $(FLAG),FLAG=$(FLAG))
DOCKER_BUILD_ARGS := $(ARG_FLAG)

#Specify the port which the challenge will be running on
DOCKER_PORTS := 41236

#Specify that the Docker Container should be read only
DOCKER_RUN_ARGS := --read-only

#Define the stack to be NX (non-executable)
b0_NX := TRUE
```

One thing, there is a huge amount of other options and settings to define things from ASLR to if it is 32 bit or 64 bit (it's 32 bit by default). Those settings can be found  in the Build.mk file from stack0. Now onto the dockerfile.

```
#Import the pwnableharness docker image from https://hub.docker.com/r/c0deh4cker/pwnableharness/
FROM c0deh4cker/pwnableharness

#Specify the maintainer of the challenge
MAINTAINER guyinatuxedo <guy@tux.com>


#Import the Flag.txt file
ARG FLAG=flag.txt
ENV FLAG=$FLAG

#Copy over the flag.txt file
copy $FLAG flag.txt

#Set permissions for the flag.txt file
RUN chown root:$RUNTIME_NAME flag.txt && chmod 0640 flag.txt

#Define the port which the docker container will be accessible over
EXPOSE 41236 
```

Now that we have those three things in place, let's compile the binary. To do this, we will need to go to b0's parent directory, which is PwnableHarness's root directory.

```
PwnableHarness$ make
Compiling pwnable_harness.c
Linking shared library libpwnableharness32.so
Compiling pwnable_harness.c
Linking shared library libpwnableharness64.so
Compiling stack0/stack0.c
Linking executable stack0/stack0
Compiling b0/b0.c
b0/b0.c: In function ‘handle_connection’:
b0/b0.c:10:5: warning: implicit declaration of function ‘gets’ [-Wimplicit-function-declaration]
     gets(buffer);
     ^
Linking executable b0/b0
build/b0/b0.c.32.o: In function `handle_connection':
b0.c:(.text+0x1b): warning: the `gets' function is dangerous and should not be used.
PwnableHarness$ cd b0
PwnableHarness/b0$ ls
b0  b0.c  Build.mk  Dockerfile  flag.txt
```

As you can see, the binary has been compiled. Now in order to run it locally, since it has the include "pwnable_harness" in the C code, it will have to have either the libpwnableharness32.so or libpwnableharness64.so (matching if it is 32 bit or 64 bit) so let's do that. The challenge will run as a service, so you shouldn't need to keep the terminal open.

```
PwnableHarness/b0$ cd ..
PwnableHarness$ ls
b0        Dockerfile              LICENSE.txt  pwnable_harness.c  stack0
build     libpwnableharness32.so  Macros.mk    pwnable_harness.h
Build.mk  libpwnableharness64.so  Makefile     README.md
PwnableHarness$ cp libpwnableharness32.so b0/
```

So now that we have the compiled binary with the libpwnableharness library in the same directory, let's run it with Docker. Fortunately PwnableHarness makes this easy for us.

```
PwnableHarness$ sudo make docker-start
Building docker image c0deh4cker/pwnableharness
Sending build context to Docker daemon 291.8 kB
Step 1/11 : FROM ubuntu
 ---> 104bec311bcd
Step 2/11 : MAINTAINER C0deH4cker <c0deh4cker@gmail.com>
 ---> Using cache
 ---> 9d51c8fe8d6c
Step 3/11 : RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y libc6:i386
 ---> Using cache
 ---> 354b825f1624
Step 4/11 : COPY libpwnableharness32.so libpwnableharness64.so /usr/local/lib/
 ---> Using cache
 ---> 007e3e061783
Step 5/11 : CMD /bin/bash
 ---> Using cache
 ---> b9ac6eed06e7
Step 6/11 : ONBUILD arg RUNTIME_NAME
 ---> Using cache
 ---> 59d2274e1155
Step 7/11 : ONBUILD env RUNTIME_NAME $RUNTIME_NAME
 ---> Using cache
 ---> fcc5a7d9af7a
Step 8/11 : ONBUILD run useradd -m -s /bin/bash -U $RUNTIME_NAME
 ---> Using cache
 ---> 68bb8a1dcc3d
Step 9/11 : ONBUILD workdir /home/$RUNTIME_NAME
 ---> Using cache
 ---> 91e95e675704
Step 10/11 : ONBUILD copy $RUNTIME_NAME ./
 ---> Using cache
 ---> 7320641bde5b
Step 11/11 : ONBUILD entrypoint /bin/sh -c exec /home/$RUNTIME_NAME/$RUNTIME_NAME --listen --no-chroot --user $RUNTIME_NAME
 ---> Using cache
 ---> 6c347022d2d0
Successfully built 6c347022d2d0
Building docker image c0deh4cker/stack0
Sending build context to Docker daemon  25.6 kB
Step 1/9 : FROM c0deh4cker/pwnableharness
# Executing 6 build triggers...
Step 1/1 : ARG RUNTIME_NAME
 ---> Using cache
Step 1/1 : ENV RUNTIME_NAME $RUNTIME_NAME
 ---> Using cache
Step 1/1 : RUN useradd -m -s /bin/bash -U $RUNTIME_NAME
 ---> Using cache
Step 1/1 : WORKDIR /home/$RUNTIME_NAME
 ---> Using cache
Step 1/1 : COPY $RUNTIME_NAME ./
 ---> Using cache
Step 1/1 : ENTRYPOINT /bin/sh -c exec /home/$RUNTIME_NAME/$RUNTIME_NAME --listen --no-chroot --user $RUNTIME_NAME
 ---> Using cache
 ---> 8c2d047df347
Step 2/9 : MAINTAINER C0deH4cker <c0deh4cker@gmail.com>
 ---> Using cache
 ---> b4ea964be64d
Step 3/9 : ARG FLAG1=flag1.txt
 ---> Using cache
 ---> 2ec4ca4649e0
Step 4/9 : ARG FLAG2=flag2.txt
 ---> Using cache
 ---> 917942426258
Step 5/9 : ENV FLAG1 $FLAG1 FLAG2 $FLAG2
 ---> Using cache
 ---> 2430b1837ab7
Step 6/9 : COPY $FLAG1 flag1.txt
 ---> Using cache
 ---> bb5151730159
Step 7/9 : COPY $FLAG2 flag2.txt
 ---> Using cache
 ---> 88a19cef4e55
Step 8/9 : RUN chown root:$RUNTIME_NAME flag*.txt && chmod 0640 flag1.txt flag2.txt
 ---> Using cache
 ---> 921bdb1c0047
Step 9/9 : EXPOSE 32101
 ---> Using cache
 ---> d25359d5bc31
Successfully built d25359d5bc31
Starting docker container stack0 from image c0deh4cker/stack0
b66e95942b03a021da91aaab55b7cf4e842981d307cfb436babde144822e2e62
Building docker image guyinatuxedo/b0
Sending build context to Docker daemon  12.8 kB
Step 1/6 : FROM c0deh4cker/pwnableharness
# Executing 6 build triggers...
Step 1/1 : ARG RUNTIME_NAME
 ---> Using cache
Step 1/1 : ENV RUNTIME_NAME $RUNTIME_NAME
 ---> Using cache
Step 1/1 : RUN useradd -m -s /bin/bash -U $RUNTIME_NAME
 ---> Using cache
Step 1/1 : WORKDIR /home/$RUNTIME_NAME
 ---> Using cache
Step 1/1 : COPY $RUNTIME_NAME ./
 ---> Using cache
Step 1/1 : ENTRYPOINT /bin/sh -c exec /home/$RUNTIME_NAME/$RUNTIME_NAME --listen --no-chroot --user $RUNTIME_NAME
 ---> Using cache
 ---> 98e488ac94d8
Step 2/6 : ARG FLAG=flag.txt
 ---> Using cache
 ---> 5828eb516772
Step 3/6 : ENV FLAG $FLAG
 ---> Using cache
 ---> 6cbc9f1eacf8
Step 4/6 : COPY $FLAG flag.txt
 ---> 22c24081a32b
Removing intermediate container 07309a09e4c2
Step 5/6 : RUN chown root:$RUNTIME_NAME flag.txt && chmod 0640 flag.txt
 ---> Running in bf46a0c623cf
 ---> 2c47c488434f
Removing intermediate container bf46a0c623cf
Step 6/6 : EXPOSE 41236
 ---> Running in be4415162e30
 ---> cc446c23984c
Removing intermediate container be4415162e30
Successfully built cc446c23984c
Starting docker container b0 from image guyinatuxedo/b0
470e46b6017701199d7ac3d25da31c64d0fabc828a760072f837febb440c7949
```

There are other commands that PwnableHarness supports for managine docker containers.

```
make docker-stop:	Stops Docker containers
make docker-restart:	Restarts Docker containers
make docker-clean:	Removes Docker Images and Containers
make docker-build:	Build Docker images for all challenges without one, or that isn't current
make docker-rebuild:	Forces all challenges to rebuild their images.
```

Now let's verify that the two docker containers are running (one for stack0 and one for b0).

```
$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
a2b1d96a11f3        guyinatuxedo/b0     "/bin/sh -c 'exec ..."   3 seconds ago       Up 2 seconds        0.0.0.0:41236->41236/tcp   b0
f5692f1b3488        c0deh4cker/stack0   "/bin/sh -c 'exec ..."   3 seconds ago       Up 2 seconds        0.0.0.0:32101->32101/tcp   stack0
```

So now that b0 is running, let's try and solve the challenge via the intance running in the docker container.

```
$ nc localhost 41236
Is this working?
$	python -c 'print "0"*500' | nc localhost 41236
flag{N0w_y0u_g3t_2_m@k3_pe0ple_cry}
```

As you can see, the challenge is functioning as expected. Let's test the challenge using the locally stored copy to see if that is working.

```
guyinatuxedo@tux:/Hackery/PwnableHarness/b0$ ./b0
This better be working
guyinatuxedo@tux:/Hackery/PwnableHarness/b0$ python -c 'print "0"*500' | ./b0
flag{N0w_y0u_g3t_2_m@k3_pe0ple_cry}
```

As you can see, the local copy is working just fine (remember that it has to have one of the libpwnableharness.so files in the same folder). And just like that, we made something for someone to pwn. Now for all of the other possible options for the Build.mk file. Now if you want more advanced documentation, you can find that with the project itself for things such as how to deal with individual challenges and other settings from the Build.mk file.
 


