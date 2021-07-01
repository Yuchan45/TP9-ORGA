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
    msj_op_in_digito_invalido       db  "El operador inicial ingresado tiene digitos que no son (1 o 0).",0
    msj_op_in_long_invalida         db  "El operador inicial ingresado no tiene 16 digitos.",0

    long_input_op_inicial           dq  0
    msj_long_input_valido           db  "Longitud de operando valida: %lli",10,0
    msj_long_input_invalido               db  "Longitud de oprando invalida: %lli",10,0

	;*** Mensajes para debug
	msj_inicio                       db "Iniciando...",0
	msj_apertura_ok                  db "Apertura Listado ok",0
	msj_guarde_operando_inicial      db " - Operando inicial guardado - ",0
	msj_leyendo     	             db	"leyendo...",0
    imprimo_operando_inicial         db  "Operando inicial ingresado: %s",10,0

section     .bss  ; Variables sin valor inicial
    operando_inicial            resb    500
    dato_valido		            resb	1
    operando_inicial_valido     resb    1

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

;mov		rcx,msj_guarde_operando_inicial  ; printf - Operando inicial guardado.
;sub		rsp,32
;call	puts
;add		rsp,32

mov     rcx,imprimo_operando_inicial
mov     rdx,operando_inicial
sub     rsp,32
call    printf
add     rsp,32

;   Valido el operando ingresado.
    call    validar_operando_inicial
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
ret  ;  ret del cerrar_archivos


;************************************
;       RUTINAS INTERNAS
;************************************
validar_operando_inicial:
    mov     byte[operando_inicial_valido],'N'

    call    validar_long_op_inicial
    cmp     byte[dato_valido],'N'
    je      fin_validar_op_inicial

    call    validar_digitos
    cmp     byte[dato_valido],'N'
    je      fin_validar_op_inicial

    mov     byte[operando_inicial_valido],'S'

fin_validar_op_inicial:
ret  ; ret del validar_operador_inicial

;------------------------------------------------------
;VALIDAR DIGITOS
validar_digitos:
    mov     byte[dato_valido],'S'

    mov		rcx,16  ;  Porque son 16 digitos a ver si son 1 o 0. (loop usa el rcx).
	mov		rbx,0
proximo_digito:
	cmp		byte[operando_inicial+rbx],'0'
	jl		error_digito_invalido
	cmp		byte[operando_inicial+rbx],'1'
	jg		error_digito_invalido
	inc		rbx
	loop	proximo_digito

    jmp     fin_validar_operador_inicial

error_digito_invalido:
    mov     byte[dato_valido],'N'

mov		rcx,msj_op_in_digito_invalido  ; printf - El operador inicial ingresado tiene digitos que no son (1 o 0).
sub		rsp,32
call	puts
add		rsp,32


fin_validar_operador_inicial:
ret  ;  ret del validar_digitos

;------------------------------------------------------
;VALIDAR LONGITUD DE OPERADOR
validar_long_op_inicial:
    mov     qword[long_input_op_inicial],0
    mov     byte[dato_valido],'S'

    mov     rsi,0 ; rsi es un registro indice. Lo inicializo en 0. Podriamos usar el rsi como contador de long_texto. Pero para el ejemplo mejor no.
comp_caracter:
    cmp     byte[operando_inicial + rsi],0 ; 
    je      fin_string ; Salta a la etiqueta fin_string si cmp da 0, osea si llegue al final.
    inc     qword[long_input_op_inicial]  ; long_input_op_inicial++  . Hace falta "recordarle" a assembler que es un quad. qword = 8 bytes = quad.

    inc     rsi ; rsi++
    jmp     comp_caracter ; Jmp incondicional a un rotulo que pongo ahora (Si, codie hasta el jmp y ahora pongo un rotulo a donde quiero ir).
fin_string:
;   *** Fin de recorrido (ida) ***

    cmp     qword[long_input_op_inicial],16
    je      fin_validar_long_op_inicial

    mov     byte[dato_valido],'N'
; DEBUG
mov     rcx,msj_long_input_invalido
mov     rdx,[long_input_op_inicial]  ; Si ves raro estom de que este en rcx y rdc, mira el ppt que te muestra como usar el printf. printf imprime lo que hay en el rcx, y el rdx, r8, etc son los parametros del printf.
sub     rsp,32
call    printf
add     rsp,32

fin_validar_long_op_inicial:
ret  ;  ret del validar_long_op_inicial



ret  ; ret del main



