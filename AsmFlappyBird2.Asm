.386
.model flat,stdcall
option casemap:none

include AsmFlappyBird2.inc

.code

; 1.debuff
; 2.dec debuff
; 3.change other player debuff
; 4.change bird img
; 5.totpoint 


; 窗口主程序
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG
    ;窗口属性

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
    
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd

    ;mov isFirst,1
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL	hBmp:DWORD

	mov		eax,uMsg

    ;WM_INITDIALOG消息是对话框才能收到的消息，表明对话框及其所有子控件都创建完毕了
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd

        ; check first game?
        ; no:
        ;  check lastLife
        ;  print win and loss
        ;  print score: totpoint maxpoint....
        
		; Load background image
		invoke ImageList_Create,576,500,ILC_COLOR16,1,0
		mov		bgIml,eax
		invoke LoadBitmap,hInstance,IDB_BG
		mov		hBmp,eax
		invoke ImageList_AddMasked,bgIml,hBmp,0
		invoke DeleteObject,hBmp

		; Load tube image
		invoke ImageList_Create,52,320,ILC_COLOR16 or ILC_MASK,2,2
		mov		tubeIml,eax
		invoke LoadBitmap,hInstance,IDB_TUBE
		mov		hBmp,eax
		invoke ImageList_AddMasked,tubeIml,hBmp,0
		invoke DeleteObject,hBmp

		; Load bird image
		invoke ImageList_Create,34,24,ILC_COLOR16 or ILC_MASK,3,3
		mov		birdIml,eax
		invoke LoadBitmap,hInstance,IDB_BIRD
		mov		hBmp,eax
		invoke ImageList_AddMasked,birdIml,hBmp,0
		invoke DeleteObject,hBmp

        ; Load bird2 image
		invoke ImageList_Create,34,24,ILC_COLOR16 or ILC_MASK,3,3
		mov		birdIml2,eax
		invoke LoadBitmap,hInstance,IDB_BIRD2
		mov		hBmp,eax
		invoke ImageList_AddMasked,birdIml2,hBmp,0
		invoke DeleteObject,hBmp

        ; Load bird_de image
		invoke ImageList_Create,34,24,ILC_COLOR16 or ILC_MASK,3,3
		mov		birdIml3,eax
		invoke LoadBitmap,hInstance,IDB_BIRD3
		mov		hBmp,eax
		invoke ImageList_AddMasked,birdIml3,hBmp,0
		invoke DeleteObject,hBmp

         ; Load bird_de2 image
		invoke ImageList_Create,34,24,ILC_COLOR16 or ILC_MASK,3,3
		mov		birdIml4,eax
		invoke LoadBitmap,hInstance,IDB_BIRD4
		mov		hBmp,eax
		invoke ImageList_AddMasked,birdIml4,hBmp,0
		invoke DeleteObject,hBmp

		; Load bar image
		invoke ImageList_Create,336,112,ILC_COLOR16,1,0
		mov		barIml,eax
		invoke LoadBitmap,hInstance,IDB_BAR
		mov		hBmp,eax
		invoke ImageList_AddMasked,barIml,hBmp,0
		invoke DeleteObject,hBmp


		invoke GetDlgItem,hWin,IDC_BOARD
		mov		hBoard,eax
        
		invoke GetDlgItem,hWin,IDC_BOARD2
		mov		hBoard2,eax

		invoke SetWindowLong,hBoard,GWL_WNDPROC,offset BoardProc
		mov		OldBoardProc,eax

        invoke SetWindowLong,hBoard2,GWL_WNDPROC,offset BoardProc2
		mov		OldBoardProc2,eax

		invoke InitParam
		invoke EndGame

        mov isFirst,1

        ;invoke InvalidateRect,hBoard,NULL,TRUE
        ;invoke InvalidateRect,hBoard2,NULL,TRUE

		invoke SetTimer,hWin,200,MTIMER,offset TimerProc
        ;hWnd是和timer关联的窗口句柄,nIDEvent是timer的标识,uElapse是以毫秒指定的计时间隔值,lpTimerFunc是一个回调函数的指针
        ;如果lpTimerFunc为NULL，系统将向应用程序队列发送WM_TIMER消息；
        ;如果lpTimerFunc指定了一个值，DefWindowProc将在处理WM_TIMER消息时调用这个lpTimerFunc所指向的回调函数，
        ;因此即使使用TimerProc代替处理WM_TIMER也需要向窗口分发消息。 

	.elseif eax==WM_KEYDOWN
		mov	eax,wParam
		.if eax==VK_SPACE
			.if gStatus == 0
			    mov gStatus, 1
			    invoke SetupFly
			.else
			    mov eax, jumpAc2
			    mov birdAc2, eax
			.endif

            .if isFirst == 1
                mov isFirst,0
            .endif

        ;new
        .elseif eax==VK_X
			.if gStatus == 0
			    mov gStatus, 1
			    invoke SetupFly
			.else
			    mov eax, jumpAc
			    mov birdAc, eax
			.endif

            .if isFirst == 1
                mov isFirst,0
            .endif
        ;new

		.elseif eax==VK_A
		    .if isAuto
		        mov isAuto, 0
		    .else
		        mov isAuto, 1
		    .endif
		.endif

	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_MODE
		    .if isAuto
		        mov isAuto, 0
		    .else
		        mov isAuto, 1
		    .endif
		.elseif eax==IDM_SAVE
		    invoke SaveFile
		.elseif eax==IDM_OPEN
		    invoke ReadModelFile
		.endif

	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin

	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL

	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

; paint
PaintBoard proc uses ebx esi edx,hWin:HWND,hDC:HDC
	LOCAL	mDC:HDC         ; 内存设备上下文环境的句柄
	LOCAL	hBmp:DWORD
	LOCAL	hOld:DWORD
	LOCAL	rect:RECT
	LOCAL	wRect:RECT
	LOCAL	xmax:DWORD
	LOCAL	buffer[32]:BYTE

	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,288,500
	invoke SelectObject,mDC,eax
	push	eax
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,288
	mov		rect.bottom,500

	; Draw background
	invoke ImageList_Draw, bgIml, 0, mDC, 0, 0, ILD_TRANSPARENT
    
	; Draw words
	.if gStatus == 0
	    mov		wRect.left,0
	    mov		wRect.top,210
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT
	    invoke SetTextColor,mDC,0000000h

        mov edx,prebirdLife2
        mov esi,prebirdLife
        .if esi > edx
            mov whowin,1
        .elseif edx > esi
            mov whowin,2
        .else 
            mov whowin,3
        .endif

        
        .if isFirst == 0
            .if whowin==1
                invoke wsprintfA,addr buffer,offset winStr
                invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
            .elseif whowin==2
                invoke wsprintfA,addr buffer,offset lostStr
                invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
            .endif
        .endif

        
        ; 输出上次成绩
	    ; invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

        ; ; 输出最好成绩
	    ; mov		wRect.top,235
	    ; invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

        ; 输出开始信息
	    ;mov		wRect.top,260
        sub		wRect.top,15
	    invoke wsprintfA,addr buffer,offset startStr
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

	.else
	    ; Draw tube here
	    push ebx
        
	    mov ebx, offset upTube
	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif

 	    mov ebx, offset downTube 	    
 	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
            invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
        .endif
	    pop ebx
	    ; end draw tube
        
        ; 打印当前分数
	    mov		wRect.left,0
	    mov		wRect.top,65
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT	    
	    invoke SetTextColor,mDC,0ffffffh

        ; life
        invoke wsprintfA, addr buffer, offset lifeStr, birdLife
        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER    
        ; now
        sub		wRect.top,15
	    invoke wsprintfA,addr buffer,offset nowStr,cPoint
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
        ; now
        sub		wRect.top,15
	    invoke wsprintfA,addr buffer,offset totFmtStr,totPoint
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    ; max
        sub		wRect.top,15
        invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    ; speed
        sub		wRect.top,15
        invoke wsprintfA,addr buffer,offset speedStr,speed
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    ; invoke SetTextColor,mDC,0000000h
	    ; mov		wRect.top,49
	    ; mov		wRect.right,286
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER   
	    
        ; RL的 
	    .if isAuto
	        mov		wRect.top,30
	        mov		wRect.right,288
	        invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	        mov		wRect.top,10
	        invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    .endif
	    
	.endif
	
	; Draw bird
	.if cflap < 1 && cflapDir == 3
	    mov cflapDir, 0
	.elseif cflap > 1 && cflapDir == 3
	    mov cflapDir, 1
	.elseif cflap < 1 || cflap > 1
	    mov cflapDir, 3
	.endif
	
    ; 换鸟
	.if cflapDir==0
	    inc cflap
	.elseif cflapDir==1
	    dec cflap
	.endif
	
    ; 打印鸟
	;invoke ImageList_Draw, birdIml2, cflap, mDC, birdX, birdY, ILD_TRANSPARENT

    .if indebuf ==1
        invoke ImageList_Draw, birdIml3, cflap, mDC, birdX, birdY, ILD_TRANSPARENT;new
    .elseif indebuf ==0
        invoke ImageList_Draw, birdIml, cflap, mDC, birdX, birdY, ILD_TRANSPARENT;new
    .endif
	
	; Draw bottom
	mov eax, speed
	sub bottomX, eax
	.if bottomX < -47
	    mov bottomX, 0
	.endif
	invoke ImageList_Draw, barIml, 0, mDC, bottomX, bottomY, ILD_TRANSPARENT
	
	invoke GetClientRect,hWin,addr rect
	invoke StretchBlt,hDC,0,0,rect.right,rect.bottom,mDC,0,0,288,500,SRCCOPY
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteObject,eax
	invoke DeleteDC,mDC

	ret

PaintBoard endp

PaintBoard2 proc uses ebx esi,hWin:HWND,hDC:HDC
	LOCAL	mDC:HDC         ; 内存设备上下文环境的句柄
	LOCAL	hBmp:DWORD
	LOCAL	hOld:DWORD
	LOCAL	rect:RECT
	LOCAL	wRect:RECT
	LOCAL	xmax:DWORD
	LOCAL	buffer[32]:BYTE

	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,288,500
	invoke SelectObject,mDC,eax
	push	eax
	mov		rect.left,288
	mov		rect.top,0
	mov		rect.right,288+288
	mov		rect.bottom,500

	; Draw background
	invoke ImageList_Draw, bgIml, 0, mDC, 0, 0, ILD_TRANSPARENT
    
	; Draw words
	.if gStatus == 0
	    mov		wRect.left,0
	    mov		wRect.top,210
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT
	    invoke SetTextColor,mDC,0000000h

        mov edx,prebirdLife2
        mov esi,prebirdLife
        .if esi > edx
            mov whowin,1
        .elseif edx > esi
            mov whowin,2
        .else 
            mov whowin,3
        .endif

        .if isFirst == 0
            .if whowin==2
                invoke wsprintfA,addr buffer,offset winStr
                invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
            .elseif whowin==1
                invoke wsprintfA,addr buffer,offset lostStr
                invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
            .endif
        .endif


        ; ; 输出上次成绩
	    ; invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

        ; ; 输出最好成绩
	    ; mov		wRect.top,235
	    ; invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

        ; 输出开始信息
	    ;mov		wRect.top,260
        sub	wRect.top,15
	    invoke wsprintfA,addr buffer,offset startStr2
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER

	.else
	    ; Draw tube here
	    push ebx
        
	    mov ebx, offset upTube2
	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 0, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif

 	    mov ebx, offset downTube2 	    
 	    .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
	        invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
	    .endif
        add ebx, sizeof OBJECT
        .if [ebx].OBJECT.x < 288 || [ebx].OBJECT.x <= -1
            invoke ImageList_Draw, tubeIml, 1, mDC, [ebx].OBJECT.x, [ebx].OBJECT.y, ILD_TRANSPARENT
        .endif
	    pop ebx
	    ; end draw tube
        
        ; 打印当前分数
	    mov		wRect.left,0
	    mov		wRect.top,65
	    mov		wRect.right,288
	    mov		wRect.bottom,500
	    invoke SetBkMode,mDC,TRANSPARENT
        invoke SetTextColor,mDC,0ffffffh

        ; life
        invoke wsprintfA, addr buffer, offset lifeStr, birdLife2
        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER    
        ; now
        sub		wRect.top,15
	    invoke wsprintfA,addr buffer,offset nowStr,cPoint2
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
        ; now
        sub		wRect.top,15
	    invoke wsprintfA,addr buffer,offset totFmtStr,totPoint2
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    ; max
        sub		wRect.top,15
        invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint2
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    ; speed
        sub		wRect.top,15
        invoke wsprintfA,addr buffer,offset speedStr,speed2
	    invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    
        ; invoke SetTextColor,mDC,0000000h
	    ; mov		wRect.top,49
	    ; mov		wRect.right,286
	    ; invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER   
	    
        ; RL的 
	    .if isAuto
	        mov		wRect.top,30
	        mov		wRect.right,288
	        invoke wsprintfA,addr buffer,offset maxFmtStr,maxPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	        mov		wRect.top,10
	        invoke wsprintfA,addr buffer,offset lastFmtStr,lPoint
	        invoke DrawText,mDC,addr buffer,-1,addr wRect,DT_CENTER
	    .endif
	    
	.endif
	
	; Draw bird
	.if cflap < 1 && cflapDir == 3
	    mov cflapDir, 0
	.elseif cflap > 1 && cflapDir == 3
	    mov cflapDir, 1
	.elseif cflap < 1 || cflap > 1
	    mov cflapDir, 3
	.endif
	
    ; 换鸟
	.if cflapDir==0
	    inc cflap
	.elseif cflapDir==1
	    dec cflap
	.endif
	
    ; 打印鸟

    ; check in debuff
    ; change bird img

    .if indebuf2 ==1
        invoke ImageList_Draw, birdIml4, cflap, mDC, birdX2, birdY2, ILD_TRANSPARENT;new
    .elseif indebuf2==0
        invoke ImageList_Draw, birdIml2, cflap, mDC, birdX2, birdY2, ILD_TRANSPARENT;new
    .endif
	
	; Draw bottom
	mov eax, speed2
	sub bottomX2, eax
	.if bottomX2 < -47
	    mov bottomX2, 0
	.endif
	invoke ImageList_Draw, barIml, 0, mDC, bottomX2, bottomY2, ILD_TRANSPARENT
	
	invoke GetClientRect,hWin,addr rect
	invoke StretchBlt,hDC,0,0,rect.right,rect.bottom,mDC,0,0,288,500,SRCCOPY
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteObject,eax
	invoke DeleteDC,mDC
	ret

PaintBoard2 endp


BoardProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT

	.if uMsg==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke PaintBoard,hWin,ps.hdc
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif 
	invoke CallWindowProc,OldBoardProc,hWin,uMsg,wParam,lParam
	ret

BoardProc endp

BoardProc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT

	.if uMsg==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke PaintBoard2,hWin,ps.hdc
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif 
	invoke CallWindowProc,OldBoardProc2,hWin,uMsg,wParam,lParam
	ret

BoardProc2 endp

DeBuff proc 
    .if whodie==1 
        mov indebuf,1
        ;.if speed2==4
        mov speed, 6
        add gravityAc, 1
        add jumpAc, -4
        ;.endif
    .endif

    .if whodie==2 
        mov indebuf2,1
        ;.if speed2==4
        mov speed2, 6
        add gravityAc2, 1
        add jumpAc2, -4
        ;.endif
    .endif
    ret
DeBuff endp

DeBuff2 proc target:dword
    .if target==1 
        mov indebuf,1  ;debuf标记置位
        mov speed, 6   ;加速
        add gravityAc, 1 ;增加重力
        add jumpAc, -4  ;增加跳跃力度
    .endif

    .if target==2 
        mov indebuf2,1
        mov speed2, 6
        add gravityAc2, 1
        add jumpAc2, -4
    .endif
    ret
DeBuff2 endp

ResetBuff proc target:dword 
    .if target==1
        .if indebuf==1
            .if speed>4
                dec speed
            .elseif
                mov gravityAc, 2
                mov jumpAc, -14
                mov indebuf,0
            .endif
        .endif
    .elseif target==2
        .if indebuf2==1
            .if speed2>4
                dec speed2
            .elseif
                mov gravityAc2, 2
                mov jumpAc2, -14
                mov indebuf2,0
            .endif
        .endif
    .endif
    ret
ResetBuff endp


Random proc uses ecx edx,range:DWORD
    inc rseed
	mov eax, rseed
	mov ecx, 23
	mul ecx
	add eax, 7
	and eax, 0FFFFFFFFh
	ror eax, 1
	xor eax, rseed
	mov rseed, eax
	mov ecx, range
	xor edx, edx
	div ecx
	mov eax, edx
	ret

Random endp


;初始化游戏，鸟的位置，柱子的位置
SetupFly proc uses eax
    inc rseed
    ; set bird
    mov birdX, 127
    mov birdY, 168

    mov birdX2, 127
    mov birdY2, 168

    mov eax, jumpAc
    mov birdAc, eax

    ;new
    mov eax, jumpAc2
    mov birdAc2, eax
    ;new


    ; set tube
    push ebx
    push edx
    mov ebx, offset upTube
    mov edx, offset downTube
    mov [ebx].OBJECT.x, 576 ;第一组
    mov [edx].OBJECT.x, 576
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax


    add ebx, sizeof OBJECT ;第二组
    add edx, sizeof OBJECT
    mov [ebx].OBJECT.x, 756   ;+200
    mov [edx].OBJECT.x, 756
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax
    

    mov ebx, offset upTube2
    mov edx, offset downTube2
    mov [ebx].OBJECT.x, 576 ;第一组
    mov [edx].OBJECT.x, 576
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax


    add ebx, sizeof OBJECT ;第二组
    add edx, sizeof OBJECT
    mov [ebx].OBJECT.x, 756   ;+200
    mov [edx].OBJECT.x, 756
    invoke Random, 160
    add eax, 195
    mov [edx].OBJECT.y, eax
    sub eax, 450
    mov [ebx].OBJECT.y, eax

    pop edx
    pop ebx
    mov addedFlag, 0
    mov addedFlag2, 0
    ret
SetupFly endp

;初始化参数
InitParam proc
    mov NormSpeed, 4
    mov NormAravityAc, 2
    mov NormJumpAc, -14
    mov birdLife, 10
    mov birdLife2, 10
    mov speed, 4
    mov speed2, 4
    mov bottomY, 387
    mov bottomY2, 387
    mov birdMaxAc, 20
    mov birdBottom, 369
    mov gravityAc, 2
    mov gravityAc2, 2
    mov jumpAc, -14
    mov jumpAc2, -14
    mov cflap, 1
    mov cflapDir, 0
    mov stateV, 179
    mov stateH, 0
    mov isAuto, 0

    mov indebuf,0
    mov indebuf2,0
    ret

InitParam endp

EndGame proc uses edx esi
    mov gStatus, 0
    
    mov birdX, 127
    mov birdY, 168 ;放回中间，初始化界面

    mov birdX2, 127
    mov birdY2, 168

    .if isFirst==0
        mov edx,birdLife
        mov prebirdLife,edx

        mov edx,birdLife2
        mov prebirdLife2,edx
    .endif
    invoke InitParam
    invoke SetupFly
    ret
EndGame endp

;游戏结束，回到初始界面，更新得分
SetupDie proc uses eax

    .if whodie==1
        .if birdLife > 0
            ;mov indebuf,1
            mov eax, cPoint
            mov cPoint, 0
            mov lPoint, eax
            .if eax > maxPoint
                mov maxPoint, eax  
            .endif
            ;add eax, totPoint   ;delete
            ;mov totPoint, eax   ;delete
            dec birdLife 
            mov birdX, 63
            mov birdY, 200

            push ebx
            push edx
            mov ebx, offset upTube
            mov edx, offset downTube
            mov [ebx].OBJECT.x, 276 ;第一组
            mov [edx].OBJECT.x, 276
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax


            add ebx, sizeof OBJECT ;第二组
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, 456   ;+200
            mov [edx].OBJECT.x, 456
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax

            pop edx
            pop ebx
            mov addedFlag, 0

            invoke DeBuff2,1
        .else
            invoke EndGame
        .endif
    .endif

    .if whodie==2
        .if birdLife2 > 0
            ;mov indebuf2,1
            mov eax, cPoint2
            mov cPoint2, 0
            mov lPoint2, eax
            .if eax > maxPoint2
                mov maxPoint2, eax  
            .endif
            ;add eax, totPoint2  ;delete
            ;mov totPoint2, eax  ;delete
            dec birdLife2 
            mov birdX2, 63
            mov birdY2, 200

            push ebx
            push edx
            mov ebx, offset upTube2
            mov edx, offset downTube2
            mov [ebx].OBJECT.x, 276 ;第一组
            mov [edx].OBJECT.x, 276
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax


            add ebx, sizeof OBJECT ;第二组
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, 456   ;+200
            mov [edx].OBJECT.x, 456
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax

            pop edx
            pop ebx
            mov addedFlag2, 0
            invoke DeBuff2,2
        .else
            invoke EndGame
        .endif
    .endif

    .if isAuto
        mov gStatus, 1
	    invoke SetupFly
    .endif

 
    ret
SetupDie endp

SetupDie2 proc uses eax,target:dword

    .if target==1
        .if birdLife > 0

            mov eax, cPoint
            mov cPoint, 0
            mov lPoint, eax
            .if eax > maxPoint
                mov maxPoint, eax  
            .endif

            dec birdLife 
            mov birdX, 63
            mov birdY, 200

            push ebx
            push edx
            mov ebx, offset upTube
            mov edx, offset downTube
            mov [ebx].OBJECT.x, 276 ;第一组
            mov [edx].OBJECT.x, 276
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax


            add ebx, sizeof OBJECT ;第二组
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, 456   ;+200
            mov [edx].OBJECT.x, 456
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax

            pop edx
            pop ebx
            mov addedFlag, 0

            invoke DeBuff2,1
        .else
            invoke EndGame
        .endif
    .endif

    .if target==2
        .if birdLife2 > 0

            mov eax, cPoint2
            mov cPoint2, 0
            mov lPoint2, eax
            .if eax > maxPoint2
                mov maxPoint2, eax  
            .endif

            dec birdLife2 
            mov birdX2, 63
            mov birdY2, 200

            push ebx
            push edx
            mov ebx, offset upTube2
            mov edx, offset downTube2
            mov [ebx].OBJECT.x, 276 ;第一组
            mov [edx].OBJECT.x, 276
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax


            add ebx, sizeof OBJECT ;第二组
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, 456   ;+200
            mov [edx].OBJECT.x, 456
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax

            pop edx
            pop ebx
            mov addedFlag2, 0
            invoke DeBuff2,2
        .else
            invoke EndGame
        .endif
    .endif

    .if isAuto
        mov gStatus, 1
	    invoke SetupFly
    .endif

 
    ret
SetupDie2 endp


SetDist proc uses eax ebx
    
    mov ebx, offset downTube
    mov eax, [ebx].OBJECT.x
    add eax, 52
    .if eax < (birdX) || eax > 10000 ; behind the bird, use the second tube
        add ebx, sizeof OBJECT
    .endif
    mov eax, [ebx].OBJECT.x
    sub eax, birdX
    ;sub eax, 34
    .if eax > 179
        mov eax, 179
    .endif
    mov stateDashH, eax
    mov eax, [ebx].OBJECT.y
    mov ebx, birdY
    add ebx, 24
    sub eax, ebx
    add eax, 200
    mov stateDashV, eax 
    ret

SetDist endp

;new
SetDist2 proc uses eax ebx
    
    mov ebx, offset downTube
    mov eax, [ebx].OBJECT.x
    add eax, 52
    .if eax < (birdX2) || eax > 10000 ; behind the bird, use the second tube
        add ebx, sizeof OBJECT
    .endif
    mov eax, [ebx].OBJECT.x
    sub eax, birdX2
    ;sub eax, 34
    .if eax > 179
        mov eax, 179
    .endif
    mov stateDashH, eax
    mov eax, [ebx].OBJECT.y
    mov ebx, birdY2
    add ebx, 24
    sub eax, ebx
    add eax, 200
    mov stateDashV, eax 
    ret

SetDist2 endp


UpdateQ proc uses eax ebx edx
    LOCAL V_s_dash_a_dash:REAL8
    LOCAL Q_s_a:REAL8
    LOCAL tempX:DWORD
    LOCAL tempY:DWORD
    
    finit
    
    mov edx, 0
    mov eax, stateDashV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateDashH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    mov ebx, eax
    add ebx, tempY
    add ebx, tempY
    fld QMap[ebx * type QMap] ; load Q[tempX][tempY][0]
    inc ebx
    fcom QMap[ebx * type QMap] ; compare with Q[tempX][tempY][1]
    fnstsw ax
    sahf
    ja L1
    fstp V_s_dash_a_dash
    fld QMap[ebx * type QMap]
    L1:
    fstp V_s_dash_a_dash ; save the bigger number to V_s_dash_a_dash
    
    finit
    
    mov edx, 0
    mov eax, stateV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    add eax, tempY
    add eax, tempY
    add eax, actionToPerform
    mov ebx, eax
    fld QMap[ebx * type QMap]
    fstp Q_s_a ; get Q_s_a
    
    fld V_s_dash_a_dash
    fsub Q_s_a
    
    fild reward
    fadd
    
    fld alpha_QL
    fmul
    
    fld Q_s_a
    fadd
    
    fstp QMap[ebx * type QMap]
    
    mov eax, stateDashV
    mov stateV, eax
    
    mov eax, stateDashH
    mov stateH, eax

    ret

UpdateQ endp


PerformAction proc uses eax ebx
    LOCAL tempX:DWORD
    LOCAL tempY:DWORD
    
    finit
    
    mov edx, 0
    mov eax, stateV
    mov ebx, 10
    div ebx
    mov tempX, eax
    mov edx, 0
    mov eax, stateH
    mov ebx, 10
    div ebx
    mov tempY, eax
    mov eax, tempX
    mov ebx, 50
    mul ebx
    add eax, tempY
    add eax, tempY
    mov ebx, eax
    
    fld QMap[ebx * type QMap] ; load Q[tempX][tempY][0]
    inc ebx
    fcom QMap[ebx * type QMap] ; compare with Q[tempX][tempY][1]
    fnstsw ax
    sahf
    jb L3
    mov actionToPerform, 0 ; do nothing
    jmp L4
    L3:
    mov actionToPerform, 1
    mov eax, jumpAc
	mov birdAc, eax
    L4:

    ret

PerformAction endp


TimerProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

    .if gStatus == 1
        .if isAuto
            invoke PerformAction
        .endif

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;bird1
        mov whodie, 1
        ;mov birdAc,0
        mov eax, birdAc
        add eax, gravityAc   ;鸟的速度+重力,每个loop重力都在不断累积

        mov reward, 1
        .if eax > birdMaxAc && eax < 10000   ;此处由于无符号数相减比较，内存中为反码形式，只要限定一个较大的数即可
            mov eax, birdMaxAc ;11为鸟下落的最大速度
        .endif

        mov birdAc, eax
        add eax, birdY


        .if eax > 10000
            mov eax, 0   ;防止溢出屏幕
        .endif


        .if eax > birdBottom ; touch the ground, failed
            mov reward, -1000
            invoke SetupDie2,1

        .else
            mov birdY, eax   ;改变位置
        .endif

        push ebx
        push edx

        mov ebx, offset downTube
        mov eax, [ebx].OBJECT.x

        .if eax < birdX && addedFlag == 0
            invoke ResetBuff,1
            mov reward, 2
            inc cPoint
            inc totPoint;new
            mov addedFlag, 1
        .endif

        .if eax > 16 && eax < 97
            mov eax, [ebx].OBJECT.y
            sub eax, birdY
            .if eax < 20 || eax > 135   ;撞柱子
                mov reward, -1000
                invoke SetupDie2,1 ;触发死亡事件
            .endif

        .endif
        
        mov ebx, offset upTube
        mov edx, offset downTube

        .if [ebx].OBJECT.x < -54 && [ebx].OBJECT.x > 10000
            mov eax, ebx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [ebx].OBJECT.x, ecx    ;2号柱子转移到1号柱子
            mov ecx, [eax].OBJECT.y
            mov [ebx].OBJECT.y, ecx
            mov eax, edx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [edx].OBJECT.x, ecx
            mov ecx, [eax].OBJECT.y
            mov [edx].OBJECT.y, ecx
            
            mov eax, [edx].OBJECT.x
            add eax, 180
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.y, eax
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax
            
            mov addedFlag, 0
        .endif

        mov ecx, 2
        mov ebx, offset upTube
        mov edx, offset downTube
        
        ;移动柱子位置
        .while ecx
            mov eax, [ebx].OBJECT.x
            sub eax, speed
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.x, eax
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            dec ecx
        .endw
        pop edx
        pop ebx
        
        .if isAuto
            invoke SetDist
            invoke SetDist2 ;new
            invoke UpdateQ    
        .endif


        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;bird1


        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;bird2
        ;new
        mov whodie, 2

        mov eax, birdAc2
        add eax, gravityAc2   ;鸟的速度+重力,每个loop重力都在不断累积

        mov reward, 1
        .if eax > birdMaxAc && eax < 10000   ;此处由于无符号数相减比较，内存中为反码形式，只要限定一个较大的数即可
            mov eax, birdMaxAc ;11为鸟下落的最大速度
        .endif

        mov birdAc2, eax
        add eax, birdY2


        .if eax > 10000
            mov eax, 0   ;防止溢出屏幕
        .endif


        .if eax > birdBottom ; touch the ground, failed
            mov reward, -1000
            invoke SetupDie2,2

        .else
            mov birdY2, eax   ;改变位置
        .endif
        ;new

        push ebx
        push edx

        mov ebx, offset downTube2
        mov eax, [ebx].OBJECT.x

        .if eax < birdX2 && addedFlag2 == 0
            invoke ResetBuff,2
            mov reward, 2
            inc cPoint2
            inc totPoint2;new
            mov addedFlag2, 1
        .endif

        .if eax > 16 && eax < 97
            mov eax, [ebx].OBJECT.y
            sub eax, birdY2
            .if eax < 20 || eax > 135   ;撞柱子
                mov reward, -1000
                invoke SetupDie2,2
            .endif
        .endif
        
        mov ebx, offset upTube2
        mov edx, offset downTube2

        .if [ebx].OBJECT.x < -54 && [ebx].OBJECT.x > 10000
            mov eax, ebx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [ebx].OBJECT.x, ecx    ;2号柱子转移到1号柱子
            mov ecx, [eax].OBJECT.y
            mov [ebx].OBJECT.y, ecx
            mov eax, edx
            add eax, sizeof OBJECT
            mov ecx, [eax].OBJECT.x
            mov [edx].OBJECT.x, ecx
            mov ecx, [eax].OBJECT.y
            mov [edx].OBJECT.y, ecx
            
            mov eax, [edx].OBJECT.x
            add eax, 180
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.y, eax
            invoke Random, 160
            add eax, 195
            mov [edx].OBJECT.y, eax
            sub eax, 450
            mov [ebx].OBJECT.y, eax
            
            mov addedFlag2, 0
        .endif

        mov ecx, 2
        mov ebx, offset upTube2
        mov edx, offset downTube2
        
        ;移动柱子位置
        .while ecx
            mov eax, [ebx].OBJECT.x
            sub eax, speed2
            mov [ebx].OBJECT.x, eax
            mov [edx].OBJECT.x, eax
            add ebx, sizeof OBJECT
            add edx, sizeof OBJECT
            dec ecx
        .endw
        pop edx
        pop ebx
        
        .if isAuto
            invoke SetDist
            invoke SetDist2 ;new
            invoke UpdateQ    
        .endif
        

    .endif
	
    invoke InvalidateRect,hBoard,NULL,TRUE
    invoke InvalidateRect,hBoard2,NULL,TRUE

	ret

TimerProc endp

SaveFile proc uses eax ebx
    LOCAL writtenByte:DWORD
    
	invoke CreateFile,offset szFile,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	mov ebx, eax
	invoke WriteFile, ebx, offset QMap, MapSize, addr writtenByte, 0
	invoke CloseHandle, ebx
    ret

SaveFile endp


ReadModelFile proc
    LOCAL readByte

    invoke CreateFile,offset szFile,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
    .if eax
	    mov ebx, eax
	    invoke ReadFile, ebx, offset QMap, MapSize, addr readByte, 0
	.endif
	invoke CloseHandle, ebx
    ret

ReadModelFile endp


WinMain2 proc
    LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG
    invoke  GetModuleHandle,NULL
	mov     hInstance,eax
	invoke  GetCommandLine
	mov	    CommandLine,eax
	invoke  InitCommonControls


	
    ;窗口属性

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
    
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd

	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret
WinMain2 endp


start:
	invoke  GetModuleHandle,NULL
	mov     hInstance,eax
	invoke  GetCommandLine
	mov	    CommandLine,eax
	invoke  InitCommonControls
	invoke  WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
    ;call WinMain2
	invoke  ExitProcess,eax
end start




