; Exercise 3 - Find maximum 3-digit (base 10) value in Word array
; Array dw 100,6,35,250,18,1000,180  sz dw 7
; Result: Max = 250

data segment
    Array dw 100, 6, 35, 250, 18, 1000, 180
    sz    dw 7
    Max   dw 0
data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax

    mov cx, sz          ; loop counter = number of elements
    mov bx, 0           ; byte index into Array

find_max_loop:
    mov ax, Array[bx]   ; ax = current element

    ; Check if ax >= 100 (at least 3 digits)
    cmp ax, 100
    jl  skip            ; less than 100 -> skip

    ; Check if ax <= 999 (at most 3 digits)
    cmp ax, 999
    jg  skip            ; greater than 999 -> skip

    ; ax is a 3-digit number, check if > Max
    cmp ax, Max
    jle skip
    mov Max, ax         ; new maximum

skip:
    add bx, 2           ; advance to next word
    loop find_max_loop

    ; Exit DOS
    mov ah, 4ch
    mov al, 0
    int 21h

code ends
end start
