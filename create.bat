@echo off
set include=D:\masm32\include
set lib=D:\masm32\lib
ml /c /coff AsmFlappyBird2.Asm
rc AsmFlappyBird.Rc
link /subsystem:windows AsmFlappyBird2.obj AsmFlappyBird.RES

.\AsmFlappyBird2.exe 
echo on