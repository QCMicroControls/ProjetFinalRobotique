/*****************************Contr�le Carte Dallas*******************************/
/* 
   Nom du fichier : Dallas.c
   Auteur : Xavier Champoux, Harold Malbrouck, Charles-Olivier Lemelin

Version 1.0 25-06-06
Date de modification :  09-11-09
 
D 
 
     
    
      
*****************************************************************************************/

//-------------- header files  -----------------
#include "ds89c450.h"				// D�finition des bits et des registres du microcontr�leur
#include "ClavierI2C.h"
#include "Dallas.h"
#include "I2C.h"



// *************************************************************************************************
unsigned char ucReadKeyI2C(void)
//   Auteur : Alain Champagne                  
//      Date de cr�ation : 22-06-06   
//   Description : Cette fonction initialise les SFRs pour permettre une communication s�rie
//                 � 57600 bauds sans interruptions. La communication s�rie utilise le timer
//                 1. On ne pourra donc pas utiliser ce timer lorsque la communication s�rie 
//                 sera employ�e.
//          
//   Param�tres d'entr�e : Aucun.
//   Param�tres de sortie : Aucun.                
//   Variables utilis�es : Aucun.
//***************************************************************************************************
{
	unsigned int uiAddresse = 0x28;
  unsigned char ucTouche = 0x20;
	if (INT == 0)
	{
		uiAddresse = uiAddresse + ucI2CLire8Bits(1);//ADDRESSE = 0X28+LECTURE I2C AVEC NACK
		ucTouche = ucLireMemI2C(uiAddresse);        //TOUCHE LUE DANS LA MEMOIRE I2C A L'ADDRESSE POINTEE
	} 
	return ucTouche;
}
// **************************************************************************************************
void vTraiteTouche (unsigned char ucTouche)
//  Auteur: Xavier Champoux 	
//  Date de cr�ation :  29 novembre 2023
//  Version 1.0
//
//  Description					 : Traite les touches lues sur le clavier I2C
//  Param�tres d'entr�es : Touche lue sur le clavier I2C
//  Param�tres de sortie : Aucune
//
//  Notes     		       : Cette fonction est faite pour lire le clavier sans utiliser les interruptions
//												 Pour ne pas manquer de touches appuy�es par l'utilisateur, il est recommand� 
//												 d'appeler cette fonction aux 10 ms.
// *************************************************************************************************
{
	
}
	