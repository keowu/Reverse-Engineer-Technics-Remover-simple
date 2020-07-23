entry start

; Credits for OPEN SOURCE <3

offset equ -start

macro struct name
{
   name@struct fix name
   struc name {
}

macro struct_helper name
{
   virtual at 0
   name name
   sizeof.#name = $ - name
   name equ sizeof.#name
   end virtual
}

ends fix } struct_helper name@struct

struct STARTUPINFO
  .cb		   dd ?
  .lpReserved	   dd ?
  .lpDesktop	   dd ?
  .lpTitle	   dd ?
  .dwX		   dd ?
  .dwY		   dd ?
  .dwXSize	   dd ?
  .dwYSize	   dd ?
  .dwXCountChars   dd ?
  .dwYCountChars   dd ?
  .dwFillAttribute dd ?
  .dwFlags	   dd ?
  .wShowWindow	   dw ?
  .cbReserved2	   dw ?
  .lpReserved2	   dd ?
  .hStdInput	   dd ?
  .hStdOutput	   dd ?
  .hStdError	   dd ?
ends

struct PROCESS_INFORMATION
  .hProcess    dd ?
  .hThread     dd ?
  .dwProcessId dd ?
  .dwThreadId  dd ?
ends

section '.text' code readable writeable executable

start:
   call @geteip
 @geteip:
   pop ebp
   sub ebp,05h
   mov esi,[esp]
   mov edi,esi
   and edi,70000000h
   test edi,edi
   jz return
   call getbase
   mov edi,eax
   mov ebx,eax
   lea eax,[ebp+lpGetProcAddress offset]
   call getprocaddr
   test eax,eax
   jz return
   mov esi,eax

   lea ebx,[ebp+lpProgID offset]
   push ebx
   lea ebx,[ebp+lpFindAtom offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; FindAtom
   test ax,ax
   jnz exit

   call getlasterror
   cmp eax,05h
   je return

   lea ebx,[ebp+lpProgID offset]
   push ebx
   lea ebx,[ebp+lpAddAtom offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; AddAtom
   test ax,ax
   jz @fatal

   mov dword ptr ebp+startinfo.cb offset,44h
   mov dword ptr ebp+startinfo.lpReserved offset,0
   mov dword ptr ebp+startinfo.lpDesktop offset,0
   mov dword ptr ebp+startinfo.lpTitle offset,0
   mov dword ptr ebp+startinfo.dwFlags offset,0
   mov dword ptr ebp+startinfo.cbReserved2 offset,0
   mov dword ptr ebp+startinfo.lpReserved2 offset,0

   lea ebx,[ebp+procinfo offset]
   push ebx
   lea ebx,[ebp+startinfo offset]
   push ebx
   push 0
   push 0
   push 0
   push 0
   push 0
   push 0
   lea ebx,[ebp+lpGetCommandLine offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; GetCommandLine
   push eax
   push 0
   lea ebx,[ebp+lpCreateProcess offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; CreateProcess
   mov ebx,[ebp+procinfo.hProcess offset]
   push ebx
   lea ebx,[ebp+lpCloseHandle offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; CloseHandle
   mov ebx,[ebp+procinfo.hThread offset]
   push ebx
   lea ebx,[ebp+lpCloseHandle offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; CloseHandle

 @fatal:
   push 0
   lea ebx,[ebp+lpFatalExit offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz @fatal2
   call eax ; FatalExit
 @fatal2:
   ret

;______END END END___________
getlasterror:
   mov eax,[fs:00000018h]
   mov eax,[eax+34h]
   ret
;______END END END___________
check:
; ->esi handle DO MÓDULO
; <-eax 0 ou 1
   xor eax,eax
   push esi
   pushf
   cmp word ptr esi,5A4Dh
   jne @cperet
   add esi,[esi+3Ch]
   cmp dword ptr esi,00004550h
   jne @cperet
   inc eax
 @cperet:
   popf
   pop esi
   ret
;______END END END___________
getbase:
; ->esi qualquer endereço de um módulo
; <-eax handle DO MÓDULO
   xor eax,eax
   push esi
   push ecx
   pushf
   and esi,0FFFF0000h
   mov ecx,6
 @npage:
   call check
   cmp eax,1
   jne @continue
   mov eax,esi
   jmp @gbret
 @continue:
   sub esi,10000h
   loop @npage
 @gbret:
   popf
   pop ecx
   pop esi
   ret
;______END END END___________
getprocaddr:
; ->eax É O NOME DA FUNÇÃO
; ->ebx handle DO MÓDULO
; <-eax FUNÇÃO DE ENDEREÇAMENTO
   pushad
   mov [ebp+ptrTempMem offset],eax
   mov esi,ebx
   add esi,[esi+3Ch]
   lea esi,[esi+18h]
   lea esi,[esi+60h]
   mov esi,[esi]
   add esi,ebx
   push esi
   mov esi,[esi+20h]
   add esi,ebx
   xor edx,edx
   mov eax,esi
   mov esi,[esi]
 @nname:
   add esi,ebx
   mov edi,[ebp+ptrTempMem offset]
   mov ecx,14
   cld
   repe cmpsb
   test ecx,ecx
   jz @gparet
   inc edx
   add eax,4
   mov esi,[eax]
   jmp @nname
 @gparet:
   pop esi
   mov edi,esi
   mov esi,[esi+24h]
   add esi,ebx
   mov dx,[edx*2+esi]
   sub edx,[edi+10h]
   inc edx
   mov esi,[edi+1Ch]
   add esi,ebx
   mov eax,[edx*4+esi]
   add eax,ebx
   mov [ebp+ptrTempMem offset],eax
   popad
   mov eax,[ebp+ptrTempMem offset]
   ret
;______END END END___________

exit:
   push eax
   lea ebx,[ebp+lpDeleteAtom offset]
   push ebx
   push edi
   call esi
   test eax,eax
   jz return
   call eax ; DeleteAtom
   jmp return

ptrTempMem dd ?

lpGetProcAddress    db 'GetProcAddress',0
lpFindAtom	    db 'GlobalFindAtomA',0
lpAddAtom	    db 'GlobalAddAtomA',0
lpDeleteAtom	    db 'GlobalDeleteAtom',0
lpCreateProcess     db 'CreateProcessA',0
lpGetCommandLine    db 'GetCommandLineA',0
lpCloseHandle	    db 'CloseHandle',0
lpFatalExit	    db 'FatalExit',0

startinfo STARTUPINFO
procinfo PROCESS_INFORMATION

lpProgID db 'PROGRAM_ID_0123456789',0

return:
   nop