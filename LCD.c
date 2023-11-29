/**************************************************************************************************
Nom du fichier : LCD.c
Auteur : Xavier Champoux                 
Date de cr�ation : 06-09-2023
Version 1.0
	 
	Ce programme sert � la cr�ationde fonctions pour la m�moire 24LC32 et la communication I2C
		
		Versions:
		1.0 - 06 Septembre 2023:  Premi�re version 
	
***************************************************************************************************/

// *************************************************************************************************
//  INCLUDES
// *************************************************************************************************	

#include <stdio.h>          // Prototype de declarations des fonctions I/O
	
#include "ds89c450.h"				// D�finition des bits et des registres du microcontr�leur
#include "LCD.h"
// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************


// *************************************************************************************************
// VARIABLES LOCALES
// *************************************************************************************************

unsigned char xdata *PtrLCDConfig = 0x8000;
unsigned char xdata *PtrLCDBusy = 0x8001;
unsigned char xdata *PtrLCDChar = 0x8002;

// *************************************************************************************************
//  FONCTIONS LOCALES
// *************************************************************************************************

void vAttendreBusyLcd(void);

// *************************************************************************************************
void vAttendreBusyLcd(void)
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
{
	unsigned char i;
	while ( *PtrLCDBusy & 0x80 )
  {
  };
  for(i=0; i<10; i++);	
}
// *************************************************************************************************
void vInitialiseLCD(void)
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
{
	unsigned int i; 
  
	for(i = 0; i < 12000; i++);	//Delai d'activation de l'ecran au demarrage	
  vAttendreBusyLcd();
	*PtrLCDConfig = 0x38;				//Mode �cran 8 bit, r�solution charact�re 5x7, mode 2 lignes
 	vAttendreBusyLcd();
	*PtrLCDConfig = 0x0C;				//Display on, cursor & brink off
	vAttendreBusyLcd();
	*PtrLCDConfig = 0x06;				//Curseur en mode incrementation, display
	vAttendreBusyLcd();	
  *PtrLCDConfig = 0x01;				//Clear display & return to address 0
	vAttendreBusyLcd();
}
// *************************************************************************************************
void vLcdEcrireCaract(unsigned char ucCaract, unsigned char ucLigne, unsigned char ucColonne)
//
//  Auteur: Xavier Champoux 	
//  Date de cr�ation :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
{
	vAttendreBusyLcd();
	*PtrLCDConfig = ucLigne + ucColonne;
	vAttendreBusyLcd();
	*PtrLCDChar = ucCaract;
}
//// *************************************************************************************************
//void vAfficheLigneLCD(unsigned char ucTab[],unsigned char ucLigne)
////
////  Auteur: Xavier Champoux 	
////  Date de cr�ation :  20-09-2023
////  Version 1.0
////
////  Description: 
////  Param�tres d'entr�es : Aucun
////  Param�tres de sortie : Aucun
////  Notes     		       : Aucune
//// *************************************************************************************************
//{
//	unsigned char i = 0;
//	for (i=0; i<20; i++)
//	{
//		vLcdEcrireCaract(ucTab[i], ucLigne, i);
//	}
//}
//*************************************************************************************************
void vAfficheLCDComplet(unsigned char ucTab[4][21])
//
//  Auteur: Xavier Champoux 	
//  Date de cr�ation :  20-09-2023
//  Version 1.0
//
//  Description: 
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : Aucune
// *************************************************************************************************
{
	unsigned char i = 0;
	unsigned char j = 0;
	unsigned char ucLineFull;
	for (i=0; i<20; i++)
	{
		for (j=0; j<4; j++)
		{
			if(j==0){ucLineFull = LIGNE0;}
			if(j==1){ucLineFull = LIGNE1;}
			if(j==2){ucLineFull = LIGNE2;}
			if(j==3){ucLineFull = LIGNE3;}
			vLcdEcrireCaract(ucTab[j][i], ucLineFull, i);
		}
	}
}
//// *************************************************************************************************
//void vEffaceLCD()
////
////  Auteur: St�phane Desch�nes, 
////  Date de cr�ation :  01-09-2019
////  Version 1.0
////
////  Description: Fait l'animation demand�e, sur la ligne demand�e
////  Param�tres d'entr�es : 
////												 ucTab: Un tableau contenant des caract�res voulus � chacune des �tapes d'animation
////												 				Les �tapes sont faites ligne par ligne.
////												 ucLigne: Ligne sur laquelle on veut faire l'animation
////  Param�tres de sortie : Aucun
////  Notes     		       : Aucune
//// *************************************************************************************************
//{
//	*PtrLCDConfig = 0x01;				//Clear display & return to address 0
//	vAttendreBusyLcd();
//}
// *************************************************************************************************
void vLoadCGRAM(unsigned char ucTab[8][8])
//
// Auteur: St�phane Desch�nes 
// Date de cr�ation : 01-09-2019
// Version 1.0
//
// Description: Met dans la m�moire CGRAM du contr�leur de LCD un tableau complet 
// Param�tres d'entr�es : Tableau qui contient toutes les caract�res sp�ciaux voulus
// Param�tres de sortie : Aucun
// Notes : Sert � cr�er des caract�res sp�ciaux
// *************************************************************************************************
{
 unsigned char ucCompteurCaract;
 unsigned char ucCompteurOctetsDansCaract;
 // Boucle pour chacun des 8 caract�res
 for (ucCompteurCaract= 0; ucCompteurCaract < 8; ucCompteurCaract++)
 {
	// Boucle pour chacune des 8 lignes dans un caract�re
	for(ucCompteurOctetsDansCaract = 0; ucCompteurOctetsDansCaract < 8; ucCompteurOctetsDansCaract++)
	{
		vAttendreBusyLcd();
		*PtrLCDConfig = 0x40 + (8*ucCompteurCaract) + ucCompteurOctetsDansCaract;
		vAttendreBusyLcd();
		*PtrLCDChar = ucTab[ucCompteurCaract][ucCompteurOctetsDansCaract];
	}
 }
}