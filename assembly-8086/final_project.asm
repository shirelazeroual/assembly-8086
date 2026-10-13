data segment
        ; -------------------------------------------------------
        ; Messages
        ; -------------------------------------------------------
        MenuMsg db 'Please choose one of the following options:',13,10
                db '1. Prime number checker',13,10
                db '2. Caesars shift coder',13,10
                db '3. Exit',13,10
                db 'Choose option: $'

        EnterNMsg db 13,10
                  db 'Enter a positive integer number N (255>N>2): $'

        BadInputMsg db 13,10
                    db 'Invalid input. Please enter a number where 255>N>2.',13,10,'$'

        EnterStringMsg db 13,10
                       db 'Type a string (only small characters in English): $'

        EnterDigitMsg db 13,10
                      db 'Enter one decimal digit (between 2 to 9): $'

        String2Msg  db 13,10,'The shifted string is: $'
        PrimeMsg    db 13,10,'prime',13,10,'$'
        NotPrimeMsg db 13,10,'not prime',13,10,'$'

        ; -------------------------------------------------------
        ; Variables
        ; -------------------------------------------------------
        number     dw ?
        row        dw ?
        offset_val db ?

        String1 db 255 dup(?)
        String2 db 255 dup(?)
data ends

; -------------------------------------------------------

code segment
assume cs:code, ds:data

start:
        ; Initialize DS to point to the data segment
        mov ax, data
        mov ds, ax

MainMenu:
        ; Print newline before menu
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h

        ; Display main menu
        mov dx, offset MenuMsg
        mov ah, 9
        int 21h

        ; Read user choice
        mov ah, 1
        int 21h

        cmp al, '1'
        je PrimePart

        cmp al, '2'
        je CaesarPart

        cmp al, '3'
        je ExitProgram

        ; Return to menu for any other key
        jmp MainMenu

; -------------------------------------------------------
; Option 1: Prime number checker
; -------------------------------------------------------
PrimePart:
        ; Ask the user to enter a number
        mov dx, offset EnterNMsg
        mov ah, 9
        int 21h

        ; Clear BX before building the number
        mov bx, 0

GetNumber:
        ; Read one character from keyboard
        mov ah, 1
        int 21h

        ; Stop reading when '.' is entered
        cmp al, '.'
        je EndNumber

        ; Save the new digit in DL temporarily
        sub al, '0'
        mov dl, al

        ; Multiply accumulated value by 10: AX = BX * 10
        mov ax, bx
        mov cx, 10
        mul cx                  ; AX = AX * CX (BX is not touched)

        ; Add the new digit to the result
        mov bh, 0
        mov bl, dl
        add ax, bx

        ; Update BX with the new accumulated value
        mov bx, ax

        jmp GetNumber

EndNumber:
        ; Validate range: number must satisfy 255 > N > 2
        cmp bx, 2
        jle BadInput            ; N <= 2 is invalid

        cmp bx, 255
        jge BadInput            ; N >= 255 is invalid

        ; Save the valid number in memory
        mov number, bx

        ; Pass address of number to the Check procedure
        mov si, offset number
        call Check

        jmp MainMenu

BadInput:
        ; Notify user of invalid input
        mov dx, offset BadInputMsg
        mov ah, 9
        int 21h

        jmp MainMenu

; -------------------------------------------------------
; Option 2: Caesar shift coder
; -------------------------------------------------------
CaesarPart:
        ; Ask the user to enter a string
        mov dx, offset EnterStringMsg
        mov ah, 9
        int 21h

        ; Read String1 from user input
        call GetString

        ; Ask the user to enter the shift amount
        mov dx, offset EnterDigitMsg
        mov ah, 9
        int 21h

        ; Read shift digit and convert from ASCII to numeric value
        mov ah, 1
        int 21h
        sub al, '0'
        mov offset_val, al

        ; Encode String1 into String2 using Caesar shift
        call CodeString

        ; Print the encoded string
        mov dx, offset String2Msg
        mov ah, 9
        int 21h

        mov dx, offset String2
        mov ah, 9
        int 21h

        jmp MainMenu

; -------------------------------------------------------
; Option 3: Exit
; -------------------------------------------------------
ExitProgram:
        mov ax, 4c00h
        int 21h

; -------------------------------------------------------
; Procedure: GetString
; Reads characters from keyboard into String1 until '.'
; -------------------------------------------------------
GetString proc
        mov si, offset String1

GetStringLoop:
        mov ah, 1
        int 21h

        cmp al, '.'
        je FinishString

        ; Store character and advance pointer
        mov [si], al
        inc si

        jmp GetStringLoop

FinishString:
        ; Terminate string with '$' for INT 21h/AH=9 printing
        mov al, '$'
        mov [si], al
        ret
GetString endp

; -------------------------------------------------------
; Procedure: CodeString
; Encodes String1 into String2 using Caesar shift
; Spaces are preserved without shifting
; Wraps around within the a-z range
; -------------------------------------------------------
CodeString proc
        mov si, offset String1
        mov di, offset String2

CodeLoop:
        mov al, [si]

        ; Stop at end-of-string marker
        cmp al, '$'
        je FinishCode

        ; Preserve spaces without shifting
        cmp al, ' '
        je PutChar

        ; Apply Caesar shift
        mov ah, 0
        mov bl, offset_val
        mov bh, 0
        add al, bl

        ; Wrap around if character exceeds 'z'
        cmp al, 'z'
        jbe PutChar
        sub al, 26

PutChar:
        mov [di], al
        inc si
        inc di
        jmp CodeLoop

FinishCode:
        ; Terminate String2 with '$' for printing
        mov al, '$'
        mov [di], al
        ret
CodeString endp

; -------------------------------------------------------
; Procedure: PrintPrime
; Prints the "prime" message to the screen
; -------------------------------------------------------
PrintPrime proc
        mov dx, offset PrimeMsg
        mov ah, 9
        int 21h
        ret
PrintPrime endp

; -------------------------------------------------------
; Procedure: PrintNotPrime
; Prints the "not prime" message to the screen
; -------------------------------------------------------
PrintNotPrime proc
        mov dx, offset NotPrimeMsg
        mov ah, 9
        int 21h
        ret
PrintNotPrime endp

; -------------------------------------------------------
; Procedure: Check
; Receives SI = address of Number in DS
; Checks if Number is prime and prints the result
; If prime     -> calls PrintPrime    then Triangle
; If not prime -> calls PrintNotPrime then Square
; -------------------------------------------------------
Check proc
        ; Load the number from memory via SI
        mov bx, [si]

        ; Start divisor at 2
        mov cx, 2

CheckLoop:
        ; If divisor equals the number itself, it is prime
        cmp cx, bx
        je ItIsPrime

        ; Divide number by current divisor
        mov ax, bx
        xor dx, dx              ; Clear DX before division
        div cx                  ; AX = quotient, DX = remainder

        ; If remainder is zero, number is not prime
        cmp dx, 0
        je ItIsNotPrime

        ; Try next divisor
        inc cx
        jmp CheckLoop

ItIsPrime:
        call PrintPrime
        call Triangle
        ret

ItIsNotPrime:
        call PrintNotPrime
        call Square
        ret
Check endp

; -------------------------------------------------------
; Procedure: Triangle
; Draws a right-angle isosceles triangle using '@'
; Row i contains i '@' characters (i from 1 to number)
; -------------------------------------------------------
Triangle proc
        mov bx, number
        mov row, 1

TriangleRows:
        mov ax, row
        cmp ax, bx
        ja FinishTriangle

        ; Print 'row' copies of '@'
        mov cx, row

PrintAt:
        mov dl, '@'
        mov ah, 2
        int 21h
        loop PrintAt

        ; Print newline
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h

        inc row
        jmp TriangleRows

FinishTriangle:
        ret
Triangle endp

; -------------------------------------------------------
; Procedure: Square
; Draws a square of side 'number' using '*'
; Each row contains 'number' '*' characters
; -------------------------------------------------------
Square proc
        mov bx, number
        mov row, 1

SquareRows:
        mov ax, row
        cmp ax, bx
        ja FinishSquare

        ; Print 'number' copies of '*'
        mov cx, bx

PrintStar:
        mov dl, '*'
        mov ah, 2
        int 21h
        loop PrintStar

        ; Print newline
        mov dl, 13
        mov ah, 2
        int 21h
        mov dl, 10
        mov ah, 2
        int 21h

        inc row
        jmp SquareRows

FinishSquare:
        ret
Square endp

code ends
end start
