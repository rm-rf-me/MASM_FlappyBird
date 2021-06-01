@echo off
set include=E:\masm32\include
set lib=E:\masm32\lib
ml /c /coff AsmFlappyBird2.Asm
rc AsmFlappyBird.Rc
link /subsystem:windows AsmFlappyBird2.obj AsmFlappyBird.RES

.\AsmFlappyBird2.exe 
echo on