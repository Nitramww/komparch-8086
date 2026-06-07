# Computer architecture

University coursework. Three x86 assembly programs written for DOS.

## Programs

### 1. Decimal to Binary converter (`pirmas.asm`)

Reads a decimal number (0–65535) from user input, validates that it is a valid decimal, and prints it in binary using repeated division by 2.

**Usage:**
```
pirmas
Iveskite desimtaini numeri (0 - 65535): 42
Ivestas skaicius dvejetaine forma: 101010
```

---

### 2. Number-to-words converter (`antra.asm`)

Reads a text file and writes a new file where every digit (0–9) is replaced with its Lithuanian word equivalent (e.g. `3` -> `trys`, `7` -> `septyni`). Non-digit characters are passed through unchanged.

**Usage:**
```
antra duomenufailas.txt rezultatufailas.txt
```

Uses buffered file I/O via DOS interrupt `21h` calls directly.

---

### 3. MUL instruction tracer (`trec.asm`)

Installs a step-mode (trap flag) interrupt handler (`INT 1`) that intercepts every instruction executed. When a `MUL` instruction is detected, it decodes the operand encoding (mod/rm byte, addressing mode, displacement) in real time and prints the instruction details along with current register values.

Decodes all `MUL` addressing modes:
- Register (`mul cl`, `mul dx`)
- Memory with no displacement (`mul byte ptr [bx+si]`)
- Memory with 8-bit displacement (`mul byte ptr [bx+si+32h]`)
- Memory with 16-bit displacement (`mul word ptr [bx+si+3242h]`)
- Direct memory (`mul byte ptr ds:[1234h]`)

**Usage:**
```
trec
```

Runs a predefined sequence of `MUL` instructions and prints a trace of each one.

---

## Notes

- All programs use `.MODEL small` and DOS `INT 21h` system calls directly
- Tested under DOSBox
- Written as part of university "computer architecture" coursework
