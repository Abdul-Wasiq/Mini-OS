# MiniOS: 8086 Assembly System Project
**Author:** Abdul Wasiq (BS Software Engineering)  
**Environment:** EMU8086 | DOS Interrupts (INT 21h, INT 10h)

---

## 1. Project Overview
MiniOS is a modular, menu-driven environment designed to simulate basic operating system functionalities. It focuses on low-level system programming, file system interaction, and structured Assembly design.

## 2. System Architecture
The project follows a modular directory structure under `C:\emu8086\vdrive\C\MiniOS\` to ensure code maintainability:

### Directory Structure
* **\kernel**: Core logic and I/O routines.
* **\include**: Shared macros and constant definitions.
* **\disk**: Storage for simulated file system data.

### File Manifest
| File | Location | Purpose |
| :--- | :--- | :--- |
| **mini_os.asm** | \kernel | Main entry point; manages menu, calculator, and date/time logic. |
| **io.asm** | \kernel | Handles low-level input/output routines. |
| **defs.inc** | \include | Global constants and system definitions. |
| **macros.inc** | \include | Reusable Assembly macros for cleaner syntax. |

---

## 3. Core Features
* **File Management:** Create, open, read, write, and delete files; list directory contents.
* **Integrated Calculator:** Performs arithmetic with automatic result logging.
* **System Utilities:** Real-time display of system date and time.
* **UI/UX:** A structured menu interface utilizing BIOS/DOS interrupts for display.

---

## 4. Technical Objectives
* **Low-Level Mastery:** Implementing hardware-level communication via system calls.
* **Modular Programming:** Demonstrating organized code across multiple include files.
* **Resource Management:** Handling file buffers and registers efficiently within the 8086 architecture.
