/****************************************************************************************
   Nom du fichier : I2C.h
   Auteur : St�phane Desch�nes                  
      Date de cr�ation : 19-03-2006 
        Fichier de d�claration et de d�finition pour les fonctions de traitement du 
        I2C.
  
****************************************************************************************/

#ifndef LCD_H 
#define LCD_H

#define LIGNE0 0x80
#define LIGNE1 0xC0
#define LIGNE2 0x94
#define LIGNE3 0xD4


// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************

 
// *************************************************************************************************
//  LES PROTOTYPES DES FONCTIONS
// *************************************************************************************************
  
// *************************************************************************************************
void vInitialiseLCD(void);
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vLcdEcrireCaract(unsigned char ucCaract, unsigned char ucLigne, unsigned char ucColonne);
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vAfficheLigneLCD(unsigned char ucTab[],unsigned char ucLigne);
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vAfficheLCDComplet(unsigned char ucTab[4][21]);
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vLoadCGRAM(unsigned char ucTab[8][8]);
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vEffaceLCD();
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  25-08-2019
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
#endif 












