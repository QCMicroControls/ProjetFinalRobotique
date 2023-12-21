;********************************SetPWMPCA9685**********************************
;       Nom de la fonction : SetPWMPCA9685                 
;       Auteur :         harold
;       Date de creation :                               
;       Description :   
;                                                       
;       Fonctions appelees :           
;       Paramètres d'entree :              
;       Paramètres de sortie :           
;       Variables utilisees :  
;       Include :    
;       Equate :                   
;       #Define :               
;                                               
;*******************************************************************************
SetPWMPCA9685
     
     ;Calcul Moteur
     bcf    CARRY
     rlf    vMoteur
     rlf    vMoteur
     movlw  .6
     addwf  vMoteur,f

     movlw 0x00
     movwf vPwmHi
     
     movfw vPwm
     addlw .205
     movwf vPwm
     btfsc CARRY
     incf vPwmHi,1
     
     ;�crire I2CPCA********************
     call StartBitI2C
     movlw 0x80
     movwf vWryteByte
     call Ecrire8BitsI2C     
	 
    ;Selectionne le moteur
     movfw vMoteur
     movwf vWryteByte
     call Ecrire8BitsI2C
     
     ;�crit 0 au d�but de l'onde H****
     movlw 0x00
     movwf vWryteByte
     call Ecrire8BitsI2C
     
     ;�crit 0 au d�but de l'onde B****
     movlw 0x00
     movwf vWryteByte
     call Ecrire8BitsI2C
     
     ;�crire 0xFinB******************* 
     movfw vPwm
     movwf vWryteByte
     call Ecrire8BitsI2C
     
     ;�crire 0xFinB*******************
     movfw vPwmHi
     movwf vWryteByte
     call Ecrire8BitsI2C
     
     call StopBitI2C  
     return
;Fin routine SetPWMPCA9685----------------------------------------------------

; fin routine SetPWMPCA9685------------------------------------------------------
;********************************SetFreqPCA9685*********************************
;       Nom de la fonction : SetFreqPCA9685                 
;       Auteur :         
;       Date de creation :                               
;       Description :   
;                                                       
;       Fonctions appelees :           
;       Paramètres d'entree :              
;       Paramètres de sortie :           
;       Variables utilisees :  
;       Include :    
;       Equate :                   
;       #Define :               
;                                               
;*******************************************************************************
SetFreqPCA9685
     
     call    StartBitI2C
     ;;;;ECRIRE I2CPCA;;;;
     movlw   0x80
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;REG MODE 1;;;;
     movlw   0x00
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;MODE SLEEP;;;;
     movlw   0x10
     movwf   vWriteByte
     call    Ecrire8BitsI2C 
     call    StopBitI2C
     
     call    StartBitI2C
     ;;;;ECRIRE I2CPCA;;;;
     movlw   0x80
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;REG PRESCALER;;;;
     movlw   0xFE
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;0X7C;;;;
     movlw   0x7C
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     call    StopBitI2C
     
     call    StartBitI2C
     ;;;;ECRIRE I2CPCA;;;;
     movlw   0x80
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;REG MODE 1;;;;
     movlw   0x00
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;FONCTIONNEMENT NORMAL;;;;
     movlw   0xA0
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     call    StopBitI2C
     
     return

; fin routine SetFreqPCA9685----------------------------------------------------
;********************************ResetPCA9685***********************************
;       Nom de la fonction : ResetPCA9685                 
;       Auteur :         
;       Date de creation :                               
;       Description :   
;                                                       
;       Fonctions appelees :           
;       Paramètres d'entree :              
;       Paramètres de sortie :           
;       Variables utilisees :  
;       Include :    
;       Equate :                   
;       #Define :               
;                                               
;*******************************************************************************
ResetPCA9685
     call    StartBitI2C
     movlw   0x80
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     movlw   0x00
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     
     movlw   0x06
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     
     call    StopBitI2C
     
     return

; fin routine ResetPCA9685------------------------------------------------------
