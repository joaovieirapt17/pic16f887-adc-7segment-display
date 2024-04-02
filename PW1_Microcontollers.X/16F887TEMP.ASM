	list		p=16f887	; list directive to define processor
	#include	<p16f887.inc>	; processor specific variable definitions


; '__CONFIG' directive is used to embed configuration data within .asm file.
; The labels following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

	__CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	__CONFIG    _CONFIG2, _WRT_OFF & _BOR21V



;***** VARIABLE DEFINITIONS
show		EQU	0x79
var		EQU     0x7A
showL		EQU     0x7B
showR		EQU     0x7C
w_temp		EQU	0x7D		; variable used for context saving
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving


;**********************************************************************
ORG     0x000             ; processor reset vector
    nop
    goto    main              ; go to beginning of program


ORG     0x004             ; interrupt vector location
     
	movwf   w_temp            ; save off current W register contents
	movf	STATUS,w          ; move status register into W register
	movwf	status_temp       ; save off contents of STATUS register
	movf	PCLATH,w	  ; move pclath register into w register
	movwf	pclath_temp	  ; save off contents of PCLATH register

	
    ; External Interruption 1
    ISR_INT_EXTERNAL:
	btfss INTCON,INTF 
	goto end_int1
	bcf INTCON,INTF
	bsf ADCON0,GO 
    

    
    ; ADCON Interruption
    ISR_CONVERSION_ADC:
	btfss PIR1,ADIF ; check if the ADIF bit is set in ADCON1 register
	goto end_int2 ; If ADIF is not set, skip to the end of the ISR
	bcf PIR1,ADIF ; Clear ADIF bit in ADCON1

	movf ADRESH, W   ; ADC result to W
	movwf var        ; Store ADC result in var
	rrf var,f          ; Rotate right through carry
	bcf var, 7       ; Clear MSB of var
	movf var, W
	call TABLE       ; Convert to BCD
	movwf var	 ; Store BCD result in show
	
	;movlw b'00100101'
	;movwf show
	; Check '2.5V' value
	
	;subwf show, var; Compare with show
	sublw	b'00100101'
	btfss STATUS,Z   ; If result is zero, show equals 2.5V
	goto end_int2 ; result = 0
	movlw   b'00110101'
	movwf	var
	
    end_int2
	btfss INTCON,INTF
        goto ISR_INT_EXTERNAL
	bcf INTCON,INTF
        bsf ADCON0,GO
    
    end_int1
       RESTORE
       movf	pclath_temp,w	  
       movwf	PCLATH		  
       movf    status_temp,w      
       movwf	STATUS           
       swapf   w_temp,f
       swapf   w_temp,w		
       retfie                    


main
    ; ------ SETUP --------
    
    ; Set banks for configuration the registers
    bsf STATUS,RP1 ; select bank 2
    bsf STATUS,RP0 ; select bank 1
    
    ; Configure ADC (AN0 -> analog input | AN12 -> digital output)
    bsf	ANSEL,ANS0 ; set AN0 as analog input
    bcf	ANSELH, ANS12 ; set AN12 as digital output
    
    bsf	TRISB, TRISB0 ; define RB0/INT/AN12 pin as input
    
    bcf ANSELH,ANS12 ; clear AN12 pin configuration in ANSELH register
    
    bcf STATUS,RP1 ; 0
    bsf STATUS,RP0 ; 1 -> set BANK 1
	
    ; ------ Setup PORTC for output --------
    clrf TRISC ; set all bits in TRISC register to 0 (outputs)
    bcf STATUS,RP0 ; select BANK 0
    
    ; ------ Setup ADCON (ADC) --------
    BANKSEL ADCON0 ; select BANK for ADCON0 register
    movlw   b'00000001' ; move the value into W register
    movwf ADCON0 ; move value from W to ADCON0 register (enable ADC on CH0)

    ; ------ Setup Interrupt for ADC Conversion (ACON) --------
    bsf PIE1,ADIE ; enable ADC interrupt
    bcf PIR1,ADIF ; clear ADC interrupt flag
	
    ;Setup External Interrupt 
    BANKSEL PORTC ; BANK 0
    bcf INTCON, INTF
    ;INTF=0
    bsf INTCON, INTE
    ;INTE=1
    
    ;Enable Interrupts
    bsf INTCON, GIE
    ;GIE=1
    clrf var

loop 
    ; Show right display
    movf    var, W
    movwf   showR
    ;swapf   showR,f
    bsf	    showR,7
    bcf	    showR,6
    movf    showR, W
    movwf   PORTC
    
    
    ;Show left display
    movf    var, W
    movwf    showL
    swapf   showL,f
    bcf	    showL, 7
    bsf	    showL, 6
    movf    showL, W
    movwf   PORTC
    nop
    ; Delay 
    
goto loop
	
TABLE	
    addwf PCL,f
    retlw 0x0
    retlw 0x0
    retlw 0x1
    retlw 0x1
    retlw 0x2
    retlw 0x2
    retlw 0x2
    retlw 0x3
    retlw 0x3
    retlw 0x4
    retlw 0x4
    retlw 0x4
    retlw 0x5
    retlw 0x5
    retlw 0x5
    retlw 0x6
    retlw 0x6
    retlw 0x7
    retlw 0x7
    retlw 0x7
    retlw 0x8
    retlw 0x8
    retlw 0x9
    retlw 0x9
    retlw 0x9
    retlw 0x10
    retlw 0x10
    retlw 0x11
    retlw 0x11
    retlw 0x11
    retlw 0x12
    retlw 0x12
    retlw 0x13
    retlw 0x13
    retlw 0x13
    retlw 0x14
    retlw 0x14
    retlw 0x14
    retlw 0x15
    retlw 0x15
    retlw 0x16
    retlw 0x16
    retlw 0x16
    retlw 0x17
    retlw 0x17
    retlw 0x18
    retlw 0x18
    retlw 0x18
    retlw 0x19
    retlw 0x19
    retlw 0x20
    retlw 0x20
    retlw 0x20
    retlw 0x21
    retlw 0x21
    retlw 0x21
    retlw 0x22
    retlw 0x22
    retlw 0x23
    retlw 0x23
    retlw 0x23
    retlw 0x24
    retlw 0x24
    retlw 0x25
    retlw 0x25
    retlw 0x25
    retlw 0x26
    retlw 0x26
    retlw 0x27
    retlw 0x27
    retlw 0x27
    retlw 0x28
    retlw 0x28
    retlw 0x29
    retlw 0x29
    retlw 0x29
    retlw 0x30
    retlw 0x30
    retlw 0x30
    retlw 0x31
    retlw 0x31
    retlw 0x32
    retlw 0x32
    retlw 0x32
    retlw 0x33
    retlw 0x33
    retlw 0x34
    retlw 0x34
    retlw 0x34
    retlw 0x35
    retlw 0x35
    retlw 0x36
    retlw 0x36
    retlw 0x36
    retlw 0x37
    retlw 0x37
    retlw 0x38
    retlw 0x38
    retlw 0x38
    retlw 0x39
    retlw 0x39
    retlw 0x39
    retlw 0x40
    retlw 0x40
    retlw 0x41
    retlw 0x41
    retlw 0x41
    retlw 0x42
    retlw 0x42
    retlw 0x43
    retlw 0x43
    retlw 0x43
    retlw 0x44
    retlw 0x44
    retlw 0x45
    retlw 0x45
    retlw 0x45
    retlw 0x46
    retlw 0x46
    retlw 0x46
    retlw 0x47
    retlw 0x47
    retlw 0x48
    retlw 0x48
    retlw 0x48
    retlw 0x49
    retlw 0x49
    retlw 0x50

; example of preloading EEPROM locations

	ORG	0x2100
	DE	5, 4, 3, 2, 1

	END                       ; directive 'end of program'

