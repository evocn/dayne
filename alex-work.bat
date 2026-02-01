@echo off

pushd "%~dp0"

REM 
start wt --profile "cmd" -d . cmd /k "jai build.jai" ; new-tab --profile "Neovim" -d . nvim -p "source/main.jai" -p "source/game/game.jai"

REM Open the debugger
start remedybg bin\debug.rdbg

popd
