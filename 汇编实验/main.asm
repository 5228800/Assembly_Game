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
;��ťID
startGameButtonID equ 1 
exitGameButtonID equ 2 
detailGameButtonID equ 3 
backGameButtonID equ 4 

;ͼƬ���
IDB_redTank equ 101

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
        mov edi, mapOffset
        add mapWidth, edi
        add mapHeight,edi
    .ELSEIF uMsg == WM_PAINT
        ; ��ʼ�����ػ���Ϣ
        invoke BeginPaint, hWnd, ADDR ps
        mov hWindowHdc, eax
        .IF startFlag==0

        .ELSE
            ;�������ʣ�����ֱ��
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

            ; �����ڴ� DC ��ѡ��λͼ
            invoke CreateCompatibleDC, hWindowHdc
            mov memDC, eax

            invoke LoadBitmap, hInstance, IDB_redTank
            mov redTankBitmap, eax
            invoke SelectObject, memDC, redTankBitmap
            ; ��ȡλͼ��Ϣ������
            invoke GetObject, redTankBitmap, SIZEOF BITMAP, ADDR bmp
            invoke BitBlt, hWindowHdc, 100, 100, bmp.bmWidth, bmp.bmHeight, memDC, 0, 0, SRCCOPY

            ; �ͷ��ڴ� DC
            invoke ReleaseDC, hWnd, memDC
            ;invoke DeleteDC, memDC
            invoke EndPaint, hWnd, ADDR ps
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