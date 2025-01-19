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

.CONST 
;按钮ID
startGameButtonID equ 1 
exitGameButtonID equ 2 
detailGameButtonID equ 3 
backGameButtonID equ 4 

;图片序号
IDB_redTank equ 101

.DATA  
ClassName db "MyWindowClass",0       
AppName db "坦克动荡",0   

ButtonClassName db "Button",0   
startGameButtonTitle db "开始游戏",0
exitGameButtonTitle db "退出游戏",0
detailGameButtonTitle db "游戏指南",0
backGameButtonTitle db "返回开始界面",0
detailText db "红色坦克操作：W前进，S后退，A左转，D右转，Q射击",0AH,"绿色坦克操作：方向键上前进，方向键下后退，方向键左左转，方向键右右转，M射击",0AH,0

startFlag dword 0
mapWidth dword 800
mapHeight dword 520
mapOffset dword 10
mapBlockSize dword 40

.DATA?              
hInstance HINSTANCE ?
hWindowHdc HDC ?
hWindow HWND ?

startGameButton HWND ?
exitGameButton HWND ?
detailGameButton HWND ?
backGameButton HWND ?

redTankBitmap HBITMAP ?

.code      

WinMain proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL memDC:HDC
    LOCAL bmp:BITMAP

    .IF uMsg == WM_COMMAND
        mov eax, wParam
        .IF ax == startGameButtonID
            invoke ShowWindow, startGameButton, SW_HIDE
            invoke ShowWindow, exitGameButton, SW_HIDE
            invoke ShowWindow, detailGameButton, SW_HIDE
            invoke ShowWindow, backGameButton, SW_SHOW
            mov startFlag,1

            ;paint重绘
            invoke InvalidateRect, hWnd, NULL, TRUE

        .ELSEIF ax == exitGameButtonID
            ;程序结束
            invoke ExitProcess, 0
        .ELSEIF ax == detailGameButtonID
            ;提示弹窗
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
        ;创建窗口的同时创建插件
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
        mov edi, mapOffset
        add mapWidth, edi
        add mapHeight,edi
    .ELSEIF uMsg == WM_PAINT
        ; 开始处理重绘消息
        invoke BeginPaint, hWnd, ADDR ps
        mov hWindowHdc, eax
        .IF startFlag==0

        .ELSE
            ;创建画笔，绘制直线
            invoke CreatePen, PS_SOLID, 3, 0h
            invoke SelectObject, hWindowHdc, eax

            mov edi, mapOffset
            .WHILE edi <= mapHeight            
                invoke MoveToEx, hWindowHdc, mapOffset, edi, NULL
                invoke LineTo, hWindowHdc, mapWidth, edi
                add edi,mapBlockSize
            .ENDW
            mov edi, mapOffset
            .WHILE edi <= mapWidth
                invoke MoveToEx, hWindowHdc, edi, mapOffset, NULL
                invoke LineTo, hWindowHdc, edi, mapHeight
                add edi,mapBlockSize
            .ENDW

            ; 创建内存 DC 并选择位图
            invoke CreateCompatibleDC, hWindowHdc
            mov memDC, eax

            invoke LoadBitmap, hInstance, IDB_redTank
            mov redTankBitmap, eax
            invoke SelectObject, memDC, redTankBitmap
            ; 获取位图信息并绘制
            invoke GetObject, redTankBitmap, SIZEOF BITMAP, ADDR bmp
            invoke BitBlt, hWindowHdc, 100, 100, bmp.bmWidth, bmp.bmHeight, memDC, 0, 0, SRCCOPY

            ; 释放内存 DC
            invoke ReleaseDC, hWnd, memDC
            ;invoke DeleteDC, memDC
            invoke EndPaint, hWnd, ADDR ps
        .ENDIF
    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam  
    .ENDIF
    ret 
WinMain endp

;main函数创建窗口
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