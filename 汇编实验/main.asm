.386 
.model flat,stdcall 
option casemap:none 
include windows.inc 
include user32.inc 
includelib user32.lib           
include kernel32.inc 
includelib kernel32.lib 
include gdi32.inc
includelib gdi32.lib
includelib msvcrt.lib


.CONST 
;��ťID
startGameButtonID equ 1 
exitGameButtonID equ 2 
detailGameButtonID equ 3 
backGameButtonID equ 4 

;��ʱ��ID
TimerID equ 114514

;ͼƬ���
IDB_redTank equ 101
IDB_greenTank equ 102


.DATA  
ClassName db "MyWindowClass",0       
AppName db "̹�˶���",0   

ButtonClassName db "Button",0   
startGameButtonTitle db "��ʼ��Ϸ",0
exitGameButtonTitle db "�˳���Ϸ",0
detailGameButtonTitle db "��Ϸָ��",0
backGameButtonTitle db "���ؿ�ʼ����",0
detailText db "��ɫ̹�˲�����Wǰ����S���ˣ�A��ת��D��ת��Q���",0AH,"��ɫ̹�˲������������ǰ����������º��ˣ����������ת�����������ת��M���",0AH,0

startFlag dword 0
initedFlag dword 0

mapWidth dword 800
mapWidthBlockNum dword 20
mapHeight dword 520
mapHeightBlockNum dword 13
mapOffset dword 10
mapBlockSize dword 40

speed dword 2
redTankAngle REAL4 0.0
greenTankAngle REAL4 0.0

.DATA?              
hInstance HINSTANCE ?
hWindow HWND ?

startGameButton HWND ?
exitGameButton HWND ?
detailGameButton HWND ?
backGameButton HWND ?

redTankBitmap HBITMAP ?
redTankX dword ?
redTankY dword ?
redTankStepX dword ?
redTankStepY dword ?

greenTankBitmap HBITMAP ?
greenTankX dword ?
greenTankY dword ?
greenTankStepX dword ?
greenTankStepY dword ?

.code   
extern rand:proc
extern srand:proc
RandTankPosition proc    
    ; �����ɫ̹��λ��
	call rand	
	div mapWidthBlockNum
    mov eax, edx
    mul mapBlockSize
    add eax, mapOffset
    mov redTankX, eax

	call rand	
	div mapHeightBlockNum
    mov eax, edx
    mul mapBlockSize
    add eax, mapOffset
    mov redTankY, eax
    
    ; ������ɫ̹��λ��
	call rand	
	div mapWidthBlockNum
    mov eax, edx
    mul mapBlockSize
    add eax, mapOffset
    mov greenTankX, eax

	call rand	
	div mapHeightBlockNum
    mov eax, edx
    mul mapBlockSize
    add eax, mapOffset
    mov greenTankY, eax    

	ret	
RandTankPosition endp

WinMain proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL hWindowHdc:HDC
    LOCAL BufferDC:HDC
    LOCAL BitmapDC:HDC
    LOCAL hbmp:HBITMAP
    LOCAL bmp:BITMAP

    .IF uMsg == WM_COMMAND
        mov eax, wParam
        .IF ax == startGameButtonID
            invoke ShowWindow, startGameButton, SW_HIDE
            invoke ShowWindow, exitGameButton, SW_HIDE
            invoke ShowWindow, detailGameButton, SW_HIDE
            invoke ShowWindow, backGameButton, SW_SHOW
            mov startFlag,1
            mov initedFlag,0
            ;paint�ػ�
            invoke InvalidateRect, hWnd, NULL, TRUE

        .ELSEIF ax == exitGameButtonID
            ;�������
            invoke ExitProcess, 0
        .ELSEIF ax == detailGameButtonID
            ;��ʾ����
            invoke MessageBox, hWnd, offset detailText, offset detailGameButtonTitle,	MB_OK + MB_ICONQUESTION
        .ELSEIF ax == backGameButtonID
            invoke ShowWindow, startGameButton, SW_SHOW
            invoke ShowWindow, exitGameButton, SW_SHOW
            invoke ShowWindow, detailGameButton, SW_SHOW
            invoke ShowWindow, backGameButton, SW_HIDE
            mov startFlag,0
            invoke InvalidateRect, hWnd, NULL, TRUE
        .ENDIF
    .ELSEIF uMsg==WM_CREATE
        ;�������ڵ�ͬʱ�������
        invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR startGameButtonTitle, WS_TABSTOP OR WS_VISIBLE OR WS_CHILD OR BS_DEFPUSHBUTTON,\
        100, 350, 200, 70, hWnd, startGameButtonID, hInstance, NULL
        mov startGameButton, eax
        invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR exitGameButtonTitle, WS_TABSTOP OR WS_VISIBLE OR WS_CHILD OR BS_DEFPUSHBUTTON,\
        400, 350, 200, 70, hWnd, exitGameButtonID, hInstance, NULL
        mov exitGameButton, eax
        invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR detailGameButtonTitle, WS_TABSTOP OR WS_VISIBLE OR WS_CHILD OR BS_DEFPUSHBUTTON,\
        700, 350, 200, 70, hWnd, detailGameButtonID, hInstance, NULL
        mov detailGameButton, eax
        invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR backGameButtonTitle, WS_TABSTOP OR WS_VISIBLE OR WS_CHILD OR BS_DEFPUSHBUTTON,\
        850, 450, 100, 50, hWnd, backGameButtonID, hInstance, NULL
        mov backGameButton, eax
        invoke ShowWindow, backGameButton, SW_HIDE

        invoke SetTimer, hWnd, TimerID, 10, NULL  ; ÿ 10ms ���� WM_TIMER
    .ELSEIF uMsg == WM_PAINT
        invoke BeginPaint, hWnd, ADDR ps
        mov hWindowHdc, eax

        invoke CreateCompatibleDC, hWindowHdc
        mov BufferDC, eax

        invoke CreateCompatibleDC, BufferDC
        mov BitmapDC, eax

        invoke CreateCompatibleBitmap, hWindowHdc, mapWidth, mapHeight
        mov hbmp, eax

        invoke SelectObject,BufferDC,hbmp
        invoke SetBkColor, BufferDC, 0FFFFFFh
        invoke PatBlt, BufferDC, 0, 0, mapWidth, mapHeight, WHITENESS

	    invoke SetStretchBltMode,hWindowHdc,HALFTONE
	    invoke SetStretchBltMode,BufferDC,HALFTONE

        .IF startFlag==0

        .ELSE
            ;�������ʣ�����ֱ��
            invoke CreatePen, PS_SOLID, 3, 0h
            invoke SelectObject, BufferDC, eax

            mov edi, 0
            mov esi, 0
            .WHILE esi <= mapHeightBlockNum            
                invoke MoveToEx, BufferDC, 0, edi, NULL
                invoke LineTo, BufferDC, mapWidth, edi
                add edi,mapBlockSize
                inc esi
            .ENDW
            mov edi, 0
            mov esi, 0
            .WHILE esi <= mapWidthBlockNum
                invoke MoveToEx, BufferDC, edi, 0, NULL
                invoke LineTo, BufferDC, edi, mapHeight
                add edi,mapBlockSize
                inc esi
            .ENDW

            ; ���غ�ɫ̹��ͼƬ
            invoke LoadBitmap, hInstance, IDB_redTank
            mov redTankBitmap, eax

            ; ������ɫ̹��ͼƬ
            invoke LoadBitmap, hInstance, IDB_greenTank
            mov greenTankBitmap, eax

            .IF initedFlag == 0
                ; �������̹�˵�����
                invoke RandTankPosition
                mov initedFlag, 1
            .ENDIF

            ; ѡ���ɫ̹��λͼ������
            invoke GetObject, redTankBitmap, SIZEOF BITMAP, ADDR bmp
            invoke SelectObject, BitmapDC, redTankBitmap
            invoke StretchBlt, BufferDC, redTankX, redTankY, bmp.bmWidth, bmp.bmHeight, BitmapDC, 0, 0,bmp.bmWidth, bmp.bmHeight, SRCCOPY
            
            ; ѡ����ɫ̹��λͼ������
            invoke GetObject, greenTankBitmap, SIZEOF BITMAP, ADDR bmp
            invoke SelectObject, BitmapDC, greenTankBitmap
            invoke StretchBlt, BufferDC, greenTankX, greenTankY, bmp.bmWidth, bmp.bmHeight, BitmapDC, 0, 0, bmp.bmWidth, bmp.bmHeight,SRCCOPY

            invoke StretchBlt, hWindowHdc, mapOffset, mapOffset, mapWidth, mapHeight, BufferDC, 0, 0,mapWidth, mapHeight, SRCCOPY
            invoke DeleteObject, redTankBitmap
            invoke DeleteObject, greenTankBitmap
        .ENDIF

	    ;ɾ��ָ��
	    invoke DeleteDC,hbmp
	    invoke DeleteDC,BitmapDC
	    invoke DeleteDC,BufferDC
	    invoke DeleteDC,hWindowHdc
	    invoke EndPaint, hWnd, ADDR ps


    .ELSEIF uMsg == WM_TIMER
        .IF initedFlag == 0
            ret
        .ENDIF
        invoke GetAsyncKeyState, VK_W
        .IF  ax == 8000h
        ;.IF wParam == VK_W
            ;ǰ������������
            fld redTankAngle
            fsin
            fstp redTankStepX

            fld redTankAngle
            fcos
            fstp redTankStepY

            fld speed
            fld redTankStepX
            fmul
            fstp redTankStepX

            fld speed
            fld redTankStepY
            fmul
            fstp redTankStepY
            
            fld redTankX
            fld redTankStepX
            fadd
            fstp redTankX

            fld redTankY
            fld redTankStepY
            fadd
            fstp redTankY
            invoke InvalidateRect, hWnd, NULL, FALSE
        .ENDIF
        invoke GetAsyncKeyState, VK_S
        .IF  ax == 8000h
        ;.ELSEIF wParam == VK_S
            fld redTankAngle
            fsin
            fstp redTankStepX

            fld redTankAngle
            fcos
            fstp redTankStepY

            fld speed
            fld redTankStepX
            fmul
            fstp redTankStepX

            fld speed
            fld redTankStepY
            fmul
            fstp redTankStepY
            
            fld redTankX
            fld redTankStepX
            fsub
            fstp redTankX

            fld redTankY
            fld redTankStepY
            fsub
            fstp redTankY
            invoke InvalidateRect, hWnd, NULL, FALSE
        ;.ELSEIF wParam == VK_A
        ;.ELSEIF wParam == VK_D
        .ENDIF
    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam  
    .ENDIF
    ret 
WinMain endp

;main������������
main proc 
    LOCAL wc:WNDCLASSEX              
    LOCAL msg:MSG 

	invoke GetModuleHandle, NULL   
	mov hInstance, eax
    mov   wc.cbSize, SIZEOF WNDCLASSEX   
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WinMain
    mov   wc.cbClsExtra, NULL 
    mov   wc.cbWndExtra, NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground, COLOR_WINDOW+1 
    mov   wc.lpszMenuName, NULL 
    mov   wc.lpszClassName, OFFSET ClassName 
    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov   wc.hIcon, eax 
    mov   wc.hIconSm, eax 
    invoke LoadCursor, NULL, IDC_ARROW 
    mov   wc.hCursor, eax 
    invoke RegisterClassEx, ADDR wc   
    invoke CreateWindowEx, NULL,\
                ADDR ClassName,\
                ADDR AppName,\
                WS_OVERLAPPEDWINDOW,\
                300,\
                150,\
                1000,\
                600,\
                NULL,\
                NULL,\
                hInstance,\
                NULL 
    mov   hWindow, eax

    invoke ShowWindow, hWindow, SW_SHOWDEFAULT   
    invoke UpdateWindow, hWindow               

    .WHILE TRUE                                             
        invoke GetMessage, ADDR msg, NULL, 0, 0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax, msg.wParam  
    invoke ExitProcess, eax  
    ret 
main endp
end main
