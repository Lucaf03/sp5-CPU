#include <stdint.h>

// Definisco codici di errore semplici da vedere nei registri
#define SUCCESS 0
#define ERR_PATTERN_1 1  // Fallito test 0xAAAAAAAA
#define ERR_PATTERN_2 2  // Fallito test 0x55555555

int main() {
    uint32_t write_val;
    uint32_t read_val;

    // --- TEST 1: Pattern 1010... (0xAAAAAAAA) ---
    write_val = 0xAAAAAAAA;
    
    // 1. Scrittura in mstatus
    __asm__ volatile (
        "csrw mstatus, %0" 
        : 
        : "r" (write_val)
    );

    // 2. Lettura da mstatus
    __asm__ volatile (
        "csrr %0, mstatus" 
        : "=r" (read_val)
    );

    // 3. Verifica
    if (read_val != write_val) {
        return ERR_PATTERN_1; // Ritorna 1 in a0/x10
    }

    // --- TEST 2: Pattern 0101... (0x55555555) ---
    write_val = 0x55555555;

    __asm__ volatile (
        "csrw mstatus, %0" 
        : 
        : "r" (write_val)
    );

    __asm__ volatile (
        "csrr %0, mstatus" 
        : "=r" (read_val)
    );

    if (read_val != write_val) {
        return ERR_PATTERN_2; // Ritorna 2 in a0/x10
    }

    // Se arriviamo qui, entrambi i pattern sono stati scritti e riletti correttamente
    return SUCCESS; // Ritorna 0 in a0/x10
}
	
