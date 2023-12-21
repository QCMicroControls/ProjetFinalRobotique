
;******************************************************************************
;                                                                             *
;    Filename:      Projet.asm                                                *
;    Date:          2023/Dec/04                                               *
;    File Version:  version 3                                                 *
;                   Combinaison des bases de routines                         *
;                   De Harold et Xavier                                       *
;                                                                             *
;                                                                             *
;    Author:         Lemelin C.O., Malbrouk H., Champoux X.                   *
;    Company:        CÃ©gep Limoilou Campus de QuÃ©bec                          *
;                    DÃ©partement des technologies du gÃ©nie Ã©lectrique         *
;                    Technologies des SystÃ¨mes OrdinÃ©s                        *
;******************************************************************************
;                                                                             *
;    Files required: p16f88.inc  pour la dÃ©finition des registres du pic16f88 *
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
     #include <p16F88.inc>     ; DÃ©finition des registres spÃ©cifiques au CPU.
     
     
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
#define      BITX	           vUnBit,0     

     
;************************************ PWM *************************************
#define      FLAG1             vFlag,1
#define      FLAG2             vFlag,2
#define      FLAG3             vFlag,3

;************************************ ADC *************************************
#define      ADCCOORDY        0xC5     
#define      ADCCOORDX        0xCD     
#define      ADCPINCE         0xD5     
#define      ADCBALANCE       0xDD     

;************************************ Buffer ************************************
#define	     RXINT  	   	   	PIR1,RCIF ;
#define      MASKIN            	0x07
#define	     SUBST			STATUS,Z;

;***** VARIABLE DEFINITIONS  **************************************************
w_temp        EQU     0x71     ; variable used for context saving 
status_temp   EQU     0x72     ; variable used for context saving
pclath_temp   EQU     0x73     ; variable used for context saving
FSR_temp      EQU     0x74     ; variable used for context saving




;V   osVariables  EQU     0x20     ; Mettre ici vos Variables
     CBLOCK  0x20
     vTrame0  
     vTrame1  
     vTrame2
     vTrame3
     vTrame4
     vTrame5
     vTrame6
     vTrame7
     
     vBase
     vEpaule
     vCoude
     vPoignet
     vPince
     
     vTramePTRIn
     vTramePTROut
     vIndiceTrame
     vUnBit
     vAck
     
     vAddHigh
     vAddLow
     vBoucleHigh
     vBoucleLow
     
     vChannel
     vComptByte
     vCompteur5Ms
     vCompteur1ms
     vEcrireMem
     vLireMem
     
     vResetInstructPCA
     vMoteur
     vPwm
     vPwmHigh
     vReadBit
     vReadByte
     vReceive
     vWriteBit
     vWriteByte
     
     vDeviceAddrPCA
     vInputCharacter


     vChannelAD
     vADCHaut
     vADCBas
     vPincePres
     vBalancePoid
     vADCX
     vADCY
     vTrameChecksum
     vTrameChecksumCheck
    
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
     call    InitRS232
     call    ResetPCA9685
     call    SetFreqPCA9685

    clrf     vTramePTRIn
    clrf     vTramePTROut	
    BCF	     RXINT

;Boucle127x256
     movlw   0x7F
     movwf   vBoucleHigh
     movlw   0xff
     movwf   vBoucleLow

     
Encore    
    ;boucle 
    
   
    decfsz   vBoucleHigh, F
    goto     Encore

    decfsz   vBoucleLow, F
    goto     Encore
    
    movlw    0x7F
    movwf    vBoucleHigh 
    movlw    0xff
    movwf    vBoucleLow
    
    call     LireCoord 
    call     LirePince
    call     LireBalance    
    call     TransmetTrame
    ;call     TraitementBuffer
    ;call     Delai1mS

    ;call     TrameChecksumReceive

    
;    movfw    vTrameChecksumCheck 
 ;   subwf    vTrameChecksum, 1
  ;  btfsc    STATUS,Z
   ; Goto     BadCheckSum
   ; call     TransmetMoteursPWM
    

;BadCheckSum 
    goto    Encore

;*********************************routines*************************************
#include <FonctionsI2C.asm>
#include <FonctionsADC.asm>
#include <FonctionsRS232.asm>
#include <FonctionsPWM.asm>
#include <FonctionsDelai.asm>
#include <RoutineRxInt.asm>

;*************************************TransmetTrame***************************
;	Nom de la fonction : Transmettrame			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C.				      
;	Description : 	Routine de transmission de la communication série RS-232.
;                   Sur le PIC16F88. Transmet 8 characteres
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA	
;	Paramètres de sortie : NA		
;	Variables utilisées : NA
;	Equate : NA
;	#Define : NA 
;
;******************************************************************************
TransmetTrame
    movlw	 0x47    ;G 
    call	 Tx232
    movlw	 0x4f   ;O
    call	 Tx232
    movfw	 vADCX
    call	 Tx232
    movfw	 vADCY
    call	 Tx232
    movfw	 vPincePres
    call	 Tx232
    movfw	 vBalancePoid
    call	 Tx232
    movlw	 0x00
    call	 Tx232
    movfw	 vTrameChecksum
    call	 Tx232
    return
; fin routine Transmettrame----------------------------------------------------

;*************************************Tx232************************************
;	Nom de la fonction : Tx232			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de transmission de la communication série RS-232.
;                   Sur le PIC16F88. Transmet 8 characteres
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA	
;	Paramètres de sortie : NA		
;	Variables utilisées : NA
;	Equate : NA
;	#Define : NA 
;
;******************************************************************************
TrameChecksumSend
    clrf     vTrameChecksum
    movlw    0x47
    addwf    vTrameChecksum, F
    movlw    0x4f
    addwf    vTrameChecksum, F
    movfw    vADCX
    addwf    vTrameChecksum, F
    movfw    vADCY
    addwf    vTrameChecksum, F
    movfw    vPincePres
    addwf    vTrameChecksum, F
    movfw    vBalancePoid
    addwf    vTrameChecksum, F
    return
    
    ;*************************************Tx232************************************
;	Nom de la fonction : Tx232			
;	Auteur : Pierre Chouinard		
;       Date de création : 10-10-2009	
;       Date de modification : 21-07-2018	A.C. 					      
;	Description : 	Routine de transmission de la communication série RS-232.
;                   Sur le PIC16F88. Transmet 8 characteres
;							
;	Fonctions appelées : NA		
;	Paramètres d'entrée : NA	
;	Paramètres de sortie : NA		
;	Variables utilisées : NA
;	Equate : NA
;	#Define : NA 
;
;******************************************************************************
TrameChecksumReceive
    clrf     vTrameChecksumCheck
    movlw    0x47
    addwf    vTrameChecksumCheck, F
    movlw    0x4f
    addwf    vTrameChecksumCheck, F
    movfw    vBase
    addwf    vTrameChecksumCheck, F
    movfw    vEpaule
    addwf    vTrameChecksumCheck, F
    movfw    vCoude
    addwf    vTrameChecksumCheck, F
    movfw    vPoignet
    addwf    vTrameChecksumCheck, F
    movfw    vPince
    addwf    vTrameChecksumCheck, F
    return
    
    
TransmetMoteursPWM
    movlw    0x00
    movwf    vMoteur
    movfw    vBase
    movwf    vPwm
    call     SetPWMPCA9685
    movlw    0x01
    movwf    vMoteur
    movfw    vEpaule
    movwf    vPwm
    call     SetPWMPCA9685
    movlw    0x02
    movwf    vMoteur
    movfw    vCoude
    movwf    vPwm
    call     SetPWMPCA9685
    movlw    0x03
    movwf    vMoteur
    movfw    vPoignet
    movwf    vPwm
    call     SetPWMPCA9685
    movlw    0x04
    movwf    vMoteur
    movfw    vPince
    movwf    vPwm
    call     SetPWMPCA9685
    return
   
;*******************************************************************************
;                                 routines standard                           : 
;*******************************************************************************

;******************************* InitPic **************************************
;       Nom de la fonction : InitPic                    
;       Auteur : Alain Champagne
;       Date de creation : 23-09-2018                                
;       Description :      Routine d'initiation des registres du PIC.
;                          - RP1 Ã  0 pour Ãªtre toujours dans Bank 0 et 1,
;                          - DÃ©sactiver les interruptions,
;                          - DÃ©sactiver les entrÃ©es analogiques,
;                          - PortA en entrÃ©e,
;                          - PortB en entrÃ©e sauf: Bits I2C et LEDs en sortie.
;                                                       
;       Fonctions appelees : NA 
;       ParamÃ¨tres d'entree : NA  
;       ParamÃ¨tres de sortie : NA 
;       Variables utilisees : NA  
;       Include : Fichier P16F88.inc
;       Equates : NA
;       #Defines : BANK0, BANK1 
;                                               
;******************************************************************************
InitPic
    bcf      STATUS, RP1       ; Pour s'assurer d'Ãªtre dans les bank 0 et 1 
    BANK1                     ; Select Bank1        
    bsf      INTCON, PEIE 
    bsf	    PIE1,RCIE
    clrf     ANSEL             ; DÃ©sactive les convertisseurs reg ANSEL 0x9B        
    movlw    b'01111000'       ; osc internal 8 Mhz
    movwf    OSCCON
    movlw    b'11111111'       ; Remplacer les x par des 1 ou 0.
    movwf    TRISA             ; PortA en entree         
    movlw    b'11100100'       ; Bits en entrÃ©es sauf,
    movwf    TRISB             ; RB3 (Led1), RB4 (Led2) en sortie.
    movlw    0x00              ; Configure RA0 as analog input
    movwf    ADCON1      
    bsf      INTCON,GIE        ;active les interruptions   
    BANK0                  ; Select Bank0
    bcf      PIR1,RCIF
    return

; fin routine InitPic ---------------------------------------------------------

     


;****************************** Interruption **********************************
Interruption


    movwf    w_temp         ; save off current W register contents
    movfw    STATUS       ; move STATUS register into W register
    movwf    status_temp    ; save off contents of STATUS register
    movfw    PCLATH       ; move PCLATH register into W register
    movwf    pclath_temp    ; save off contents of PCLATH register


; isr code can go here or be located as a call subroutine elsewhere

    btfss    PIR1,RCIF
    goto     IntOut    
    
    btfss    RXINT
    goto     Interruption
    call     Rx232
    BCF	     RXINT
    movfw    vTramePTRIn
    andlw    MASKIN
    movwf    vTramePTRIn
    addlw    0x20
    movwf    FSR
    movfw    vReceive
    movwf    INDF	
    INCF     vTramePTRIn
    movfw    vTramePTRIn
    andlw    MASKIN
    movwf    vTramePTRIn

    movfw    FSR_temp
    movwf    FSR
    
    
IntOut    
    movf     pclath_temp,w  ; retrieve copy of PCLATH register
    movwf    PCLATH         ; restore pre-isr PCLATH register contents
    movf     status_temp,w  ; retrieve copy of STATUS register
    movwf    STATUS         ; restore pre-isr STATUS register contents
    swapf    w_temp,f
    swapf    w_temp,w       ; restore pre-isr W register contents

    

    

     retfie                   ; return from interrupt


; fin de la routine Interruption-----------------------------------------------

    END                       ; directive 'end of program'


