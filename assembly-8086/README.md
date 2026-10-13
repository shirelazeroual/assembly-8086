# 8086 Assembly

Final project and exercises in 8086 assembly (MASM/TASM syntax, DOS), written for the Computer Architecture & Assembly course of my B.Sc. in Computer Science at SCE (Sami Shamoon College of Engineering).

## Final project: `final_project.asm`

A menu-driven program that keeps returning to the menu until the user chooses Exit:

```
Please choose one of the following options:
1. Prime number checker
2. Caesars shift coder
3. Exit
```

- **Prime number checker:** reads a number N (2 < N < 255) digit by digit until `.`, converts it from ASCII to a value, and checks whether it is prime by trial division. A prime prints a right-angle triangle of `@` with side N; a non-prime prints an N × N square of `*`.
- **Caesar shift coder:** reads a lowercase string until `.` and a shift digit (2-9), then encrypts the string with a Caesar cipher, wrapping around from `z` to `a` and keeping spaces.

Techniques used: separate data and code segments, procedures (`proc` / `call` / `ret`), passing a variable by address in `SI`, `MUL` / `DIV`, string processing with `SI` / `DI` pointers, and DOS interrupts (`INT 21h`) for keyboard input and screen output.

## Exercises

| File | What it does |
|---|---|
| [`exercises/max_three_digit.asm`](exercises/max_three_digit.asm) | Finds the largest 3-digit value in a word array |
| [`exercises/rle_decode.asm`](exercises/rle_decode.asm) | Decodes a run-length-encoded string (`s1c4e4` → `scccceeee`) and prints it with commas |

## How to run

Use an 8086 environment such as **emu8086**, or **DOSBox** with MASM or TASM:

```
masm final_project.asm;
link final_project.obj;
final_project
```

## Author

Shirel Azeroual · Computer Science student, SCE
