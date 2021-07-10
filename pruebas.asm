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
    archivo_datos		        db	"datos.txt",0
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

	;*** Mensajes para debug
	msj_inicio                       db "Iniciando...",0
	msj_apertura_ok                  db " *** Se ha abierto el archivo exitosamente *** ",10,0
    msj_cierre_ok                    db " *** Se ha cerrado el archivo exitosamente *** ",10,0
	msj_guarde_operando_inicial      db " - Operando inicial guardado - ",0
	msj_leyendo     	             db	"leyendo...",0
    imprimo_operando_inicial         db  "-Operando inicial ingresado: %s",10,0
    msj_imprimo_operando_archivo     db  "-Operando del archivo: %s",10,0
    msj_imprimo_operador            db  "-Operador del archivo: %s",10,0

    msj_logico            db  "RESULTADO LOGICO: %i",10,0

    ; Registro del archivo:  (POR ALGUNA RAZON ESTO TIENE QUE IR ABAJO DE TODO EL SECTION DATA, SINO SE GUARDA LA SIG LINEA TAMBIEN)
    registro                    times   0   db  ''
        operando_archivo        times   16   db  ' '   ; -Operando (16 digitos)
        operador                times	1	db ' '     ; -Operador (1 digito)
        ;EOL			            times	1	db ' '	;Byte para guardar el fin de linea q está en el archivo
        ;ZERO_BINA		        times	1	db ' '	;Byte para guardar el 0 binario que agrega la fgets
    ;

section     .bss  ; Variables sin valor inicial
    operando_inicial            resb    500
    dato_valido		            resb	1
    operando_inicial_valido     resb    1
    ;registro_test		resb	17
    registro_valido             resb    1

    dato_a                      resb    1
    dato_b                      resb    1

section     .text

main:
    mov     al,0
    xor     al,0
    mov     [dato_a],al

mov     rcx,0
mov     rdx,0
mov     rcx,msj_logico
mov     rdx,[dato_a]
sub     rsp,32
call    printf
add     rsp,32   

ret