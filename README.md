# Venture-Below
Venture Below is a game for the SNES.

## Installation
If you want to compile Venture Below yourself from source, it can be built using the [CC65 compiler and linker](https://cc65.github.io/). For Windows, you can get the CC65 Windows snapshot and move the compiler and linker (`ca65.exe` and `ld65.exe`, respectively) to a tools directory - the tools directory should exist in the project directory (where this README is) and should be named `tools`.

Once the compiler and linker are available in the tools directory, a ROM can be built using `win-make.ps1` in PowerShell. The following commands arguments can be given to `win-make.ps1`:
* Use `.\win-make.ps1 help` for instructions to use `win-make.ps1`.
* Use `.\win-make.ps1 clean` to clean the output from a previous build. Every file in the binaries and object directories will be removed, so don't move any files in here that you wouldn't want to lose.
* Use `.\win-make.ps1 build` to build the ROM file. If no option is provided to `win-make.ps1`, this will be the default action.
* Use `.\win-make.ps1 rebuild` to clean the output from a previous build and build the ROM again from scratch.

Note that `win-make.ps1` decides which files need to be recompiled when building by checking to see if a source file has a later timestamp than its corresponding object file. If this is not the case, if for example a previous version of a source file was restored, `win-make.ps1` will not recompile even if the source file has changes. In such cases, the project should be cleaned and rebuilt.

## Licensing
Venture Below is licensed under the GNU General Public License - either version 3 or, at your discretion, any later version. You can read `LICENSE` or visit https://www.gnu.org/licenses/gpl-3.0.html for the full license text.
