   0x08048892 <+0>:	lea    ecx,[esp+0x4]
   0x08048896 <+4>:	and    esp,0xfffffff0
   0x08048899 <+7>:	push   DWORD PTR [ecx-0x4]
   0x0804889c <+10>:	push   ebp
   0x0804889d <+11>:	mov    ebp,esp
   0x0804889f <+13>:	push   ecx
   0x080488a0 <+14>:	sub    esp,0x334
   0x080488a6 <+20>:	mov    eax,gs:0x14
   0x080488ac <+26>:	mov    DWORD PTR [ebp-0xc],eax
   0x080488af <+29>:	xor    eax,eax
   0x080488b1 <+31>:	sub    esp,0xc
   0x080488b4 <+34>:	push   0x8049210
   0x080488b9 <+39>:	call   0x80484d0 <puts@plt>
   0x080488be <+44>:	add    esp,0x10
   0x080488c1 <+47>:	mov    eax,ds:0x804b060
   0x080488c6 <+52>:	sub    esp,0x4
   0x080488c9 <+55>:	push   eax
   0x080488ca <+56>:	push   0x32
   0x080488cc <+58>:	lea    eax,[ebp-0x200]
   0x080488d2 <+64>:	push   eax
   0x080488d3 <+65>:	call   0x80484a0 <fgets@plt>
   0x080488d8 <+70>:	add    esp,0x10
   0x080488db <+73>:	sub    esp,0x4
   0x080488de <+76>:	push   0x3
   0x080488e0 <+78>:	push   0x804924a
   0x080488e5 <+83>:	lea    eax,[ebp-0x200]
   0x080488eb <+89>:	push   eax
   0x080488ec <+90>:	call   0x8048540 <strncmp@plt>
   0x080488f1 <+95>:	add    esp,0x10
   0x080488f4 <+98>:	test   eax,eax
   0x080488f6 <+100>:	jne    0x804890d <main+123>
   0x080488f8 <+102>:	sub    esp,0xc
   0x080488fb <+105>:	push   0x8049250
   0x08048900 <+110>:	call   0x80484d0 <puts@plt>
   0x08048905 <+115>:	add    esp,0x10
   0x08048908 <+118>:	call   0x80486c6 <end_of_journey>
   0x0804890d <+123>:	sub    esp,0x4
   0x08048910 <+126>:	push   0x5
   0x08048912 <+128>:	push   0x8049273
   0x08048917 <+133>:	lea    eax,[ebp-0x200]
   0x0804891d <+139>:	push   eax
   0x0804891e <+140>:	call   0x8048540 <strncmp@plt>
   0x08048923 <+145>:	add    esp,0x10
   0x08048926 <+148>:	test   eax,eax
   0x08048928 <+150>:	jne    0x8048b41 <main+687>
   0x0804892e <+156>:	sub    esp,0xc
   0x08048931 <+159>:	push   0x804927c
   0x08048936 <+164>:	call   0x80484d0 <puts@plt>
   0x0804893b <+169>:	add    esp,0x10
   0x0804893e <+172>:	mov    eax,ds:0x804b060
   0x08048943 <+177>:	sub    esp,0x4
   0x08048946 <+180>:	push   eax
   0x08048947 <+181>:	push   0x14
   0x08048949 <+183>:	lea    eax,[ebp-0x2d2]
   0x0804894f <+189>:	push   eax
   0x08048950 <+190>:	call   0x80484a0 <fgets@plt>
   0x08048955 <+195>:	add    esp,0x10
   0x08048958 <+198>:	lea    eax,[ebp-0x2aa]
   0x0804895e <+204>:	mov    DWORD PTR [eax],0x74736177
   0x08048964 <+210>:	mov    DWORD PTR [eax+0x4],0x6e616c65
   0x0804896b <+217>:	mov    WORD PTR [eax+0x8],0x64
   0x08048971 <+223>:	sub    esp,0xc
   0x08048974 <+226>:	lea    eax,[ebp-0x2aa]
   0x0804897a <+232>:	push   eax
   0x0804897b <+233>:	call   0x80484d0 <puts@plt>
   0x08048980 <+238>:	add    esp,0x10
   0x08048983 <+241>:	mov    eax,ds:0x804b060
   0x08048988 <+246>:	sub    esp,0x4
   0x0804898b <+249>:	push   eax
   0x0804898c <+250>:	push   0x14
   0x0804898e <+252>:	lea    eax,[ebp-0x2be]
   0x08048994 <+258>:	push   eax
   0x08048995 <+259>:	call   0x80484a0 <fgets@plt>
   0x0804899a <+264>:	add    esp,0x10
   0x0804899d <+267>:	sub    esp,0x8
   0x080489a0 <+270>:	lea    eax,[ebp-0x2aa]
   0x080489a6 <+276>:	push   eax
   0x080489a7 <+277>:	lea    eax,[ebp-0x2d2]
   0x080489ad <+283>:	push   eax
   0x080489ae <+284>:	call   0x80484c0 <strcat@plt>
   0x080489b3 <+289>:	add    esp,0x10
   0x080489b6 <+292>:	sub    esp,0xc
   0x080489b9 <+295>:	lea    eax,[ebp-0x2d2]
   0x080489bf <+301>:	push   eax
   0x080489c0 <+302>:	call   0x80484f0 <strlen@plt>
   0x080489c5 <+307>:	add    esp,0x10
   0x080489c8 <+310>:	mov    DWORD PTR [ebp-0x314],eax
   0x080489ce <+316>:	sub    esp,0xc
   0x080489d1 <+319>:	lea    eax,[ebp-0x2be]
   0x080489d7 <+325>:	push   eax
   0x080489d8 <+326>:	call   0x8048530 <atof@plt>
   0x080489dd <+331>:	add    esp,0x10
   0x080489e0 <+334>:	fnstcw WORD PTR [ebp-0x32e]
   0x080489e6 <+340>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x080489ed <+347>:	mov    ah,0xc
   0x080489ef <+349>:	mov    WORD PTR [ebp-0x330],ax
   0x080489f6 <+356>:	fldcw  WORD PTR [ebp-0x330]
   0x080489fc <+362>:	fistp  DWORD PTR [ebp-0x310]
   0x08048a02 <+368>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048a08 <+374>:	mov    eax,DWORD PTR [ebp-0x314]
   0x08048a0e <+380>:	cmp    eax,DWORD PTR [ebp-0x310]
   0x08048a14 <+386>:	jne    0x8048b41 <main+687>
   0x08048a1a <+392>:	mov    eax,ds:0x804b060
   0x08048a1f <+397>:	sub    esp,0x4
   0x08048a22 <+400>:	push   eax
   0x08048a23 <+401>:	push   0x14
   0x08048a25 <+403>:	lea    eax,[ebp-0x296]
   0x08048a2b <+409>:	push   eax
   0x08048a2c <+410>:	call   0x80484a0 <fgets@plt>
   0x08048a31 <+415>:	add    esp,0x10
   0x08048a34 <+418>:	sub    esp,0xc
   0x08048a37 <+421>:	lea    eax,[ebp-0x296]
   0x08048a3d <+427>:	push   eax
   0x08048a3e <+428>:	call   0x8048530 <atof@plt>
   0x08048a43 <+433>:	add    esp,0x10
   0x08048a46 <+436>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048a4c <+442>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048a53 <+449>:	mov    ah,0xc
   0x08048a55 <+451>:	mov    WORD PTR [ebp-0x330],ax
   0x08048a5c <+458>:	fldcw  WORD PTR [ebp-0x330]
   0x08048a62 <+464>:	fistp  DWORD PTR [ebp-0x30c]
   0x08048a68 <+470>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048a6e <+476>:	sar    DWORD PTR [ebp-0x30c],0x2
   0x08048a75 <+483>:	shl    DWORD PTR [ebp-0x30c],0x4
   0x08048a7c <+490>:	sar    DWORD PTR [ebp-0x30c],1
   0x08048a82 <+496>:	shl    DWORD PTR [ebp-0x30c],0x4
   0x08048a89 <+503>:	sar    DWORD PTR [ebp-0x30c],0x4
   0x08048a90 <+510>:	shl    DWORD PTR [ebp-0x30c],0x9
   0x08048a97 <+517>:	sar    DWORD PTR [ebp-0x30c],0x5
   0x08048a9e <+524>:	shl    DWORD PTR [ebp-0x30c],0x4
   0x08048aa5 <+531>:	sar    DWORD PTR [ebp-0x30c],0x3
   0x08048aac <+538>:	shl    DWORD PTR [ebp-0x30c],0x2
   0x08048ab3 <+545>:	mov    eax,ds:0x804b060
   0x08048ab8 <+550>:	sub    esp,0x4
   0x08048abb <+553>:	push   eax
   0x08048abc <+554>:	push   0x14
   0x08048abe <+556>:	lea    eax,[ebp-0x264]
   0x08048ac4 <+562>:	push   eax
   0x08048ac5 <+563>:	call   0x80484a0 <fgets@plt>
   0x08048aca <+568>:	add    esp,0x10
   0x08048acd <+571>:	sub    esp,0xc
   0x08048ad0 <+574>:	lea    eax,[ebp-0x264]
   0x08048ad6 <+580>:	push   eax
   0x08048ad7 <+581>:	call   0x8048530 <atof@plt>
   0x08048adc <+586>:	add    esp,0x10
   0x08048adf <+589>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048ae5 <+595>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048aec <+602>:	mov    ah,0xc
   0x08048aee <+604>:	mov    WORD PTR [ebp-0x330],ax
   0x08048af5 <+611>:	fldcw  WORD PTR [ebp-0x330]
   0x08048afb <+617>:	fistp  DWORD PTR [ebp-0x308]
   0x08048b01 <+623>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048b07 <+629>:	mov    eax,DWORD PTR [ebp-0x30c]
   0x08048b0d <+635>:	cmp    eax,DWORD PTR [ebp-0x308]
   0x08048b13 <+641>:	jne    0x8048b41 <main+687>
   0x08048b15 <+643>:	sub    esp,0x8
   0x08048b18 <+646>:	push   0x8049130
   0x08048b1d <+651>:	push   0x80492ab
   0x08048b22 <+656>:	call   0x8048520 <fopen@plt>
   0x08048b27 <+661>:	add    esp,0x10
   0x08048b2a <+664>:	mov    DWORD PTR [ebp-0x304],eax
   0x08048b30 <+670>:	sub    esp,0xc
   0x08048b33 <+673>:	push   DWORD PTR [ebp-0x304]
   0x08048b39 <+679>:	call   0x8048787 <pathfinding>
   0x08048b3e <+684>:	add    esp,0x10
   0x08048b41 <+687>:	sub    esp,0x4
   0x08048b44 <+690>:	push   0x4
   0x08048b46 <+692>:	push   0x80492ad
   0x08048b4b <+697>:	lea    eax,[ebp-0x200]
   0x08048b51 <+703>:	push   eax
   0x08048b52 <+704>:	call   0x8048540 <strncmp@plt>
   0x08048b57 <+709>:	add    esp,0x10
   0x08048b5a <+712>:	test   eax,eax
   0x08048b5c <+714>:	jne    0x8048d6d <main+1243>
   0x08048b62 <+720>:	sub    esp,0xc
   0x08048b65 <+723>:	push   0x80492b4
   0x08048b6a <+728>:	call   0x80484d0 <puts@plt>
   0x08048b6f <+733>:	add    esp,0x10
   0x08048b72 <+736>:	mov    eax,ds:0x804b060
   0x08048b77 <+741>:	sub    esp,0x4
   0x08048b7a <+744>:	push   eax
   0x08048b7b <+745>:	push   0x14
   0x08048b7d <+747>:	lea    eax,[ebp-0x2be]
   0x08048b83 <+753>:	push   eax
   0x08048b84 <+754>:	call   0x80484a0 <fgets@plt>
   0x08048b89 <+759>:	add    esp,0x10
   0x08048b8c <+762>:	mov    eax,ds:0x804b060
   0x08048b91 <+767>:	sub    esp,0x4
   0x08048b94 <+770>:	push   eax
   0x08048b95 <+771>:	push   0x14
   0x08048b97 <+773>:	lea    eax,[ebp-0x2aa]
   0x08048b9d <+779>:	push   eax
   0x08048b9e <+780>:	call   0x80484a0 <fgets@plt>
   0x08048ba3 <+785>:	add    esp,0x10
   0x08048ba6 <+788>:	mov    eax,ds:0x804b060
   0x08048bab <+793>:	sub    esp,0x4
   0x08048bae <+796>:	push   eax
   0x08048baf <+797>:	push   0x14
   0x08048bb1 <+799>:	lea    eax,[ebp-0x296]
   0x08048bb7 <+805>:	push   eax
   0x08048bb8 <+806>:	call   0x80484a0 <fgets@plt>
   0x08048bbd <+811>:	add    esp,0x10
   0x08048bc0 <+814>:	sub    esp,0xc
   0x08048bc3 <+817>:	lea    eax,[ebp-0x296]
   0x08048bc9 <+823>:	push   eax
   0x08048bca <+824>:	call   0x8048530 <atof@plt>
   0x08048bcf <+829>:	add    esp,0x10
   0x08048bd2 <+832>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048bd8 <+838>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048bdf <+845>:	mov    ah,0xc
   0x08048be1 <+847>:	mov    WORD PTR [ebp-0x330],ax
   0x08048be8 <+854>:	fldcw  WORD PTR [ebp-0x330]
   0x08048bee <+860>:	fistp  DWORD PTR [ebp-0x300]
   0x08048bf4 <+866>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048bfa <+872>:	mov    DWORD PTR [ebp-0x2fc],0xdead
   0x08048c04 <+882>:	mov    eax,DWORD PTR [ebp-0x300]
   0x08048c0a <+888>:	xor    eax,DWORD PTR [ebp-0x2fc]
   0x08048c10 <+894>:	mov    DWORD PTR [ebp-0x2f8],eax
   0x08048c16 <+900>:	cmp    DWORD PTR [ebp-0x2f8],0x32
   0x08048c1d <+907>:	jne    0x8048d6d <main+1243>
   0x08048c23 <+913>:	mov    DWORD PTR [ebp-0x2f4],0x0
   0x08048c2d <+923>:	mov    DWORD PTR [ebp-0x2f0],0xffffffff
   0x08048c37 <+933>:	mov    eax,DWORD PTR [ebp-0x2fc]
   0x08048c3d <+939>:	or     eax,DWORD PTR [ebp-0x300]
   0x08048c43 <+945>:	mov    DWORD PTR [ebp-0x2f0],eax
   0x08048c49 <+951>:	mov    eax,DWORD PTR [ebp-0x2f4]
   0x08048c4f <+957>:	or     DWORD PTR [ebp-0x300],eax
   0x08048c55 <+963>:	mov    eax,DWORD PTR [ebp-0x2f0]
   0x08048c5b <+969>:	or     eax,DWORD PTR [ebp-0x2fc]
   0x08048c61 <+975>:	mov    DWORD PTR [ebp-0x2ec],eax
   0x08048c67 <+981>:	mov    eax,DWORD PTR [ebp-0x2ec]
   0x08048c6d <+987>:	or     eax,DWORD PTR [ebp-0x300]
   0x08048c73 <+993>:	mov    DWORD PTR [ebp-0x2f4],eax
   0x08048c79 <+999>:	mov    eax,DWORD PTR [ebp-0x2f0]
   0x08048c7f <+1005>:	or     eax,DWORD PTR [ebp-0x2f4]
   0x08048c85 <+1011>:	mov    DWORD PTR [ebp-0x2fc],eax
   0x08048c8b <+1017>:	mov    eax,DWORD PTR [ebp-0x2f0]
   0x08048c91 <+1023>:	and    eax,DWORD PTR [ebp-0x2f4]
   0x08048c97 <+1029>:	mov    DWORD PTR [ebp-0x300],eax
   0x08048c9d <+1035>:	mov    eax,DWORD PTR [ebp-0x300]
   0x08048ca3 <+1041>:	and    eax,DWORD PTR [ebp-0x2ec]
   0x08048ca9 <+1047>:	mov    DWORD PTR [ebp-0x2fc],eax
   0x08048caf <+1053>:	mov    eax,DWORD PTR [ebp-0x2fc]
   0x08048cb5 <+1059>:	xor    eax,DWORD PTR [ebp-0x2f0]
   0x08048cbb <+1065>:	mov    DWORD PTR [ebp-0x2f4],eax
   0x08048cc1 <+1071>:	mov    eax,DWORD PTR [ebp-0x300]
   0x08048cc7 <+1077>:	xor    eax,DWORD PTR [ebp-0x2f4]
   0x08048ccd <+1083>:	mov    DWORD PTR [ebp-0x2f0],eax
   0x08048cd3 <+1089>:	mov    eax,DWORD PTR [ebp-0x2f4]
   0x08048cd9 <+1095>:	xor    DWORD PTR [ebp-0x2ec],eax
   0x08048cdf <+1101>:	mov    eax,ds:0x804b060
   0x08048ce4 <+1106>:	sub    esp,0x4
   0x08048ce7 <+1109>:	push   eax
   0x08048ce8 <+1110>:	push   0x14
   0x08048cea <+1112>:	lea    eax,[ebp-0x264]
   0x08048cf0 <+1118>:	push   eax
   0x08048cf1 <+1119>:	call   0x80484a0 <fgets@plt>
   0x08048cf6 <+1124>:	add    esp,0x10
   0x08048cf9 <+1127>:	sub    esp,0xc
   0x08048cfc <+1130>:	lea    eax,[ebp-0x264]
   0x08048d02 <+1136>:	push   eax
   0x08048d03 <+1137>:	call   0x8048530 <atof@plt>
   0x08048d08 <+1142>:	add    esp,0x10
   0x08048d0b <+1145>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048d11 <+1151>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048d18 <+1158>:	mov    ah,0xc
   0x08048d1a <+1160>:	mov    WORD PTR [ebp-0x330],ax
   0x08048d21 <+1167>:	fldcw  WORD PTR [ebp-0x330]
   0x08048d27 <+1173>:	fistp  DWORD PTR [ebp-0x2e8]
   0x08048d2d <+1179>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048d33 <+1185>:	mov    eax,DWORD PTR [ebp-0x2ec]
   0x08048d39 <+1191>:	cmp    eax,DWORD PTR [ebp-0x2e8]
   0x08048d3f <+1197>:	jne    0x8048d6d <main+1243>
   0x08048d41 <+1199>:	sub    esp,0x8
   0x08048d44 <+1202>:	push   0x8049130
   0x08048d49 <+1207>:	push   0x80492da
   0x08048d4e <+1212>:	call   0x8048520 <fopen@plt>
   0x08048d53 <+1217>:	add    esp,0x10
   0x08048d56 <+1220>:	mov    DWORD PTR [ebp-0x304],eax
   0x08048d5c <+1226>:	sub    esp,0xc
   0x08048d5f <+1229>:	push   DWORD PTR [ebp-0x304]
   0x08048d65 <+1235>:	call   0x8048787 <pathfinding>
   0x08048d6a <+1240>:	add    esp,0x10
   0x08048d6d <+1243>:	sub    esp,0x4
   0x08048d70 <+1246>:	push   0x4
   0x08048d72 <+1248>:	push   0x80492dc
   0x08048d77 <+1253>:	lea    eax,[ebp-0x200]
   0x08048d7d <+1259>:	push   eax
   0x08048d7e <+1260>:	call   0x8048540 <strncmp@plt>
   0x08048d83 <+1265>:	add    esp,0x10
   0x08048d86 <+1268>:	test   eax,eax
   0x08048d88 <+1270>:	jne    0x8048f3a <main+1704>
   0x08048d8e <+1276>:	sub    esp,0xc
   0x08048d91 <+1279>:	push   0x80492e4
   0x08048d96 <+1284>:	call   0x80484d0 <puts@plt>
   0x08048d9b <+1289>:	add    esp,0x10
   0x08048d9e <+1292>:	mov    DWORD PTR [ebp-0x320],0x1
   0x08048da8 <+1302>:	jmp    0x8048dc0 <main+1326>
   0x08048daa <+1304>:	shl    DWORD PTR [ebp-0x320],1
   0x08048db0 <+1310>:	sub    esp,0xc
   0x08048db3 <+1313>:	push   0x804930c
   0x08048db8 <+1318>:	call   0x80484d0 <puts@plt>
   0x08048dbd <+1323>:	add    esp,0x10
   0x08048dc0 <+1326>:	cmp    DWORD PTR [ebp-0x320],0x31
   0x08048dc7 <+1333>:	jle    0x8048daa <main+1304>
   0x08048dc9 <+1335>:	mov    DWORD PTR [ebp-0x2e4],0x0
   0x08048dd3 <+1345>:	mov    eax,ds:0x804b060
   0x08048dd8 <+1350>:	sub    esp,0x4
   0x08048ddb <+1353>:	push   eax
   0x08048ddc <+1354>:	push   0x64
   0x08048dde <+1356>:	lea    eax,[ebp-0x264]
   0x08048de4 <+1362>:	push   eax
   0x08048de5 <+1363>:	call   0x80484a0 <fgets@plt>
   0x08048dea <+1368>:	add    esp,0x10
   0x08048ded <+1371>:	sub    esp,0xc
   0x08048df0 <+1374>:	lea    eax,[ebp-0x264]
   0x08048df6 <+1380>:	push   eax
   0x08048df7 <+1381>:	call   0x8048530 <atof@plt>
   0x08048dfc <+1386>:	add    esp,0x10
   0x08048dff <+1389>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048e05 <+1395>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048e0c <+1402>:	mov    ah,0xc
   0x08048e0e <+1404>:	mov    WORD PTR [ebp-0x330],ax
   0x08048e15 <+1411>:	fldcw  WORD PTR [ebp-0x330]
   0x08048e1b <+1417>:	fistp  DWORD PTR [ebp-0x2e4]
   0x08048e21 <+1423>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048e27 <+1429>:	mov    eax,DWORD PTR [ebp-0x2e4]
   0x08048e2d <+1435>:	cmp    eax,DWORD PTR [ebp-0x320]
   0x08048e33 <+1441>:	jne    0x8048f3a <main+1704>
   0x08048e39 <+1447>:	mov    DWORD PTR [ebp-0x31c],0x2
   0x08048e43 <+1457>:	mov    DWORD PTR [ebp-0x320],0x0
   0x08048e4d <+1467>:	jmp    0x8048ea3 <main+1553>
   0x08048e4f <+1469>:	shl    DWORD PTR [ebp-0x31c],1
   0x08048e55 <+1475>:	add    DWORD PTR [ebp-0x31c],0xf5
   0x08048e5f <+1485>:	mov    eax,DWORD PTR [ebp-0x31c]
   0x08048e65 <+1491>:	imul   eax,eax,0x6f9
   0x08048e6b <+1497>:	mov    DWORD PTR [ebp-0x31c],eax
   0x08048e71 <+1503>:	mov    ecx,DWORD PTR [ebp-0x31c]
   0x08048e77 <+1509>:	mov    edx,0x1bd71c0f
   0x08048e7c <+1514>:	mov    eax,ecx
   0x08048e7e <+1516>:	imul   edx
   0x08048e80 <+1518>:	sar    edx,0x8
   0x08048e83 <+1521>:	mov    eax,ecx
   0x08048e85 <+1523>:	sar    eax,0x1f
   0x08048e88 <+1526>:	sub    edx,eax
   0x08048e8a <+1528>:	mov    eax,edx
   0x08048e8c <+1530>:	imul   eax,eax,0x932
   0x08048e92 <+1536>:	sub    ecx,eax
   0x08048e94 <+1538>:	mov    eax,ecx
   0x08048e96 <+1540>:	mov    DWORD PTR [ebp-0x318],eax
   0x08048e9c <+1546>:	add    DWORD PTR [ebp-0x320],0x1
   0x08048ea3 <+1553>:	cmp    DWORD PTR [ebp-0x320],0x13
   0x08048eaa <+1560>:	jle    0x8048e4f <main+1469>
   0x08048eac <+1562>:	mov    eax,ds:0x804b060
   0x08048eb1 <+1567>:	sub    esp,0x4
   0x08048eb4 <+1570>:	push   eax
   0x08048eb5 <+1571>:	push   0x32
   0x08048eb7 <+1573>:	lea    eax,[ebp-0x296]
   0x08048ebd <+1579>:	push   eax
   0x08048ebe <+1580>:	call   0x80484a0 <fgets@plt>
   0x08048ec3 <+1585>:	add    esp,0x10
   0x08048ec6 <+1588>:	sub    esp,0xc
   0x08048ec9 <+1591>:	lea    eax,[ebp-0x296]
   0x08048ecf <+1597>:	push   eax
   0x08048ed0 <+1598>:	call   0x8048530 <atof@plt>
   0x08048ed5 <+1603>:	add    esp,0x10
   0x08048ed8 <+1606>:	fnstcw WORD PTR [ebp-0x32e]
   0x08048ede <+1612>:	movzx  eax,WORD PTR [ebp-0x32e]
   0x08048ee5 <+1619>:	mov    ah,0xc
   0x08048ee7 <+1621>:	mov    WORD PTR [ebp-0x330],ax
   0x08048eee <+1628>:	fldcw  WORD PTR [ebp-0x330]
   0x08048ef4 <+1634>:	fistp  DWORD PTR [ebp-0x31c]
   0x08048efa <+1640>:	fldcw  WORD PTR [ebp-0x32e]
   0x08048f00 <+1646>:	mov    eax,DWORD PTR [ebp-0x31c]
   0x08048f06 <+1652>:	cmp    eax,DWORD PTR [ebp-0x318]
   0x08048f0c <+1658>:	jne    0x8048f3a <main+1704>
   0x08048f0e <+1660>:	sub    esp,0x8
   0x08048f11 <+1663>:	push   0x8049130
   0x08048f16 <+1668>:	push   0x8049334
   0x08048f1b <+1673>:	call   0x8048520 <fopen@plt>
   0x08048f20 <+1678>:	add    esp,0x10
   0x08048f23 <+1681>:	mov    DWORD PTR [ebp-0x304],eax
   0x08048f29 <+1687>:	sub    esp,0xc
   0x08048f2c <+1690>:	push   DWORD PTR [ebp-0x304]
   0x08048f32 <+1696>:	call   0x8048787 <pathfinding>
   0x08048f37 <+1701>:	add    esp,0x10
   0x08048f3a <+1704>:	sub    esp,0x4
   0x08048f3d <+1707>:	push   0x5
   0x08048f3f <+1709>:	push   0x8049336
   0x08048f44 <+1714>:	lea    eax,[ebp-0x200]
   0x08048f4a <+1720>:	push   eax
   0x08048f4b <+1721>:	call   0x8048540 <strncmp@plt>
   0x08048f50 <+1726>:	add    esp,0x10
   0x08048f53 <+1729>:	test   eax,eax
   0x08048f55 <+1731>:	jne    0x804908e <main+2044>
   0x08048f5b <+1737>:	sub    esp,0xc
   0x08048f5e <+1740>:	push   0x804933c
   0x08048f63 <+1745>:	call   0x80484d0 <puts@plt>
   0x08048f68 <+1750>:	add    esp,0x10
   0x08048f6b <+1753>:	mov    eax,ds:0x804b060
   0x08048f70 <+1758>:	sub    esp,0x4
   0x08048f73 <+1761>:	push   eax
   0x08048f74 <+1762>:	push   0x5
   0x08048f76 <+1764>:	lea    eax,[ebp-0x296]
   0x08048f7c <+1770>:	push   eax
   0x08048f7d <+1771>:	call   0x80484a0 <fgets@plt>
   0x08048f82 <+1776>:	add    esp,0x10
   0x08048f85 <+1779>:	sub    esp,0xc
   0x08048f88 <+1782>:	lea    eax,[ebp-0x296]
   0x08048f8e <+1788>:	push   eax
   0x08048f8f <+1789>:	call   0x8048530 <atof@plt>
   0x08048f94 <+1794>:	add    esp,0x10
   0x08048f97 <+1797>:	fstp   DWORD PTR [ebp-0x2e0]
   0x08048f9d <+1803>:	fld    DWORD PTR [ebp-0x2e0]
   0x08048fa3 <+1809>:	fld    QWORD PTR ds:0x80493d0
   0x08048fa9 <+1815>:	fucomip st,st(1)
   0x08048fab <+1817>:	fstp   st(0)
   0x08048fad <+1819>:	jbe    0x8048fc9 <main+1847>
   0x08048faf <+1821>:	sub    esp,0xc
   0x08048fb2 <+1824>:	push   0x8049364
   0x08048fb7 <+1829>:	call   0x80484d0 <puts@plt>
   0x08048fbc <+1834>:	add    esp,0x10
   0x08048fbf <+1837>:	sub    esp,0xc
   0x08048fc2 <+1840>:	push   0x0
   0x08048fc4 <+1842>:	call   0x80484e0 <exit@plt>
   0x08048fc9 <+1847>:	fld    DWORD PTR [ebp-0x2e0]
   0x08048fcf <+1853>:	fld    QWORD PTR ds:0x80493d0
   0x08048fd5 <+1859>:	fxch   st(1)
   0x08048fd7 <+1861>:	fucomip st,st(1)
   0x08048fd9 <+1863>:	fstp   st(0)
   0x08048fdb <+1865>:	jbe    0x8048ff7 <main+1893>
   0x08048fdd <+1867>:	sub    esp,0xc
   0x08048fe0 <+1870>:	push   0x804936d
   0x08048fe5 <+1875>:	call   0x80484d0 <puts@plt>
   0x08048fea <+1880>:	add    esp,0x10
   0x08048fed <+1883>:	sub    esp,0xc
   0x08048ff0 <+1886>:	push   0x0
   0x08048ff2 <+1888>:	call   0x80484e0 <exit@plt>
   0x08048ff7 <+1893>:	sub    esp,0xc
   0x08048ffa <+1896>:	push   0x8049378
   0x08048fff <+1901>:	call   0x80484d0 <puts@plt>
   0x08049004 <+1906>:	add    esp,0x10
   0x08049007 <+1909>:	call   0x80487f2 <djb2hash>
   0x0804900c <+1914>:	mov    DWORD PTR [ebp-0x2dc],eax
   0x08049012 <+1920>:	mov    eax,ds:0x804b060
   0x08049017 <+1925>:	sub    esp,0x4
   0x0804901a <+1928>:	push   eax
   0x0804901b <+1929>:	push   0xa
   0x0804901d <+1931>:	lea    eax,[ebp-0x264]
   0x08049023 <+1937>:	push   eax
   0x08049024 <+1938>:	call   0x80484a0 <fgets@plt>
   0x08049029 <+1943>:	add    esp,0x10
   0x0804902c <+1946>:	sub    esp,0xc
   0x0804902f <+1949>:	lea    eax,[ebp-0x264]
   0x08049035 <+1955>:	push   eax
   0x08049036 <+1956>:	call   0x8048510 <atol@plt>
   0x0804903b <+1961>:	add    esp,0x10
   0x0804903e <+1964>:	mov    DWORD PTR [ebp-0x2d8],eax
   0x08049044 <+1970>:	mov    eax,DWORD PTR [ebp-0x2dc]
   0x0804904a <+1976>:	cmp    eax,DWORD PTR [ebp-0x2d8]
   0x08049050 <+1982>:	jne    0x804908e <main+2044>
   0x08049052 <+1984>:	sub    esp,0xc
   0x08049055 <+1987>:	push   0x80493c3
   0x0804905a <+1992>:	call   0x80484d0 <puts@plt>
   0x0804905f <+1997>:	add    esp,0x10
   0x08049062 <+2000>:	sub    esp,0x8
   0x08049065 <+2003>:	push   0x8049130
   0x0804906a <+2008>:	push   0x80493ce
   0x0804906f <+2013>:	call   0x8048520 <fopen@plt>
   0x08049074 <+2018>:	add    esp,0x10
   0x08049077 <+2021>:	mov    DWORD PTR [ebp-0x304],eax
   0x0804907d <+2027>:	sub    esp,0xc
   0x08049080 <+2030>:	push   DWORD PTR [ebp-0x304]
   0x08049086 <+2036>:	call   0x8048787 <pathfinding>
   0x0804908b <+2041>:	add    esp,0x10
   0x0804908e <+2044>:	mov    eax,0x0
   0x08049093 <+2049>:	mov    ecx,DWORD PTR [ebp-0xc]
   0x08049096 <+2052>:	xor    ecx,DWORD PTR gs:0x14
   0x0804909d <+2059>:	je     0x80490a4 <main+2066>
   0x0804909f <+2061>:	call   0x80484b0 <__stack_chk_fail@plt>
   0x080490a4 <+2066>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x080490a7 <+2069>:	leave  
   0x080490a8 <+2070>:	lea    esp,[ecx-0x4]
   0x080490ab <+2073>:	ret   
