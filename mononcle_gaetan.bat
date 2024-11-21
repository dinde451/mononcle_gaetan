@echo off
setlocal enabledelayedexpansion

rem Load pinned folders from pinned_folders.txt
set "pinned_1="
set "pinned_2="
set "pinned_3="
if exist pinned_folders.txt (
    for /f "tokens=1,* delims=:" %%A in (pinned_folders.txt) do (
        if "%%A"=="P1" set "pinned_1=%%B"
        if "%%A"=="P2" set "pinned_2=%%B"
        if "%%A"=="P3" set "pinned_3=%%B"
    )
)

rem Set the starting directory to C:\
cd C:\

rem Clipboard variables
set "clipboard="
set "clipboard_type="

:main
cls
echo ========================================
echo            MONONCLE GAETAN          
echo ========================================
echo Current Directory: %cd%
echo.
echo Files and Folders:
set count=0

rem List files and folders
for /f "delims=" %%A in ('dir /b') do (
    set /a count+=1
    echo !count!: %%A
    set item[!count!]=%%A
)
echo.
echo Pinned Folders:
if defined pinned_1 echo [P1] !pinned_1!
if defined pinned_2 echo [P2] !pinned_2!
if defined pinned_3 echo [P3] !pinned_3!
echo.
echo Options:
echo [N] Navigate Up
echo [C] Copy File/Folder
echo [P] Paste File/Folder
echo [R] Rename File/Folder
echo [D] Delete File/Folder
echo [T] Pin Current Folder
echo [Q] Quit
echo ========================================
set /p choice="mononcle_gaetan>"

rem Check if input is a number for navigation
for /l %%I in (1,1,%count%) do (
    if "!choice!"=="%%I" (
        set selected=!item[%%I]!
        if exist "!selected!\*" (
            cd "!selected!"
            goto main
        ) else (
            start "" "%cd%\!selected!"
            pause
            goto main
        )
    )
)

rem Handle pinned folder navigation
if /i "!choice!"=="P1" if defined pinned_1 cd "!pinned_1!" && goto main
if /i "!choice!"=="P2" if defined pinned_2 cd "!pinned_2!" && goto main
if /i "!choice!"=="P3" if defined pinned_3 cd "!pinned_3!" && goto main

rem Handle other options
if /i "!choice!"=="N" goto nav_up
if /i "!choice!"=="C" goto copy
if /i "!choice!"=="P" goto paste
if /i "!choice!"=="R" goto rename
if /i "!choice!"=="D" goto delete
if /i "!choice!"=="T" goto pin_folder
if /i "!choice!"=="Q" exit /b

:nav_up
cd ..
goto main

:copy
cls
echo ========================================
echo          Copy File or Folder            
echo ========================================
set /p copy_choice="Enter the number of the item to copy: "
set selected=!item[%copy_choice%]!
if not defined selected goto invalid
set "clipboard=%cd%\!selected!"
if exist "%clipboard%\*" (
    set "clipboard_type=folder"
) else (
    set "clipboard_type=file"
)
echo Copied !clipboard_type!: %clipboard%
pause
goto main

:paste
if not defined clipboard (
    echo Nothing to paste. Copy something first.
    pause
    goto main
)
if "%clipboard_type%"=="folder" (
    xcopy /e /i "%clipboard%" "%cd%\"
) else (
    copy "%clipboard%" "%cd%\"
)
echo Pasted !clipboard_type!: %clipboard%
pause
goto main

:rename
cls
echo ========================================
echo        Rename File or Folder            
echo ========================================
set /p rename_choice="Enter the number of the item to rename: "
set selected=!item[%rename_choice%]!
if not defined selected goto invalid
set /p new_name="Enter new name: "
rename "%cd%\!selected!" "!new_name!"
echo Renamed to: !new_name!
pause
goto main

:delete
cls
echo ========================================
echo        Delete File or Folder            
echo ========================================
set /p delete_choice="Enter the number of the item to delete: "
set selected=!item[%delete_choice%]!
if not defined selected (
    echo Invalid choice. Please try again.
    pause
    goto main
)
if exist "!selected!\*" (
    echo This is a folder.
    rmdir /s /q "!selected!"
) else (
    echo This is a file.
    del /q "!selected!"
)
if not errorlevel 1 (
    echo Deleted: !selected!
) else (
    echo Failed to delete: !selected! Ensure it exists or is not in use.
)
pause
goto main

:pin_folder
cls
echo ========================================
echo           Pin Current Folder            
echo ========================================
echo Current pinned folders:
echo [1] Slot 1: !pinned_1!
echo [2] Slot 2: !pinned_2!
echo [3] Slot 3: !pinned_3!
echo.
set /p pin_choice="Select a slot to pin the current folder (1-3): "
if "%pin_choice%"=="1" set "pinned_1=%cd%"
if "%pin_choice%"=="2" set "pinned_2=%cd%"
if "%pin_choice%"=="3" set "pinned_3=%cd%"
if not "%pin_choice%"=="1" if not "%pin_choice%"=="2" if not "%pin_choice%"=="3" (
    echo Invalid choice. Returning to main menu.
    pause
    goto main
)

rem Save pinned folders to pinned_folders.txt
(
    echo P1:%pinned_1%
    echo P2:%pinned_2%
    echo P3:%pinned_3%
) > pinned_folders.txt

echo Pinned folder saved to slot %pin_choice%.
pause
goto main

:invalid
echo Invalid choice. Please try again.
pause
goto main
