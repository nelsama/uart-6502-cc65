/**
 * UART.H - Librería UART para 6502 compatible con cc65
 * 
 * Mapa de memoria UART:
 *   $C020 - DATA (RX_DATA lectura / TX_DATA escritura)
 *   $C021 - STATUS (lectura) / CONTROL (escritura)
 *   $C022 - CONTROL_RD (lectura de flags de control)
 */

#ifndef UART_H
#define UART_H

#include <stdint.h>

/* Registros UART - Hardware FPGA */
#define UART_BASE       0xC020

#define UART_DATA       (*(volatile uint8_t *)(UART_BASE + 0x00))
#define UART_STATUS     (*(volatile uint8_t *)(UART_BASE + 0x01))
#define UART_CONTROL    (*(volatile uint8_t *)(UART_BASE + 0x01))
#define UART_CONTROL_RD (*(volatile uint8_t *)(UART_BASE + 0x02))

/* Bits del registro STATUS (lectura $C021) */
#define UART_TX_READY   0x01    /* Bit 0: Transmisor listo */
#define UART_RX_VALID   0x02    /* Bit 1: Dato recibido disponible */
#define UART_TX_BUSY    0x04    /* Bit 2: Transmisión en curso */
#define UART_RX_ERROR   0x08    /* Bit 3: Error de frame */
#define UART_RX_OVERRUN 0x10    /* Bit 4: Dato perdido */

/* Bits del registro CONTROL (escritura $C021) */
#define UART_TX_IRQ_EN  0x01    /* Bit 0: Habilitar IRQ TX listo */
#define UART_RX_IRQ_EN  0x02    /* Bit 1: Habilitar IRQ RX válido */
#define UART_RESET_FLAGS 0x80   /* Bit 7: Limpiar flags de error */

/* Funciones básicas */
void uart_init(void);
void uart_putc(char c);
char uart_getc(void);
uint8_t uart_rx_ready(void);
uint8_t uart_tx_ready(void);
void uart_puts(const char *str);
void uart_clear_errors(void);

#endif /* UART_H */
