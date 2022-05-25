# This file is a part of Venture Below, a game for the SNES.
# Copyright (C) 2022 Nicholas Lovdahl

# Venture Below is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.

# Venture Below is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# Venture Below. If not, see <https://www.gnu.org/licenses/>.

# Paths and files needed for compilation and stuff
New-Variable -Option Constant -Name ProjectPath -Value (Split-Path -Parent $MyInvocation.MyCommand.Definition)
New-Variable -Option Constant -Name SourcePath -Value "$ProjectPath\src"
New-Variable -Option Constant -Name DataPath -Value "$ProjectPath\data"
New-Variable -Option Constant -Name MemoryMap -Value "$SourcePath\_memory_map.cfg"
New-Variable -Option Constant -Name ObjectPath -Value "$ProjectPath\build\obj"
New-Variable -Option Constant -Name BinariesPath -Value "$ProjectPath\build\bin"
New-Variable -Option Constant -Name RomName -Value "Venture Below.smc"
New-Variable -Option Constant -Name Rom -Value "$BinariesPath\$RomName"

New-Variable -Option Constant -Name ToolPath -Value "$ProjectPath\tools"
New-Variable -Option Constant -Name Compiler -Value "$ToolPath\ca65.exe"
New-Variable -Option Constant -Name Linker -Value "$ToolPath\ld65.exe"

# Keywords
New-Variable -Option Constant -Name HelpKeyword -Value "help"
New-Variable -Option Constant -Name RebuildKeyword -Value "rebuild"
New-Variable -Option Constant -Name BuildKeyword -Value "build"
New-Variable -Option Constant -Name CleanKeyword -Value "clean"

# Functions
<#
.SYNOPSIS
    Returns whether the tools needed for compilation are available.
.DESCRIPTION
    Returns whether the tools needed for compilation are available.
#>
function Check-Tools {
    [OutputType([Boolean])]
    Param ()

    $FoundCompiler = Test-Path $Compiler
    $FoundLinker = Test-Path $Linker
    $HasTools = ($FoundCompiler -and $FoundLinker)

    if (-not $HasTools) {
        Write-Host "Some required tools could not be found."
        if (-not $FoundCompiler) {
            Write-Host ("Could not find compiler. Expected to find {0}" -f $Compiler)
        }
        if (-not $FoundLinker) {
            Write-Host ("Could not find linker. Expected to find {0}" -f $Linker)
        }
    }

    return $HasTools
}

<#
.SYNOPSIS
    Writes usage info for this script.
.DESCRIPTION
    Writes usage info for this script.
#>
function Rom-Help {
    [OutputType([Void])]
    Param ()

    Write-Host "Usage Instructions:"
    Write-Host (".\{0} [argument]" -f (Split-Path -Leaf $MyInvocation.ScriptName))
    Write-Host ("Argument Options: (defaults to '{0}')" -f $BuildKeyword)
    Write-Host ("`t{0} - Shows usage instructions." -f $HelpKeyword)
    Write-Host ("`t{0} - Cleans and builds from scratch." -f $RebuildKeyword)
    Write-Host ("`t{0} - Builds from source, recompiled only as needed." -f $BuildKeyword)
    Write-Host ("`t{0} - Removes any output from building." -f $CleanKeyword)
}

<#
.SYNOPSIS
    Cleans all output from a build, if any.
.DESCRIPTION
    Cleans all output from a build, if any. Returns whether the clean was
    successful.
#>
function Rom-Clean {
    [OutputType([Boolean])]
    Param ()

    $NumFiles = 0
    $NumErrors = 0
    $NumCleaned = 0

    # Clean out entire bin directory if other stuff was added by an emulator / debugger
    foreach ($File in ((Get-ChildItem "$ObjectPath\*.o") + (Get-ChildItem "$BinariesPath\*"))) {
        $NumFiles += 1
        Remove-Item -LiteralPath $File -ErrorVariable CleanErrors

        if ($CleanErrors.Count -gt $NumErrors) {
            $NumErrors = $CleanErrors.Count
            Write-Host ("Failed to clean {0}" -f (Split-Path -Leaf $File))
        } else {
            $NumCleaned += 1
            Write-Host ("Cleaned {0}" -f (Split-Path -Leaf $File))
        }
    }

    Write-Host "--------------------------------"
    Write-Host ("Number of files: {0}" -f $NumFiles)
    Write-Host ("Number of files cleaned: {0}" -f $NumCleaned)
    Write-Host "--------------------------------`n"

    return (-not $NumErrors)
}

<#
.SYNOPSIS
    Builds the ROM.
.DESCRIPTION
    Builds the ROM as needed, incorporating any changes. Things should only be
    compiled if necessary. Returns whether the build was successful.
#>
function Rom-Build {
    [OutputType([Boolean])]
    Param ()

    $NumFiles = 0
    $NumSkipped = 0
    $NumFileErrors = 0
    $NumErrors = 0
    $NumBuilt = 0

    # Create the build directories if they don't already exist
    if (-not (Test-Path $ObjectPath)) { New-Item -ItemType directory -Path $ObjectPath }
    if (-not (Test-Path $BinariesPath)) { New-Item -ItemType directory -Path $BinariesPath }

    # Compilation
    foreach ($SourceFile in ((Get-ChildItem "$SourcePath\*.s") + (Get-ChildItem "$DataPath\*.s"))) {
        $NumFiles += 1

        # Trim the source file extension and tack on the object file extension
        $ObjectFile = ("$ObjectPath\{0}o" -f (Split-Path -Leaf $SourceFile).ToString().TrimEnd("s"))
        # If we don't already have a corresponding object file newer than the source file...
        if (-not (Test-Path -LiteralPath $ObjectFile -NewerThan (Get-Item $SourceFile | Get-Date))) {
            Write-Host ("Compiling {0} into {1}" -f (Split-Path -Leaf $SourceFile), (Split-Path -Leaf $ObjectFile))
            $NumFileErrors = 0

            # Capture compiler output and redirect stderr (2) to stdout (1)
            $ExpressionOutput = (Invoke-Expression -Command "$Compiler --cpu 65816 -s -o `"$ObjectFile`" `"$SourceFile`"") 2>&1
            foreach ($ExpressionOutputLine in $ExpressionOutput) {
                Write-Host "`t$ExpressionOutputLine"
                if ($ExpressionOutputLine.ToString().Contains(" Error: ")) { $NumFileErrors += 1 }
            }

            if ($NumFileErrors) {
                $NumErrors += $NumFileErrors
            } else {
                $NumBuilt += 1
            }
        } else {
            $NumSkipped += 1
        }
    }

    # Linking
    if ((-not $NumErrors) -and ($NumBuilt -or (-not (Test-Path $Rom)))) {
        $NumFileErrors = 0
        
        # Append quotes to each object file when listing
        $ObjectFiles = (Get-ChildItem "$ObjectPath\*.o" | foreach { "`"$_`""})

        # Capture compiler output and redirect stderr (2) to stdout (1)
        $ExpressionOutput = (Invoke-Expression -Command "$Linker -C `"$MemoryMap`" -o `"$Rom`" $ObjectFiles") 2>&1
        foreach ($ExpressionOutputLine in $ExpressionOutput) {
            Write-Host "`t$ExpressionOutputLine"
            if ($ExpressionOutputLine.ToString().Contains(" Error: ")) { $NumFileErrors += 1 }
        }

        $NumErrors += $NumFileErrors
    }

    Write-Host "--------------------------------"
    Write-Host ("Number of files: {0}" -f $NumFiles)
    Write-Host ("Number of files skipped: {0}" -f $NumSkipped)
    Write-Host ("Number of files built: {0}" -f $NumBuilt)
    Write-Host "--------------------------------`n"

    return (-not $NumErrors)
}

# Check out what we need to do based on arguments (if any)
if ($args.Count -le 0) { $Keyword = $BuildKeyword }
else { $Keyword = $args[0] }
# Matches shouldn't be case-sensitive by default
switch ($Keyword) {
    $HelpKeyword {
        Rom-Help
        break
    }
    $RebuildKeyword {
        $Successful = Check-Tools
        if ($Successful) { $Successful = Rom-Clean }
        if ($Successful) { $Successful = Rom-Build }

        if (-not $Successful) { Write-Host "Rebuild failed." }
        break
    }
    $BuildKeyword {
        $Successful = Check-Tools
        if ($Successful) { $Successful = Rom-Build }

        if (-not $Successful) { Write-Host "Build failed." }
        break
    }
    $CleanKeyword {
        $Successful = Rom-Clean

        if (-not $Successful) { Write-Host "Clean failed." }
        break
    }
    default {
        Write-Host ("Unrecognized argument: {0}" -f $Keyword)
        Rom-Help
    }
}
