/****************************************************************************************
   Nom du fichier :LCDC.h
   Auteur : Xavier Champoux                 
      Date de création : 20-09-2023 
        Fichier de déclaration et de définition pour les fonctions de traitement du 
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
//  Auteur: Xaveir Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vLcdEcrireCaract(unsigned char ucCaract, unsigned char ucLigne, unsigned char ucColonne);
//
//  Auteur: Xavier Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vAfficheLigneLCD(unsigned char ucTab[],unsigned char ucLigne);
//
//  Auteur: Xavier Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vAfficheLCDComplet(unsigned char ucTab[4][21]);
//
//  Auteur: Xavier Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vLoadCGRAM(unsigned char ucTab[8][8]);
//
//  Auteur: Xavier Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
// *************************************************************************************************
void vEffaceLCD();
//
//  Auteur: Xavier Champoux 	
//  Date de création :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
#endif 












