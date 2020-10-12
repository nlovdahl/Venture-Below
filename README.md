# Venture-Below
Venture Below is a game for the SNES.

## Installation
Currently, Venture Below only has a build system prepared for Windows. Venture Below can be built using the [CC65 compiler and linker](https://cc65.github.io/). For Windows, you can get the CC65 Windows snapshot and move the compiler and linker (`ca65.exe` and `ld65.exe`, respectively) to a tools directory - the tools directory should exist in the project directory (where this Readme is) and should be named `tools`.

Once the compiler and linker for have been moved, a ROM can be built using `win-make.cmd`. The following commands can be used by `win-make.cmd`:
* Use `win-make.cmd help` for instructions to use `win-make.cmd`.
* Use `win-make.cmd clean` to clean the output from a previous build. Every file in the binaries and object directories will be removed, so don't move any files in here that you wouldn't want to lose.
* Use `win-make.cmd make` to build a ROM file. If no option is provided to `win-make.cmd`, this will be the default action.

## Licensing
Venture Below is licensed under the GNU General Public License - either version 3 or, at your discretion, any later version. You can read `LICENSE` or visit https://www.gnu.org/licenses/gpl-3.0.html for the full license text.
