; CREDITS FOR OPEN SOURCE !
entry start

section '.text' code readable writeable

start:

    mov eax,[fs:$30]   ; PEB
    mov eax,[eax+$0C]  ; PEB_LDR_DATA
    mov eax,[eax+$0C]  ; Ldr.InLoadOrderModuleList.Flink
    lea ebx,[eax+$20]  ; LDR_DATA_TABLE_ENTRY.SizeOfImage
    lea ecx,[eax+$18]  ; LDR_DATA_TABLE_ENTRY.DllBase
    xor dword [ebx],$FFFFFFFF
    mov esi,[ecx]
    mov eax,[eax]      ; Flink
    mov edi,[eax+$18]
    mov dword [ecx],edi
    lea eax,[esp-$20]
    push eax
    push $04
    mov dword [esp-$24],$1000
    lea eax,[esp-$24]
    push eax
    mov dword [esp-$28],esi
    lea eax,[esp-$28]
    push eax
    push $FFFFFFFF
    push 0
    call @geteip
@geteip:
    pop ebx
    add ebx,@retaddr-@geteip
    push ebx
    mov eax,$89
    mov edx,esp
    sysenter
@retaddr:
    pop edx
    pop edx
    pop edx
    pop edx
    pop edx
    pop edx
    test eax,eax
    jl @quit
    cmp word [esi],$5A4D
    jne @quit
    mov ebx,esi
    mov esi,[esi+$3C]
    add esi,ebx
    cmp dword [esi],$00004550
    jne @quit
    mov word [esi+$04],0	  ; Tipo da CPU
    sub word [esi+$06],1	  ; Numero de Seções
    mov dword [esi+$28],esi	  ; RVA EntryPoint 
    mov dword [esi+$34],edi	  ; ImageBase
    sub dword [esi+$50],$100	  ; ImageSize
    sub dword [esi+$50],$1000	  ; HeaderSize
    mov dword [esi+$80],0	  ; RVA ImportTable
    mov dword [esi+$84],0	  ; Size ImportTable
@quit:
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    xor esi,esi
    xor edi,edi