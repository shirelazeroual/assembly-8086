; Exercise 4 - Run-Length Encoding (RLE) decoding
; Input:  str1 = pairs of (letter, count digit), e.g. s1 c4 e4 b2 s2
; Output: str2 = expanded string, e.g. scccceeeebbss (size2 = 13)
; The result is printed with commas between characters

data segment
    str1  db 's','1','c','4','e','4','b','2','s','2'
    size1 dw 10
    str2  db 100 dup(?)     ; output buffer (large enough)
    size2 dw 0
    comma db ','
    crlf  db 13,10,'$'
data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax

    ; --- Decode RLE: str1 pairs (char, digit) -> expanded str2 ---
    mov cx, size1       ; total chars in str1 (must be even)
    shr cx, 1           ; number of pairs = size1 / 2
    mov si, 0           ; index into str1
    mov di, 0           ; index into str2
    mov word ptr size2, 0

decode_loop:
    mov al, str1[si]    ; al = character
    inc si
    mov bl, str1[si]    ; bl = digit character ('1'..'9')
    inc si
    sub bl, '0'         ; bl = count (numeric)
    mov bh, 0

    ; Write 'bl' copies of 'al' into str2
expand_char:
    mov str2[di], al
    inc di
    inc word ptr size2
    dec bl
    jnz expand_char

    loop decode_loop    ; next pair

    ; --- Print str2 with commas between characters ---
    mov cx, size2
    mov si, 0

print_loop:
    ; Print character str2[si]
    mov dl, str2[si]
    mov ah, 02h
    int 21h

    inc si
    dec cx
    jz  print_done

    ; Print comma separator
    mov dl, ','
    mov ah, 02h
    int 21h

    jmp print_loop

print_done:
    ; Print newline
    lea dx, crlf
    mov ah, 09h
    int 21h

    ; Exit
    mov ah, 4ch
    mov al, 0
    int 21h

code ends
end start
