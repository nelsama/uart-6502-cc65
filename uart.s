;
; UART.S - Librería UART optimizada para 6502
; Compatible con cc65 - Mantiene misma API que uart.h
;
; Mapa de memoria UART:
;   $C020 - DATA (RX_DATA lectura / TX_DATA escritura)
;   $C021 - STATUS (lectura) / CONTROL (escritura)
;   $C022 - BAUD_LO (divisor de baudrate byte bajo)
;   $C023 - BAUD_HI (divisor de baudrate byte alto)
;

    .setcpu     "6502"
    .smart      on
    .autoimport on
    .case       on

    .export     _uart_init
    .export     _uart_putc
    .export     _uart_getc
    .export     _uart_rx_ready
    .export     _uart_tx_ready
    .export     _uart_puts
    .export     _uart_clear_errors
    .export     _uart_set_baudrate

; ---------------------------------------------------------------
; Constantes de hardware
; ---------------------------------------------------------------
UART_DATA       = $C020
UART_STATUS     = $C021
UART_CONTROL    = $C021
UART_BAUD_LO    = $C022
UART_BAUD_HI    = $C023

UART_TX_READY   = $01       ; Bit 0: Transmisor listo
UART_RX_VALID   = $02       ; Bit 1: Dato recibido disponible
UART_RESET_FLAGS = $80      ; Bit 7: Limpiar flags de error

.segment    "CODE"

; ---------------------------------------------------------------
; void uart_init(void)
; Inicializa UART, limpia flags de error
; ---------------------------------------------------------------
.proc _uart_init
    lda     #UART_RESET_FLAGS
    sta     UART_CONTROL
    lda     #$00
    sta     UART_CONTROL
    rts
.endproc

; ---------------------------------------------------------------
; void uart_putc(char c)
; Envía un carácter (bloqueante)
; Entrada: A = carácter a enviar
; ---------------------------------------------------------------
.proc _uart_putc
    pha                     ; Guardar carácter
@wait:
    lda     UART_STATUS
    and     #UART_TX_READY
    beq     @wait           ; Esperar TX listo
    pla                     ; Recuperar carácter
    sta     UART_DATA
    rts
.endproc

; ---------------------------------------------------------------
; char uart_getc(void)
; Recibe un carácter (bloqueante)
; Salida: A = carácter recibido
; ---------------------------------------------------------------
.proc _uart_getc
@wait:
    lda     UART_STATUS
    and     #UART_RX_VALID
    beq     @wait           ; Esperar dato disponible
    lda     UART_DATA
    ldx     #$00            ; cc65 espera resultado en A (low) y X (high)
    rts
.endproc

; ---------------------------------------------------------------
; uint8_t uart_rx_ready(void)
; Verifica si hay dato disponible
; Salida: A = 1 si hay dato, 0 si no
; ---------------------------------------------------------------
.proc _uart_rx_ready
    lda     UART_STATUS
    and     #UART_RX_VALID
    beq     @no_data
    lda     #$01
@no_data:
    ldx     #$00            ; cc65 espera resultado en A:X
    rts
.endproc

; ---------------------------------------------------------------
; uint8_t uart_tx_ready(void)
; Verifica si el transmisor está listo
; Salida: A = 1 si listo, 0 si no
; ---------------------------------------------------------------
.proc _uart_tx_ready
    lda     UART_STATUS
    and     #UART_TX_READY
    beq     @not_ready
    lda     #$01
@not_ready:
    ldx     #$00            ; cc65 espera resultado en A:X
    rts
.endproc

; ---------------------------------------------------------------
; void uart_puts(const char *str)
; Envía una cadena de texto terminada en null
; Entrada: A:X = puntero a cadena (low:high)
; ---------------------------------------------------------------
.proc _uart_puts
    sta     ptr1            ; Guardar puntero low
    stx     ptr1+1          ; Guardar puntero high
    ldy     #$00
@loop:
    lda     (ptr1),y        ; Leer carácter
    beq     @done           ; Si es null, terminar
    pha                     ; Guardar carácter
    ; Esperar TX listo
@wait_tx:
    lda     UART_STATUS
    and     #UART_TX_READY
    beq     @wait_tx
    pla                     ; Recuperar carácter
    sta     UART_DATA       ; Enviar
    iny                     ; Siguiente carácter
    bne     @loop           ; Si Y no overflow, continuar
    inc     ptr1+1          ; Incrementar página
    bne     @loop           ; Siempre salta (cadenas < 64KB)
@done:
    rts

    .importzp ptr1          ; Usar puntero de cc65 runtime
.endproc

; ---------------------------------------------------------------
; void uart_clear_errors(void)
; Limpia flags de error del UART
; ---------------------------------------------------------------
.proc _uart_clear_errors
    lda     #UART_RESET_FLAGS
    sta     UART_CONTROL
    lda     #$00
    sta     UART_CONTROL
    rts
.endproc

; ---------------------------------------------------------------
; void uart_set_baudrate(uint16_t divisor)
; Configura el divisor de baudrate
; Entrada: A:X = divisor (low:high)
; ---------------------------------------------------------------
.proc _uart_set_baudrate
    sta     UART_BAUD_LO    ; Guardar byte bajo del divisor
    stx     UART_BAUD_HI    ; Guardar byte alto del divisor
    rts
.endproc
