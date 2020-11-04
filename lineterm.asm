.486
.model flat,stdcall
option casemap:none
.NOLIST
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
TProc	proto:DWORD
GetArgCommandLine	PROTO:DWORD,:DWORD
strcopy	PROTO:DWORD,:DWORD

.LIST
.DATA
baud	DB	": baud=",0
par	DB	" parity=N data=8 stop=1 dtr=on rts=on TO=ON",0
Log	DB	"lineterm.log",0
DCB1	DCB	<>
TO	COMMTIMEOUTS	<-1,0,0,0,0>
msgStrt	db	'Start terminal. Press "Ctrl+C" for exit.',13,10
msgErr	db	"COM port operation error!",13,10
flag	db	0
len	db	0

.DATA?
hInst	dd	?
hStdIn	dd	?   
hStdOut	dd	?   
ARG0	dd	?
ARG1	dd	?
ARG2	dd	?
hCOM	dd	?
hLog	dd	?
SZRW	dd	?
SZRW2	dd	?
TID	dd	?
buf2	db	8 dup (?)
buf	db	1024 dup (?)

.CODE
START:	invoke	GetModuleHandle,0
        mov	hInst,eax
	invoke	GetStdHandle,STD_INPUT_HANDLE
	mov	hStdIn,eax
	invoke	GetStdHandle,STD_OUTPUT_HANDLE
	mov	hStdOut,eax
	invoke	GetArgCommandLine,ADDR ARG0,3
	or	eax,eax
	jnz	error
	mov	eax,ARG1
	mov	eax,[eax]
	mov	dword ptr [buf],eax
	and	eax,00dfdfdfh
	cmp	eax,004d4f43h
	jnz	error
	invoke	CreateFile,ADDR buf,GENERIC_READ or GENERIC_WRITE,0,0,OPEN_EXISTING,0,0
	cmp	eax,INVALID_HANDLE_VALUE
	jz	error
	mov	hCOM,eax
	invoke	WriteFile,hStdOut,ADDR msgStrt,SIZEOF msgStrt,ADDR SZRW,0
	invoke	SetCommTimeouts,hCOM,ADDR TO
	invoke	strcopy,ADDR buf + 4, ADDR baud
	invoke	strcopy,eax, ARG2
	invoke	strcopy,eax, ADDR par
	invoke	BuildCommDCB,ADDR buf,ADDR DCB1
	invoke	SetCommState,hCOM,ADDR DCB1
	invoke	CreateThread,0,0,OFFSET TProc,0,NORMAL_PRIORITY_CLASS,ADDR TID
	invoke	CloseHandle,eax
        invoke	CreateFile,ADDR Log,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
	mov	hLog,eax
lll0:	invoke	ReadFile,hCOM,ADDR buf,1,ADDR SZRW,0
	cmp	SZRW,0
	jz	lll0
	cmp	buf,1bh
	jnz	lll1
	inc	len
	cmp	len,4
	jc	lll0
exit:	invoke	ExitProcess,0
lll1:	cmp	buf,0ah
	jnz	lll2
	mov	flag,0
lll2:	mov	len,0
	invoke	WriteFile,hStdOut,ADDR buf,1,ADDR SZRW,0
	invoke	WriteFile,hLog,ADDR buf,1,ADDR SZRW,0
	jmp	lll0
error:	invoke	WriteFile,hStdOut,ADDR msgErr,SIZEOF msgErr,ADDR SZRW,0
	invoke	ExitProcess,1

TProc	PROC	param:DWORD
	invoke	SetConsoleMode,hStdIn,ENABLE_PROCESSED_INPUT
llt0:	cmp	flag,0
	jnz	llt2
	invoke	ReadFile,hStdIn,ADDR buf2,1,ADDR SZRW2,0
	cmp	SZRW2,0
	jz	llt0
	cmp	buf2,0ah
	jnz	llt1
	mov	flag,1
llt1:	invoke	WriteFile,hCOM,ADDR buf2,1,ADDR SZRW2,0
llt2:	invoke	Sleep,0
	jmp	llt0
TProc	ENDP

GetArgCommandLine proc uses edi arg0:DWORD, narg:DWORD
	invoke	GetCommandLine
	mov	edi,arg0
ll0:	stosd
	dec	narg
	jz	ll3
ll1:	inc	eax
	cmp	byte ptr [eax],0
	jz	ll3
	cmp	byte ptr [eax],20h
	jnz	ll1
ll2:	inc	eax
	cmp	byte ptr [eax],20h
	jz	ll2
	cmp	byte ptr [eax],0
	jnz	ll0
ll3:	mov	eax,narg
	ret
GetArgCommandLine endp

strcopy	proc uses esi edi dest:DWORD, sour:DWORD
	mov	esi,sour
	mov	edi,dest
sc0:	lodsb
	or	al,al
	jz	sc1
	stosb
	jmp	sc0	
sc1:	mov	eax,edi
	ret
strcopy	endp

END START

