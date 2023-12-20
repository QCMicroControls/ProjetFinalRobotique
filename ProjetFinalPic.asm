
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
;    Company:        Cégep Limoilou Campus de Québec                          *
;                    Département des technologies du génie électrique         *
;                    Technologies des Systèmes Ordinés                        *
;******************************************************************************
;                                                                             *
;    Files required: p16f88.inc  pour la définition des registres du pic16f88 *
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

;************************************ ADC *************************************
#define       ADCCOORDY        0xC5     
#define       ADCCOORDX        0xCD     
#define       ADCPINCE         0xD5     
#define       ADCBALANCE       0xDD     

;***** VARIABLE DEFINITIONS  **************************************************
;w_temp        EQU     0x71     ; variable used for context saving 
;status_temp   EQU     0x72     ; variable used for context saving
;pclath_temp   EQU     0x73     ; variable used for context saving


;V   osVariables  EQU     0x20     ; Mettre ici vos Variables
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
   
     vTrame0  
     vTrame1  
     vTrame2
     vTrame3
     vTrame4
     vTrame5
     vTrame6
     vTrame7

     vChannelAD
     vADCHaut
     vADCBas
     vPincePres
     vBalancePoid


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
     
    ;premiers charactères de la trame


Boucle127x256
     movlw   0x7F
     movwf   vBoucleHigh
     movlw   0xff
     movwf   vBoucleLow

     
Encore    
     ;boucle 
     decfsz vBoucleHigh, 0
     goto Encore
     decfsz  vBoucleLow, 0
     goto Encore
     
     movlw   0x7F
     movwf   vBoucleHigh
     movlw   0xff
     movwf   vBoucleLow
     
     


    goto    Encore

;*********************************routines*************************************
#include <FonctionsI2C.asm>
#include <FonctionsADC.asm>
#include <FonctionsRS232.asm>

LIRE


*******************************************************************************
;                                 routines standard                           : 
*******************************************************************************

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
     movlw   0x00              ; Configure RA0 as analog input
     movwf   ADCON1      
     BANK0                     ; Select Bank0
     return

; fin routine InitPic ---------------------------------------------------------


;****************************** Interruption **********************************
Interruption

;    movwf     w_temp         ; save off current W register contents
;    movfw      STATUS,w       ; move STATUS register into W register
;    movwf     status_temp    ; save off contents of STATUS register
;    movfw      PCLATH,W       ; move PCLATH register into W register
;    movwf     pclath_temp    ; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere


;    movfw      pclath_temp,w  ; retrieve copy of PCLATH register
;    movwf     PCLATH         ; restore pre-isr PCLATH register contents
;    movfw      status_temp,w  ; retrieve copy of STATUS register
;    movwf     STATUS         ; restore pre-isr STATUS register contents
;    swapf     w_temp,f
;    swapf     w_temp,w       ; restore pre-isr W register contents
    retfie                   ; return from interrupt

; fin de la routine Interruption-----------------------------------------------



        END                       ; directive 'end of program'