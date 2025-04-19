RISC-V-Terminal-Emulator

This is just a simple project to understand system calls in RISC-V
This mini project implements a **basic terminal emulator using RISC-V assembly language**, built to run on a Linux system via RISC-V emulation. The terminal supports a small set of commands:
- `help` – Displays a list of available commands
- `sysinfo` – Shows system information (CPU and memory)
- `exit` – Exits the terminal

It also handles invalid inputs gracefully, printing an appropriate error message.

Technologies used
RISC-V Assembly Language
QEMU – For running RISC-V binaries
Linux System Calls(`ecall`)
Filesystem interaction: `/proc/cpuinfo`, `/proc/meminfo`

In the above code, The strcmp function is used to compare input strings with command strings.
The read_file function reads contents from /proc/cpuinfo and /proc/meminfo to display CPU and memory details using the sysinfo command.
The help command lists available commands, while exit terminates the program.
Helper functions like itoa convert integers to strings for output formatting.
ecall: General instruction to invoke system services. The type of service is defined by a7 (system call number).
Read (a7=63): Reads user input or file data.
Write (a7=64): Outputs strings or system data to the terminal.
Open (a7=56): Opens a file for reading.
Close (a7=57): Closes an opened file.
Exit (a7=93): Terminates the program.
uname (a7=160): Fetches system information for the sysinfo command.

Prerequisites
Make sure you have the following installed:

- `riscv64-linux-gnu-gcc` (RISC-V toolchain)
- `qemu-riscv64` (RISC-V emulator)
- A Linux system (or WSL on Windows)

To Assemble and Run:
1. Assemble the code:
   riscv64-linux-gnu-gcc -nostdlib -o terminal terminal.s
2. Run the code:
   qemu-riscv64 ./terminal
