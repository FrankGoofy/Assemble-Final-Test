.386
.model		flat,stdcall
.stack		4096
option casemap:none

include .\header.inc

.data
endl			EQU<0Dh,0Ah>
buffer			BYTE	BufSize	DUP(?),0,0		;�����ݴ���
stdInHandle		HANDLE	?			;������
stdOutHandle	HANDLE	?			;������
bytesRead		DWORD	?			;��ȡ�ֽ���
bytesWrite		DWORD	?			;д���ֽ���
userName		BYTE	BufSize DUP(?),0,0		;�û��������棩
userNameLen		DWORD	?						;�û�������
password		BYTE	BufSize DUP(?),0,0		;���루���棩
passwordLen		DWORD	?						;���루���ȣ�
menu			BYTE	"Menu",0Ah,"Register",0Ah,"Login",0Ah,"Operating",0Ah,		;Ŀ¼
						"Please input the first character to select function:",endl
title			BYTE	"Final Test"		;���⣨��ʱû�ã�
userHint		BYTE	"Please input username(no more than 80 char)",endl		;�û���������ʾ
passwordHint	BYTE	"Please input password(no more than 80 char)",endl		;����������ʾ
errorHint		BYTE	"Unauthorized User!",endl		;������ʾ
result			DWORD	?				;���������ݱ�����
string			BYTE	10 DUP(?),endl	;result���ַ��ͱ�ʾ����10��ʮ������������ȫ��ʾDWORD��

.code
;---------------------------------------------------
main PROC
;��������ʾ�˵�������ѡ��
;---------------------------------------------------
	;invoke		SetConsoleTitleA,ADDR title
L0:	
	invoke		GetStdHandle,STD_OUTPUT_HANDLE			;��ȡ������
	mov			stdOutHandle,eax						;����������
	invoke		WriteConsole,stdOutHandle,				;����˵�
							ADDR menu,					;�˵����ݵ�ַ
							SIZEOF menu,				;�����С
							bytesWrite,0				;����ַ�����

	invoke		GetStdHandle,STD_INPUT_HANDLE			;��ȡ������
	mov			stdInHandle,eax							;����������
	invoke		FlushConsoleInputBuffer,stdInHandle		;������뻺��
	invoke		ReadConsole,stdInHandle,				;��ȡ�û�����ѡ��
							ADDR buffer,				;������
							3,							;��ȡ�ַ�����
							ADDR bytesRead,0			;�����ַ�����

	mov			AL,buffer		;�Ƚ��û����벢��ת����Ӧ����
	cmp			AL,'R'
	je			L1
	cmp			AL,'L'
	je			L2
	cmp			AL,'O'
	je			L3
	jne			L0
L1:
	invoke		Register
	jmp			L0
L2:
	invoke		Login
	jmp			L0
L3:
	invoke		Operating
	jmp			L0

	invoke		ExitProcess,0
main ENDP

;---------------------------------------------------
Register PROC
;�û�ע��
;���գ�
;���أ�
;---------------------------------------------------
	invoke		WriteConsole,stdOutHandle,					;�����ʾ��
							ADDR userHint,					;���ݵ�ַ
							SIZEOF userHint,				;�����С
							bytesWrite,0					;����ַ�����

	invoke		FlushConsoleInputBuffer,stdInHandle		;������뻺��
	invoke		ReadConsole,stdInHandle,				;��ȡ�û�����ѡ��
							ADDR userName,				;������
							BufSize,					;��ȡ�ַ�����
							ADDR userNameLen,0			;�����ַ�����

	invoke		WriteConsole,stdOutHandle,					;�����ʾ��
							ADDR passwordHint,				;���ݵ�ַ
							SIZEOF passwordHint,			;�����С
							bytesWrite,0					;����ַ�����

	invoke		FlushConsoleInputBuffer,stdInHandle		;������뻺��
	invoke		ReadConsole,stdInHandle,				;��ȡ�û�����ѡ��
							ADDR password,				;������
							BufSize,					;��ȡ�ַ�����
							ADDR passwordLen,0			;�����ַ�����
	ret
Register ENDP

;---------------------------------------------------
Login PROC
;�û���¼
;���գ�
;���أ�
;---------------------------------------------------
	mov			ecx,3
START:
	invoke		WriteConsole,stdOutHandle,					;�����ʾ��
							ADDR userHint,					;���ݵ�ַ
							SIZEOF userHint,				;�����С
							bytesWrite,0					;����ַ�����
	invoke		FlushConsoleInputBuffer,stdInHandle		;������뻺��
	invoke		ReadConsole,stdInHandle,				;��ȡ�û�����ѡ��
							ADDR buffer,				;������
							userNameLen,				;��ȡ�ַ�����
							ADDR bytesRead,0			;�����ַ�����
	mov			eax,userNameLen			;����û��������Ƿ�һ��
	cmp			eax,bytesRead			
	je			CHECK_INDEX_A				;����һ����������
	invoke		WriteConsole,stdOutHandle,					;���������ʾ��
							ADDR errorHint,					;���ݵ�ַ
							SIZEOF errorHint,				;�����С
							bytesWrite,0					;����ַ�����
	jmp			RE1
	CHECK_INDEX_A:						;�Ƚ��û�������
	mov			esi,0
	mov			edi,0
NEXT_1:
	mov			AL,buffer[esi]
	mov			AH,userName[edi]
	cmp			AL,AH
	jne			RE1
	inc			esi
	inc			edi
	mov			eax,bytesRead
	inc			eax
	cmp			esi,eax
	jne			NEXT_1

CHECK_PASSWORD:
	invoke		WriteConsole,stdOutHandle,					;�����ʾ��
							ADDR passwordHint,				;���ݵ�ַ
							SIZEOF passwordHint,			;�����С
							bytesWrite,0					;����ַ�����

	invoke		FlushConsoleInputBuffer,stdInHandle		;������뻺��
	invoke		ReadConsole,stdInHandle,				;��ȡ�û�����ѡ��
							ADDR buffer,				;������
							passwordLen,				;��ȡ�ַ�����
							ADDR bytesRead,0			;�����ַ�����

	mov			eax,passwordLen			;����û��������Ƿ�һ��
	cmp			eax,bytesRead			
	je			CHECK_INDEX_B			;����һ����������
	invoke		WriteConsole,stdOutHandle,					;���������ʾ��
							ADDR errorHint,					;���ݵ�ַ
							SIZEOF errorHint,				;�����С
							bytesWrite,0					;����ַ�����
	jmp			RE1
	CHECK_INDEX_B:						;�Ƚ���������
	mov			esi,0
	mov			edi,0
NEXT_2:
	mov			AL,buffer[esi]
	cmp			AL,password[edi]
	jne			RE1
	inc			esi
	inc			edi
	mov			eax,bytesRead
	inc			eax
	cmp			esi,eax
	jne			NEXT_2
	jmp			YEA
RE1:
	dec			ecx
	cmp			ecx,0
	jne			START
YEA:
	invoke		Operating
	ret
Login ENDP

;---------------------------------------------------
Operating PROC
;����׳˲����
;���գ�
;���أ�
;---------------------------------------------------
	mov			ecx,5
	mov			eax,1
Factorial:				;����׳�
	mul			ecx
	loop		Factorial
	mov			result,eax

	mov			esi,9		;���鶨λ
	mov			eax,result	;������/��
	mov			edx,0		;����
	mov			ebx,10		;����
A1:
	div			ebx
	mov			string[esi],DL
	dec			esi
	cmp			eax,10
	jae			A1
	mov			string[esi],AL

	mov			ecx,0			;�����ַ�������
	mov			esi,sizeof string
	sub			esi,2
A3:
	dec			esi
	add			string[esi],30h
	cmp			esi,0
	jne			A3

	invoke		WriteConsole,stdOutHandle,				;�����ʾ��
							ADDR string,				;���ݵ�ַ
							SIZEOF string,				;�����С
							bytesWrite,0				;����ַ�����
	ret
Operating ENDP
END	main