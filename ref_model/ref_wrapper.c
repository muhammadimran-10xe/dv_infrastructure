#include <stdio.h>
#include <stdint.h>
#include <veriuser.h>
#include "spi_lite.h"

// Shadow Registers: 0x00 to 0x70 (Approx 32 words)
static uint32_t shadow_regs[32];

// Help map addresses to array indices (0x68 -> index 26)
#define ADDR_TO_IDX(addr) ((addr) >> 2)

extern "C"
{

    // 1. Initialize the model state
    void dpi_model_init()
    {
        for (int i = 0; i < 32; i++)
            shadow_regs[i] = 0;

        // Set default hardware states
        // SPI_SR (0x64): Set TX_EMPTY (bit 2) and RX_EMPTY (bit 0) to 1
        shadow_regs[ADDR_TO_IDX(0x64)] = (1 << 2) | (1 << 0);

        printf("[C-Model] SPI Lite Reference Model Initialized\n");
    }

    // 2. Handle AXI Writes (Updates shadow registers)
    void dpi_axi_write(uint32_t addr, uint32_t data)
    {
        uint32_t idx = ADDR_TO_IDX(addr);

        // Software Reset Logic (SRR @ 0x40)
        if (addr == 0x40 && data == 0x0000000A)
        {
            dpi_model_init();
            return;
        }

        // Standard Write
        shadow_regs[idx] = data;

        // If writing to DTR (0x68), clear TX_EMPTY in Status Reg (0x64)
        // to mimic hardware becoming "busy"
        if (addr == 0x68)
        {
            shadow_regs[ADDR_TO_IDX(0x64)] &= ~(1 << 2); // Clear TX_EMPTY
        }
    }

    // 3. Handle AXI Reads (Returns data to SV Scoreboard)
    uint32_t dpi_axi_read(uint32_t addr)
    {
        return shadow_regs[ADDR_TO_IDX(addr)];
    }

    // 4. Update MISO (Called when your SPI Slave Agent drives data)
    // This pushes data into the DRR (0x6C) for future AXI reads
    void dpi_update_miso(uint8_t miso_val)
    {
        shadow_regs[ADDR_TO_IDX(0x6C)] = (uint32_t)miso_val;

        // Update Status: Set RX_FULL (bit 1) and Clear RX_EMPTY (bit 0)
        shadow_regs[ADDR_TO_IDX(0x64)] |= (1 << 1);
        shadow_regs[ADDR_TO_IDX(0x64)] &= ~(1 << 0);

        // Set TX_EMPTY back to 1 (transfer finished)
        shadow_regs[ADDR_TO_IDX(0x64)] |= (1 << 2);
    }
}