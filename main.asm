global	main

extern  puts
extern  gets
extern  printf
extern  fopen
extern  fclose
extern  fread
extern  fwrite
extern  fgets
extern  sscanf


section     .data  ; Variables con valor inicial
    archivo_datos		        db	"datos.dat",0
	modo_apertura_datos		    db	"r",0		;read | texto | abrir o error
	msj_err_abrir_datos	        db	"Error en apertura de archivo de datos",10,0
    handle_datos	            dq	0


    msj_ingresar_operando_inicial           db  "- Ingrese el operando inicial (solo caracteres 0 o 1)(16 bytes): ",0
    msj_operador_inicial_invalido           db  " * Operador inicial invalido!!",10,0
    msj_operador_inicial_valido             db  " * Operador inicial valido!!",10,0
    msj_operador_inicial_digito_invalido    db  " * El operador inicial ingresado tiene digitos que no son (1 o 0).",10,0
    msj_operador_inicial_long_invalida      db  " * El operador inicial ingresado no tiene 16 digitos.",10,0

    long_input_op_inicial           dq  0
    msj_long_input_valido           db  " * Longitud de operando valida: %lli",10,0
    msj_long_input_invalido         db  " * Longitud de operando invalida: %lli",10,0

    opr_xor                           db      'X',0    ;Operador XOR
    opr_or                            db      'O',0    ;Operador OR
    opr_and                           db      'N',0    ;Operador AND


    op_incial_test                           db      '1234567890123456',0
    op_reg_test                              db      '9876543210987654',0
    caracter                                 db      '1',0
    uno                                 db      '1',0
    contador_caracter                        dq       0
    contador_caracter2                       dq       0
    mensaje_chars_uno                        db      'Hay %lli unos en el string.',0

 

	;*** Mensajes para debug
	msj_inicio                       db "Iniciando...",0
	msj_apertura_ok                  db " *** Se ha abierto el archivo exitosamente *** ",10,0
    msj_cierre_ok                    db " *** Se ha cerrado el archivo exitosamente *** ",10,0
	msj_guarde_operando_inicial      db " - Operando inicial guardado - ",0
	msj_leyendo     	             db	"leyendo...",0
    imprimo_operando_inicial         db  "-Operando inicial ingresado: %s",10,0
    msj_resultado                    db  "-Resultado parcial:          %s",10,0
    msj_imprimo_operando_archivo     db  "-Operando del archivo:       %s",10,0
    msj_imprimo_operador             db  "-Operador del archivo:       %s",10,0
    msj_tengo_x                      db "-Operacion a realizar:       X (XOR)",0
    msj_tengo_o                      db "-Operacion a realizar:       O (OR)",0
    msj_tengo_n                      db "-Operacion a realizar:       N (AND)",0
    msj_problema                     db "Problema...",0
    msj_operando_aux                 db  "-Operando auxiliar: %s",10,0



    ; Registro del archivo:  (POR ALGUNA RAZON ESTO TIENE QUE IR ABAJO DE TODO EL SECTION DATA, SINO SE GUARDA LA SIG LINEA TAMBIEN)
    registro                    times   0   db  ''
        operando_archivo        times   16  db  ' '   ; -Operando (16 digitos)
        operador                times	1	db ' '     ; -Operador (1 digito). 1Byte. 8Bits
        ;EOL			            times	1	db ' '	;Byte para guardar el fin de linea q está en el archivo
        ;ZERO_BINA		        times	1	db ' '	;Byte para guardar el 0 binario que agrega la fgets
    ;

section     .bss  ; Variables sin valor inicial
    operando_inicial            resb    50
    dato_valido		            resb	1
    operando_inicial_valido     resb    1
    ;registro_test		resb	17
    registro_valido             resb    1
    aux_operando                resb    50

section     .text

main:

; volver_a_solicitar:
    call    solicitar_operando_inicial
;    call    validar_operando_inicial
;    cmp     byte[dato_valido],'N'
;    je      volver_a_solicitar


    call    abrir_archivo
    cmp     qword[handle_datos],0    ; Error de apertura?
    jle     error_al_abrir_archivo
mov		rcx,msj_apertura_ok  ; printf - Apertura Listado ok.
sub		rsp,32
call	puts
add		rsp,32

mov     rcx,imprimo_operando_inicial
mov     rdx,operando_inicial
sub     rsp,32
call    printf
add     rsp,32

    call    leer_archivo


 fin_de_programa:
ret  ; Ret main




;******************FUNCIONES********************
abrir_archivo:
    ;Abro archivo listado. Retorno 
    mov		rcx,archivo_datos
    mov     rdx,modo_apertura_datos 
	sub		rsp,32
    call	fopen
	add		rsp,32

    mov     qword[handle_datos],rax
    ret  ; Ret abrir_archivo


solicitar_operando_inicial:
    ; --- Solicito ingreso del "Operando inicial" ---
    ;Printf mensaje de ingreso de operando
    mov     rcx,msj_ingresar_operando_inicial
    sub     rsp,32
    call    printf
    add     rsp,32

    ;Gets recibe la cadena operando
    mov     rcx,0   ;Esto lo agregue dsp, si se rompe sacar.
    mov     rcx,operando_inicial
    sub     rsp,32
    call    gets
    add     rsp,32
   
    ret

validar_operando_inicial:
    ; --- Valido el operador ingresado --- 
    mov     byte[operando_inicial_valido],'N'

    call    validar_long_op_inicial   ; Que tenga 16 digitos
    cmp     byte[dato_valido],'N'
    je      fin_validar_op_inicial

    call    validar_digitos   ; Que sea binario (1 o 0)
    cmp     byte[dato_valido],'N'
    je      fin_validar_op_inicial

    mov     byte[operando_inicial_valido],'S'

     fin_validar_op_inicial:
    ret  ; ret del validar_operador_inicial


validar_long_op_inicial:
    ; --- Validar longitud de operador inicial ---
    mov     qword[long_input_op_inicial],0
    mov     byte[dato_valido],'S'

    mov     rsi,0 ; rsi es un registro indice. Lo inicializo en 0. Podriamos usar el rsi como contador de long_texto. Pero para el ejemplo mejor no.
     comp_caracter:
    cmp     byte[operando_inicial + rsi],0 ; 
    je      fin_string ; Salta a la etiqueta fin_string si cmp da 0, osea si llegue al final.
    inc     qword[long_input_op_inicial]  ; long_input_op_inicial++  . Hace falta "recordarle" a assembler que es un quad. qword = 8 bytes = quad.

    inc     rsi 
    jmp     comp_caracter
     fin_string:

;   *** Fin de recorrido (ida) ***

    cmp     qword[long_input_op_inicial],16
    je      fin_validar_long_op_inicial

    mov     byte[dato_valido],'N'
; DEBUG
mov     rcx,msj_long_input_invalido
mov     rdx,[long_input_op_inicial]
sub     rsp,32
call    printf
add     rsp,32

     fin_validar_long_op_inicial:
    ret


validar_digitos:
    ; --- Validar digitos ---
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

mov		rcx,msj_operador_inicial_digito_invalido  ; printf - El operador inicial ingresado tiene digitos que no son (1 o 0).
sub		rsp,32
call	puts
add		rsp,32


    fin_validar_operador_inicial:
    ret  ;  ret del validar_digitos


leer_archivo:
    ;Se encarga de leer el archivo e ir actualizando la matriz con los datos que va hallando.
 leer_registro:
    mov     rcx,0   ;Esto lo agregue dsp, si se rompe sacar.
    mov     rcx,registro            ;Param 1: dir area de memoria donde va a copiar.
    mov     rdx,17                  ;Param 2: longitud del registro. Osea de lo que va a recibir. 2bytes para los dos chars del dia, 1byte para la semana y 20 para la descripcion.
    mov     r8,1                    ;Param 3: Cantidad de registros. En realidad creo que es de a cuantos bytes tiene que leer. De a uno. uno por uno.
    mov     r9,qword[handle_datos]

    sub     rsp,32
    call    fread                   ; Leo registro. Devuelve en rax la cantidad de bytes leidos. El fread se encarga de avanzar las lineas a leer, no hace falta decir que lea la prox linea o algo asi,
    add     rsp,32 

    cmp     rax,0                   ; El rax va a tener 0 cuando el fread lea un linea vacia. Osea el fin del archivo.
    jle     cerrar_archivos                     ; EOF

mov 	rcx,msj_leyendo
sub		rsp,32
call	puts  
add		rsp,32

    ; ******* ESTO DE VALIDAR NO HACE FALTA CREO ***********
    call    validar_registro                  ; Rutina interna para validar si la linea leida es valida. Devuelve 'S' en la variable "esValid" en caso de valido, y 'N' en caso contrario.
    cmp     byte[registro_valido],'S'         ; Si el registro no es valido, ignorarlo y leer el proximo.
    jne     leer_registro            ; El fread se encarga de avanzar las lineas a leer, no hace falta decir que lea la prox linea o algo asi. Asi que mandamos a leer denuevo asi noma


mov     rcx,msj_imprimo_operando_archivo
mov     rdx,operando_archivo
sub     rsp,32
call    printf
add     rsp,32   

;mov     rcx,msj_imprimo_operador
;mov     rdx,operador
;sub     rsp,32
;call    printf
;add     rsp,32   

        ; YA TENGO LOS DATOS NECESARIOS. ACA DEBERIA HACER LA OPERACION.

    mov     al,[operador]
    cmp     al,[opr_xor]
    je      hacer_xor
    cmp     al,[opr_or]
    je      hacer_or
    cmp     al,[opr_and]
    je      hacer_and

jmp     cerrar_archivos  ; Si no encotrne letra valida, cierro todo.

hacer_xor:
mov		rcx,msj_tengo_x  
sub		rsp,32
call	puts
add		rsp,32
    call    operacion_xor
    jmp     next

hacer_or:
mov		rcx,msj_tengo_o 
sub		rsp,32
call	puts
add		rsp,32
    call    operacion_or
    jmp     next

hacer_and:
mov		rcx,msj_tengo_n 
sub		rsp,32
call	puts
add		rsp,32
    call    operacion_and
    jmp     next


next:
    jmp     leer_registro            ; Volvemo a leer la siguiente linea 

cerrar_archivos:
    mov     rcx,[handle_datos]
	sub		rsp,32
    call    fclose
	add		rsp,32
    mov		rcx,msj_cierre_ok  ; printf - Cierre de archivo ok.
    sub		rsp,32
    call	puts
    add		rsp,32
    ret

    
operacion_and:
    mov     rsi,0 ; rsi es un registro indice. Lo inicializo en 0.
    cmp_char_and:
    cmp     byte[operando_inicial + rsi],0 
    je      fin_str_and ; Salta a la etiqueta fin_string si cmp da 0, osea si llegue al final.

    ; Ahora realizo la operacion entre las cadenas[i] de ambos operandos y copio su resultado en un auxiliar (el cual luego pisara el operando inicial)
    mov     al,[operando_inicial + rsi] 
    mov     bl,[operando_archivo + rsi]
    and     al,bl 
    mov     [aux_operando + rsi],al

    inc     rsi ; rsi++
    jmp     cmp_char_and 

    fin_str_and:
    ; Ahora tengo que pisar el contenido de operando_inicial con el aux_operando. Porque hay que seguir iterando y realizando operaciones luego.
;    mov     rcx,msj_operando_aux
;    mov     rdx,aux_operando  
;    sub     rsp,32
;    call    printf
;    add     rsp,32
    ; Piso el contenido de operando_inicio con el de aux_operando
    mov     rcx,16                 ;Indico cuandos bytes tengo que copiar
    lea     rsi,[aux_operando]     ; Origen
    lea     rdi,[operando_inicial] ; Destino
    rep     movsb
    mov     rcx,msj_resultado
    mov     rdx,operando_inicial  
    sub     rsp,32
    call    printf
    add     rsp,32

    ret ; Ret del operacion_and

operacion_or:
    mov     rsi,0 ; rsi es un registro indice. Lo inicializo en 0.
    cmp_char_or:
    cmp     byte[operando_inicial + rsi],0 
    je      fin_str_or ; Salta a la etiqueta fin_string si cmp da 0, osea si llegue al final.

    ; Ahora realizo la operacion entre las cadenas[i] de ambos operandos y copio su resultado en un auxiliar (el cual luego pisara el operando inicial)
    mov     al,[operando_inicial + rsi] 
    mov     bl,[operando_archivo + rsi]
    or      al,bl 
    mov     [aux_operando + rsi],al

    inc     rsi ; rsi++
    jmp     cmp_char_or 

    fin_str_or:
    ; Ahora tengo que pisar el contenido de operando_inicial con el aux_operando. Porque hay que seguir iterando y realizando operaciones luego.
;    mov     rcx,msj_operando_aux
;    mov     rdx,aux_operando  
;    sub     rsp,32
;    call    printf
;    add     rsp,32
    ; Piso el contenido de operando_inicio con el de aux_operando
    mov     rcx,16                 ;Indico cuandos bytes tengo que copiar
    lea     rsi,[aux_operando]     ; Origen
    lea     rdi,[operando_inicial] ; Destino
    rep     movsb
    mov     rcx,msj_resultado
    mov     rdx,operando_inicial  
    sub     rsp,32
    call    printf
    add     rsp,32

    ret ; Ret del operacion_or


operacion_xor:
    mov     rsi,0 ; rsi es un registro indice. Lo inicializo en 0.
    cmp_char_xor:
    cmp     byte[operando_inicial + rsi],0 
    je      fin_str_xor ; Salta a la etiqueta fin_string si cmp da 0, osea si llegue al final.

    ; Ahora realizo la operacion entre las cadenas[i] de ambos operandos y copio su resultado en un auxiliar (el cual luego pisara el operando inicial)
    mov     al,[operando_inicial + rsi] 
    mov     bl,[operando_archivo + rsi]
    xor     al,bl 
    mov     [aux_operando + rsi],al

    inc     rsi ; rsi++
    jmp     cmp_char_xor 

    fin_str_xor:
    ; Ahora tengo que pisar el contenido de operando_inicial con el aux_operando. Porque hay que seguir iterando y realizando operaciones luego.
;    mov     rcx,msj_operando_aux
;    mov     rdx,aux_operando  
;    sub     rsp,32
;    call    printf
;    add     rsp,32
    ; Piso el contenido de operando_inicio con el de aux_operando
    mov     rcx,16                 ;Indico cuandos bytes tengo que copiar
    lea     rsi,[aux_operando]     ; Origen
    lea     rdi,[operando_inicial] ; Destino
    rep     movsb
    mov     rcx,msj_resultado
    mov     rdx,operando_inicial  
    sub     rsp,32
    call    printf
    add     rsp,32

    ret ; Ret del operacion_xor


validar_registro:
    mov    byte[registro_valido],'S' 

    ret

;--------------Mensajes de error-----------------
error_al_abrir_archivo:
	mov		rcx,msj_err_abrir_datos ; printf - Error en apertura de archivo de datos.
	sub		rsp,32
	call	puts
	add		rsp,32
	jmp		fin_de_programa

