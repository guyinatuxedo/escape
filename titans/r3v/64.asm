   0x0000000000400ab7 <+0>:	push   rbp
   0x0000000000400ab8 <+1>:	mov    rbp,rsp
   0x0000000000400abb <+4>:	sub    rsp,0x370
   0x0000000000400ac2 <+11>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400acb <+20>:	mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400acf <+24>:	xor    eax,eax
   0x0000000000400ad1 <+26>:	mov    edi,0x401310
   0x0000000000400ad6 <+31>:	call   0x4006a0 <puts@plt>
   0x0000000000400adb <+36>:	mov    rdx,QWORD PTR [rip+0x2015ae]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400ae2 <+43>:	lea    rax,[rbp-0x200]
   0x0000000000400ae9 <+50>:	mov    esi,0x32
   0x0000000000400aee <+55>:	mov    rdi,rax
   0x0000000000400af1 <+58>:	call   0x400700 <fgets@plt>
   0x0000000000400af6 <+63>:	lea    rax,[rbp-0x200]
   0x0000000000400afd <+70>:	mov    edx,0x3
   0x0000000000400b02 <+75>:	mov    esi,0x40134a
   0x0000000000400b07 <+80>:	mov    rdi,rax
   0x0000000000400b0a <+83>:	call   0x400690 <strncmp@plt>
   0x0000000000400b0f <+88>:	test   eax,eax
   0x0000000000400b11 <+90>:	jne    0x400b27 <main+112>
   0x0000000000400b13 <+92>:	mov    edi,0x401350
   0x0000000000400b18 <+97>:	call   0x4006a0 <puts@plt>
   0x0000000000400b1d <+102>:	mov    eax,0x0
   0x0000000000400b22 <+107>:	call   0x4008c9 <end_of_journey>
   0x0000000000400b27 <+112>:	lea    rax,[rbp-0x200]
   0x0000000000400b2e <+119>:	mov    edx,0x5
   0x0000000000400b33 <+124>:	mov    esi,0x401373
   0x0000000000400b38 <+129>:	mov    rdi,rax
   0x0000000000400b3b <+132>:	call   0x400690 <strncmp@plt>
   0x0000000000400b40 <+137>:	test   eax,eax
   0x0000000000400b42 <+139>:	jne    0x400cea <main+563>
   0x0000000000400b48 <+145>:	mov    edi,0x401380
   0x0000000000400b4d <+150>:	call   0x4006a0 <puts@plt>
   0x0000000000400b52 <+155>:	mov    rdx,QWORD PTR [rip+0x201537]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400b59 <+162>:	lea    rax,[rbp-0x310]
   0x0000000000400b60 <+169>:	mov    esi,0x14
   0x0000000000400b65 <+174>:	mov    rdi,rax
   0x0000000000400b68 <+177>:	call   0x400700 <fgets@plt>
   0x0000000000400b6d <+182>:	lea    rax,[rbp-0x2d0]
   0x0000000000400b74 <+189>:	movabs rcx,0x6e616c6574736177
   0x0000000000400b7e <+199>:	mov    QWORD PTR [rax],rcx
   0x0000000000400b81 <+202>:	mov    WORD PTR [rax+0x8],0x64
   0x0000000000400b87 <+208>:	lea    rax,[rbp-0x2d0]
   0x0000000000400b8e <+215>:	mov    rdi,rax
   0x0000000000400b91 <+218>:	call   0x4006a0 <puts@plt>
   0x0000000000400b96 <+223>:	mov    rdx,QWORD PTR [rip+0x2014f3]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400b9d <+230>:	lea    rax,[rbp-0x2f0]
   0x0000000000400ba4 <+237>:	mov    esi,0x14
   0x0000000000400ba9 <+242>:	mov    rdi,rax
   0x0000000000400bac <+245>:	call   0x400700 <fgets@plt>
   0x0000000000400bb1 <+250>:	lea    rdx,[rbp-0x2d0]
   0x0000000000400bb8 <+257>:	lea    rax,[rbp-0x310]
   0x0000000000400bbf <+264>:	mov    rsi,rdx
   0x0000000000400bc2 <+267>:	mov    rdi,rax
   0x0000000000400bc5 <+270>:	call   0x400730 <strcat@plt>
   0x0000000000400bca <+275>:	lea    rax,[rbp-0x310]
   0x0000000000400bd1 <+282>:	mov    rdi,rax
   0x0000000000400bd4 <+285>:	call   0x4006c0 <strlen@plt>
   0x0000000000400bd9 <+290>:	mov    DWORD PTR [rbp-0x35c],eax
   0x0000000000400bdf <+296>:	lea    rax,[rbp-0x2f0]
   0x0000000000400be6 <+303>:	mov    rdi,rax
   0x0000000000400be9 <+306>:	call   0x4006b0 <atof@plt>
   0x0000000000400bee <+311>:	cvttsd2si eax,xmm0
   0x0000000000400bf2 <+315>:	mov    DWORD PTR [rbp-0x358],eax
   0x0000000000400bf8 <+321>:	mov    eax,DWORD PTR [rbp-0x35c]
   0x0000000000400bfe <+327>:	cmp    eax,DWORD PTR [rbp-0x358]
   0x0000000000400c04 <+333>:	jne    0x400cea <main+563>
   0x0000000000400c0a <+339>:	mov    rdx,QWORD PTR [rip+0x20147f]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400c11 <+346>:	lea    rax,[rbp-0x2b0]
   0x0000000000400c18 <+353>:	mov    esi,0x14
   0x0000000000400c1d <+358>:	mov    rdi,rax
   0x0000000000400c20 <+361>:	call   0x400700 <fgets@plt>
   0x0000000000400c25 <+366>:	lea    rax,[rbp-0x2b0]
   0x0000000000400c2c <+373>:	mov    rdi,rax
   0x0000000000400c2f <+376>:	call   0x4006b0 <atof@plt>
   0x0000000000400c34 <+381>:	cvttsd2si eax,xmm0
   0x0000000000400c38 <+385>:	mov    DWORD PTR [rbp-0x354],eax
   0x0000000000400c3e <+391>:	sar    DWORD PTR [rbp-0x354],0x2
   0x0000000000400c45 <+398>:	shl    DWORD PTR [rbp-0x354],0x4
   0x0000000000400c4c <+405>:	sar    DWORD PTR [rbp-0x354],1
   0x0000000000400c52 <+411>:	shl    DWORD PTR [rbp-0x354],0x4
   0x0000000000400c59 <+418>:	sar    DWORD PTR [rbp-0x354],0x4
   0x0000000000400c60 <+425>:	shl    DWORD PTR [rbp-0x354],0x9
   0x0000000000400c67 <+432>:	sar    DWORD PTR [rbp-0x354],0x5
   0x0000000000400c6e <+439>:	shl    DWORD PTR [rbp-0x354],0x4
   0x0000000000400c75 <+446>:	sar    DWORD PTR [rbp-0x354],0x3
   0x0000000000400c7c <+453>:	shl    DWORD PTR [rbp-0x354],0x2
   0x0000000000400c83 <+460>:	mov    rdx,QWORD PTR [rip+0x201406]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400c8a <+467>:	lea    rax,[rbp-0x270]
   0x0000000000400c91 <+474>:	mov    esi,0x14
   0x0000000000400c96 <+479>:	mov    rdi,rax
   0x0000000000400c99 <+482>:	call   0x400700 <fgets@plt>
   0x0000000000400c9e <+487>:	lea    rax,[rbp-0x270]
   0x0000000000400ca5 <+494>:	mov    rdi,rax
   0x0000000000400ca8 <+497>:	call   0x4006b0 <atof@plt>
   0x0000000000400cad <+502>:	cvttsd2si eax,xmm0
   0x0000000000400cb1 <+506>:	mov    DWORD PTR [rbp-0x350],eax
   0x0000000000400cb7 <+512>:	mov    eax,DWORD PTR [rbp-0x354]
   0x0000000000400cbd <+518>:	cmp    eax,DWORD PTR [rbp-0x350]
   0x0000000000400cc3 <+524>:	jne    0x400cea <main+563>
   0x0000000000400cc5 <+526>:	mov    esi,0x401228
   0x0000000000400cca <+531>:	mov    edi,0x4013af
   0x0000000000400ccf <+536>:	call   0x400720 <fopen@plt>
   0x0000000000400cd4 <+541>:	mov    QWORD PTR [rbp-0x328],rax
   0x0000000000400cdb <+548>:	mov    rax,QWORD PTR [rbp-0x328]
   0x0000000000400ce2 <+555>:	mov    rdi,rax
   0x0000000000400ce5 <+558>:	call   0x400986 <pathfinding>
   0x0000000000400cea <+563>:	lea    rax,[rbp-0x200]
   0x0000000000400cf1 <+570>:	mov    edx,0x4
   0x0000000000400cf6 <+575>:	mov    esi,0x4013b1
   0x0000000000400cfb <+580>:	mov    rdi,rax
   0x0000000000400cfe <+583>:	call   0x400690 <strncmp@plt>
   0x0000000000400d03 <+588>:	test   eax,eax
   0x0000000000400d05 <+590>:	jne    0x400ecb <main+1044>
   0x0000000000400d0b <+596>:	mov    edi,0x4013b8
   0x0000000000400d10 <+601>:	call   0x4006a0 <puts@plt>
   0x0000000000400d15 <+606>:	mov    rdx,QWORD PTR [rip+0x201374]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400d1c <+613>:	lea    rax,[rbp-0x2f0]
   0x0000000000400d23 <+620>:	mov    esi,0x14
   0x0000000000400d28 <+625>:	mov    rdi,rax
   0x0000000000400d2b <+628>:	call   0x400700 <fgets@plt>
   0x0000000000400d30 <+633>:	mov    rdx,QWORD PTR [rip+0x201359]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400d37 <+640>:	lea    rax,[rbp-0x2d0]
   0x0000000000400d3e <+647>:	mov    esi,0x14
   0x0000000000400d43 <+652>:	mov    rdi,rax
   0x0000000000400d46 <+655>:	call   0x400700 <fgets@plt>
   0x0000000000400d4b <+660>:	mov    rdx,QWORD PTR [rip+0x20133e]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400d52 <+667>:	lea    rax,[rbp-0x2b0]
   0x0000000000400d59 <+674>:	mov    esi,0x14
   0x0000000000400d5e <+679>:	mov    rdi,rax
   0x0000000000400d61 <+682>:	call   0x400700 <fgets@plt>
   0x0000000000400d66 <+687>:	lea    rax,[rbp-0x2b0]
   0x0000000000400d6d <+694>:	mov    rdi,rax
   0x0000000000400d70 <+697>:	call   0x4006b0 <atof@plt>
   0x0000000000400d75 <+702>:	cvttsd2si eax,xmm0
   0x0000000000400d79 <+706>:	mov    DWORD PTR [rbp-0x34c],eax
   0x0000000000400d7f <+712>:	mov    DWORD PTR [rbp-0x348],0xdead
   0x0000000000400d89 <+722>:	mov    eax,DWORD PTR [rbp-0x34c]
   0x0000000000400d8f <+728>:	xor    eax,DWORD PTR [rbp-0x348]
   0x0000000000400d95 <+734>:	mov    DWORD PTR [rbp-0x344],eax
   0x0000000000400d9b <+740>:	cmp    DWORD PTR [rbp-0x344],0x32
   0x0000000000400da2 <+747>:	jne    0x400ecb <main+1044>
   0x0000000000400da8 <+753>:	mov    DWORD PTR [rbp-0x340],0x0
   0x0000000000400db2 <+763>:	mov    DWORD PTR [rbp-0x33c],0xffffffff
   0x0000000000400dbc <+773>:	mov    eax,DWORD PTR [rbp-0x348]
   0x0000000000400dc2 <+779>:	or     eax,DWORD PTR [rbp-0x34c]
   0x0000000000400dc8 <+785>:	mov    DWORD PTR [rbp-0x33c],eax
   0x0000000000400dce <+791>:	mov    eax,DWORD PTR [rbp-0x340]
   0x0000000000400dd4 <+797>:	or     DWORD PTR [rbp-0x34c],eax
   0x0000000000400dda <+803>:	mov    eax,DWORD PTR [rbp-0x33c]
   0x0000000000400de0 <+809>:	or     eax,DWORD PTR [rbp-0x348]
   0x0000000000400de6 <+815>:	mov    DWORD PTR [rbp-0x338],eax
   0x0000000000400dec <+821>:	mov    eax,DWORD PTR [rbp-0x338]
   0x0000000000400df2 <+827>:	or     eax,DWORD PTR [rbp-0x34c]
   0x0000000000400df8 <+833>:	mov    DWORD PTR [rbp-0x340],eax
   0x0000000000400dfe <+839>:	mov    eax,DWORD PTR [rbp-0x33c]
   0x0000000000400e04 <+845>:	or     eax,DWORD PTR [rbp-0x340]
   0x0000000000400e0a <+851>:	mov    DWORD PTR [rbp-0x348],eax
   0x0000000000400e10 <+857>:	mov    eax,DWORD PTR [rbp-0x33c]
   0x0000000000400e16 <+863>:	and    eax,DWORD PTR [rbp-0x340]
   0x0000000000400e1c <+869>:	mov    DWORD PTR [rbp-0x34c],eax
   0x0000000000400e22 <+875>:	mov    eax,DWORD PTR [rbp-0x34c]
   0x0000000000400e28 <+881>:	and    eax,DWORD PTR [rbp-0x338]
   0x0000000000400e2e <+887>:	mov    DWORD PTR [rbp-0x348],eax
   0x0000000000400e34 <+893>:	mov    eax,DWORD PTR [rbp-0x348]
   0x0000000000400e3a <+899>:	xor    eax,DWORD PTR [rbp-0x33c]
   0x0000000000400e40 <+905>:	mov    DWORD PTR [rbp-0x340],eax
   0x0000000000400e46 <+911>:	mov    eax,DWORD PTR [rbp-0x34c]
   0x0000000000400e4c <+917>:	xor    eax,DWORD PTR [rbp-0x340]
   0x0000000000400e52 <+923>:	mov    DWORD PTR [rbp-0x33c],eax
   0x0000000000400e58 <+929>:	mov    eax,DWORD PTR [rbp-0x340]
   0x0000000000400e5e <+935>:	xor    DWORD PTR [rbp-0x338],eax
   0x0000000000400e64 <+941>:	mov    rdx,QWORD PTR [rip+0x201225]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400e6b <+948>:	lea    rax,[rbp-0x270]
   0x0000000000400e72 <+955>:	mov    esi,0x14
   0x0000000000400e77 <+960>:	mov    rdi,rax
   0x0000000000400e7a <+963>:	call   0x400700 <fgets@plt>
   0x0000000000400e7f <+968>:	lea    rax,[rbp-0x270]
   0x0000000000400e86 <+975>:	mov    rdi,rax
   0x0000000000400e89 <+978>:	call   0x4006b0 <atof@plt>
   0x0000000000400e8e <+983>:	cvttsd2si eax,xmm0
   0x0000000000400e92 <+987>:	mov    DWORD PTR [rbp-0x334],eax
   0x0000000000400e98 <+993>:	mov    eax,DWORD PTR [rbp-0x338]
   0x0000000000400e9e <+999>:	cmp    eax,DWORD PTR [rbp-0x334]
   0x0000000000400ea4 <+1005>:	jne    0x400ecb <main+1044>
   0x0000000000400ea6 <+1007>:	mov    esi,0x401228
   0x0000000000400eab <+1012>:	mov    edi,0x4013de
   0x0000000000400eb0 <+1017>:	call   0x400720 <fopen@plt>
   0x0000000000400eb5 <+1022>:	mov    QWORD PTR [rbp-0x328],rax
   0x0000000000400ebc <+1029>:	mov    rax,QWORD PTR [rbp-0x328]
   0x0000000000400ec3 <+1036>:	mov    rdi,rax
   0x0000000000400ec6 <+1039>:	call   0x400986 <pathfinding>
   0x0000000000400ecb <+1044>:	lea    rax,[rbp-0x200]
   0x0000000000400ed2 <+1051>:	mov    edx,0x4
   0x0000000000400ed7 <+1056>:	mov    esi,0x4013e0
   0x0000000000400edc <+1061>:	mov    rdi,rax
   0x0000000000400edf <+1064>:	call   0x400690 <strncmp@plt>
   0x0000000000400ee4 <+1069>:	test   eax,eax
   0x0000000000400ee6 <+1071>:	jne    0x401045 <main+1422>
   0x0000000000400eec <+1077>:	mov    edi,0x4013e8
   0x0000000000400ef1 <+1082>:	call   0x4006a0 <puts@plt>
   0x0000000000400ef6 <+1087>:	mov    DWORD PTR [rbp-0x368],0x1
   0x0000000000400f00 <+1097>:	jmp    0x400f12 <main+1115>
   0x0000000000400f02 <+1099>:	shl    DWORD PTR [rbp-0x368],1
   0x0000000000400f08 <+1105>:	mov    edi,0x401410
   0x0000000000400f0d <+1110>:	call   0x4006a0 <puts@plt>
   0x0000000000400f12 <+1115>:	cmp    DWORD PTR [rbp-0x368],0x31
   0x0000000000400f19 <+1122>:	jle    0x400f02 <main+1099>
   0x0000000000400f1b <+1124>:	mov    DWORD PTR [rbp-0x330],0x0
   0x0000000000400f25 <+1134>:	mov    rdx,QWORD PTR [rip+0x201164]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400f2c <+1141>:	lea    rax,[rbp-0x270]
   0x0000000000400f33 <+1148>:	mov    esi,0x64
   0x0000000000400f38 <+1153>:	mov    rdi,rax
   0x0000000000400f3b <+1156>:	call   0x400700 <fgets@plt>
   0x0000000000400f40 <+1161>:	lea    rax,[rbp-0x270]
   0x0000000000400f47 <+1168>:	mov    rdi,rax
   0x0000000000400f4a <+1171>:	call   0x4006b0 <atof@plt>
   0x0000000000400f4f <+1176>:	cvttsd2si eax,xmm0
   0x0000000000400f53 <+1180>:	mov    DWORD PTR [rbp-0x330],eax
   0x0000000000400f59 <+1186>:	mov    eax,DWORD PTR [rbp-0x330]
   0x0000000000400f5f <+1192>:	cmp    eax,DWORD PTR [rbp-0x368]
   0x0000000000400f65 <+1198>:	jne    0x401045 <main+1422>
   0x0000000000400f6b <+1204>:	mov    DWORD PTR [rbp-0x364],0x2
   0x0000000000400f75 <+1214>:	mov    DWORD PTR [rbp-0x368],0x0
   0x0000000000400f7f <+1224>:	jmp    0x400fd5 <main+1310>
   0x0000000000400f81 <+1226>:	shl    DWORD PTR [rbp-0x364],1
   0x0000000000400f87 <+1232>:	add    DWORD PTR [rbp-0x364],0xf5
   0x0000000000400f91 <+1242>:	mov    eax,DWORD PTR [rbp-0x364]
   0x0000000000400f97 <+1248>:	imul   eax,eax,0x6f9
   0x0000000000400f9d <+1254>:	mov    DWORD PTR [rbp-0x364],eax
   0x0000000000400fa3 <+1260>:	mov    ecx,DWORD PTR [rbp-0x364]
   0x0000000000400fa9 <+1266>:	mov    edx,0x1bd71c0f
   0x0000000000400fae <+1271>:	mov    eax,ecx
   0x0000000000400fb0 <+1273>:	imul   edx
   0x0000000000400fb2 <+1275>:	sar    edx,0x8
   0x0000000000400fb5 <+1278>:	mov    eax,ecx
   0x0000000000400fb7 <+1280>:	sar    eax,0x1f
   0x0000000000400fba <+1283>:	sub    edx,eax
   0x0000000000400fbc <+1285>:	mov    eax,edx
   0x0000000000400fbe <+1287>:	imul   eax,eax,0x932
   0x0000000000400fc4 <+1293>:	sub    ecx,eax
   0x0000000000400fc6 <+1295>:	mov    eax,ecx
   0x0000000000400fc8 <+1297>:	mov    DWORD PTR [rbp-0x360],eax
   0x0000000000400fce <+1303>:	add    DWORD PTR [rbp-0x368],0x1
   0x0000000000400fd5 <+1310>:	cmp    DWORD PTR [rbp-0x368],0x13
   0x0000000000400fdc <+1317>:	jle    0x400f81 <main+1226>
   0x0000000000400fde <+1319>:	mov    rdx,QWORD PTR [rip+0x2010ab]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000400fe5 <+1326>:	lea    rax,[rbp-0x2b0]
   0x0000000000400fec <+1333>:	mov    esi,0x32
   0x0000000000400ff1 <+1338>:	mov    rdi,rax
   0x0000000000400ff4 <+1341>:	call   0x400700 <fgets@plt>
   0x0000000000400ff9 <+1346>:	lea    rax,[rbp-0x2b0]
   0x0000000000401000 <+1353>:	mov    rdi,rax
   0x0000000000401003 <+1356>:	call   0x4006b0 <atof@plt>
   0x0000000000401008 <+1361>:	cvttsd2si eax,xmm0
   0x000000000040100c <+1365>:	mov    DWORD PTR [rbp-0x364],eax
   0x0000000000401012 <+1371>:	mov    eax,DWORD PTR [rbp-0x364]
   0x0000000000401018 <+1377>:	cmp    eax,DWORD PTR [rbp-0x360]
   0x000000000040101e <+1383>:	jne    0x401045 <main+1422>
   0x0000000000401020 <+1385>:	mov    esi,0x401228
   0x0000000000401025 <+1390>:	mov    edi,0x401438
   0x000000000040102a <+1395>:	call   0x400720 <fopen@plt>
   0x000000000040102f <+1400>:	mov    QWORD PTR [rbp-0x328],rax
   0x0000000000401036 <+1407>:	mov    rax,QWORD PTR [rbp-0x328]
   0x000000000040103d <+1414>:	mov    rdi,rax
   0x0000000000401040 <+1417>:	call   0x400986 <pathfinding>
   0x0000000000401045 <+1422>:	lea    rax,[rbp-0x200]
   0x000000000040104c <+1429>:	mov    edx,0x5
   0x0000000000401051 <+1434>:	mov    esi,0x40143a
   0x0000000000401056 <+1439>:	mov    rdi,rax
   0x0000000000401059 <+1442>:	call   0x400690 <strncmp@plt>
   0x000000000040105e <+1447>:	test   eax,eax
   0x0000000000401060 <+1449>:	jne    0x401181 <main+1738>
   0x0000000000401066 <+1455>:	mov    edi,0x401440
   0x000000000040106b <+1460>:	call   0x4006a0 <puts@plt>
   0x0000000000401070 <+1465>:	mov    rdx,QWORD PTR [rip+0x201019]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000401077 <+1472>:	lea    rax,[rbp-0x2b0]
   0x000000000040107e <+1479>:	mov    esi,0x5
   0x0000000000401083 <+1484>:	mov    rdi,rax
   0x0000000000401086 <+1487>:	call   0x400700 <fgets@plt>
   0x000000000040108b <+1492>:	lea    rax,[rbp-0x2b0]
   0x0000000000401092 <+1499>:	mov    rdi,rax
   0x0000000000401095 <+1502>:	call   0x4006b0 <atof@plt>
   0x000000000040109a <+1507>:	cvtsd2ss xmm2,xmm0
   0x000000000040109e <+1511>:	movss  DWORD PTR [rbp-0x32c],xmm2
   0x00000000004010a6 <+1519>:	cvtss2sd xmm0,DWORD PTR [rbp-0x32c]
   0x00000000004010ae <+1527>:	movsd  xmm1,QWORD PTR [rip+0x422]        # 0x4014d8
   0x00000000004010b6 <+1535>:	ucomisd xmm1,xmm0
   0x00000000004010ba <+1539>:	jbe    0x4010d0 <main+1561>
   0x00000000004010bc <+1541>:	mov    edi,0x401468
   0x00000000004010c1 <+1546>:	call   0x4006a0 <puts@plt>
   0x00000000004010c6 <+1551>:	mov    edi,0x0
   0x00000000004010cb <+1556>:	call   0x400740 <exit@plt>
   0x00000000004010d0 <+1561>:	cvtss2sd xmm0,DWORD PTR [rbp-0x32c]
   0x00000000004010d8 <+1569>:	ucomisd xmm0,QWORD PTR [rip+0x3f8]        # 0x4014d8
   0x00000000004010e0 <+1577>:	jbe    0x4010f6 <main+1599>
   0x00000000004010e2 <+1579>:	mov    edi,0x401471
   0x00000000004010e7 <+1584>:	call   0x4006a0 <puts@plt>
   0x00000000004010ec <+1589>:	mov    edi,0x0
   0x00000000004010f1 <+1594>:	call   0x400740 <exit@plt>
   0x00000000004010f6 <+1599>:	mov    edi,0x401480
   0x00000000004010fb <+1604>:	call   0x4006a0 <puts@plt>
   0x0000000000401100 <+1609>:	mov    eax,0x0
   0x0000000000401105 <+1614>:	call   0x4009f9 <djb2hash>
   0x000000000040110a <+1619>:	mov    QWORD PTR [rbp-0x320],rax
   0x0000000000401111 <+1626>:	mov    rdx,QWORD PTR [rip+0x200f78]        # 0x602090 <stdin@@GLIBC_2.2.5>
   0x0000000000401118 <+1633>:	lea    rax,[rbp-0x270]
   0x000000000040111f <+1640>:	mov    esi,0xa
   0x0000000000401124 <+1645>:	mov    rdi,rax
   0x0000000000401127 <+1648>:	call   0x400700 <fgets@plt>
   0x000000000040112c <+1653>:	lea    rax,[rbp-0x270]
   0x0000000000401133 <+1660>:	mov    rdi,rax
   0x0000000000401136 <+1663>:	call   0x400710 <atol@plt>
   0x000000000040113b <+1668>:	mov    QWORD PTR [rbp-0x318],rax
   0x0000000000401142 <+1675>:	mov    rax,QWORD PTR [rbp-0x320]
   0x0000000000401149 <+1682>:	cmp    rax,QWORD PTR [rbp-0x318]
   0x0000000000401150 <+1689>:	jne    0x401181 <main+1738>
   0x0000000000401152 <+1691>:	mov    edi,0x4014cb
   0x0000000000401157 <+1696>:	call   0x4006a0 <puts@plt>
   0x000000000040115c <+1701>:	mov    esi,0x401228
   0x0000000000401161 <+1706>:	mov    edi,0x4014d6
   0x0000000000401166 <+1711>:	call   0x400720 <fopen@plt>
   0x000000000040116b <+1716>:	mov    QWORD PTR [rbp-0x328],rax
   0x0000000000401172 <+1723>:	mov    rax,QWORD PTR [rbp-0x328]
   0x0000000000401179 <+1730>:	mov    rdi,rax
   0x000000000040117c <+1733>:	call   0x400986 <pathfinding>
   0x0000000000401181 <+1738>:	mov    eax,0x0
   0x0000000000401186 <+1743>:	mov    rcx,QWORD PTR [rbp-0x8]
   0x000000000040118a <+1747>:	xor    rcx,QWORD PTR fs:0x28
   0x0000000000401193 <+1756>:	je     0x40119a <main+1763>
   0x0000000000401195 <+1758>:	call   0x4006d0 <__stack_chk_fail@plt>
   0x000000000040119a <+1763>:	leave  
   0x000000000040119b <+1764>:	ret  
