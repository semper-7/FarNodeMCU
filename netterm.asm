.486
.model flat,stdcall
option casemap:none
.NOLIST
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\wsock32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock32.lib

TProc	proto:DWORD
atodw	proto:DWORD
GetArgCommandLine PROTO:DWORD,:DWORD
ReadLine PROTO:DWORD,:DWORD

.LIST
.DATA
Log	DB	"netterm.log",0
msgStrt	db	'Start terminal. Press "Ctrl+C" for exit.',13,10
msgErrs	db	"Socket operation error!",13,10
msgErrc	db	"Error in command line!",13,10
flag	db	0

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
s	dd	?
ws	WSADATA <?>
sa	sockaddr_in <?>
buf	db	1024 dup (?)
buf2	db	1024 dup (?)

.CODE
START:	invoke	GetModuleHandle,0
        mov	hInst,eax
	invoke	GetStdHandle,STD_INPUT_HANDLE
	mov	hStdIn,eax
	invoke	SetConsoleMode,eax,ENABLE_PROCESSED_INPUT or ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT
	invoke	GetStdHandle,STD_OUTPUT_HANDLE
	mov	hStdOut,eax
	invoke	GetArgCommandLine,ADDR ARG0,3
	or	eax,eax
	jnz	errcl
	mov	sa.sin_family,AF_INET
	invoke	inet_addr,ARG1
	cmp	eax,-1
	jz	errcl
	mov	[sa.sin_addr],eax
	invoke	atodw,ARG2
	xchg	al,ah
	mov	[sa.sin_port],ax
	invoke	WriteFile,hStdOut,ADDR msgStrt,SIZEOF msgStrt,ADDR SZRW,0
	invoke	WSAStartup,0101h,ADDR ws
	invoke	socket,PF_INET,SOCK_STREAM,0
	mov	s,eax
	invoke	connect,s,ADDR sa,sizeof sa
	cmp	eax,-1
	jz	errso
	invoke	CreateThread,0,0,OFFSET TProc,0,NORMAL_PRIORITY_CLASS,ADDR TID
	invoke	CloseHandle,eax
        invoke	CreateFile,ADDR Log,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
	mov	hLog,eax
lll0:	invoke	recv,s,ADDR buf,1024,0
	cmp	eax,-1
	jz	exit
	cmp	eax,0
	jz	exit
	mov	flag,0
	push	eax
	invoke	WriteFile,hStdOut,ADDR buf,eax,ADDR SZRW,0
	pop	eax
	invoke	WriteFile,hLog,ADDR buf,eax,ADDR SZRW,0
	jmp	lll0
exit:	invoke	closesocket,s
	invoke	ExitProcess,0
errso:	invoke	closesocket,s
	invoke	WriteFile,hStdOut,ADDR msgErrs,SIZEOF msgErrs,ADDR SZRW,0
	invoke	ExitProcess,1
errcl:	invoke	WriteFile,hStdOut,ADDR msgErrc,SIZEOF msgErrc,ADDR SZRW,0
	invoke	ExitProcess,1

TProc	PROC	param:DWORD
	invoke	Sleep,1000
llt0:	cmp	flag,0
	jnz	llt1
	invoke	ReadFile,hStdIn,ADDR buf2,1024,ADDR SZRW2,0
	cmp	SZRW2,0
	jz	llt0
	mov	flag,1
	invoke	send,s,ADDR buf2,SZRW2,0
llt1:	invoke	Sleep,100
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

atodw	proc USES ESI sour:DWORD
	mov	esi,sour
	xor	ecx,ecx
	xor	eax,eax
ato0:	lodsb
	cmp	al,'0'
	jc	ato1
	and	al,0fh
	lea	ecx,dword ptr [ecx+4*ecx]
	lea	ecx,dword ptr [eax+2*ecx]
	jmp	ato0
ato1:	mov	eax,ecx
	ret
atodw	endp

END START
