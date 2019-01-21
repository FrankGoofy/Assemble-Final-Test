.386
.model		flat,stdcall
.stack		4096
option casemap:none

include .\header.inc

.data
endl			EQU<0Dh,0Ah>
buffer			BYTE	BufSize	DUP(?),0,0		;输入暂存区
stdInHandle		HANDLE	?			;输入句柄
stdOutHandle	HANDLE	?			;输出句柄
bytesRead		DWORD	?			;读取字节数
bytesWrite		DWORD	?			;写入字节数
userName		BYTE	BufSize DUP(?),0,0		;用户名（保存）
userNameLen		DWORD	?						;用户名长度
password		BYTE	BufSize DUP(?),0,0		;密码（保存）
passwordLen		DWORD	?						;密码（长度）
menu			BYTE	"Menu",0Ah,"Register",0Ah,"Login",0Ah,"Operating",0Ah,		;目录
						"Please input the first character to select function:",endl
title			BYTE	"Final Test"		;标题（暂时没用）
userHint		BYTE	"Please input username(no more than 80 char)",endl		;用户名输入提示
passwordHint	BYTE	"Please input password(no more than 80 char)",endl		;密码输入提示
errorHint		BYTE	"Unauthorized User!",endl		;错误提示
result			DWORD	?				;计算结果数据保存区
string			BYTE	10 DUP(?),endl	;result的字符型表示区（10个十进制数可以完全表示DWORD）

.code
;---------------------------------------------------
main PROC
;主程序，显示菜单，输入选项
;---------------------------------------------------
	;invoke		SetConsoleTitleA,ADDR title
L0:	
	invoke		GetStdHandle,STD_OUTPUT_HANDLE			;获取输出句柄
	mov			stdOutHandle,eax						;保存输出句柄
	invoke		WriteConsole,stdOutHandle,				;输出菜单
							ADDR menu,					;菜单内容地址
							SIZEOF menu,				;输出大小
							bytesWrite,0				;输出字符计数

	invoke		GetStdHandle,STD_INPUT_HANDLE			;获取输入句柄
	mov			stdInHandle,eax							;保存输入句柄
	invoke		FlushConsoleInputBuffer,stdInHandle		;清空输入缓冲
	invoke		ReadConsole,stdInHandle,				;获取用户输入选项
							ADDR buffer,				;缓冲区
							3,							;读取字符限制
							ADDR bytesRead,0			;输入字符计数

	mov			AL,buffer		;比较用户输入并跳转到相应函数
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
;用户注册
;接收：
;返回：
;---------------------------------------------------
	invoke		WriteConsole,stdOutHandle,					;输出提示语
							ADDR userHint,					;内容地址
							SIZEOF userHint,				;输出大小
							bytesWrite,0					;输出字符计数

	invoke		FlushConsoleInputBuffer,stdInHandle		;清空输入缓冲
	invoke		ReadConsole,stdInHandle,				;获取用户输入选项
							ADDR userName,				;缓冲区
							BufSize,					;读取字符限制
							ADDR userNameLen,0			;输入字符计数

	invoke		WriteConsole,stdOutHandle,					;输出提示语
							ADDR passwordHint,				;内容地址
							SIZEOF passwordHint,			;输出大小
							bytesWrite,0					;输出字符计数

	invoke		FlushConsoleInputBuffer,stdInHandle		;清空输入缓冲
	invoke		ReadConsole,stdInHandle,				;获取用户输入选项
							ADDR password,				;缓冲区
							BufSize,					;读取字符限制
							ADDR passwordLen,0			;输入字符计数
	ret
Register ENDP

;---------------------------------------------------
Login PROC
;用户登录
;接收：
;返回：
;---------------------------------------------------
	mov			ecx,3
START:
	invoke		WriteConsole,stdOutHandle,					;输出提示语
							ADDR userHint,					;内容地址
							SIZEOF userHint,				;输出大小
							bytesWrite,0					;输出字符计数
	invoke		FlushConsoleInputBuffer,stdInHandle		;清空输入缓冲
	invoke		ReadConsole,stdInHandle,				;获取用户输入选项
							ADDR buffer,				;缓冲区
							userNameLen,				;读取字符限制
							ADDR bytesRead,0			;输入字符计数
	mov			eax,userNameLen			;检查用户名长度是否一致
	cmp			eax,bytesRead			
	je			CHECK_INDEX_A				;长度一致则检查内容
	invoke		WriteConsole,stdOutHandle,					;输出错误提示语
							ADDR errorHint,					;内容地址
							SIZEOF errorHint,				;输出大小
							bytesWrite,0					;输出字符计数
	jmp			RE1
	CHECK_INDEX_A:						;比较用户名内容
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
	invoke		WriteConsole,stdOutHandle,					;输出提示语
							ADDR passwordHint,				;内容地址
							SIZEOF passwordHint,			;输出大小
							bytesWrite,0					;输出字符计数

	invoke		FlushConsoleInputBuffer,stdInHandle		;清空输入缓冲
	invoke		ReadConsole,stdInHandle,				;获取用户输入选项
							ADDR buffer,				;缓冲区
							passwordLen,				;读取字符限制
							ADDR bytesRead,0			;输入字符计数

	mov			eax,passwordLen			;检查用户名长度是否一致
	cmp			eax,bytesRead			
	je			CHECK_INDEX_B			;长度一致则检查内容
	invoke		WriteConsole,stdOutHandle,					;输出错误提示语
							ADDR errorHint,					;内容地址
							SIZEOF errorHint,				;输出大小
							bytesWrite,0					;输出字符计数
	jmp			RE1
	CHECK_INDEX_B:						;比较密码内容
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
;计算阶乘并输出
;接收：
;返回：
;---------------------------------------------------
	mov			ecx,5
	mov			eax,1
Factorial:				;计算阶乘
	mul			ecx
	loop		Factorial
	mov			result,eax

	mov			esi,9		;数组定位
	mov			eax,result	;被除数/商
	mov			edx,0		;余数
	mov			ebx,10		;除数
A1:
	div			ebx
	mov			string[esi],DL
	dec			esi
	cmp			eax,10
	jae			A1
	mov			string[esi],AL

	mov			ecx,0			;处理字符串操作
	mov			esi,sizeof string
	sub			esi,2
A3:
	dec			esi
	add			string[esi],30h
	cmp			esi,0
	jne			A3

	invoke		WriteConsole,stdOutHandle,				;输出提示语
							ADDR string,				;内容地址
							SIZEOF string,				;输出大小
							bytesWrite,0				;输出字符计数
	ret
Operating ENDP
END	main