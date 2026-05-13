/*
    Name 1: Aarav Lakdawala
    UTEID 1: ajl5265
*/

/***************************************************************/
/*                                                             */
/*   LC-3b Simulator - Lab 6                                   */
/*                                                             */
/*   EE 460N -- Spring 2013                                    */
/*   The University of Texas at Austin                         */
/*                                                             */
/***************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <queue>

/***************************************************************/
/*                                                             */
/* Files:  ucode        Microprogram file                      */
/*         isaprogram   LC-3b machine language program file    */
/*                                                             */
/***************************************************************/

/***************************************************************/
/* These are the functions you'll have to write.               */
/***************************************************************/
void FETCH_stage();
void DE_stage();
void AGEX_stage();
void MEM_stage();
void SR_stage();
/***************************************************************/
/* A couple of useful definitions.                             */
/***************************************************************/
#define TRUE 1
#define FALSE 0

/***************************************************************/
/* Use this to avoid overflowing 16 bits on the bus.           */
/***************************************************************/
#define Low16bits(x) ((x) & 0xFFFF)

/***************************************************************/
/* Definition of the control store layout.                     */
/***************************************************************/
#define CONTROL_STORE_ROWS 64

/***************************************************************/
/* Definition of bit order in control store word.              */
/***************************************************************/
/* control signals from the control store */
enum CS_BITS
{
    SR1_NEEDED,
    SR2_NEEDED,
    DRMUX,

    ADDR1MUX,
    ADDR2MUX1,
    ADDR2MUX0,
    LSHF1,
    ADDRESSMUX,
    SR2MUX,
    ALUK1,
    ALUK0,
    ALU_RESULTMUX,

    BR_OP,
    UNCOND_OP,
    TRAP_OP,
    BR_STALL,

    DCACHE_EN,
    DCACHE_RW,
    DATA_SIZE,

    DR_VALUEMUX1,
    DR_VALUEMUX0,
    LD_REG,
    LD_CC,
    NUM_CONTROL_STORE_BITS

} CS_BITS;

enum AGEX_CS_BITS
{

    AGEX_ADDR1MUX,
    AGEX_ADDR2MUX1,
    AGEX_ADDR2MUX0,
    AGEX_LSHF1,
    AGEX_ADDRESSMUX,
    AGEX_SR2MUX,
    AGEX_ALUK1,
    AGEX_ALUK0,
    AGEX_ALU_RESULTMUX,

    AGEX_BR_OP,
    AGEX_UNCOND_OP,
    AGEX_TRAP_OP,
    AGEX_BR_STALL,
    AGEX_DCACHE_EN,
    AGEX_DCACHE_RW,
    AGEX_DATA_SIZE,

    AGEX_DR_VALUEMUX1,
    AGEX_DR_VALUEMUX0,
    AGEX_LD_REG,
    AGEX_LD_CC,
    NUM_AGEX_CS_BITS
} AGEX_CS_BITS;

enum MEM_CS_BITS
{
    MEM_BR_OP,
    MEM_UNCOND_OP,
    MEM_TRAP_OP,
    MEM_BR_STALL,
    MEM_DCACHE_EN,
    MEM_DCACHE_RW,
    MEM_DATA_SIZE,

    MEM_DR_VALUEMUX1,
    MEM_DR_VALUEMUX0,
    MEM_LD_REG,
    MEM_LD_CC,
    NUM_MEM_CS_BITS
} MEM_CS_BITS;

enum SR_CS_BITS
{
    SR_DR_VALUEMUX1,
    SR_DR_VALUEMUX0,
    SR_LD_REG,
    SR_LD_CC,
    NUM_SR_CS_BITS
} SR_CS_BITS;

enum class PIPELINE_STAGE
{
    F,
    D,
    RS,
    E,
    M,
    W,
    R

};

/***************************************************************/
/* Functions to get at the control bits.                       */
/***************************************************************/
int Get_SR1_NEEDED(int *x) { return (x[SR1_NEEDED]); }
int Get_SR2_NEEDED(int *x) { return (x[SR2_NEEDED]); }
int Get_DRMUX(int *x) { return (x[DRMUX]); }
int Get_DE_BR_OP(int *x) { return (x[BR_OP]); }
int Get_ADDR1MUX(int *x) { return (x[AGEX_ADDR1MUX]); }
int Get_ADDR2MUX(int *x) { return ((x[AGEX_ADDR2MUX1] << 1) + x[AGEX_ADDR2MUX0]); }
int Get_LSHF1(int *x) { return (x[AGEX_LSHF1]); }
int Get_ADDRESSMUX(int *x) { return (x[AGEX_ADDRESSMUX]); }
int Get_SR2MUX(int *x) { return (x[AGEX_SR2MUX]); }
int Get_ALUK(int *x) { return ((x[AGEX_ALUK1] << 1) + x[AGEX_ALUK0]); }
int Get_ALU_RESULTMUX(int *x) { return (x[AGEX_ALU_RESULTMUX]); }
int Get_BR_OP(int *x) { return (x[MEM_BR_OP]); }
int Get_UNCOND_OP(int *x) { return (x[MEM_UNCOND_OP]); }
int Get_TRAP_OP(int *x) { return (x[MEM_TRAP_OP]); }
int Get_DCACHE_EN(int *x) { return (x[MEM_DCACHE_EN]); }
int Get_DCACHE_RW(int *x) { return (x[MEM_DCACHE_RW]); }
int Get_DATA_SIZE(int *x) { return (x[MEM_DATA_SIZE]); }
int Get_DR_VALUEMUX1(int *x) { return ((x[SR_DR_VALUEMUX1] << 1) + x[SR_DR_VALUEMUX0]); }
int Get_AGEX_LD_REG(int *x) { return (x[AGEX_LD_REG]); }
int Get_AGEX_LD_CC(int *x) { return (x[AGEX_LD_CC]); }
int Get_MEM_LD_REG(int *x) { return (x[MEM_LD_REG]); }
int Get_MEM_LD_CC(int *x) { return (x[MEM_LD_CC]); }
int Get_SR_LD_REG(int *x) { return (x[SR_LD_REG]); }
int Get_SR_LD_CC(int *x) { return (x[SR_LD_CC]); }
int Get_DE_BR_STALL(int *x) { return (x[BR_STALL]); }
int Get_AGEX_BR_STALL(int *x) { return (x[AGEX_BR_STALL]); }
int Get_MEM_BR_STALL(int *x) { return (x[MEM_BR_STALL]); }

/***************************************************************/
/* The control store rom.                                      */
/***************************************************************/
int CONTROL_STORE[CONTROL_STORE_ROWS][NUM_CONTROL_STORE_BITS];

/***************************************************************/
/* Main memory.                                                */
/***************************************************************/
/* MEMORY[A][0] stores the least significant byte of word at word address A
   MEMORY[A][1] stores the most significant byte of word at word address A
   There are two write enable signals, one for each byte. WE0 is used for
   the least significant byte of a word. WE1 is used for the most significant
   byte of a word. */

#define WORDS_IN_MEM 0x08000
int MEMORY[WORDS_IN_MEM][2];

/***************************************************************/
/* The LC-3b register file.                                      */
/***************************************************************/
#define LC3b_REGS 8
int REGS[LC3b_REGS];
/***************************************************************/
/* architectural state */
/***************************************************************/
int PC,    /* program counter */
    N,     /* n condition bit */
    Z = 1, /* z condition bit */
    P;     /* p condition bit */
/***************************************************************/
/* LC-3b State info.                                             */
/***************************************************************/

typedef struct PipeState_Entry_Struct
{

    /* DE latches */
    int DE_NPC,
        DE_IR,
        DE_V,
        /* RS latches */
        RS_NPC,
        RS_IR,
        RS_SR1,
        RS_SR1TAG,
        RS_SR1V,
        RS_SR2,
        RS_SR2TAG,
        RS_SR2V,
        RS_CC,
        RS_DRID,
        RS_DRTAG,
        RS_DRV,
        /* AGEX lateches */
        AGEX_NPC,
        AGEX_SR1,
        AGEX_SR2,
        AGEX_CC,
        AGEX_IR,
        AGEX_DRID,
        AGEX_V,
        AGEX_CS[NUM_AGEX_CS_BITS],
        /* MEM latches */
        MEM_NPC,
        MEM_ALU_RESULT,
        MEM_ADDRESS,
        MEM_CC,
        MEM_IR,
        MEM_DRID,
        MEM_V,
        MEM_CS[NUM_MEM_CS_BITS],
        /* SR latches */
        SR_NPC,
        SR_DATA,
        SR_ALU_RESULT,
        SR_ADDRESS,
        SR_IR,
        SR_DRID,
        SR_V,
        SR_CS[NUM_SR_CS_BITS];

} PipeState_Entry;

/* data structure for latch */
PipeState_Entry PS, NEW_PS;

int dep_stall,
    v_de_br_stall,
    v_de_prf_stall,
    v_rs_stall,
    v_rob_stall,
    v_agex_br_stall,
    v_mem_br_stall,
    mem_stall,
    icache_r;

typedef struct RAT
{
    int REGS_VAL;
    int TAG;
    bool R;

} RAT;

RAT RAT_FILE[8];

typedef struct PRF
{
    int VALUE;
    bool V;
    bool F;

} PRF;

PRF PRF_FILE[32];

typedef struct RS
{
    bool V_1;
    int TAG_1;
    int VALUE_1;
    bool V_2;
    int TAG_2;
    int VALUE_2;

} RS;

std::queue<RS> andRS_FILE; //4

void push_andRS_FILE(RS andRS)
{
    if(andRS_FILE.size() > 4)
    {
        v_rs_stall = 1;
    }
    else
    {
        andRS_FILE.push(andRS);
    }

}

std::queue<RS> xorRS_FILE; //4

void push_xorRS_FILE(RS xorRS)
{
    if(xorRS_FILE.size() > 4)
    {
        v_rs_stall = 1;
    }
    else
    {
        xorRS_FILE.push(xorRS);
    }

}

std::queue<RS> addRS_FILE; //8

void push_addRS_FILE(RS addRS)
{
    if(addRS_FILE.size() > 8)
    {
        v_rs_stall = 1;
    }
    else
    {
        addRS_FILE.push(addRS);
    }

} 

std::queue<RS> mulRS_FILE; //8

void push_mulRS_FILE(RS mulRS)
{
    if(mulRS_FILE.size() > 8)
    {
        v_rs_stall = 1;
    }
    else
    {
        mulRS_FILE.push(mulRS);
    }

} 

typedef struct ROB
{
    bool VALID;
    bool ISSUED;
    bool DONE;
    int IR;
    int NPC;
    int REG_NUM;
    int TAG;

} ROB;

std::queue<ROB> ROB_FILE; //32

void pushROB_FILE(ROB entryROB)
{
    if(ROB_FILE.size() > 32)
    {
        v_rob_stall = 1;
    }
    else
    {
        ROB_FILE.push(entryROB);
    }
}

void assignTag(int regNum)
{
    for(int i = 0; i < 32; i++)
    {
        if(PRF_FILE[i].F)
        {
            PRF_FILE[i].F = 0;
            RAT_FILE[regNum].R = 0;
            RAT_FILE[regNum].TAG = i;
            break;
        }
    }
    v_de_prf_stall = 1;
}

/* simulator signal */
int RUN_BIT;

/* Internal stall signals */


/***************************************************************/
/* A cycle counter.                                            */
/***************************************************************/
int CYCLE_COUNT;

/***************************************************************/
/*                                                             */
/* Procedure : help                                            */
/*                                                             */
/* Purpose   : Print out a list of commands.                   */
/*                                                             */
/***************************************************************/
void help()
{
    printf("----------------LC-3bSIM Help-------------------------\n");
    printf("go               -  run program to completion       \n");
    printf("run n            -  execute program for n cycles    \n");
    printf("mdump low high   -  dump memory from low to high    \n");
    printf("rdump            -  dump the architectural state    \n");
    printf("idump            -  dump the internal state         \n");
    printf("?                -  display this help menu          \n");
    printf("quit             -  exit the program                \n\n");
}

void print_CS(int *CS, int num)
{
    int ii;
    for (ii = 0; ii < num; ii++)
    {
        printf("%d", CS[ii]);
    }
    printf("\n");
}
/***************************************************************/
/*                                                             */
/* Procedure : cycle                                           */
/*                                                             */
/* Purpose   : Execute a cycle                                 */
/*                                                             */
/***************************************************************/
void cycle()
{
    NEW_PS = PS;
    SR_stage();
    MEM_stage();
    AGEX_stage();
    DE_stage();
    FETCH_stage();
    PS = NEW_PS;
    CYCLE_COUNT++;
}

/***************************************************************/
/*                                                             */
/* Procedure : run n                                           */
/*                                                             */
/* Purpose   : Simulate the LC-3b for n cycles.                */
/*                                                             */
/***************************************************************/
void run(int num_cycles)
{
    int i;

    if (RUN_BIT == FALSE)
    {
        printf("Can't simulate, Simulator is halted\n\n");
        return;
    }

    printf("Simulating for %d cycles...\n\n", num_cycles);
    for (i = 0; i < num_cycles; i++)
    {
        if (PC == 0x0000)
        {
            cycle();
            RUN_BIT = FALSE;
            printf("Simulator halted\n\n");
            break;
        }
        cycle();
    }
}

/***************************************************************/
/*                                                             */
/* Procedure : go                                              */
/*                                                             */
/* Purpose   : Simulate the LC-3b until HALTed.                 */
/*                                                             */
/***************************************************************/
void go()
{
    if ((RUN_BIT == FALSE) || (PC == 0x0000))
    {
        printf("Can't simulate, Simulator is halted\n\n");
        return;
    }
    printf("Simulating...\n\n");
    /* initialization */
    while (PC != 0x0000)
        cycle();
    cycle();
    RUN_BIT = FALSE;
    printf("Simulator halted\n\n");
}

/***************************************************************/
/*                                                             */
/* Procedure : mdump                                           */
/*                                                             */
/* Purpose   : Dump a region of memory to the output file.     */
/*                                                             */
/***************************************************************/
void mdump(FILE *dumpsim_file, int start, int stop)
{
    int address; /* this is a byte address */

    printf("\nMemory content [0x%04x..0x%04x] :\n", start, stop);
    printf("-------------------------------------\n");
    for (address = (start >> 1); address <= (stop >> 1); address++)
        printf("  0x%04x (%d) : 0x%02x%02x\n", address << 1, address << 1, MEMORY[address][1], MEMORY[address][0]);
    printf("\n");

    /* dump the memory contents into the dumpsim file */
    fprintf(dumpsim_file, "\nMemory content [0x%04x..0x%04x] :\n", start, stop);
    fprintf(dumpsim_file, "-------------------------------------\n");
    for (address = (start >> 1); address <= (stop >> 1); address++)
        fprintf(dumpsim_file, " 0x%04x (%d) : 0x%02x%02x\n", address << 1, address << 1, MEMORY[address][1], MEMORY[address][0]);
    fprintf(dumpsim_file, "\n");
    fflush(dumpsim_file);
}

/***************************************************************/
/*                                                             */
/* Procedure : rdump                                           */
/*                                                             */
/* Purpose   : Dump current architectural state  to the       */
/*             output file.                                    */
/*                                                             */
/***************************************************************/
void rdump(FILE *dumpsim_file)
{
    int k;

    printf("\nCurrent architectural state :\n");
    printf("-------------------------------------\n");
    printf("Cycle Count : %d\n", CYCLE_COUNT);
    printf("PC          : 0x%04x\n", PC);
    printf("CCs: N = %d  Z = %d  P = %d\n", N, Z, P);
    printf("Registers:\n");
    for (k = 0; k < LC3b_REGS; k++)
        printf("%d: 0x%04x\n", k, (RAT_FILE[k].REGS_VAL & 0xFFFF));
    printf("\n");

    /* dump the state information into the dumpsim file */
    fprintf(dumpsim_file, "\nCurrent architectural state :\n");
    fprintf(dumpsim_file, "-------------------------------------\n");
    fprintf(dumpsim_file, "Cycle Count : %d\n", CYCLE_COUNT);
    fprintf(dumpsim_file, "PC          : 0x%04x\n", PC);
    fprintf(dumpsim_file, "CCs: N = %d  Z = %d  P = %d\n", N, Z, P);
    fprintf(dumpsim_file, "Registers:\n");
    for (k = 0; k < LC3b_REGS; k++)
        fprintf(dumpsim_file, "%d: 0x%04x\n", k, (RAT_FILE[k].REGS_VAL & 0xFFFF));
    fprintf(dumpsim_file, "\n");
    fflush(dumpsim_file);
}

/***************************************************************/
/*                                                             */
/* Procedure : idump                                           */
/*                                                             */
/* Purpose   : Dump current internal state to the              */
/*             output file.                                    */
/*                                                             */
/***************************************************************/
void idump(FILE *dumpsim_file)
{
    int k;

    printf("\nCurrent architectural state :\n");
    printf("-------------------------------------\n");
    printf("Cycle Count     : %d\n", CYCLE_COUNT);
    printf("PC              : 0x%04x\n", PC);
    printf("CCs: N = %d  Z = %d  P = %d\n", N, Z, P);
    printf("Registers:\n");
    for (k = 0; k < LC3b_REGS; k++)
        printf("%d: 0x%04x\n", k, (RAT_FILE[k].REGS_VAL & 0xFFFF));
    printf("\n");

    printf("------------- Stall Signals -------------\n");
    printf("ICACHE_R        :  %d\n", icache_r);
    printf("DEP_STALL       :  %d\n", dep_stall);
    printf("V_DE_BR_STALL   :  %d\n", v_de_br_stall);
    printf("V_AGEX_BR_STALL :  %d\n", v_agex_br_stall);
    printf("MEM_STALL       :  %d\n", mem_stall);
    printf("V_MEM_BR_STALL  :  %d\n", v_mem_br_stall);
    printf("\n");

    printf("------------- DE   Latches --------------\n");
    printf("DE_NPC          :  0x%04x\n", PS.DE_NPC);
    printf("DE_IR           :  0x%04x\n", PS.DE_IR);
    printf("DE_V            :  %d\n", PS.DE_V);
    printf("\n");

    printf("------------- AGEX Latches --------------\n");
    printf("AGEX_NPC        :  0x%04x\n", PS.AGEX_NPC);
    printf("AGEX_SR1        :  0x%04x\n", PS.AGEX_SR1);
    printf("AGEX_SR2        :  0x%04x\n", PS.AGEX_SR2);
    printf("AGEX_CC         :  %d\n", PS.AGEX_CC);
    printf("AGEX_IR         :  0x%04x\n", PS.AGEX_IR);
    printf("AGEX_DRID       :  %d\n", PS.AGEX_DRID);
    printf("AGEX_CS         :  ");
    for (k = 0; k < NUM_AGEX_CS_BITS; k++)
    {
        printf("%d", PS.AGEX_CS[k]);
    }
    printf("\n");
    printf("AGEX_V          :  %d\n", PS.AGEX_V);
    printf("\n");

    printf("------------- MEM  Latches --------------\n");
    printf("MEM_NPC         :  0x%04x\n", PS.MEM_NPC);
    printf("MEM_ALU_RESULT  :  0x%04x\n", PS.MEM_ALU_RESULT);
    printf("MEM_ADDRESS     :  0x%04x\n", PS.MEM_ADDRESS);
    printf("MEM_CC          :  %d\n", PS.MEM_CC);
    printf("MEM_IR          :  0x%04x\n", PS.MEM_IR);
    printf("MEM_DRID        :  %d\n", PS.MEM_DRID);
    printf("MEM_CS          :  ");
    for (k = 0; k < NUM_MEM_CS_BITS; k++)
    {
        printf("%d", PS.MEM_CS[k]);
    }
    printf("\n");
    printf("MEM_V           :  %d\n", PS.MEM_V);
    printf("\n");

    printf("------------- SR   Latches --------------\n");
    printf("SR_NPC          :  0x%04x\n", PS.SR_NPC);
    printf("SR_DATA         :  0x%04x\n", PS.SR_DATA);
    printf("SR_ALU_RESULT   :  0x%04x\n", PS.SR_ALU_RESULT);
    printf("SR_ADDRESS      :  0x%04x\n", PS.SR_ADDRESS);
    printf("SR_IR           :  0x%04x\n", PS.SR_IR);
    printf("SR_DRID         :  %d\n", PS.SR_DRID);
    printf("SR_CS           :  ");
    for (k = 0; k < NUM_SR_CS_BITS; k++)
    {
        printf("%d", PS.SR_CS[k]);
    }
    printf("\n");
    printf("SR_V            :  %d\n", PS.SR_V);

    printf("\n");

    /* dump the state information into the dumpsim file */
    fprintf(dumpsim_file, "\nCurrent register/bus values :\n");
    fprintf(dumpsim_file, "\nCurrent architectural state :\n");
    fprintf(dumpsim_file, "-------------------------------------\n");
    fprintf(dumpsim_file, "Cycle Count     : %d\n", CYCLE_COUNT);
    fprintf(dumpsim_file, "PC              : 0x%04x\n", PC);
    fprintf(dumpsim_file, "CCs: N = %d  Z = %d  P = %d\n", N, Z, P);
    fprintf(dumpsim_file, "Registers:\n");
    for (k = 0; k < LC3b_REGS; k++)
        fprintf(dumpsim_file, "%d: 0x%04x\n", k, (RAT_FILE[k].REGS_VAL & 0xFFFF));
    fprintf(dumpsim_file, "\n");

    fprintf(dumpsim_file, "------------- Stall Signals -------------\n");
    fprintf(dumpsim_file, "ICACHE_R        :  %d\n", icache_r);
    fprintf(dumpsim_file, "DEP_STALL       :  %d\n", dep_stall);
    fprintf(dumpsim_file, "V_DE_BR_STALL   :  %d\n", v_de_br_stall);
    fprintf(dumpsim_file, "V_AGEX_BR_STALL :  %d\n", v_agex_br_stall);
    fprintf(dumpsim_file, "MEM_STALL       :  %d\n", mem_stall);
    fprintf(dumpsim_file, "V_MEM_BR_STALL  :  %d\n", v_mem_br_stall);
    fprintf(dumpsim_file, "\n");

    fprintf(dumpsim_file, "------------- DE   Latches --------------\n");
    fprintf(dumpsim_file, "DE_NPC          :  0x%04x\n", PS.DE_NPC);
    fprintf(dumpsim_file, "DE_IR           :  0x%04x\n", PS.DE_IR);
    fprintf(dumpsim_file, "DE_V            :  %d\n", PS.DE_V);
    fprintf(dumpsim_file, "\n");

    fprintf(dumpsim_file, "------------- AGEX Latches --------------\n");
    fprintf(dumpsim_file, "AGEX_NPC        :  0x%04x\n", PS.AGEX_NPC);
    fprintf(dumpsim_file, "AGEX_SR1        :  0x%04x\n", PS.AGEX_SR1);
    fprintf(dumpsim_file, "AGEX_SR2        :  0x%04x\n", PS.AGEX_SR2);
    fprintf(dumpsim_file, "AGEX_CC         :  %d\n", PS.AGEX_CC);
    fprintf(dumpsim_file, "AGEX_IR         :  0x%04x\n", PS.AGEX_IR);
    fprintf(dumpsim_file, "AGEX_DRID       :  %d\n", PS.AGEX_DRID);
    fprintf(dumpsim_file, "AGEX_CS         :  ");
    for (k = 0; k < NUM_AGEX_CS_BITS; k++)
    {
        fprintf(dumpsim_file, "%d", PS.AGEX_CS[k]);
    }
    fprintf(dumpsim_file, "\n");
    fprintf(dumpsim_file, "AGEX_V          :  %d\n", PS.AGEX_V);
    fprintf(dumpsim_file, "\n");

    fprintf(dumpsim_file, "------------- MEM  Latches --------------\n");
    fprintf(dumpsim_file, "MEM_NPC         :  0x%04x\n", PS.MEM_NPC);
    fprintf(dumpsim_file, "MEM_ALU_RESULT  :  0x%04x\n", PS.MEM_ALU_RESULT);
    fprintf(dumpsim_file, "MEM_ADDRESS     :  0x%04x\n", PS.MEM_ADDRESS);
    fprintf(dumpsim_file, "MEM_CC          :  %d\n", PS.MEM_CC);
    fprintf(dumpsim_file, "MEM_IR          :  0x%04x\n", PS.MEM_IR);
    fprintf(dumpsim_file, "MEM_DRID        :  %d\n", PS.MEM_DRID);
    fprintf(dumpsim_file, "MEM_CS          :  ");
    for (k = 0; k < NUM_MEM_CS_BITS; k++)
    {
        fprintf(dumpsim_file, "%d", PS.MEM_CS[k]);
    }
    fprintf(dumpsim_file, "\n");
    fprintf(dumpsim_file, "MEM_V           :  %d\n", PS.MEM_V);
    fprintf(dumpsim_file, "\n");

    fprintf(dumpsim_file, "------------- SR   Latches --------------\n");
    fprintf(dumpsim_file, "SR_NPC          :  0x%04x\n", PS.SR_NPC);
    fprintf(dumpsim_file, "SR_DATA         :  0x%04x\n", PS.SR_DATA);
    fprintf(dumpsim_file, "SR_ALU_RESULT   :  0x%04x\n", PS.SR_ALU_RESULT);
    fprintf(dumpsim_file, "SR_ADDRESS      :  0x%04x\n", PS.SR_ADDRESS);
    fprintf(dumpsim_file, "SR_IR           :  0x%04x\n", PS.SR_IR);
    fprintf(dumpsim_file, "SR_DRID         :  %d\n", PS.SR_DRID);
    fprintf(dumpsim_file, "SR_CS           :  ");
    for (k = 0; k < NUM_SR_CS_BITS; k++)
    {
        fprintf(dumpsim_file, "%d", PS.SR_CS[k]);
    }
    fprintf(dumpsim_file, "\n");
    fprintf(dumpsim_file, "SR_V            :  %d\n", PS.SR_V);

    fprintf(dumpsim_file, "\n");
    fflush(dumpsim_file);
}
/***************************************************************/
/*                                                             */
/* Procedure : get_command                                     */
/*                                                             */
/* Purpose   : Read a command from standard input.             */
/*                                                             */
/***************************************************************/
void get_command(FILE *dumpsim_file)
{
    char buffer[20];
    int start, stop, cycles;

    printf("LC-3b-SIM> ");

    scanf("%s", buffer);
    printf("\n");

    switch (buffer[0])
    {
    case 'G':
    case 'g':
        go();
        break;

    case 'M':
    case 'm':
        scanf("%i %i", &start, &stop);
        mdump(dumpsim_file, start, stop);
        break;

    case '?':
        help();
        break;
    case 'Q':
    case 'q':
        printf("Bye.\n");
        exit(0);

    case 'R':
    case 'r':
        if (buffer[1] == 'd' || buffer[1] == 'D')
            rdump(dumpsim_file);
        else
        {
            scanf("%d", &cycles);
            run(cycles);
        }
        break;

    case 'I':
    case 'i':
        idump(dumpsim_file);
        break;

    default:
        printf("Invalid Command\n");
        break;
    }
}

/***************************************************************/
/*                                                             */
/* Procedure : init_control_store                              */
/*                                                             */
/* Purpose   : Load microprogram into control store ROM        */
/*                                                             */
/***************************************************************/
void init_control_store(char *ucode_filename)
{
    FILE *ucode;
    int i, j, index;
    char line[200];

    printf("Loading Control Store from file: %s\n", ucode_filename);

    /* Open the micro-code file. */
    if ((ucode = fopen(ucode_filename, "r")) == NULL)
    {
        printf("Error: Can't open micro-code file %s\n", ucode_filename);
        exit(-1);
    }

    /* Read a line for each row in the control store. */
    for (i = 0; i < CONTROL_STORE_ROWS; i++)
    {
        if (fscanf(ucode, "%[^\n]\n", line) == EOF)
        {
            printf("Error: Too few lines (%d) in micro-code file: %s\n",
                   i, ucode_filename);
            exit(-1);
        }

        /* Put in bits one at a time. */
        index = 0;

        for (j = 0; j < NUM_CONTROL_STORE_BITS; j++)
        {
            /* Needs to find enough bits in line. */
            if (line[index] == '\0')
            {
                printf("Error: Too few control bits in micro-code file: %s\nLine: %d\n",
                       ucode_filename, i);
                exit(-1);
            }
            if (line[index] != '0' && line[index] != '1')
            {
                printf("Error: Unknown value in micro-code file: %s\nLine: %d, Bit: %d\n",
                       ucode_filename, i, j);
                exit(-1);
            }

            /* Set the bit in the Control Store. */
            CONTROL_STORE[i][j] = (line[index] == '0') ? 0 : 1;
            index++;
        }
        /* Warn about extra bits in line. */
        if (line[index] != '\0')
            printf("Warning: Extra bit(s) in control store file %s. Line: %d\n",
                   ucode_filename, i);
    }
    printf("\n");
}

/***************************************************************/
/*                                                             */
/* Procedure : init_memory                                     */
/*                                                             */
/* Purpose   : Zero out the memory array                       */
/*                                                             */
/***************************************************************/
void init_memory()
{
    int i;

    for (i = 0; i < WORDS_IN_MEM; i++)
    {
        MEMORY[i][0] = 0;
        MEMORY[i][1] = 0;
    }
}

/***************************************************************/
/*                                                             */
/* Procedure : init_state                                      */
/*                                                             */
/* Purpose   : Zero out all latches and registers              */
/*                                                             */
/***************************************************************/
void init_state()
{

    memset(&PS, 0, sizeof(PipeState_Entry));
    memset(&NEW_PS, 0, sizeof(PipeState_Entry));

    dep_stall = 0;
    v_de_br_stall = 0;
    v_agex_br_stall = 0;
    v_mem_br_stall = 0;
    mem_stall = 0;
}

/**************************************************************/
/*                                                            */
/* Procedure : load_program                                   */
/*                                                            */
/* Purpose   : Load program and service routines into mem.    */
/*                                                            */
/**************************************************************/
void load_program(char *program_filename)
{
    FILE *prog;
    int ii, word, program_base;

    /* Open program file. */
    prog = fopen(program_filename, "r");
    if (prog == NULL)
    {
        printf("Error: Can't open program file %s\n", program_filename);
        exit(-1);
    }

    /* Read in the program. */
    if (fscanf(prog, "%x\n", &word) != EOF)
        program_base = word >> 1;
    else
    {
        printf("Error: Program file is empty\n");
        exit(-1);
    }

    ii = 0;
    while (fscanf(prog, "%x\n", &word) != EOF)
    {
        /* Make sure it fits. */
        if (program_base + ii >= WORDS_IN_MEM)
        {
            printf("Error: Program file %s is too long to fit in memory. %x\n",
                   program_filename, ii);
            exit(-1);
        }

        /* Write the word to memory array. */
        MEMORY[program_base + ii][0] = word & 0x00FF;
        MEMORY[program_base + ii][1] = (word >> 8) & 0x00FF;
        ii++;
    }

    if (PC == 0)
        PC = program_base << 1;
    printf("Read %d words from program into memory.\n\n", ii);
}

/***************************************************************/
/*                                                             */
/* Procedure : initialize                                      */
/*                                                             */
/* Purpose   : Load microprogram and machine language program  */
/*             and set up initial state of the machine.        */
/*                                                             */
/***************************************************************/
void initialize(char *ucode_filename, char *program_filename, int num_prog_files)
{
    int i;
    init_control_store(ucode_filename);

    init_memory();

    for (i = 0; i < num_prog_files; i++)
    {
        load_program(program_filename);
        while (*program_filename++ != '\0')
            ;
    }
    init_state();

    RUN_BIT = TRUE;
}

/***************************************************************/
/*                                                             */
/* dcache_access                                               */
/*                                                             */
/***************************************************************/
void dcache_access(int dcache_addr, int *read_word, int write_word, int *dcache_r,
                   int mem_w0, int mem_w1)
{

    int addr = dcache_addr >> 1;
    int random = CYCLE_COUNT % 9;

    if (!random)
    {
        *dcache_r = 0;
        *read_word = 0xfeed;
    }
    else
    {
        *dcache_r = 1;

        *read_word = (MEMORY[addr][1] << 8) | (MEMORY[addr][0] & 0x00FF);
        if (mem_w0)
            MEMORY[addr][0] = write_word & 0x00FF;
        if (mem_w1)
            MEMORY[addr][1] = (write_word & 0xFF00) >> 8;
    }
}
/***************************************************************/
/*                                                             */
/* icache_access                                               */
/*                                                             */
/***************************************************************/

void icache_access(int icache_addr, int *read_word, int *icache_r)
{

    int addr = icache_addr >> 1;
    int random = CYCLE_COUNT % 13;

    if (!random)
    {
        *icache_r = 0;
        *read_word = 0xfeed;
    }
    else
    {
        *icache_r = 1;
        *read_word = MEMORY[addr][1] << 8 | MEMORY[addr][0];
    }
}
/***************************************************************/
/*                                                             */
/* Procedure : main                                            */
/*                                                             */
/***************************************************************/
int main(int argc, char *argv[])
{
    FILE *dumpsim_file;

    /* Error Checking */
    if (argc < 3)
    {
        printf("Error: usage: %s <micro_code_file> <program_file_1> <program_file_2> ...\n",
               argv[0]);
        exit(1);
    }

    printf("LC-3b Simulator\n\n");

    initialize(argv[1], argv[2], argc - 2);

    if ((dumpsim_file = fopen("dumpsim", "w")) == NULL)
    {
        printf("Error: Can't open dumpsim file\n");
        exit(-1);
    }

    while (1)
        get_command(dumpsim_file);
}

/***************************************************************/
/* Do not modify the above code.
   You are allowed to use the following global variables in your
   code. These are defined above.

   RUN_BIT
   REGS
   MEMORY

   PC
   N
   Z
   P

   dep_stall
   v_de_br_stall
   v_agex_br_stall
   v_mem_br_stall
   mem_stall
   icache_r

   PS
   NEW_PS


   You may define your own local/global variables and functions.
   You may use the functions to get at the control bits defined
   above.


   Begin your code here 	  			       */
/***************************************************************/
#define COPY_AGEX_CS_START 3
#define COPY_MEM_CS_START 9
#define COPY_SR_CS_START 7

int EXTRACT_BITS(int value, int shift_amount, int num_bits)
{
    // This dynamically creates the correct mask (e.g., if num_bits is 3, mask becomes 0x07)
    int mask = (1 << num_bits) - 1;

    return (value >> shift_amount) & mask;
}

int SEXT(int value, int num_bits)
{

    int sign_bit = (value >> (num_bits - 1)) & 1;
    value = value & ((1 << num_bits) - 1);
    if (sign_bit == 1)
    {
        int padding_mask = 0xFFFF << num_bits;
        value = value | padding_mask;
    }
    return value & 0xFFFF;
}

/* * Zero-extends an n-bit value to a 16-bit integer.
 * * Parameters:
 * value:    The number you want to zero extend.
 * num_bits: How many bits 'value' is SUPPOSED to be (e.g., 8).
 */
int ZEXT(int value, int num_bits)
{

    int mask = (1 << num_bits) - 1;
    return value & mask;
}

void update_ROB(int IR, bool Valid, bool Issued, bool Done, int NPC, int ArchReg, int Tag, PIPELINE_STAGE stage, bool delay) //slow but safe
{
    std::queue<ROB> tempROB_FILE;
    while (!ROB_FILE.empty()) {
        ROB val = ROB_FILE.front();
        ROB_FILE.pop();

        // --- EDIT LOGIC START ---
        // Example: Multiply even numbers by 10, leave others alone
        if(PIPELINE_STAGE::D == stage)
        {
            val.IR = IR;
            val.VALID = Valid;
            val.ISSUED = Issued;
            val.REG_NUM = ArchReg;
            val.TAG = Tag;
            if(!delay)
            {
                val.NPC = NPC;
            }
        }

        if(PIPELINE_STAGE::M == stage)
        {
            if(delay)
            {
                val.NPC = NPC; // No BP Yet
            }
            val.DONE = Done;
        }
        // --- EDIT LOGIC END ---

        tempROB_FILE.push(val);
    }

    while (!tempROB_FILE.empty()) {
        ROB_FILE.push(tempROB_FILE.front());
        tempROB_FILE.pop();
    }
}

/************************* ROB_stage() ************************/


void ROB_stage()
{
    ROB val = ROB_FILE.front();
    if(val.VALID && val.ISSUED && val.DONE)
    {
        
        RAT_FILE[val.REG_NUM].R = 1; // Mark RAT entry as retired
        PRF_FILE[val.TAG].F = 1; // Mark physical register as free
        ROB_FILE.pop(); // Remove from ROB
    }
}

/************************* SR_stage() *************************/

/* Signals generated by SR stage and needed by previous stages in the
   pipeline are declared below. */
int sr_reg_data,
    sr_n, sr_z, sr_p,
    v_sr_ld_cc,
    v_sr_ld_reg,
    sr_reg_id;

void SR_stage()
{

    /* You are given the code for SR_stage to get you started. Look at
       the figure for SR stage to see how this code is implemented. */

    switch (Get_DR_VALUEMUX1(PS.SR_CS))
    {
    case 0:
        sr_reg_data = PS.SR_ADDRESS;
        break;
    case 1:
        sr_reg_data = PS.SR_DATA;
        break;
    case 2:
        sr_reg_data = PS.SR_NPC;
        break;
    case 3:
        sr_reg_data = PS.SR_ALU_RESULT;
        break;
    }

    sr_reg_id = PS.SR_DRID;
    v_sr_ld_reg = Get_SR_LD_REG(PS.SR_CS) & PS.SR_V;
    v_sr_ld_cc = Get_SR_LD_CC(PS.SR_CS) & PS.SR_V;

    /* CC LOGIC  */
    sr_n = ((sr_reg_data & 0x8000) ? 1 : 0);
    sr_z = ((sr_reg_data & 0xFFFF) ? 0 : 1);
    sr_p = 0;
    if ((!sr_n) && (!sr_z))
        sr_p = 1;
}

/************************* MEM_stage() *************************/

int v_mem_ld_cc,
    target_pc,
    trap_pc,
    v_mem_ld_reg,
    mem_reg_id,
    mem_pcmux;

int MEM_ALU_RESULT_TO_DCACHE_DATA(int result, int datasize, int oddOrEven)
{
    if (datasize == 0) // byte
    {
        if (oddOrEven)
            return (result & 0x00FF) << 8;
        else
            return result & 0x00FF;
    }
    else // word
    {
        return result & 0xFFFF;
    }
}

int DCACHE_DATA_TO_SR_DATA(int dcache_data, int datasize, int oddOrEven)
{
    if (datasize == 0) // byte
    {
        if (oddOrEven)
            return SEXT((dcache_data & 0xFF00) >> 8, 8);
        else
            return SEXT(dcache_data & 0x00FF, 8);
    }
    else // word
    {
        return SEXT(dcache_data & 0xFFFF, 16);
    }
}

void WE_LOGIC(int mem_rw, int data_size, int address, int *mem_w0, int *mem_w1)
{
    if (mem_rw == 0) // read
    {
        *mem_w0 = 0;
        *mem_w1 = 0;
    }
    else // write
    {
        if (data_size == 0) // byte
        {
            if (address & 0x1) // odd
            {
                *mem_w0 = 0;
                *mem_w1 = 1;
            }
            else // even
            {
                *mem_w0 = 1;
                *mem_w1 = 0;
            }
        }
        else // word
        {
            *mem_w0 = 1;
            *mem_w1 = 1;
        }
    }
}

void MEM_BR_REG_CC_LOGIC()
{
    v_mem_br_stall = Low16bits(Get_MEM_BR_STALL(PS.MEM_CS) & PS.MEM_V);
    v_mem_ld_reg = Low16bits(Get_MEM_LD_REG(PS.MEM_CS) & PS.MEM_V);
    v_mem_ld_cc = Low16bits(Get_MEM_LD_CC(PS.MEM_CS) & PS.MEM_V);
}

void MEM_BR_LOGIC()
{
    int n_bit = Low16bits(EXTRACT_BITS(PS.MEM_IR, 11, 1));
    int z_bit = Low16bits(EXTRACT_BITS(PS.MEM_IR, 10, 1));
    int p_bit = Low16bits(EXTRACT_BITS(PS.MEM_IR, 9, 1));
    int n_cc_bit = Low16bits(EXTRACT_BITS(PS.MEM_CC, 2, 1));
    int z_cc_bit = Low16bits(EXTRACT_BITS(PS.MEM_CC, 1, 1));
    int p_cc_bit = Low16bits(EXTRACT_BITS(PS.MEM_CC, 0, 1));
    int ben = Low16bits(((n_bit && n_cc_bit) || (z_bit && z_cc_bit) || (p_bit && p_cc_bit)) ? 1 : 0);
    int condbr = Low16bits((ben & PS.MEM_V & Get_BR_OP(PS.MEM_CS) & ~mem_stall) ? 1 : 0);
    int uncondbr = Low16bits((PS.MEM_V & Get_UNCOND_OP(PS.MEM_CS) & ~mem_stall) ? 1 : 0);
    int mem_pc_mux0 = Low16bits((condbr || uncondbr) ? 1 : 0);
    int mem_pc_mux1 = Low16bits((Get_TRAP_OP(PS.MEM_CS) & PS.MEM_V & ~mem_stall) ? 1 : 0);
    mem_pcmux = Low16bits((mem_pc_mux1 << 1) | mem_pc_mux0);
}

void MEM_stage()
{

    int ii, jj = 0;
    int v_mem_dcache_en;
    int readdata = 0, writedata = 0;
    int we0, we1;
    int dcache_r;

    target_pc = Low16bits(PS.MEM_ADDRESS);
    v_mem_dcache_en = Low16bits(Get_DCACHE_EN(PS.MEM_CS)) & Low16bits(PS.MEM_V);
    writedata = Low16bits(MEM_ALU_RESULT_TO_DCACHE_DATA(PS.MEM_ALU_RESULT, Get_DATA_SIZE(PS.MEM_CS), PS.MEM_ADDRESS & 0x1));
    WE_LOGIC(Get_DCACHE_RW(PS.MEM_CS), Get_DATA_SIZE(PS.MEM_CS), PS.MEM_ADDRESS, &we0, &we1);
    if (v_mem_dcache_en)
    {
        dcache_access(PS.MEM_ADDRESS, &readdata, writedata, &dcache_r, we0, we1);
    }
    mem_stall = Low16bits(v_mem_dcache_en & (~dcache_r));
    NEW_PS.SR_DATA = Low16bits(DCACHE_DATA_TO_SR_DATA(readdata, Get_DATA_SIZE(PS.MEM_CS), PS.MEM_ADDRESS & 0x1));
    trap_pc = Low16bits(DCACHE_DATA_TO_SR_DATA(readdata, Get_DATA_SIZE(PS.MEM_CS), PS.MEM_ADDRESS & 0x1));
    MEM_BR_REG_CC_LOGIC();
    mem_reg_id = Low16bits(PS.MEM_DRID);
    MEM_BR_LOGIC();
    NEW_PS.SR_V = Low16bits(PS.MEM_V & (~mem_stall));

    /* your code for MEM stage goes here */

    /* The code below propagates the control signals from MEM.CS latch
       to SR.CS latch. You still need to latch other values into the
       other SR latches. */
    NEW_PS.SR_ADDRESS = Low16bits(PS.MEM_ADDRESS);
    for (ii = COPY_SR_CS_START; ii < NUM_MEM_CS_BITS; ii++)
    {
        NEW_PS.SR_CS[jj++] = PS.MEM_CS[ii];
    }
    NEW_PS.SR_NPC = Low16bits(PS.MEM_NPC);
    NEW_PS.SR_ALU_RESULT = Low16bits(PS.MEM_ALU_RESULT);
    NEW_PS.SR_IR = Low16bits(PS.MEM_IR);
    NEW_PS.SR_DRID = Low16bits(PS.MEM_DRID);
}

/************************* AGEX_stage() *************************/
int v_agex_ld_cc,
    v_agex_ld_reg,
    agex_reg_id;

void AGEX_BR_REG_CC_LOGIC()
{
    v_agex_br_stall = Low16bits(Get_AGEX_BR_STALL(PS.AGEX_CS) & PS.AGEX_V);
    v_agex_ld_reg = Low16bits(Get_AGEX_LD_REG(PS.AGEX_CS) & PS.AGEX_V);
    v_agex_ld_cc = Low16bits(Get_AGEX_LD_CC(PS.AGEX_CS) & PS.AGEX_V);
}

int ADDR1MUXFXN()
{
    return (Get_ADDR1MUX(PS.AGEX_CS) == 0) ? PS.AGEX_NPC : PS.AGEX_SR1;
}

int ADDR2MUXFXN()
{
    int addr2mux = Get_ADDR2MUX(PS.AGEX_CS);
    switch (addr2mux)
    {
    case 0:
        return 0;
    case 1:
        return SEXT(EXTRACT_BITS(PS.AGEX_IR, 0, 6), 6);
    case 2:
        return SEXT(EXTRACT_BITS(PS.AGEX_IR, 0, 9), 9);
    case 3:
        return SEXT(EXTRACT_BITS(PS.AGEX_IR, 0, 11), 11);
    default:
        return 0;
    }
}

int LSHF1FXN()
{
    return (Get_LSHF1(PS.AGEX_CS) == 1) ? (ADDR2MUXFXN() << 1) : ADDR2MUXFXN();
}

int ADDRESSMUXFXN()
{
    int addressmux_0 = ZEXT(EXTRACT_BITS(PS.AGEX_IR, 0, 8) << 1, 9);
    int addressmux_1 = Low16bits(ADDR1MUXFXN() + LSHF1FXN());
    return Low16bits((Get_ADDRESSMUX(PS.AGEX_CS) == 0) ? addressmux_0 : addressmux_1);
    // return Low16bits(ZERO_EXTEND((CURRENT_LATCHES.IR & mask(8)) << 1));
}

int SR2MUXFXN()
{
    return (Get_SR2MUX(PS.AGEX_CS) == 0) ? PS.AGEX_SR2 : SEXT(EXTRACT_BITS(PS.AGEX_IR, 0, 5), 5);
}

int SHF_val()
{
    int SR = PS.AGEX_SR1;
    int amount4 = EXTRACT_BITS(PS.AGEX_IR, 0, 4);
    if (EXTRACT_BITS(PS.AGEX_IR, 4, 1) == 0)
    {
        return Low16bits(SR << amount4);
    }
    else if (EXTRACT_BITS(PS.AGEX_IR, 5, 1) == 0)
    {
        return Low16bits(SR >> amount4);
    }
    else
    {
        // Arithmetic right shift
        if (SR & 0x8000) // If negative, fill with 1s
            return Low16bits((SR >> amount4) | (0xFFFF << (16 - amount4)));
        else // If positive, fill with 0s
            return Low16bits(SR >> amount4);
    }
}

int ALU_val()
{
    int SR1 = Low16bits(PS.AGEX_SR1);
    int SR2 = Low16bits(SR2MUXFXN());
    if (Get_ALUK(PS.AGEX_CS) == 0)
        return Low16bits(SR1 + SR2);
    else if (Get_ALUK(PS.AGEX_CS) == 1)
        return Low16bits(SR1 & SR2);
    else if (Get_ALUK(PS.AGEX_CS) == 2)
        return Low16bits(SR1 ^ SR2);
    else
        return Low16bits(SR2); // Pass through
}

int ALURESULTMUX()
{
    int alu_resultmux_1 = ALU_val();
    int alu_resultmux_0 = SHF_val();
    return Low16bits((Get_ALU_RESULTMUX(PS.AGEX_CS) == 0) ? alu_resultmux_0 : alu_resultmux_1);
}

void AGEX_stage()
{

    int ii, jj = 0;

    /* your code for AGEX stage goes here */
    agex_reg_id = Low16bits(PS.AGEX_DRID);
    AGEX_BR_REG_CC_LOGIC();

    int LD_MEM = !mem_stall; // We can latch into MEM stage if we're not stalling or if the MEM stage is not valid (i.e., we're stalling but it's a bubble)

    if (LD_MEM)
    {
        /* Your code for latching into MEM latches goes here */
        NEW_PS.MEM_ADDRESS = Low16bits(ADDRESSMUXFXN());

        /* The code below propagates the control signals from AGEX.CS latch
           to MEM.CS latch. */
        for (ii = COPY_MEM_CS_START; ii < NUM_AGEX_CS_BITS; ii++)
        {
            NEW_PS.MEM_CS[jj++] = PS.AGEX_CS[ii];
        }
        NEW_PS.MEM_NPC = Low16bits(PS.AGEX_NPC);
        NEW_PS.MEM_CC = Low16bits(PS.AGEX_CC);
        NEW_PS.MEM_ALU_RESULT = Low16bits(ALURESULTMUX());
        NEW_PS.MEM_IR = Low16bits(PS.AGEX_IR);
        NEW_PS.MEM_DRID = Low16bits(PS.AGEX_DRID);
        NEW_PS.MEM_V = PS.AGEX_V;
    }
    else
    {
        NEW_PS.MEM_ADDRESS = PS.MEM_ADDRESS; // Keep the same address if we're stalling
        /* The code below propagates the control signals from AGEX.CS latch
        to MEM.CS latch. */
        for (ii = 0; ii < NUM_MEM_CS_BITS; ii++)
        {
            NEW_PS.MEM_CS[ii] = PS.MEM_CS[ii]; // Keep the same control signals if we're stalling
        }
        NEW_PS.MEM_NPC = PS.MEM_NPC;               // Keep the same NPC if we're stalling
        NEW_PS.MEM_CC = PS.MEM_CC;                 // Keep the same CC if we're stalling
        NEW_PS.MEM_ALU_RESULT = PS.MEM_ALU_RESULT; // Keep the same ALU result if we're stalling
        NEW_PS.MEM_IR = PS.MEM_IR;                 // Keep the same IR if we're stalling
        NEW_PS.MEM_DRID = PS.MEM_DRID;             // Keep the same DRID if we're stalling
        NEW_PS.MEM_V = PS.MEM_V;                   // Keep the same valid bit if we're stalling
    }
}

/************************* DE_stage() *************************/
int CC = 2; // Default condition code is Z TALK TO TAS ABT THIS!!!
void V_DE_BR_STALL_LOGIC(int CONTROL_STORE_ADDRESS)
{
    v_de_br_stall = ((Get_DE_BR_STALL(CONTROL_STORE[CONTROL_STORE_ADDRESS]) && PS.DE_V) ? 1 : 0);
}

int SR2IDMUXFXN()
{
    return (EXTRACT_BITS(PS.DE_IR, 13, 1) == 0x1) ? EXTRACT_BITS(PS.DE_IR, 9, 3) : EXTRACT_BITS(PS.DE_IR, 0, 3);
}

void REG_FILE_LOGIC(int *sr1_id, int *sr2_id)
{
    int sr1_ids = EXTRACT_BITS(PS.DE_IR, 6, 3);
    int sr2_ids = SR2IDMUXFXN();
    *sr1_id = RAT_FILE[sr1_ids].REGS_VAL;
    *sr2_id = RAT_FILE[sr2_ids].REGS_VAL;
}

void REG_FILE_WRITEBACK()
{
    if (v_sr_ld_reg)
    {
        RAT_FILE[sr_reg_id].REGS_VAL = sr_reg_data;
    }
}

void setCC()
{
    if (v_sr_ld_cc)
    {
        N = sr_n;
        Z = sr_z;
        P = sr_p;
        CC = (N << 2) | (Z << 1) | P;
    }
}

int DRMUXFXN(int CONTROL_STORE_ADDRESS)
{
    return (Get_DRMUX(CONTROL_STORE[CONTROL_STORE_ADDRESS]) == 0) ? EXTRACT_BITS(PS.DE_IR, 9, 3) : 7;
}

void DEP_STALL_LOGIC(int CONTROL_STORE_ADDRESS)
{
    int sr1_needed = Get_SR1_NEEDED(CONTROL_STORE[CONTROL_STORE_ADDRESS]);
    int sr2_needed = Get_SR2_NEEDED(CONTROL_STORE[CONTROL_STORE_ADDRESS]);
    int sr1_id = EXTRACT_BITS(PS.DE_IR, 6, 3);
    int sr2_id = SR2IDMUXFXN();

    int allcc = (v_agex_ld_cc | v_mem_ld_cc | v_sr_ld_cc) ? 1 : 0;
    int controlHazard = (allcc & Get_DE_BR_OP(CONTROL_STORE[CONTROL_STORE_ADDRESS])) ? 1 : 0;

    Get_DE_BR_OP(CONTROL_STORE[CONTROL_STORE_ADDRESS]);
    int case1Agex = (sr1_needed & (v_agex_ld_reg) & ((sr1_id == agex_reg_id) ? 1 : 0)) ? 1 : 0;
    int case2Agex = (sr2_needed & (v_agex_ld_reg) & ((sr2_id == agex_reg_id) ? 1 : 0)) ? 1 : 0;
    int caseAgex = (case1Agex | case2Agex) ? 1 : 0;

    int case1Mem = (sr1_needed & (v_mem_ld_reg) & ((sr1_id == mem_reg_id) ? 1 : 0)) ? 1 : 0;
    int case2Mem = (sr2_needed & (v_mem_ld_reg) & ((sr2_id == mem_reg_id) ? 1 : 0)) ? 1 : 0;
    int caseMem = (case1Mem | case2Mem) ? 1 : 0;

    int case1Sr = (sr1_needed & (v_sr_ld_reg) & ((sr1_id == sr_reg_id) ? 1 : 0)) ? 1 : 0;
    int case2Sr = (sr2_needed & (v_sr_ld_reg) & ((sr2_id == sr_reg_id) ? 1 : 0)) ? 1 : 0;
    int caseSr = (case1Sr | case2Sr) ? 1 : 0;

    int dataHazard = (caseAgex | caseMem | caseSr) ? 1 : 0;
    dep_stall = ((controlHazard | dataHazard) & PS.DE_V) ? 1 : 0;
}

void DE_stage()
{

    int CONTROL_STORE_ADDRESS = (PS.DE_IR >> 11) << 1 | (PS.DE_IR >> 5) & 0x1; /* You need to implement the logic to
                      set the value of this variable. Look
                      at the figure for DE stage */
    int ii, jj = 0;
    int LD_AGEX = !mem_stall; /* You need to write code to compute the value of
            LD.AGEX signal */
    int sr1_id, sr2_id;
    V_DE_BR_STALL_LOGIC(CONTROL_STORE_ADDRESS);
    REG_FILE_LOGIC(&sr1_id, &sr2_id);
    DEP_STALL_LOGIC(CONTROL_STORE_ADDRESS);

    /* your code for DE stage goes here */

    if (LD_AGEX)
    {
        /* Your code for latching into AGEX latches goes here */

        /* The code below propagates the control signals from the CONTROL
           STORE to the AGEX.CS latch. */
        NEW_PS.AGEX_NPC = Low16bits(PS.DE_NPC);
        for (ii = COPY_AGEX_CS_START; ii < NUM_CONTROL_STORE_BITS; ii++)
        {
            NEW_PS.AGEX_CS[jj++] = CONTROL_STORE[CONTROL_STORE_ADDRESS][ii];
        }
        NEW_PS.AGEX_IR = Low16bits(PS.DE_IR);
        NEW_PS.AGEX_SR1 = Low16bits(sr1_id);
        NEW_PS.AGEX_SR2 = Low16bits(sr2_id);
        NEW_PS.AGEX_CC = Low16bits(CC);
        NEW_PS.AGEX_DRID = Low16bits(DRMUXFXN(CONTROL_STORE_ADDRESS));
        NEW_PS.AGEX_V = PS.DE_V & (~dep_stall);
    }
    else
    {
        NEW_PS.AGEX_NPC = Low16bits(PS.AGEX_NPC);
        NEW_PS.AGEX_IR = Low16bits(PS.AGEX_IR);
        NEW_PS.AGEX_SR1 = Low16bits(PS.AGEX_SR1);
        NEW_PS.AGEX_SR2 = Low16bits(PS.AGEX_SR2);
        NEW_PS.AGEX_CC = Low16bits(PS.AGEX_CC);
        NEW_PS.AGEX_DRID = Low16bits(PS.AGEX_DRID);
        for (ii = 0; ii < NUM_AGEX_CS_BITS; ii++)
        {
            NEW_PS.AGEX_CS[jj++] = PS.AGEX_CS[ii];
        }
        NEW_PS.AGEX_V = PS.AGEX_V;
    }
    REG_FILE_WRITEBACK();
    setCC();
}

/************************* FETCH_stage() *************************/
int LD_DE;
int LD_PC;

void DE_V_LOGIC()
{
    NEW_PS.DE_V = ((icache_r & ~v_agex_br_stall & ~v_de_br_stall & ~v_mem_br_stall)) ? 1 : 0; /* You need to write code to compute the value of
             DE.V signal */
}
void LD_DE_LOGIC()
{
    LD_DE = (!dep_stall & !mem_stall) ? 1 : 0; /* You need to write code to compute the value of
             LD.DE signal */
}

void LD_PC_LOGIC()
{
    int normal_fetch = (icache_r & (~v_agex_br_stall & ~mem_stall & ~dep_stall & ~v_de_br_stall & ~v_mem_br_stall)) ? 1 : 0; /* You need to write code to compute the value of
             LD.PC signal */
    int redirect = (mem_pcmux == 1 || mem_pcmux == 2) ? 1 : 0;
    LD_PC = (normal_fetch | redirect) ? 1 : 0;
}
void PC_LATCH()
{
    if (LD_DE)
    {
        NEW_PS.DE_NPC = Low16bits(PC + 2);
    }
    if (LD_PC)
    {
        switch (mem_pcmux)
        {
        case 0:
            PC = Low16bits(PC + 2);
            break;
        case 1:
            PC = Low16bits(target_pc);
            break;
        case 2:
            PC = Low16bits(trap_pc);
            break;
        default:
            break;
        }
    }
}
void FETCH_stage()
{
    int read_word;
    icache_access(PC, &read_word, &icache_r);
    LD_DE_LOGIC();
    LD_PC_LOGIC();
    PC_LATCH();
    DE_V_LOGIC();
    if (LD_DE)
    {
        NEW_PS.DE_IR = Low16bits(read_word);
    }
    else
    {
        NEW_PS.DE_IR = Low16bits(PS.DE_IR);
        NEW_PS.DE_NPC = Low16bits(PS.DE_NPC);
        NEW_PS.DE_V = PS.DE_V;
    }
    /* your code for FETCH stage goes here */
}
// BEFORE U TURN IN MAKE SURE BRACKETS ARE GOOD FOR ICACHE AND DCACHE 4/13/2026