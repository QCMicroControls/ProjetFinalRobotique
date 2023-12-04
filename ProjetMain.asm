
;******************************************************************************
;                                                                             *
;    Filename:      ProjetMain.asm                                              *
;    Date:                                                                    *
;    File Version:                                                            *
;                                                                             *
;    Author:                                                                  *
;    Company:                                                                 *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Files required:                                                          *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Notes:                                                                   *
;                                                                             *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************

;***********************DIAGRAMME DU CONTROLEUR********************************
;                                                                     
;                     IN  IN  S3  IN      S2  S1  TX  D2            S: Switch 
;                     A1  A0  A7  A6 VDD  B7  B6  B5  B4              
;                    ____________________________________             
;           PIN     | 18  17  16  15  14  13  12  11  10 |            
;                   |               16C88                |            
;           PIN     | 1   2   3  _4_  5   6   7   8   9  |            
;                    ------------------------------------             
;                     A2  A3  A4  A5 VSS  B0  B1  B2  B3              
;                     IN  IN  IN  MCL     SCL SDA RX  D1            D: Del  
;
;******************************************************************************



;******************** Les fonctions utilisees *********************************
; InitPic                      ; Initialise le PIC.
; SDA0                         ; Met SDA a 0
; SDA1                         ; Met SDA a 1
; SCL0                         ; Met SCL a 0 
; SCL1                         ; Met SCL a 1  
; EcrireMemI2C                 ; Ecrire un octet en memoire I2C
; LireMemI2C                   ; Lecture d'un octet en memoire I2C
; Ecrire8BitsI2C               ; Ecrire 8 bits sur la ligne I2C
; Lire8BitsI2C                 ; Lire 8 bits sur la ligne I2C
; Ecrit1BitI2C                 ; Emet 1 bit sur la ligne I2C
; Lire1BitI2C                  ; Recoit 1 bit sur la ligne I2C
; StartBitI2C                  ; Start une communication I2C
; StopBitI2C                   ; Termine une communication I2C
; Delai5us                     ; Delai pour maintenir signaux 5us.
;******************************************************************************



     LIST      p=16f88         ; Liste des directives du processeur.
     #include <p16F88.inc>     ; Définition des registres spécifiques au CPU.

     errorlevel  -302          ; Retrait du message d'erreur 302.

     __CONFIG    _CONFIG1, _CP_OFF & _CCP1_RB0 & _DEBUG_OFF & _WRT_PROTECT_OFF & _CPD_OFF & _LVP_OFF & _BODEN_ON & _MCLR_ON & _PWRTE_ON & _WDT_OFF & _INTRC_IO

     __CONFIG    _CONFIG2, _IESO_OFF & _FCMEN_OFF



;*********************************** DEFINES **********************************
#define      BANK0   bcf       STATUS,RP0;
#define      BANK1   bsf       STATUS,RP0;


;*********************************** KIT-PIC **********************************
#define      SW1               PORTB,6
#define      SW2               PORTB,7
#define      SW3               PORTA,7
#define      DEL1              PORTB,3
#define      DEL2              PORTB,4

;************************************ I2C *************************************
#define      SCL               PORTB,0
#define      SDA               PORTB,1
     
;************************************ PWM *************************************
#define      FLAG1             vFlag,1
#define      FLAG2             vFlag,2
#define      FLAG3             vFlag,3




;***** VARIABLE DEFINITIONS  **************************************************
;w_temp        EQU     0x71     ; variable used for context saving 
;status_temp   EQU     0x72     ; variable used for context saving
;pclath_temp   EQU     0x73     ; variable used for context saving


;VosVariables  EQU     0x20     ; Mettre ici vos Variables
  CBLOCK  0x20
  vAck
  vAddHigh
  vAddLow
  vBoucleHigh
  vBoucleLow
  vChannel
  vComptByte
  vCompteur5Ms
  vCompteurMs
  vEcrireMem
  vLireMem
  vMoteur
  vPwm
  vPwmHigh
  vReadBit
  vReadByte
  vReceive
  vWriteBit
  vWriteByte
  endc



;***************************VECTEUR DE RESET***********************************
     ORG     0x000             ; Processor reset vector
     clrf    PCLATH            ; Page 0 (a cause du BootLoader)
     goto    Main              ; 
        

;***********************VECTEUR D'INTERRUPTION*********************************    
     ORG     0x004             ; Interrupt vector location
     goto    Interruption


;**************************PROGRAMME PRINCIPAL*********************************

Main    
     call    InitPic
     call    ResetPCA9685
     call    SetFreqPCA9685
     
Boucle127x256
     movlw   0x7F
     movwf   vBoucleHigh
     movlw   0x00
     movwf   vBoucleLow

     
Encore    
     
     goto    Encore
;****************************** ROUTINES **************************************


;******************************* ROUTINES *************************************

;******************************* InitPic **************************************
;       Nom de la fonction : InitPic                    
;       Auteur : Alain Champagne
;       Date de creation : 23-09-2018                                
;       Description :      Routine d'initiation des registres du PIC.
;                          - RP1 à 0 pour être toujours dans Bank 0 et 1,
;                          - Désactiver les interruptions,
;                          - Désactiver les entrées analogiques,
;                          - PortA en entrée,
;                          - PortB en entrée sauf: Bits I2C et LEDs en sortie.
;                                                       
;       Fonctions appelees : NA 
;       Paramètres d'entree : NA  
;       Paramètres de sortie : NA 
;       Variables utilisees : NA  
;       Include : Fichier P16F88.inc
;       Equates : NA
;       #Defines : BANK0, BANK1 
;                                               
;******************************************************************************
InitPic
     bcf     STATUS, RP1       ; Pour s'assurer d'être dans les bank 0 et 1 
     BANK1                     ; Select Bank1        
     bcf     INTCON,GIE        ; Désactive les interruptions        
     clrf    ANSEL             ; Désactive les convertisseurs reg ANSEL 0x9B        
     movlw   b'01111000'       ; osc internal 8 Mhz
     movwf   OSCCON
     movlw   b'11111111'       ; Remplacer les x par des 1 ou 0.
     movwf   TRISA             ; PortA en entree         
     movlw   b'11100100'       ; Bits en entrées sauf,
     movwf   TRISB             ; RB3 (Led1), RB4 (Led2) en sortie. 
     BANK0                     ; Select Bank0
     return

; fin routine InitPic ---------------------------------------------------------
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
;       Auteur :             
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
     call    Delai5us
     call    SDA1
     call    SCL0
     call    SCL1
     btfsc   SDA
     goto    LitSDA1
     goto    LitSDA0
LitSDA1
     movlw   0xFF
     movwf   vReadBit
     goto    SuiteLire1Bit
LitSDA0
     movlw   0x00
     movwf   vReadBit
     goto    SuiteLire1Bit
SuiteLire1Bit
     call    SCL0
     return

; fin routine Lire1BitI2C------------------------------------------------------



;****************************** Ecrire1BitI2C *********************************
;       Nom de la fonction : Ecrire1BitI2C                      
;       Auteur :                 
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



;***************************** Lire8BitsI2C ***********************************
;       Nom de la fonction : Lire8BitsI2C                      
;       Auteur :         
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
  
     
     
;***************************** SendAckI2C *************************************
;       Nom de la fonction : Lire8BitsI2C                      
;       Auteur :         
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
SendAckI2C
     movlw    0x00
     btfsc    vAck,1
     movlw    0xff
     movwf    vWriteBit
     call     Ecrire1BitI2C
     return

; fin routine SendAckI2C-------------------------------------------------------



;**************************  Ecrire8BitsI2C ***********************************
;       Nom de la fonction : Ecrire8BitsI2C
;       Auteur :         
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
 
 

;***************************** EcrireMemI2C ***********************************
;       Nom de la fonction : EcrireMemI2C                                      
;       Auteur :                                          
;       Date de creation :                                  
;       Modification :                               
;       Description :   Routine de transmission d'un octet de donnee          
;                       vers la memoire I2C (24LC32).
;                       Genere les Start et les Stop. 
;                       Avant l'appel de la fonction: 
;                          Decrire les parametres d'entrees.
;                       A la sortie de la fonction:
;                          Decrire les parametres de sortie.
;                       Une fois l'ecriture effectuee, il faut un delai 
;                       d'environ 5 ms (Write Time).                        
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
EcrireMemI2C
     call     StartBitI2C
     
     movlw    0xA0
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     ;;;;;ADRESSE HIGH;;;;;
     movfw    vAddHigh
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     ;;;;;ADDRESSE LOW;;;;;
     movfw    vAddLow
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     ;;;;;DATA;;;;;;;;;;;;;
     movfw    vEcrireMem
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     
     call     StopBitI2C
     call     Delai5ms
     return
; fin routine EcrireMemI2C-----------------------------------------------------



;****************************** LireMemI2C ************************************
;       Nom de la fonction : LireMemI2C                  
;       Auteur :           
;       Date de creation :                            
;       Modification :  
;       Description :   Routine de reception d'un octet de donnee 
;                       provenant de la memoire I2C (24LC32).
;                       Genere les Start et les Stop. 
;                       Avant l'appel de la fonction: 
;                          Decrire les parametres d'entrees.
;                       A la sortie de la fonction:
;                          Decrire les parametres de sortie. 
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
LireMemI2C
     call     StartBitI2C
     
     movlw    0xA0
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     ;;;;;ADRESSE HIGH;;;;;
     movfw    vAddHigh
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     ;;;;;ADDRESSE LOW;;;;;
     movfw    vAddLow
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     
     call     StopBitI2C
     call     StartBitI2C
     
     movlw    0xA1
     movwf    vWriteByte
     call     Ecrire8BitsI2C
     
     movlw    0xFF
     movwf    vAck
     call     Lire8BitsI2C
     movfw    vReadByte
     movwf    vLireMem
     call     StopBitI2C
     
     return
; fin routine LireMemI2C-------------------------------------------------------



;******************************** Delais   ************************************
;  Nom de la fonction : Delai      
;  Auteur :    
;       Date de creation :              
;  Description :   Routine de delai de 5 us.
;       Calcul du delai:
; 
;              
;  Fonctions appelees :        
;  Paramètres d'entree :        
;  Paramètres de sortie :        
;  Variables utilisees :    
;  Equate :      
;  #Define :      
;              
;******************************************************************************

;DELAI DE 5 MILLISECONDES     
Delai5ms
     movlw   .5
     movwf   vCompteur5Ms
Calldelai5
     call    Delaims
     decfsz  vCompteur5Ms
     goto    Calldelai5
     RETURN
     

;DELAI DE 1 MILLISECONDE     
Delaims
     movlw   .199
     movwf   vCompteurMs
Calldelai
     call    Delai5us
     decfsz  vCompteurMs
     goto    Calldelai
     RETURN
     
     
;DELAI DE 5 MICROSECONDES     
Delai5us
     nop
     nop
     nop
     RETURN

; fin routine Delai5us---------------------------------------------------------
;******************************************************************************
; Ne pas oublier:  Appeler InitRS232 dans la fonction InitPic
;******************************************************************************

;------------------------------------RS 232------------------------------------
;*********************************InitRS232************************************
;	Nom de la fonction : InitRS232			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine d'initialisation du port de communication série.
;                   RS232 sur le PIC16F88 à 19200 bd (RX=RB2 et TX=RB5)
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA		
;	Paramètres de sortie : NA	
;	Variables utilisées : NA
;	Equate : NA
;	#Define : BANK0, BANK1.  
;              
;							
;******************************************************************************
InitRS232
    movlw     b'10010000'    ; Set reception sur port série SPEN=CREN = 1
    movwf     RCSTA          ;
    BANK1                    ;
    movlw     b'00100100'    ; Set la transmission sur le port série
    movwf     TXSTA          ;
    movlw     .25            ; Set la vitesse à 19200 bds
    movwf     SPBRG          ;
    BANK0                    ;
    return                   ;             
; fin routine InitRS232--------------------------------------------------------

;*************************************Rx232************************************
;	Nom de la fonction : Rx232			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de réception de la communication série RS-232.
;                   RS232 sur le PIC16F88 à 19200 bd (RX=RB2 et TX=RB5)
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA
;	Paramètres de sortie : vReceive.		
;	Variables utilisées : NA
;	Equate : NA	
;	#Define : NA 
; 						
;******************************************************************************
Rx232
    Btfss     PIR1,RCIF      ; Attend de recevoir quelque chose sur 
    goto      Rx232          ; le port serie.
Rx232Go                      ; Si recu sur le port serie
    movfw     RCREG          ;
    movwf     vReceive       ; Met le caractère reçu dans vReceive
    return
; fin routine Rx232------------------------------------------------------------

;*************************************Tx232************************************
;	Nom de la fonction : Tx232			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de transmission de la communication série RS-232.
;                   Sur le PIC16F88 (RX=RB2 et TX=RB5). La vitesse est fixée à 
;                   19200. On place la donnée à transmettre dans W avant l'appel  
;                   de Tx232.
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA	
;	Paramètres de sortie : NA		
;	Variables utilisées : NA
;	Equate : NA
;	#Define : NA 
;
;******************************************************************************
Tx232
    btfss     PIR1,TXIF      ; Attend que la transmission du caractère 
    goto      Tx232          ; précédant soit terminer   
    movwf     TXREG          ; Transmet le caractere
    return                   ;       
; fin routine Tx232------------------------------------------------------------



;****************************** Interruption **********************************
Interruption

;    movwf     w_temp         ; save off current W register contents
;    movf      STATUS,w       ; move STATUS register into W register
;    movwf     status_temp    ; save off contents of STATUS register
;    movf      PCLATH,W       ; move PCLATH register into W register
;    movwf     pclath_temp    ; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere


;    movf      pclath_temp,w  ; retrieve copy of PCLATH register
;    movwf     PCLATH         ; restore pre-isr PCLATH register contents
;    movf      status_temp,w  ; retrieve copy of STATUS register
;    movwf     STATUS         ; restore pre-isr STATUS register contents
;    swapf     w_temp,f
;    swapf     w_temp,w       ; restore pre-isr W register contents
    retfie                   ; return from interrupt

; fin de la routine Interruption-----------------------------------------------

        END                       ; directive 'end of program'


HAROLD


;******************************************************************************
;                                                                             *
;    Filename:      FrameI2C.asm                                              *
;    Date:          2023-11-16                                                          *
;    File Version:  1.0                                                          *
;                                                                             *
;    Author:        Malbrouck Harold                                                          *
;    Company:                                                                 *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Files required:                                                          *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Notes:                                                                   *
;                                                                             *
;                                                                             *
;                                                                             *
;                                                                             *
;******************************************************************************

;***********************DIAGRAMME DU CONTROLEUR********************************
;                                                                     
;                     IN  IN  S3  IN      S2  S1  TX  D2            S: Switch 
;                     A1  A0  A7  A6 VDD  B7  B6  B5  B4              
;                    ____________________________________             
;           PIN     | 18  17  16  15  14  13  12  11  10 |            
;                   |               16C88                |            
;           PIN     | 1   2   3  _4_  5   6   7   8   9  |            
;                    ------------------------------------             
;                     A2  A3  A4  A5 VSS  B0  B1  B2  B3              
;                     IN  IN  IN  MCL     SCL SDA RX  D1            D: Del  
;
;******************************************************************************



;******************** Les fonctions utilisees *********************************
; InitPic                      ; Initialise le PIC.
; SDA0                         ; Met SDA a 0
; SDA1                         ; Met SDA a 1
; SCL0                         ; Met SCL a 0 
; SCL1                         ; Met SCL a 1  
; EcrireMemI2C                 ; Ecrire un octet en memoire I2C
; LireMemI2C                   ; Lecture d'un octet en memoire I2C
; Ecrire8BitsI2C               ; Ecrire 8 bits sur la ligne I2C
; Lire8BitsI2C                 ; Lire 8 bits sur la ligne I2C
; Ecrit1BitI2C                 ; Emet 1 bit sur la ligne I2C
; Lire1BitI2C                  ; Recoit 1 bit sur la ligne I2C
; StartBitI2C                  ; Start une communication I2C
; StopBitI2C                   ; Termine une communication I2C
; Delai5us                     ; Delai pour maintenir signaux 5us.
;******************************************************************************



     LIST      p=16f88         ; Liste des directives du processeur.
     #include <p16F88.inc>     ; Définition des registres spécifiques au CPU.

     errorlevel  -302          ; Retrait du message d'erreur 302.

     __CONFIG    _CONFIG1, _CP_OFF & _CCP1_RB0 & _DEBUG_OFF & _WRT_PROTECT_OFF & _CPD_OFF & _LVP_OFF & _BODEN_ON & _MCLR_ON & _PWRTE_ON & _WDT_OFF & _INTRC_IO

     __CONFIG    _CONFIG2, _IESO_OFF & _FCMEN_OFF



;*********************************** DEFINES **********************************
#define      BANK0   bcf       STATUS,RP0;
#define      BANK1   bsf       STATUS,RP0;

;*********************************** KIT-PIC **********************************
#define      SW1               PORTB,6
#define      SW2               PORTB,7
#define      SW3               PORTA,7
#define      DEL1              PORTB,3
#define      DEL2              PORTB,4

;************************************ I2C *************************************
#define      SCL               PORTB,0
#define      SDA               PORTB,1
#define      BITX	       vUnBit,0
#define	     CARRY	       STATUS,C		


;***** VARIABLE DEFINITIONS  **************************************************
;w_temp        EQU     0x71     ; variable used for context saving 
;status_temp   EQU     0x72     ; variable used for context saving
;pclath_temp   EQU     0x73     ; variable used for context saving


;VosVariables  EQU     0x20     ; Mettre ici vos Variables
  CBLOCK  0x20
  vCompteur1ms
  vCompteur5ms
  vCompteur  
  vChannel  
  vReceive  
  vMoteur
  vPwmHi
  vUnBit
  vBitLu
  vADRH
  vADRL
  vDATA
  vPwm
  vOct
  vAck
  vSet
  vW
  endc

;***************************VECTEUR DE RESET***********************************
     ORG     0x000             ; Processor reset vector
     clrf    PCLATH            ; Page 0 (a cause du BootLoader)
     goto    Main              ; 
        

;***********************VECTEUR D'INTERRUPTION*********************************    
     ORG     0x004             ; Interrupt vector location
     goto    Interruption


;**************************PROGRAMME PRINCIPAL*********************************

Main    
     call InitPic   ; Initialise PIC et place les ports en IN/OUT
		    ; Les lignes suivantes doivent être appelées
		    ; lors de l?initialisation ou dans la routine
		    ; StartBitI2C.
    call  InitRS232
    call  SDA1	    ; Condition initial SDA = SCL =1
    call  SCL1 
    
    call  ResetPCA9685
    call  SetFreqPCA9685
    Main    
     call    InitPic
     call    ResetPCA9685
     call    SetFreqPCA9685
     
Boucle127x256
     movlw   0x7F
     movwf   vBoucleHigh
     movlw   0x00
     movwf   vBoucleLow
Encore    
     
     goto    Encore
    
 
;****************************** ROUTINES **************************************


;******************************* ROUTINES *************************************

;******************************* InitPic **************************************
;       Nom de la fonction : InitPic                    
;       Auteur : Alain Champagne
;       Date de creation : 23-09-2018                                
;       Description :      Routine d'initiation des registres du PIC.
;                          - RP1 à 0 pour être toujours dans Bank 0 et 1,
;                          - Désactiver les interruptions,
;                          - Désactiver les entrées analogiques,
;                          - PortA en entrée,
;                          - PortB en entrée sauf: Bits I2C et LEDs en sortie.
;                                                       
;       Fonctions appelees : NA 
;       Paramètres d'entree : NA  
;       Paramètres de sortie : NA 
;       Variables utilisees : NA  
;       Include : Fichier P16F88.inc
;       Equates : NA
;       #Defines : BANK0, BANK1 
;                                               
;******************************************************************************
InitPic
     bcf     STATUS, RP1       ; Pour s'assurer d'être dans les bank 0 et 1 
     BANK1                     ; Select Bank1        
     bcf     INTCON,GIE        ; Désactive les interruptions        
     clrf    ANSEL             ; Désactive les convertisseurs reg ANSEL 0x9B        
     movlw   b'01111000'       ; osc internal 8 Mhz
     movwf   OSCCON
     movlw   b'11111111'       ; Remplacer les x par des 1 ou 0.
     movwf   TRISA             ; PortA en entree         
     movlw   b'11100100'       ; Bits en entrées sauf,
     movwf   TRISB             ; RB3 (Led1), RB4 (Led2) en sortie. 
     BANK0                     ; Select Bank0
     return

; fin routine InitPic ---------------------------------------------------------
#include <RS232-PIC88.asm>


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

;****************************** ResetPCA9685 ************************************
;       Nom de la fonction : ResetPCA9685                  
;       Auteur : Malbrouck Harold       
;       Date de creation :  16-11-2023                          
;       Modification :  
;       Description :   Routine qui permet de remettre	zéro le circuit 
;			PCA9685
;                       
;       Fonctions appelees :  StartBitI2C, Ecrire8BitsI2c, StopBitI2C            
;       Paramètres d'entree :                   
;       Paramètres de sortie :                 
;       Variables utilisees :  
;       Include :              
;       Equate :                          
;       #Define : 
;                        
;******************************************************************************
ResetPCA9685
     call StartBitI2C
     movlw 0x00
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0x06
     movwf vOct
     call Ecrire8BitsI2C
     call StopBitI2C
     return
;Fin routine ResetPCA9685------------------------------------------------------
 
;****************************** SetFreqPCA9685 ************************************
;       Nom de la fonction : SetFreqPCA9685                  
;       Auteur : Malbrouck Harold          
;       Date de creation : 16-11-2023                           
;       Modification :  
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
;******************************************************************************
SetFreqPCA9685
     call StartBitI2C
     movlw 0x80
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0x00
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0x10
     movwf vOct
     call Ecrire8BitsI2C
     call StopBitI2C
     
     call StartBitI2C
     movlw 0x80
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0xFE
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0x7C
     movwf vOct
     call Ecrire8BitsI2C
     call StopBitI2C
     
     call StartBitI2C
     movlw 0x80
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0x00
     movwf vOct
     call Ecrire8BitsI2C
     movlw 0xA0
     movwf vOct
     call Ecrire8BitsI2C
     call StopBitI2C
     
     return
;Fin routine SetFreqPCA9685----------------------------------------------------
     
;****************************** SetPWMPCA9685 ************************************
;       Nom de la fonction : SetPWMPCA9685                  
;       Auteur : Malbrouck Harold          
;       Date de creation : 16-11-2023                           
;       Modification :  
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
;******************************************************************************
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
     movwf vW
     btfsc CARRY
     incf vPwmHi,1
     
     ;Écrire I2CPCA********************
     call StartBitI2C
     movlw 0x80
     movwf vOct
     call Ecrire8BitsI2C     
	 
    ;Selectionne le moteur
     movfw vMoteur
     movwf vOct
     call Ecrire8BitsI2C
     
     ;Écrit 0 au début de l'onde H****
     movlw 0x00
     movwf vOct
     call Ecrire8BitsI2C
     
     ;Écrit 0 au début de l'onde B****
     movlw 0x00
     movwf vOct
     call Ecrire8BitsI2C
     
     ;Écrire 0xFinB******************* 
     movfw vW
     movwf vOct
     call Ecrire8BitsI2C
     
     ;Écrire 0xFinB*******************
     movfw vPwmHi
     movwf vOct
     call Ecrire8BitsI2C
     
     call StopBitI2C  
     return
;Fin routine SetPWMPCA9685----------------------------------------------------
     
;****************************** StartBitI2C ***********************************
;       Nom de la fonction : StartBitI2C                       
;       Auteur : Malbrouck Harold                 
;      Date de creation : 2023-11-02                                  
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
    call SDA1    
    call SCL1    
    call SDA0    
    call SCL0
    return
; fin routine StartBitI2C------------------------------------------------------



;******************************* StopBitI2C ***********************************
;       Nom de la fonction : StopBitI2C                 
;       Auteur :  Malbrouck Harold       
;       Date de creation : 2023-11-02                               
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
    call SDA0
    call SCL0
    call SCL1
    call SDA1
    return
; fin routine StopBitI2C-------------------------------------------------------         
         
   
      
;******************************* Lire1BitI2C **********************************
;       Nom de la fonction : Lire1BitI2C                        
;       Auteur :             
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



;****************************** Ecrire1BitI2C *********************************
;       Nom de la fonction : Ecrire1BitI2C                      
;       Auteur :                 
;       Modification :  
;       Date de creation :                           
;       Description : Routine d'emission d'un bit de communication I2C.
;                     La routine utilise le bit 0 de la variable ___BITX_______ 
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
    call  SCL0    
    btfss BITX
    goto  PortSDA0
    goto  PortSDA1

SuiteEcrire1b 
    call  SCL1
    call  Delais5us    
    call  SCL0
    return
    
PortSDA1
    call  SDA1
    goto  SuiteEcrire1b      
    
PortSDA0
    call  SDA0
    goto  SuiteEcrire1b  
    
    
; fin routine Ecrire1BitI2C----------------------------------------------------



;***************************** Lire8BitsI2C ***********************************
;       Nom de la fonction : Lire8BitsI2C                      
;       Auteur : Malbrouck Harold        
;       Date de creation :  09-11-2023                          
;       Modification :  
;       Description :   Routine de reception de 8 bits de donnee 
;                       provenant du dispositif I2C.
;                       La donnee lue est memorisee dans la variable ___vOct___.
;                       Parlez de la gestion du Ack                                
;       Fonctions appelees :     Lire1BitI2C, Ecrire1BitI2C      
;       Paramètres d'entree :    vOct       
;       Paramètres de sortie :   vUnBit            
;       Variables utilisees :	vCompteur, BITX, vOct, vAck, vUnBit
;       Include :    
;       Equate :                 
;       #Define :  BITX              
;                                               
;******************************************************************************
Lire8BitsI2C
    movlw .8
    movwf vCompteur
TacheLire8b
    rlf vOct
    bcf STATUS,C
    call Lire1BitI2C
    btfsc BITX
    goto Bita1
    goto Bita0
    
Bita1
    bsf vOct,0
    goto SuiteLire8b
Bita0
    bcf vOct,0
    
SuiteLire8b
    decfsz vCompteur,F
    goto TacheLire8b
    movfw vAck
    movwf vUnBit
    call Ecrire1BitI2C
    return
    
    
; fin routine Lire8BitsI2C-----------------------------------------------------



;**************************  Ecrire8BitsI2C ***********************************
;       Nom de la fonction : Ecrire8BitsI2C
;       Auteur :         
;       Date de creation :                          
;       Modification :  
;       Description :   Routine d'ecriture d'un octet de donnee vers
;                       le dispositif I2C.
;                       L'octet a transmettre est dans la variable __vOct______ 
;                       avant l'appel de la fonction.
;                       Parlez de la gestion du Ack                                
;       Fonctions appelees :  Ecrire1BitI2C, Lire1BitI2C      
;       Paramètres d'entree :  vOct
;       Paramètres de sortie :     
;       Variables utilisees : 
;       Include :     
;       Equate :              
;       #Define :       
;                                               
;******************************************************************************
Ecrire8BitsI2C
    movlw .8
    movwf vCompteur

TacheEcrire8b
    btfsc vOct,7
    goto EcrireUn
    goto EcrireZero
	
EcrireUn
    BSF BITX
    call Ecrire1BitI2C
    goto SuiteEcrire8b
EcrireZero
    BCF BITX
    call Ecrire1BitI2C
    goto SuiteEcrire8b

SuiteEcrire8b
    bcf STATUS,C
    rlf vOct ;for left shift
    decfsz vCompteur,F
    goto TacheEcrire8b
    call Lire1BitI2C
    return	

; fin routine Ecrire8BitsI2C---------------------------------------------------
 
 

;***************************** EcrireMemI2C ***********************************
;       Nom de la fonction : EcrireMemI2C                                      
;       Auteur :                                          
;       Date de creation :                                  
;       Modification :                               
;       Description :   Routine de transmission d'un octet de donnee          
;                       vers la memoire I2C (24LC32).
;                       Genere les Start et les Stop. 
;                       Avant l'appel de la fonction: 
;                          Decrire les parametres d'entrees.
;                       A la sortie de la fonction:
;                          Decrire les parametres de sortie.
;                       Une fois l'ecriture effectuee, il faut un delai 
;                       d'environ 5 ms (Write Time).                        
;                                                                             
;       Fonctions appelees :  Ecrire8BitsI2C, StartBitI2C, StopBitI2C, DelaisI5ms   
;       Paramètres d'entree : vADRH, vADRL, vDATA                            
;       Paramètres de sortie :  vOct                                       
;       Variables utilisees : 
;       Include :                                          
;       Equate :                                                    
;       #Define :                                                     
;                                                                             
;******************************************************************************      

EcrireMemI2C    
    call StartBitI2C
    movlw 0xA0
    movwf vOct
    call Ecrire8BitsI2C
    
    movfw vADRH
    movwf vOct
    call Ecrire8BitsI2C
    
    movfw vADRL
    movwf vOct
    call Ecrire8BitsI2C
    
    movfw vDATA
    movwf vOct
    call Ecrire8BitsI2C
    call StopBitI2C
    call Delais5ms
    return
; fin routine EcrireMemI2C-----------------------------------------------------



;****************************** LireMemI2C ************************************
;       Nom de la fonction : LireMemI2C                  
;       Auteur :           
;       Date de creation :                            
;       Modification :  
;       Description :   Routine de reception d'un octet de donnee 
;                       provenant de la memoire I2C (24LC32).
;                       Genere les Start et les Stop. 
;                       Avant l'appel de la fonction: 
;                          Decrire les parametres d'entrees.
;                       A la sortie de la fonction:
;                          Decrire les parametres de sortie. 
;                       
;       Fonctions appelees : Ecrire8BitsI2C,Lire8BitsI2C,StartBitI2C,StopBitI2C             
;       Paramètres d'entree :  vADRH, vADRL, vOct                 
;       Paramètres de sortie : vDATA                
;       Variables utilisees :  
;       Include :              
;       Equate :                          
;       #Define : 
;                        
;******************************************************************************

LireMemI2C
    call StartBitI2C
    movlw 0xA0
    movwf vOct
    call Ecrire8BitsI2C
    
    movfw vADRH
    movwf vOct
    call Ecrire8BitsI2C
    
    movfw vADRL
    movwf vOct
    call Ecrire8BitsI2C
    call StopBitI2C
    
    call StartBitI2C
    movlw 0xA1
    movwf vOct
    call Ecrire8BitsI2C
    
    call Lire8BitsI2C
    movfw vOct
    movwf vDATA
    call StopBitI2C
    return
; fin routine LireMemI2C-------------------------------------------------------



;******************************** Delai5us ************************************
;  Nom de la fonction : Delai5us      
;  Auteur :  Malbrouck Harold  
;       Date de creation :              
;  Description :   Routine de delai de 5 us.
;       Calcul du delai:
; 
;              
;  Fonctions appelees :        
;  Paramètres d'entree :        
;  Paramètres de sortie :        
;  Variables utilisees :    
;  Equate :      
;  #Define :      
;              
;******************************************************************************
Delais5us			;Fonction de délai de 5 usec
     NOP
     NOP
     NOP
     NOP
     NOP
     NOP
     return

; fin routine Delai5us---------------------------------------------------------
     
;******************************** Delai1ms ************************************
;  Nom de la fonction : Delai1ms      
;  Auteur :  Malbrouck Harold  
;       Date de creation :              
;  Description :   Routine de delai de 1 ms.
;       Calcul du delai:
; 
;              
;  Fonctions appelees :        
;  Paramètres d'entree :        
;  Paramètres de sortie :        
;  Variables utilisees :    
;  Equate :      
;  #Define :      
;              
;******************************************************************************
Delais1ms
     movlw  .152
     movwf  vCompteur1ms
Encore1ms     
     call Delais5us
     decfsz vCompteur1ms,F
     goto Encore1ms
     return
; fin routine Delai1ms---------------------------------------------------------
     
     ;******************************** Delais5ms ************************************
;  Nom de la fonction : Delais5ms      
;  Auteur : Malbrouck Harold   
;       Date de creation :              
;  Description :   Routine de delai de 5 ms.
;       Calcul du delai:
; 
;              
;  Fonctions appelees :        
;  Paramètres d'entree :        
;  Paramètres de sortie :        
;  Variables utilisees :    
;  Equate :      
;  #Define :      
;              
;******************************************************************************
Delais5ms
     movlw .5
     movwf vCompteur5ms
Encore5ms
     call Delais1ms
     decfsz vCompteur5ms,F
     goto Encore5ms
     return
; fin routine Delai5ms---------------------------------------------------------
     
;****************************** Interruption **********************************
Interruption

;    movwf     w_temp         ; save off current W register contents
;    movf      STATUS,w       ; move STATUS register into W register
;    movwf     status_temp    ; save off contents of STATUS register
;    movf      PCLATH,W       ; move PCLATH register into W register
;    movwf     pclath_temp    ; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere


;    movf      pclath_temp,w  ; retrieve copy of PCLATH register
;    movwf     PCLATH         ; restore pre-isr PCLATH register contents
;    movf      status_temp,w  ; retrieve copy of STATUS register
;    movwf     STATUS         ; restore pre-isr STATUS register contents
;    swapf     w_temp,f
;    swapf     w_temp,w       ; restore pre-isr W register contents
    retfie                   ; return from interrupt

; fin de la routine Interruption-----------------------------------------------



        END                       ; directive 'end of program'





