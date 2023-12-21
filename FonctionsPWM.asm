;********************************SetPWMPCA9685**********************************
;       Nom de la fonction : SetPWMPCA9685                 
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
SetPWMPCA9685
     
     call    StartBitI2C
     ;;;;ECRIRE I2CPCA;;;;
     movlw   0x80
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;PREMIER REGISTRE DU MOTEUR;;;;
     movfw   vMoteur
     addwf   vMoteur,F
     addwf   vMoteur,F
     addwf   vMoteur,F
     movlw   0x06
     addwf   vMoteur,F
     movfw   vMoteur
     movwf   vChannel
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;DEBUT ONDE L;;;;
     movlw   0x00
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;DEBUT ONDE H;;;;
     movlw   0x00
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     ;;;;FIN ONDE H & L;;;;
     bcf     STATUS,C
     movlw   .0
     movwf   vPwmHigh
     movlw   .205
     addwf   vPwm,F
     btfsc   STATUS,C
     goto    PWMA1
     goto    PWMSUITE
PWMA1
     movlw   .1
     movwf   vPwmHigh
     goto    PWMSUITE  
PWMSUITE
     movfw   vPwm
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     
     movfw   vPwmHigh
     movwf   vWriteByte
     call    Ecrire8BitsI2C
     
     return

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
