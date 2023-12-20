/**************************************************************************************************
Nom du fichier : I2C.C
Auteur : Xavier Champoux                 
Date de création : 06-09-2023
Version 1.0
	 
	Ce programme sert à la créationde fonctions pour la mémoire 24LC32 et la communication I2C
		
		Versions:
		1.0 - 06 Septembre 2023:  Première version 
	
***************************************************************************************************/

// *************************************************************************************************
//  INCLUDES
// *************************************************************************************************	

#include <stdio.h>          // Prototype de declarations des fonctions I/O
	
#include "ds89c450.h"				// Définition des bits et des registres du microcontrôleur
#include "Dallas.h"
#include "I2C.h"
// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************
#define VERSION_MAJEUR  		1
#define VERSION_MINEUR  		0

// *************************************************************************************************
//  FONCTIONS LOCALES
// *************************************************************************************************

void vI2CDelai (unsigned int iTemps);
void vI2CEcrire1Bit(bit bBit);
bit blI2CLire1Bit();


// *************************************************************************************************
//  STRUCTURES ET UNIONS
// *************************************************************************************************
/* VIDE */

// *************************************************************************************************
// VARIABLES GLOBALES
// *************************************************************************************************
/* VIDE */

// *************************************************************************************************
// VARIABLES LOCALES
// *************************************************************************************************
/* VIDE */

void vI2CStartBit(void)
//
//  Auteur: Xavier Champoux	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Effectue un start bit sur SDA et SCL
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : 	Passage de 1 à 0 sur la ligne SDA durant un niveau haut de SCL
// *************************************************************************************************
{
	//NOTE: I2C_DELAI est un #define qui est = 1
	SDA = 1;
	vI2CDelai (I2C_DELAI);
	SCL = 1;
	vI2CDelai (I2C_DELAI);
	SDA = 0;
	vI2CDelai (I2C_DELAI);
	SCL = 0;
	vI2CDelai (I2C_DELAI);
}
// *************************************************************************************************
void vI2CStopBit(void)
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Effectue un stop bit sur SDA et SCL
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : 	Passage de 0 à 1 sur la ligne SDA durant un niveau haut de SCL
// *************************************************************************************************
{
	//NOTE: I2C_DELAI est un #define qui est = 1
	SCL = 0;
	vI2CDelai (I2C_DELAI);
	SDA = 0;
	vI2CDelai (I2C_DELAI);
	SCL = 1;
	vI2CDelai (I2C_DELAI);
	SDA = 1;
	vI2CDelai (I2C_DELAI);
}
// *************************************************************************************************
void vI2CDelai (unsigned int iTemps)
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Délai pour la communication I2C
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Variables utilisées  : Aucun
//	Equate							 : Aucun
//	#Define	   					 : Aucun
// *************************************************************************************************
	{
		while (iTemps > 0)
		{
			iTemps --;
		}
	}
// *************************************************************************************************
	void vI2CEcrire1Bit(bit bBit)
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Ecrire un bit sur SDA dans une communicatgion I2C
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Écriture d'un bit 
// *************************************************************************************************
{
	SCL = 0;
  vI2CDelai (I2C_DELAI);
	SDA = bBit;
  vI2CDelai (I2C_DELAI);
	SCL = 1;
  vI2CDelai (I2C_DELAI);
	SCL = 0;
  vI2CDelai (I2C_DELAI);
}
// *************************************************************************************************
	bit blI2CLire1Bit()
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Écriture d'un bit 
// *************************************************************************************************
{
	bit bLecture;
	SDA = 1;
	vI2CDelai (I2C_DELAI);
	SCL = 0;
	vI2CDelai (I2C_DELAI);
	SCL = 1;
	vI2CDelai (I2C_DELAI);
	bLecture = SDA;
	vI2CDelai (I2C_DELAI);
	SCL = 0;
	vI2CDelai (I2C_DELAI);
	return bLecture;
}
// *************************************************************************************************
void vI2CEcrire8Bits(unsigned char ucTxData)
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Écriture d'un bit 
// *************************************************************************************************
{
	unsigned char i;
	for (i=0; i<8; i++)
	{
		if ((ucTxData & 0x80)==0x80)
		{
			vI2CEcrire1Bit(1);
		}
		else
		{
			vI2CEcrire1Bit(0);
		}
		
		ucTxData = ucTxData << 1;				
	}
	blI2CLire1Bit();
}

// *************************************************************************************************
unsigned char ucI2CLire8Bits (bit bAckValue)
//
//  Auteur: Xavier Champoux 	
//  Date de création :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		       : Écriture d'un bit 
// *************************************************************************************************
{
	unsigned char ucRecu = 0x00;
	unsigned char i;
	for (i=0; i<8; i++)
	{
		ucRecu = ucRecu << 1;
		if(blI2CLire1Bit() != 0)
		{
			ucRecu = ucRecu+1;
		}
	}
	vI2CEcrire1Bit(bAckValue);
	return ucRecu;
}
