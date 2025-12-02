/**
 * UART.C - Implementación UART para 6502
 */

#include "uart.h"

/**
 * Inicializar UART
 * Limpia flags de error y deshabilita interrupciones
 */
void uart_init(void) {
    UART_CONTROL = UART_RESET_FLAGS;  /* Limpiar errores */
    UART_CONTROL = 0x00;              /* Sin interrupciones */
}

/**
 * Verificar si hay dato recibido disponible
 */
uint8_t uart_rx_ready(void) {
    return (UART_STATUS & UART_RX_VALID) ? 1 : 0;
}

/**
 * Verificar si el transmisor está listo
 */
uint8_t uart_tx_ready(void) {
    return (UART_STATUS & UART_TX_READY) ? 1 : 0;
}

/**
 * Enviar un carácter (espera si TX ocupado)
 */
void uart_putc(char c) {
    /* Esperar hasta que TX esté listo */
    while (!(UART_STATUS & UART_TX_READY));
    UART_DATA = c;
}

/**
 * Recibir un carácter (espera si no hay dato)
 */
char uart_getc(void) {
    /* Esperar hasta que haya dato disponible */
    while (!(UART_STATUS & UART_RX_VALID));
    return UART_DATA;
}

/**
 * Enviar una cadena de texto
 */
void uart_puts(const char *str) {
    while (*str) {
        uart_putc(*str);
        str++;
    }
}

/**
 * Limpiar flags de error
 */
void uart_clear_errors(void) {
    UART_CONTROL = UART_RESET_FLAGS;
    UART_CONTROL = 0x00;
}
