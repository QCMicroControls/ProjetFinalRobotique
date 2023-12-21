
TraitementBuffer 

	movfw vTramePTRIn
	subwf vTramePTROut
	btfss SUBST
	goto Interruption

Case0 
	movfw 
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
	goto  
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame
	goto  
	
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
	goto  
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame
	goto  
	
LireCar3	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame1
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  

LireCar4	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame2
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  
	
LireCar5	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame3
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  
	
LireCar6	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame4
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  
	
LireCar7	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame5
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  
	
LireCar8	
	movfw vTramePTROut
	andlw 0x07
	addlw 0x20
	movwf FSR
	movfw INDF
	movwf vTrame6
	incf  vTramePTROut
	movlw 0x07
	andwf vTramePTROut
	incf  vIndiceTrame
	movlw 0x07
	andwf vIndiceTrame,f
	goto  