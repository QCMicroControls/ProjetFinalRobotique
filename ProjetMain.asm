
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
     #include <p16F88.inc>     ; D�finition des registres sp�cifiques au CPU.

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
;                          - RP1 � 0 pour �tre toujours dans Bank 0 et 1,
;                          - D�sactiver les interruptions,
;                          - D�sactiver les entr�es analogiques,
;                          - PortA en entr�e,
;                          - PortB en entr�e sauf: Bits I2C et LEDs en sortie.
;                                                       
;       Fonctions appelees : NA 
;       Param�tres d'entree : NA  
;       Param�tres de sortie : NA 
;       Variables utilisees : NA  
;       Include : Fichier P16F88.inc
;       Equates : NA
;       #Defines : BANK0, BANK1 
;                                               
;******************************************************************************
InitPic
     bcf     STATUS, RP1       ; Pour s'assurer d'�tre dans les bank 0 et 1 
     BANK1                     ; Select Bank1        
     bcf     INTCON,GIE        ; D�sactive les interruptions        
     clrf    ANSEL             ; D�sactive les convertisseurs reg ANSEL 0x9B        
     movlw   b'01111000'       ; osc internal 8 Mhz
     movwf   OSCCON
     movlw   b'11111111'       ; Remplacer les x par des 1 ou 0.
     movwf   TRISA             ; PortA en entree         
     movlw   b'11100100'       ; Bits en entr�es sauf,
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
;       Param�tres d'entree :              
;       Param�tres de sortie :           
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
;       Param�tres d'entree :              
;       Param�tres de sortie :           
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
;       Param�tres d'entree :              
;       Param�tres de sortie :           
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
; Pour mettre SDA ou SCL � 1 on met le bit en entree.
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
;                       Doit �tre appelee � chaque debut d'operation.
;                       Le passage de 1 � 0 sur la ligne SDA durant
;                       un niveau 1 sur la ligne SCL initie un START BIT.
;                                                       
;       Fonctions appelees :            
;       Param�tres d'entree :            
;       Param�tres de sortie :            
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
;       Description :   Routine de cl�ture d'une communication serie I2C.
;                       Doit �tre appelee � la fin de toutes operations.
;                       Passage de 0 � 1 sur la ligne SDA durant
;                       un niveau 1 sur la ligne SCL initie un STOP BIT.
;                                                       
;       Fonctions appelees :           
;       Param�tres d'entree :              
;       Param�tres de sortie :           
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
;                       La routine prend le bit de la ligne SDA apr�s avoir 
;                       active la ligne SCL. Le bit de donnee est place 
;                       temporairement dans la variable ___________ et sera  
;                       reutilise dans la routine de traitement d'octets.
;                                                       
;       Fonctions appelees :          
;       Param�tres d'entree :             
;       Param�tres de sortie :               
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
;                     Les lignes SDA et SCL sont activee � tour de r�le pour 
;                     communiquer l'information du ma�tre � l'esclave.
;                                                       
;       Fonctions appelees :          
;       Param�tres d'entree :                  
;       Param�tres de sortie :          
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
;       Param�tres d'entree :           
;       Param�tres de sortie :               
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
;       Param�tres d'entree :           
;       Param�tres de sortie :               
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
;       Param�tres d'entree :  
;       Param�tres de sortie :     
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
;       Param�tres d'entree :                               
;       Param�tres de sortie :                                         
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
;       Param�tres d'entree :                   
;       Param�tres de sortie :                 
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
;  Param�tres d'entree :        
;  Param�tres de sortie :        
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
;       Date de cr�ation : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine d'initialisation du port de communication s�rie.
;                   RS232 sur le PIC16F88 � 19200 bd (RX=RB2 et TX=RB5)
;							
;	Fonctions appel�es : NA		
;	Param�tres d'entr�e : NA		
;	Param�tres de sortie : NA	
;	Variables utilis�es : NA
;	Equate : NA
;	#Define : BANK0, BANK1.  
;              
;							
;******************************************************************************
InitRS232
    movlw     b'10010000'    ; Set reception sur port s�rie SPEN=CREN = 1
    movwf     RCSTA          ;
    BANK1                    ;
    movlw     b'00100100'    ; Set la transmission sur le port s�rie
    movwf     TXSTA          ;
    movlw     .25            ; Set la vitesse � 19200 bds
    movwf     SPBRG          ;
    BANK0                    ;
    return                   ;             
; fin routine InitRS232--------------------------------------------------------

;*************************************Rx232************************************
;	Nom de la fonction : Rx232			
;	Auteur : Pierre Chouinard		
;       Date de cr�ation : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de r�ception de la communication s�rie RS-232.
;                   RS232 sur le PIC16F88 � 19200 bd (RX=RB2 et TX=RB5)
;							
;	Fonctions appel�es : NA		
;	Param�tres d'entr�e : NA
;	Param�tres de sortie : vReceive.		
;	Variables utilis�es : NA
;	Equate : NA	
;	#Define : NA 
; 						
;******************************************************************************
Rx232
    Btfss     PIR1,RCIF      ; Attend de recevoir quelque chose sur 
    goto      Rx232          ; le port serie.
Rx232Go                      ; Si recu sur le port serie
    movfw     RCREG          ;
    movwf     vReceive       ; Met le caract�re re�u dans vReceive
    return
; fin routine Rx232------------------------------------------------------------

;*************************************Tx232************************************
;	Nom de la fonction : Tx232			
;	Auteur : Pierre Chouinard		
;       Date de cr�ation : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de transmission de la communication s�rie RS-232.
;                   Sur le PIC16F88 (RX=RB2 et TX=RB5). La vitesse est fix�e � 
;                   19200. On place la donn�e � transmettre dans W avant l'appel  
;                   de Tx232.
;							
;	Fonctions appel�es : NA		
;	Param�tres d'entr�e : NA	
;	Param�tres de sortie : NA		
;	Variables utilis�es : NA
;	Equate : NA
;	#Define : NA 
;
;******************************************************************************
Tx232
    btfss     PIR1,TXIF      ; Attend que la transmission du caract�re 
    goto      Tx232          ; pr�c�dant soit terminer   
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