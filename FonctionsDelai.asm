


;********************************** Delai5uS **********************************
;       Nom de la fonction : Delai5uS
;       Auteur : Alain Champagne
;       Date de creation : 23-09-2018
;       Description :      Fonction de Delai de 5 microSeconde par
;               non opération et temps d'exécution.
;               Pour opération à 8Mhz
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
Delai5uS
    nop
    nop
    nop
    nop
    nop
    return

; fin routine Delai5uS---------------------------------------------------------

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
Delai1mS
     movlw  .152
     movwf  vCompteur1ms
Encore1ms     
     call Delai5uS
     decfsz vCompteur1ms,F
     goto Encore1ms
     return