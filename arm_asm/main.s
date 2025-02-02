
 

.equ STDOUT, 1     @ Linux output console
.equ EXIT,   1     @ Linux syscall
.equ WRITE,  4     @ Linux syscall
.equ MAXI,   22

.data
sMessValeur:       .fill 11, 1, ' '            @ size => 11
szCarriageReturn: .asciz "\n"
sBlanc1:            .asciz " "
sBlanc2:            .asciz "  "
sBlanc3:            .asciz "   "

.bss  

.text
.global main 
main:                @ entry of program 
    push {fp,lr}      @ saves 2 registers 
    @ display first line
    mov r4,#0
1:    @ begin loop
    mov r0,r4
    ldr r1,iAdrsMessValeur     @ display value
    bl conversion10             @ call function
    mov r2,#0                      @ final zéro
    strb r2,[r1,r0]               @ on display value
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
    cmp r4,#10                     @ one or two digit in résult
    ldrgt r0,iAdrsBlanc2       @ two  display two spaces
    ldrle r0,iAdrsBlanc3       @ one  display 3 spaces
    bl affichageMess            @ display message
    add r4,#1                      @ increment counter
    cmp r4,#MAXI
    ble 1b                       @ loop
    ldr r0,iAdrszCarriageReturn   
    bl affichageMess            @ display carriage return
 
    mov r5,#1                   @ line counter
2:    @ begin loop lines
    mov r0,r5                      @ display column 1 with N° line
    ldr r1,iAdrsMessValeur     @ display value
    bl conversion10             @ call function
    mov r2,#0                      @ final zéro
    strb r2,[r1,r0]
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
    cmp r5,#10                      @ one or two digit in N° line
    ldrge r0,iAdrsBlanc2
    ldrlt r0,iAdrsBlanc3
    bl affichageMess  
    mov r4,#1                     @ counter column
3:  @ begin loop columns
    mul r0,r4,r5                   @ multiplication
    mov r3,r0                      @ save résult
    ldr r1,iAdrsMessValeur     @ display value
    bl conversion10             @ call function
    mov r2,#0
    strb r2,[r1,r0]
    ldr r0,iAdrsMessValeur
    bl affichageMess            @ display message
    cmp r3,#100                    @ 3 digits in résult ?
    ldrge r0,iAdrsBlanc1       @ yes, display one space
    bge 4f
    cmp r3,#10                     @ 2 digits in result
    ldrge r0,iAdrsBlanc2       @ yes display 2 spaces
    ldrlt r0,iAdrsBlanc3       @ no  display 3 spaces
4:
    bl affichageMess            @ display message
    add r4,#1                      @ increment counter column
    cmp r4,r5                      @ < counter lines
    ble 3b                        @ loop
    ldr r0,iAdrszCarriageReturn  
    bl affichageMess            @ display carriage return
    add r5,#1                      @ increment line counter
    cmp r5,#MAXI                  @ MAXI ?
    ble 2b                        @ loop
 
100:   @ standard end of the program 
    mov r0, #0                  @ return code
    pop {fp,lr}                 @restaur 2 registers
    mov r7, #EXIT              @ request to exit program
    svc #0                       @ perform the system call
 
iAdrsMessValeur:          .int sMessValeur
iAdrszCarriageReturn:	.int szCarriageReturn
iAdrsBlanc1:		.int sBlanc1
iAdrsBlanc2:		.int sBlanc2
iAdrsBlanc3:		.int sBlanc3

affichageMess:
    push {r0,r1,r2,r7,lr}      @ save  registres
    mov r2,#0                  @ counter length 
1:      @ loop length calculation 
    ldrb r1,[r0,r2]           @ read octet start position + index 
    cmp r1,#0                  @ if 0 its over 
    addne r2,r2,#1            @ else add 1 in the length 
    bne 1b                    @ and loop 
                                @ so here r2 contains the length of the message 
    mov r1,r0        			@ address message in r1 
    mov r0,#STDOUT      		@ code to write to the standard output Linux 
    mov r7, #WRITE             @ code call system "write" 
    svc #0                      @ call systeme 
    pop {r0,r1,r2,r7,lr}        @ restaur des  2 registres */ 
    bx lr                       @ return  

.equ LGZONECAL,   10
conversion10:
    push {r1-r4,lr}    @ save registers 
    mov r3,r1
    mov r2,#LGZONECAL
 
1:	   @ start loop
    bl divisionpar10U   @unsigned  r0 <- dividende. quotient ->r0 reste -> r1
    add r1,#48        @ digit	
    strb r1,[r3,r2]  @ store digit on area
    cmp r0,#0         @ stop if quotient = 0 */
    subne r2,#1      @ else previous position
    bne 1b	          @ and loop
    @ and move digit from left of area
    mov r4,#0
2:
    ldrb r1,[r3,r2]
    strb r1,[r3,r4]
    add r2,#1
    add r4,#1
    cmp r2,#LGZONECAL
    ble 2b
    @ and move spaces in end on area
    mov r0,r4     @ result length 
    mov r1,#' '   @ space	
3:
    strb r1,[r3,r4]  @ store space in area
    add r4,#1         @ next position
    cmp r4,#LGZONECAL
    ble 3b           @ loop if r4 <= area size
 
100:
    pop {r1-r4,lr}    @ restaur registres 
    bx lr             @return
 

divisionpar10U:
    push {r2,r3,r4, lr}
    mov r4,r0         @ save value
    mov r3,#0xCCCD   @ r3 <- magic_number  lower
    movt r3,#0xCCCC  @ r3 <- magic_number  upper
    umull r1, r2, r3, r0      @ r1<- Lower32Bits(r1*r0) r2<- Upper32Bits(r1*r0) 
    mov r0, r2, LSR #3      @ r2 <- r2 >> shift 3
    add r2,r0,r0, lsl #2     @ r2 <- r0 * 5 
    sub r1,r4,r2, lsl #1     @ r1 <- r4 - (r2 * 2)  = r4 - (r0 * 10)
    pop {r2,r3,r4,lr}
    bx lr                  @ leave function 
 
 
 
 
