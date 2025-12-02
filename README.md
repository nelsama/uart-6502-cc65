# Librería UART para 6502

## Descripción

Librería para comunicación serial UART compatible con cc65. Implementada para el controlador UART en FPGA con velocidad fija de **115200 baud**.

## Archivos

- `uart.h` - Definiciones y prototipos
- `uart.c` - Implementación (polling)

## Configuración de Hardware

```c
#define UART_BASE       0xC020  // Dirección base de registros UART en FPGA
```

**Registros UART:**
| Offset | Registro | Modo | Descripción |
|--------|----------|------|-------------|
| +0x00 | DATA | R/W | TX_DATA (escritura) / RX_DATA (lectura) |
| +0x01 | STATUS | R | Estado del UART |
| +0x01 | CONTROL | W | Control del UART |
| +0x02 | CONTROL_RD | R | Lectura de flags de control |

**Bits de STATUS (lectura):**
| Bit | Nombre | Descripción |
|-----|--------|-------------|
| 0 | TX_READY | Transmisor listo para enviar |
| 1 | RX_VALID | Dato recibido disponible |
| 2 | TX_BUSY | Transmisión en curso |
| 3 | RX_ERROR | Error de frame |
| 4 | RX_OVERRUN | Dato perdido (overrun) |

**Bits de CONTROL (escritura):**
| Bit | Nombre | Descripción |
|-----|--------|-------------|
| 0 | TX_IRQ_EN | Habilitar IRQ TX listo |
| 1 | RX_IRQ_EN | Habilitar IRQ RX válido |
| 7 | RESET_FLAGS | Limpiar flags de error |

## Características

- ✅ Modo polling (sin interrupciones)
- ✅ Velocidad: 115200 baud (fija en FPGA)
- ✅ 8 bits de datos, sin paridad, 1 bit de stop (8N1)
- ✅ Funciones bloqueantes y no bloqueantes

## Funciones

### Inicialización
```c
void uart_init(void);
```
Limpia flags de error y deshabilita interrupciones. **Llamar al inicio.**

### Transmisión
```c
void uart_putc(char c);          // Enviar un carácter (bloqueante)
void uart_puts(const char *str); // Enviar cadena de texto
uint8_t uart_tx_ready(void);     // Verificar si TX listo (no bloqueante)
```

### Recepción
```c
char uart_getc(void);            // Recibir un carácter (bloqueante)
uint8_t uart_rx_ready(void);     // Verificar si hay dato disponible
```

### Utilidades
```c
void uart_clear_errors(void);    // Limpiar flags de error
```

## Ejemplo de Uso

```c
#include "uart.h"

void main(void) {
    char c;
    
    // Inicializar UART
    uart_init();
    
    // Enviar mensaje
    uart_puts("Hola desde 6502!\r\n");
    
    // Enviar caracteres individuales
    uart_putc('O');
    uart_putc('K');
    uart_putc('\n');
    
    // Esperar y recibir un carácter
    c = uart_getc();
    
    // Verificar sin bloquear
    if (uart_rx_ready()) {
        c = uart_getc();
    }
}
```

## Uso para Debug

La UART es ideal para debug durante desarrollo:

```c
#include "uart.h"

void debug_hex(uint8_t val) {
    const char hex[] = "0123456789ABCDEF";
    uart_putc(hex[val >> 4]);
    uart_putc(hex[val & 0x0F]);
}

void main(void) {
    uint8_t status;
    
    uart_init();
    uart_puts("Debug: ");
    debug_hex(status);
    uart_puts("\r\n");
}
```

## Conexión

Conectar a PC con adaptador USB-Serial (3.3V o nivel TTL):

| FPGA Pin | Señal | PC |
|----------|-------|-----|
| TX | UART_TX | RX del adaptador |
| RX | UART_RX | TX del adaptador |
| GND | GND | GND del adaptador |

**Terminal:** 115200 baud, 8N1

## Notas Importantes

1. **Llamar `uart_init()` antes de usar otras funciones**
2. `uart_putc()` y `uart_getc()` son **bloqueantes** - esperan hasta completar
3. Usar `uart_tx_ready()` y `uart_rx_ready()` para operaciones no bloqueantes
4. La velocidad 115200 está fija en hardware FPGA

## Compatibilidad

- ✅ cc65 compiler
- ✅ C89 estándar
- ✅ 6502/65C02
- ✅ FPGA Tang Nano
