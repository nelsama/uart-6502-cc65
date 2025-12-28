# Librería UART para 6502

## Descripción

Librería para comunicación serial UART compatible con cc65. Implementada en **ensamblador optimizado** para el controlador UART en FPGA con velocidad fija de **115200 baud**.

## Archivos

- `uart.h` - Definiciones y prototipos (header C para compatibilidad)
- `uart.s` - Implementación optimizada en ensamblador (105 bytes)

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

- ✅ **Ensamblador optimizado** - Solo 105 bytes de código
- ✅ Modo polling (sin interrupciones)
- ✅ Velocidad: 115200 baud (fija en FPGA)
- ✅ 8 bits de datos, sin paridad, 1 bit de stop (8N1)
- ✅ Funciones bloqueantes y no bloqueantes
- ✅ Compatible con código C (usa el header uart.h)

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

## Compilación

### Compilar la librería

```bash
# Compilar uart.s a objeto
ca65 -t none -o uart.o uart.s
```

### Integración en Makefile

```makefile
# Directorios
LIBS_DIR = libs
UART_DIR = $(LIBS_DIR)/uart

# Archivo objeto
UART_OBJ = build/uart.o

# Regla para compilar uart (ensamblador)
$(UART_OBJ): $(UART_DIR)/uart.s
	ca65 -t none -o $@ $<

# Linkear con tu programa
mi_programa.bin: main.o $(UART_OBJ) vectors.o
	ld65 -C config/fpga.cfg -o $@ $^
```

### Estructura de proyecto recomendada

```
mi_proyecto/
├── libs/
│   └── uart/
│       ├── uart.s
│       └── uart.h
├── src/
│   └── main.c
├── config/
│   └── fpga.cfg
└── makefile
```

### Include en tu código

```c
// Desde src/main.c
#include "../libs/uart/uart.h"
```

## Compatibilidad

- ✅ cc65 compiler (ca65 assembler)
- ✅ API C89 estándar (via uart.h)
- ✅ 6502/65C02
- ✅ FPGA Tang Nano 9K

## Tamaño del código

| Función | Bytes |
|---------|-------|
| `uart_init` | 11 |
| `uart_putc` | 13 |
| `uart_getc` | 13 |
| `uart_rx_ready` | 12 |
| `uart_tx_ready` | 12 |
| `uart_puts` | 33 |
| `uart_clear_errors` | 11 |
| **Total** | **105** |
