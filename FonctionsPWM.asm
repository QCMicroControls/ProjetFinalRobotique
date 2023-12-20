
;**************************  ResetPCA9685 ***********************************
;
;       Nom de la fonction : ResetPCA
;       Auteur :         
;       Date de creation :                          
;       Modification :  
;       Description :   Envoi un signal de reset à la carte PCA                           
;       Fonctions appelees :        
;       Paramètres d'entree :  
;       Paramètres de sortie :     
;       Variables utilisees : 
;       Include :     
;       Equate :              
;       #Define :       
;                                               
;******************************************************************************

ResetPCA9685
    call     StartBitI2C
    
    movfw    vDeviceAddrPCA
    movwf    vInputCharacter
    call     Ecrire8BitsI2C
    
    movfw    vResetInstructPCA
    movwf    vInputCharacter
    call     Ecrire8BitsI2C
    
    call     StopBitI2C
; fin routine ResetPCA9685---------------------------------------------------


;**************************  SetFreqPCA9685 ***********************************
;       Nom de la fonction : ResetPCA
;       Auteur :
;       Date de creation :
;       Modification :
;       Description :   Envoi un signal de reset à la carte PCA
;       Fonctions appelees :
;       Paramètres d'entree :
;       Paramètres de sortie :
;       Variables utilisees :
;       Include :
;       Equate :
;       #Define :
;
;******************************************************************************

SetFreqPCA9685

	movf	 vDeviceAddrPCA
	movwf	 vInputCharacter
	bcf	 vInputCharacter, 7
	call 	 StartBitI2C
	
	call 	 Ecrire8BitsI2C
	
	movlw	 0x00	;Register mode 1
	movwf	 vInputCharacter
	call	 Ecrire8BitsI2C
	
	movlw 	 0x10 	;OSC off
	movwf	 vInputCharacter
	call 	 Ecrire8BitsI2C
	
    movlw    0xFE   ;Register prescaler
    movwf    vInputCharacter
    call     Ecrire8BitsI2C

    movlw    0x79   ;50hz
    movwf    vInputCharacter
    call     Ecrire8BitsI2C
	
	
 	movlw    0x00   ;Register mode 1
    movwf    vInputCharacter
    call     Ecrire8BitsI2C

    movlw    0xA0   ;OSC on
    movwf    vInputCharacter
    call     Ecrire8BitsI2C
	return
;	fin routine	SetFreqPCA9685