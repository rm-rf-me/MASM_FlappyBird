include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include gdi32.inc
include comdlg32.inc
include	masm32.inc 

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib gdi32.lib
includelib comdlg32.lib
includelib masm32.lib
includelib msvcrt.lib

printf PROTO C :ptr sbyte, :VARARG	
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
ResetBuff PROTO :DWORD
DeBuff PROTO
DeBuff2 PROTO :dword
BoardProc PROTO hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM 
BoardProc2 PROTO hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
InitParam PROTO
EndGame PROTO
SetupDie PROTO
SetupFly PROTO
SaveFile PROTO
ReadModelFile PROTO
TimerProc PROTO hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

IDB_BG              equ 100
IDB_TUBE            equ 101
IDB_BIRD			equ 102
IDB_BIRD2			equ 104
IDB_BIRD3			equ 105
IDB_BIRD4		    equ 106
IDB_BAR             equ 103

IDD_DIALOG			equ 1000
IDC_BOARD           equ 1001
IDC_BOARD2          equ 1002

IDM_MENU			equ 10000
IDM_FILE_EXIT		equ 10001
IDM_OPEN            equ 10002
IDM_SAVE            equ 10003
IDM_MODE            equ 10004

MTIMER				equ 25  ;系统时钟

OBJECT	struct
	x		dd ?
	y		dd ?
OBJECT ends

.const

ClassName			db 'DLGCLASS',0
AppName				db 'Flappy Bird',0
AboutMsg			db 'Flppy Bird',13,10,'Copyright ? ljc 2021',0
ExitAsk             db 'Are you sure ?',0
startStr            db 'HIT X TO START', 0
startStr2			db 'HIT SPACE TO START', 0
fmtStr				db '%lu',0
lastFmtStr          db 'Last: %lu', 0
maxFmtStr           db 'Max: %lu', 0
totFmtStr			db 'Tot: %lu', 0
lifeStr				db 'Life: %lu', 0
speedStr			db 'Speed: %lu', 0
nowStr 				db 'Now: %lu', 0
alpha_QL            REAL8 0.7
MapSize             dd 60*30*2*(sizeof REAL8)
szFile		        db	'fbai.model', 0

winStr db 'You Win!',0ah,0
lostStr db 'You Lost!',0ah,0

.data?

couthelp byte '请输入两�?整数�?',0ah,0
hInstance			dd ?
CommandLine			dd ?
hWnd				dd ?

hBoard				dd ?
hBoard2				dd ?
OldBoardProc		dd ?
OldBoardProc2		dd ?

bgIml				dd ?
birdIml             dd ?
birdIml2            dd ?
birdIml3            dd ?
birdIml4            dd ?
tubeIml             dd ?
barIml              dd ?

gStatus             dd 0 ; 0-die 1-flying

speed               dd ?
speed2              dd ?

cPoint              dd 0 ; current point
lPoint              dd 0 ; last point
maxPoint            dd 0 ; max point
totPoint			dd 0 

cPoint2             dd 0 ; current point
lPoint2             dd 0 ; last point
maxPoint2           dd 0 ; max point
totPoint2			dd 0 

rseed				dd ?

; Tube:
; switch when the first disappear
;维护两根管子
upTube              OBJECT 4 dup(<>)
downTube            OBJECT 4 dup(<>)

upTube2             OBJECT 4 dup(<>)
downTube2           OBJECT 4 dup(<>)

; Bottom (Ground)
bottomY             dd 384
bottomX             dd 0

bottomY2             dd 384
bottomX2             dd 0

; Bird: 
; in every loop, birdAc = min(birdAc + gravityAc, birdMaxAc);
; birdY = min(max(birdAC + birdAC, 0), birdBottom)
; If hit the buttom, birdAc = jumpAc

; 鸟位�?信息
birdX               dd ?
birdY               dd ?
birdX2              dd ?	; new
birdY2              dd ?	 

; 鸟生命�?
birdLife			sdword ?
birdLife2			sdword ?
prebirdLife			sdword ?
prebirdLife2		sdword ?

NormSpeed			dd 4
NormAravityAc		dd 1
NormJumpAc			dd -7
	
birdAc              dd 0
birdAc2             dd 0	; new
birdMaxAc           dd 8
birdBottom          dd 361
gravityAc           dd 2
gravityAc2           dd 2
jumpAc              dd -14
jumpAc2              dd -14

cflap               dd 1	; 鸟切�?
cflapDir            dd 0

addedFlag           dd 0	; 柱子更新
addedFlag2          dd 0	; 柱子更新

vDistRangeL         dd ?
vDistRangeR         dd ?
hDistRangeL         dd ?
hDistRangeR         dd ?

stateDashV          dd ? 	; range [0, 529], real distance + 174; 53
stateDashH          dd ? 	; range [0, 180]; 19
stateV              dd ?
stateH              dd ?

reward              dd 0
actionToPerform     dd 0

isAuto              dd 0 ; open auto mode?

QMap                REAL8 60*30*2 dup(<>) ; 53 in V, 18 in H, 2 in action; 0 = do_nothing, 1 = jump

debug               dd 0

whodie				dd 0 ;0 init 1:1 die 2:2 die

stOpenFileName      OPENFILENAME <?>

indebuf dd 0
indebuf2 dd 0

isFirst dd 1

whowin dd 0