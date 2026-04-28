# calc plugin

A lightweight inline calculator for Micro editor.

---

## Features

- Selection-based evaluation
- Line evaluation fallback
- Inline result insertion (`= result`)
- Persistent `ans` variable
- Basic math + functions

---

## Usage

Select an expression or place cursor on a line:


2 + 2


Run:

calc


Result:

2 + 2 = 4


---

## Operators

- `+` addition
- `-` subtraction
- `*` multiplication
- `/` division
- `^` exponent

Example:

2^3 = 8


---

## Functions

- `sqrt(x)`
- `abs(x)`
- `floor(x)`
- `ceil(x)`
- `sin(x)`
- `cos(x)`
- `tan(x)`
- `asin(x)`
- `acos(x)`
- `atan(x)`
- `pow(x, y)`

---

## Constants

- `pi`
- `e`

---

## Last result (`ans`)

The result of the last successful calculation is stored in `ans`.

Example:


2 + 2

ans * 3


Result:

ans * 3 = 12


---

## Behaviour

- If expression has ` = result`, it is updated instead of duplicated
- Errors are shown in the info bar
- Invalid expressions are not written to the buffer

---

## Notes

- Scientific notation with non-integer exponent is rejected (e.g. `2e3.1`)
- Only safe arithmetic expressions are allowed