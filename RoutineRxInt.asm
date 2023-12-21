
TraitementBuffer 

	movfw vTramePTRIn
	subwf vTramePTROut,0
	btfss SUBST
	goto FinReceive

Case0 
	movlw 0x00
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case1
	goto LireCar1

Case1
	movlw 0x01
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case2
	goto LireCar2

Case2
	movlw 0x02
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case3
	goto LireCar3

Case3
	movlw 0x03
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case4
	goto LireCar4
	
Case4
	movlw 0x04
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case5
	goto LireCar5
	
Case5
	movlw 0x05
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case6
	goto LireCar6
	
Case6
	movlw 0x06
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case7
	goto LireCar7

Case7
	movlw 0x07
	subwf vIndiceTrame,W
	btfss SUBST
	goto Case1
	goto LireCar8

	
LireCar1	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vReceive
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	movlw 0x20
	movwf INDF
	movlw 0x47
	subwf vReceive
	btfss SUBST
	goto  FinReceive
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame
	goto  FinReceive
	
LireCar2	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vReceive
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	movlw 0x20
	movwf INDF
	movlw 0x4F
	subwf vReceive
	btfss SUBST
	goto  FinReceive
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame
	goto  FinReceive
	
LireCar3	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vBase
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  FinReceive

LireCar4	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vEpaule
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  FinReceive
	
LireCar5	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vCoude
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  FinReceive
	
LireCar6	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vPoignet
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  FinReceive
	
LireCar7	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vPince
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  FinReceive
	
LireCar8	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vMoteur6
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto FinReceive 

FinReceive
	return
