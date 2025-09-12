# Catch-Em
A lightweight, interactive process monitor and management tool for linux machines, written in C.

Features:
- Lists processes (PID, command, state, VSZ, RSS, CPU%)
- Interactive TUI (ncurses) with navigation
- Send signals: kill (k), stop (s), continue (c)
- Auto-refresh (1s)

### Project structure

catchem/
#### ├─ CMakeLists.txt
#### ├─ .gitignore
#### ├─ README.md
#### ├─ include/
#### │  ├─ proc_utils.h
#### │  ├─ signals.h
#### │  └─ ui.h
#### └─ src/
####  │  ├─ main.c
####  │  ├─ proc_utils.c
####  │  ├─ signals.c
####  │  └─ ui.c



### Build & run (WSL Ubuntu)
---
1. Install dependencies:
```   
sudo apt update
sudo apt install -y build-essential cmake libncurses5-dev libncursesw5-dev

```
2. build
```  
mkdir build && cd build
cmake ..
make
```
3. Run:
```  
./catchem
```

### Visual Studio 2022 (CMake + WSL)
- Open the project folder (File -> Open -> Folder...) containing CMakelists.txt.
- Ensure Visusl Studio has **Linux development** workload installed.
- Choose your WSL target (Ubuntu)when building / debugging.

### Controls 
 ##### Arrow Up / Down ==== navigate
 ##### k           ==== SIGKILL
 ##### s           ==== SIGSTOP
 ##### c           ==== SIGCONT
 ##### q           ==== quit


This is intentionally lightweight and modular so you can extend it, for example you can;
- Add sorting options, filters
- Add process detail view (open files, threads)
- Export to JSON/CSV
- Add color/highlight for high CPU/memory processes.

Built with even more extended features is built for windows Os and in c++, you can check that out
[here](https://github.com/iCode1t/catchEm-win.git)



---

### How to test quickly (on WSL Ubuntu)

1. Open **Ubuntu (WSL)** terminal in the project root.  
2. Install packages (if not already):
```  
sudo apt update
sudo apt install -y build-essential cmake libncurses5-dev libncursesw5-dev
```
3. Create build dir and build:

```  
mkdir -p build
cd build
cmake ..
make -j
```
4. Run:
```
./catchem
```


Navigate with arrow keys; hightlight a process and press **k** (kill) or **s**/**c**. Quit with **q**.

---

### Note;  
- if you're testing with the test script, change the file permission (it's advisable to test killing or stopping a process feature with the test script so you won't interfere with important system process. )
- CPU% is computed as a delta jiffies per interval (since last call) divided by total delta jiffies, it's then displayed as percent of whole machine CPU. On multi-core sysytems, this will show relative usage across all cores (0-100%).    
