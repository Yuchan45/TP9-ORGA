global	main

extern  puts
extern  gets
extern  printf
extern  fopen
extern  fclose
extern  fgets
extern  sscanf


section     .data  ; Variables con valor inicial

    archivo_datos		        db	"datos.txt",0
	modo_apertura_datos		    db	"r",0		;read | texto | abrir o error
	msj_err_abrir_datos	        db	"Error en apertura de archivo de datos",0
    handle_datos	            dq	0
    
    msj_ingresar_operando_inicial   db  "-Ingrese el operando inicial (solo caracteres 0 o 1)(16 bytes): ",10,0
    msj_op_inicial_invalido         db  "Operador inicial invalido!!",0
    msj_op_inicial_valido           db  "Operador inicial valido!!",0

	;*** Mensajes para debug
	msj_inicio                       db "Iniciando...",0
	msj_apertura_ok                  db "Apertura Listado ok",0
	msj_guarde_operando_inicial      db " - Operando inicial guardado - ",0
	msj_leyendo     	             db	"leyendo...",0
    imprimo_operando_inicial         db  "Operando inicial ingresado: %s",10,0

section     .bss  ; Variables sin valor inicial
    operando_inicial    resb    500
    dato_valido		    resb	1

section     .text

main:
    ;Abro archivo listado
    mov		rcx,archivo_datos
    mov     rdx,modo_apertura_datos 
	sub		rsp,32
    call	fopen
	add		rsp,32

    cmp     rax,0
    jle     error_al_abrir_archivo
    mov     [handle_datos],rax

mov		rcx,msj_apertura_ok  ; printf - Apertura Listado ok.
sub		rsp,32
call	puts
add		rsp,32

; --- Solicito ingreso del "Operando inicial" ---

volver_a_solicitar:
;   Printf mensaje de ingreo de operando
    mov     rcx,msj_ingresar_operando_inicial
    sub     rsp,32
    call    printf
    add     rsp,32

;   Gets recibe la cadena operando
    mov     rcx,operando_inicial
    sub     rsp,32
    call    gets
    add     rsp,32

mov		rcx,msj_guarde_operando_inicial  ; printf - Operando inicial guardado.
sub		rsp,32
call	puts
add		rsp,32

mov     rcx,imprimo_operando_inicial
mov     rdx,operando_inicial
sub     rsp,32
call    printf
add     rsp,32

;   Valido el operador ingresado.
    call    validar_operador
    cmp     byte[dato_valido],'N'
    je      volver_a_solicitar

mov		rcx,msj_op_inicial_valido  ; printf - Operando inicial guardado.
sub		rsp,32
call	puts
add		rsp,32

    jmp     fin_de_programa  ;  Si llego aca es xq ya paso todo. Asi que saltate todos los msjs de error que hay abajo.

;----Mensajes de error
error_al_abrir_archivo:
	mov		rcx,msj_err_abrir_datos ; printf - Error en apertura de archivo de datos.
	sub		rsp,32
	call	puts
	add		rsp,32
	jmp		fin_de_programa



cerrar_archivos:
    mov     rcx,[handle_datos]
	sub		rsp,32
    call    fclose
	add		rsp,32
    jmp     fin_de_programa


fin_de_programa:
ret


;************************************
;       RUTINAS INTERNAS
;************************************
validar_operador:
    mov     byte[dato_valido],'S'



;mov		rcx,msj_op_inicial_invalido  ; printf - Operador inicial invalido.
;sub		rsp,32
;call	puts
;add		rsp,32

ret



