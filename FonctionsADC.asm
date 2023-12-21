;****************************** LireCoord *************************************
;       Nom de la fonction : LireCoord                       
;       Auteur : C-O Lemelin                
;      Date de creation :                                  
;      Modification : 
;       Description :   Routine qui contient la lecture du module convertisseur 
;                       analogue/digital de la carte pic pour lire la coordonÃ©e
;                       X/Y
;
;
;       Fonctions appelees :            
;       ParamÃ¨tres d'entree :            
;       ParamÃ¨tres de sortie :            
;       Variables utilisees : 
;       Include :    
;       Equate :                   
;       #Define :                    
;                                               
;******************************************************************************
LireCoord

LectureX
     BANK1
     movlw     b'10111110' ;RA0-6 en sortie
     movwf     TRISA
     bsf       ANSEL, 1   ;RA1 en analogue
     BANK0
     bsf       PORTA, 0   ;RA0 a 1
     bcf       PORTA, 6   ;RA6 a 0
     
     call     LectureADC
     movfw     vADCHaut
     movwf     vADCX
     BANK1
     clrf      ANSEL
     BANK0

LectureY
     BANK1
     movlw     b'01111101' ;RA1-7 en sortie
     movwf     TRISA
     bsf       ANSEL, 0   ;RA0 en analogue
     BANK0
     bsf       PORTA, 1   ;RA1 a 1 
     bcf       PORTA, 7   ;RA7 a 0
     
     call      LectureADC
     movfw     vADCHaut
     movwf     vADCY
     BANK1
     clrf      ANSEL
     BANK0
     return
; fin routine LireCoord--------------------------------------------------------

;****************************** LirePince *************************************
;       Nom de la fonction : LirePince                       
;       Auteur : C-O Lemelin                
;      Date de creation :                                  
;      Modification : 
;       Description :   Routine qui contient la lecture du module convertisseur 
;                       analogue/digital de la carte pic pour le senseur de la
;                       pince, de faÃ§on Ã  vÃ©rifier l'acquisition d'un poix.
;
;       Fonctions appelees :            
;       ParamÃ¨tres d'entree :            
;       ParamÃ¨tres de sortie :            
;       Variables utilisees : 
;       Include :    
;       Equate :                   
;       #Define :                    
;                                               
;******************************************************************************
LirePince
     BANK1
     bsf       ANSEL, 2
     BANK0
     movlw     ADCPINCE
     movwf     vChannelAD
     call      LectureADC
     movfw     vADCHaut
     movwf     vPincePres
     BANK1
     clrf      ANSEL
     BANK0
     return
; fin routine LirePince------------------------------------------------------


;****************************** LireBalance *************************************
;       Nom de la fonction : LireBalance                       
;       Auteur : C-O Lemelin                
;      Date de creation :   19/12/2023                               
;      Modification : 
;       Description :   Routine qui contient la lecture du module convertisseur 
;                       analogue/digital de la carte pic pour lire le poid sur la 
;                       balance
;
;
;       Fonctions appelees :            
;       ParamÃ¨tres d'entree :            
;       ParamÃ¨tres de sortie :            
;       Variables utilisees : 
;       Include :    
;       Equate :                   
;       #Define :                    
;                                               
;******************************************************************************
LireBalance
     BANK1
     bsf       ANSEL, 2
     BANK0

     movlw     ADCBALANCE
     movwf     vChannelAD
     call      LectureADC
     movfw     vADCHaut
     movwf     vPincePres
     BANK1
     clrf      ANSEL
     BANK0
     return
; fin routine LireBalance------------------------------------------------------


;****************************** LectureADC *************************************
;       Nom de la fonction : LectureADC                       
;       Auteur : C-O Lemelin                
;      Date de creation : 15/12/                                  
;      Modification : 
;       Description :   Conversion analogue/digitale par la carte pic
;
;
;       Fonctions appelees :            
;       ParamÃ¨tres d'entree :            
;       ParamÃ¨tres de sortie :            
;       Variables utilisees : 
;       Include :    
;       Equate :                   
;       #Define :                    
;                                               
;******************************************************************************
LectureADC
     movlw   vChannelAD
     movwf   ADCON0
     call    Delai1mS
CONVERT 
     btfsc   ADCON0, GO_DONE ; Check if conversion is still in progress
     goto    CONVERT ; Wait for the previous conversion to finish
     bsf     ADCON0, GO_DONE ; Start the conversion
     nop   
     nop

; Wait for conversion to complete
WAIT    
     btfsc   ADCON0, GO_DONE ; Check if conversion is still in progress
     goto    WAIT ; Wait until the conversion is complete

; Retrieve ADC result
     movfw    ADRESH ; Move the high byte of the result to W
     movwf    vADCHaut ; Store it in a variable if needed
     movfw    ADRESL ; Move the low byte of the result to W
     movwf    vADCBas ; Store it in a variable if needed
     return

; fin routine LectureADC--------------------------------------------------------

