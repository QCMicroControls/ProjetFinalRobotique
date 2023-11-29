/**************************************************************************************************
Nom du fichier : Lab2I2C
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
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  20 mai 2021
//  Version 1.0
//
//  Description: Effectue un start bit sur SDA et SCL
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : 	Passage de 1 � 0 sur la ligne SDA durant un niveau haut de SCL
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
//  Date de cr�ation :  06 septembre 2023
//  Version 1.0
//
//  Description: Effectue un stop bit sur SDA et SCL
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : 	Passage de 0 � 1 sur la ligne SDA durant un niveau haut de SCL
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
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  20 mai 2021
//  Version 1.0
//
//  Description: D�lai pour la communication I2C
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Variables utilis�es  : Aucun
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
//  Date de cr�ation :  06 septembre 2023
//  Version 1.0
//
//  Description: Ecrire un bit sur SDA dans une communicatgion I2C
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : �criture d'un bit 
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
//  Date de cr�ation :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : �criture d'un bit 
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
//  Date de cr�ation :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : �criture d'un bit 
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
//  Date de cr�ation :  06 septembre 2023
//  Version 1.0
//
//  Description: Lire un bit sur SDA dans une communicatgion I2C
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		       : �criture d'un bit 
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