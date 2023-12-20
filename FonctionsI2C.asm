
;****************************** StartBitI2C ***********************************
;       Nom de la fonction : StartBitI2C                       
;       Auteur :                 
;      Date de creation :                                  
;      Modification : 
;       Description :   Routine d'initiation d'une communication serie I2C. 
;                       Doit être appelee à chaque debut d'operation.
;                       Le passage de 1 à 0 sur la ligne SDA durant
;                       un niveau 1 sur la ligne SCL initie un START BIT.
;                                                       
;       Fonctions appelees :            
;       Paramètres d'entree :            
;       Paramètres de sortie :            
;       Variables utilisees : 
;       Include :    
;       Equate :                   
;       #Define :                    
;                                               
;******************************************************************************
StartBitI2C
     call    SDA1
     call    SCL1
     call    SDA0
     call    SCL0
     return
; fin routine StartBitI2C------------------------------------------------------

;******************************* StopBitI2C ***********************************
;       Nom de la fonction : StopBitI2C                 
;       Auteur :         
;       Date de creation :                               
;       Description :   Routine de clôture d'une communication serie I2C.
;                       Doit être appelee à la fin de toutes operations.
;                       Passage de 0 à 1 sur la ligne SDA durant
;                       un niveau 1 sur la ligne SCL initie un STOP BIT.
;                                                       
;       Fonctions appelees :           
;       Paramètres d'entree :              
;       Paramètres de sortie :           
;       Variables utilisees :  
;       Include :    
;       Equate :                   
;       #Define :               
;                                               
;******************************************************************************
StopBitI2C
     call    SCL0    
     call    SDA0
     call    SCL1
     call    SDA1
     return

; fin routine StopBitI2C-------------------------------------------------------  

;******************************* Lire1BitI2C **********************************
;       Nom de la fonction : Lire1BitI2C                        
;       Auteur : champoux Xavier             
;       Date de creation :                           
;       Modification :  
;       Description :   Routine de reception d'un bit de communication I2C.
;                       La routine prend le bit de la ligne SDA après avoir 
;                       active la ligne SCL. Le bit de donnee est place 
;                       temporairement dans la variable ___________ et sera  
;                       reutilise dans la routine de traitement d'octets.
;                                                       
;       Fonctions appelees :          
;       Paramètres d'entree :             
;       Paramètres de sortie :               
;       Variables utilisees :  
;       Include :    
;       Equate :                 
;       #Define :         
;                                               
;******************************************************************************
Lire1BitI2C	
    call SDA1
    call SCL0
    call Delais5us
    call SCL1
    btfsc SDA
    goto Ecrire1
    goto Ecrire0
        
Ecrire1
    BSF BITX
    goto FinLecture
Ecrire0
    BCF BITX
    goto FinLecture
    
FinLecture
    call SCL0
    return
; fin routine Lire1BitI2C------------------------------------------------------

;***************************** Lire8BitsI2C ***********************************
;       Nom de la fonction : Lire8BitsI2C                      
;       Auteur :         champoux Xavier
;       Date de creation :                            
;       Modification :  
;       Description :   Routine de reception de 8 bits de donnee 
;                       provenant du dispositif I2C.
;                       La donnee lue est memorisee dans la variable _________.
;                       Parlez de la gestion du Ack                                
;       Fonctions appelees :           
;       Paramètres d'entree :           
;       Paramètres de sortie :               
;       Variables utilisees : 
;       Include :    
;       Equate :                 
;       #Define :                
;                                               
;******************************************************************************
Lire8BitsI2C
     movlw    0x00
     movwf    vReadByte
     
     movlw    .8
     movwf    vComptByte
SuiteLire8Bit
     call     Lire1BitI2C
     bcf      STATUS,C           ;CLEAR LE CARRY
     rlf      vReadByte,F        ;DECALAGE A GAUCHE
     btfsc    vReadBit,1         ;ON ADDITIONNE JUSTE SI LA VALEUR LUE EST 1 PCQ
     bsf      vReadByte,0        ;LE CARRY REINJECTE UN 0
     decfsz   vComptByte,F       ;DECREMENTE LE COMPTEUR POUR LA BOUCLE FOR
     goto     SuiteLire8Bit      ;RETOURNE A SUITELIRE8BIT SI LE COMPTEUR PAS 0
     call     SendAckI2C         ;ECRIT LA VALEUR DU ACK/NOACK SUR LE PORT SERIE
     return
; fin routine Lire8BitsI2C-----------------------------------------------------  

;****************************** Ecrire1BitI2C *********************************
;       Nom de la fonction : Ecrire1BitI2C                      
;       Auteur :        champoux Xavier         
;       Modification :  
;       Date de creation :                           
;       Description : Routine d'emission d'un bit de communication I2C.
;                     La routine utilise le bit 0 de la variable _____________ 
;                     pour ajuster le niveau de la ligne SDA.  
;                     Les lignes SDA et SCL sont activee à tour de rôle pour 
;                     communiquer l'information du maître à l'esclave.
;                                                       
;       Fonctions appelees :          
;       Paramètres d'entree :                  
;       Paramètres de sortie :          
;       Variables utilisees : 
;       Include :    
;       Equate :                 
;       #Define :                 
;                                               
;******************************************************************************
Ecrire1BitI2C
     call    Delai5us 
     call    SCL0
     btfsc   vWriteBit,1   ;TOUTS LES BITS DE LA VARIABLE SONT A LA MEME VALEUR
     goto    EcrireSDA1    ;IL FAUT JUSTE EN CHOISIR UN AU HASARD A TESTER
     goto    EcrireSDA0
EcrireSDA1
     call    SDA1
     goto    SuiteEcrire1Bit
EcrireSDA0
     call    SDA0
     goto    SuiteEcrire1Bit
SuiteEcrire1Bit
     call    SCL1
     call    SCL0
     return
     
; fin routine Ecrire1BitI2C----------------------------------------------------

;**************************  Ecrire8BitsI2C ***********************************
;       Nom de la fonction : Ecrire8BitsI2C
;       Auteur :         champoux Xavier
;       Date de creation :                          
;       Modification :  
;       Description :   Routine d'ecriture d'un octet de donnee vers
;                       le dispositif I2C.
;                       L'octet a transmettre est dans la variable __________ 
;                       avant l'appel de la fonction.
;                       Parlez de la gestion du Ack                                
;       Fonctions appelees :        
;       Paramètres d'entree :  
;       Paramètres de sortie :     
;       Variables utilisees : 
;       Include :     
;       Equate :              
;       #Define :       
;                                               
;******************************************************************************
Ecrire8BitsI2C 
     movlw    .8
     movwf    vComptByte
SuiteEcrire8Bit     
     movlw    0x00
     btfsc    vWriteByte,7
     movlw    0xff
     movwf    vWriteBit
;;;;GESTION DU WRITE;;;;
     call     Ecrire1BitI2C
     rlf      vWriteByte
     decfsz   vComptByte,F
     goto     SuiteEcrire8Bit
     call     Lire1BitI2C
     return
; fin routine Ecrire8BitsI2C---------------------------------------------------
 

;********************************** SDA SCL ***********************************
;
; Gestion de SDA et SCL pour ne jamais mettre de vrai 1 sur le bus. C'est les 
; pull-up sur SDA et SCL qui s'en charge.
;
; Pour mettre SDA ou SCL à 1 on met le bit en entree.
;
;******************************************************************************
SDA0     
     bcf     SDA               ; On s'assure que bit du latch est a 0.
     BANK1
     bcf     TRISB,1           ; SDA en output met bit a 0.
     BANK0
     return
; fin routine SDA0 ------------------------------------------------------------

;******************************************************************************      
SDA1 
     BANK1
     bsf     TRISB,1           ; SDA input (pull-up met a 1 ).
     BANK0
     return  
; fin routine SDA1 ------------------------------------------------------------

;******************************************************************************
SCL0 
     bcf     SCL               ; On s'assure que le bit du latch est a 0.
     BANK1
     bcf     TRISB,0           ; SCL en output met bit a 0.
     BANK0
     return
; fin routine SCL0 ------------------------------------------------------------

;******************************************************************************         
SCL1 
     BANK1
     bsf     TRISB,0           ; SCL input (pull-up met a 1 ).
     BANK0
     return 
; fin routine SCL1 ------------------------------------------------------------  

