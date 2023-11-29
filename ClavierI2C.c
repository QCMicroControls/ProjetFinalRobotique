/*****************************Contrôle Carte Dallas*******************************/
/* 
   Nom du fichier : Dallas.c
   Auteur : Xavier Champoux, Harold Malbrouck, Charles-Olivier Lemelin

Version 1.0 25-06-06
Date de modification :  09-11-09
 
D 
 
     
    
      
*****************************************************************************************/

//-------------- header files  -----------------
#include "ds89c450.h"				// Définition des bits et des registres du microcontrôleur
#include "ClavierI2C.h"
#include "Dallas.h"
#include "I2C.h"



// *************************************************************************************************
unsigned char ucReadKeyI2C(void)
//   Auteur : Alain Champagne                  
//      Date de création : 22-06-06   
//   Description : Cette fonction initialise les SFRs pour permettre une communication série
//                 à 57600 bauds sans interruptions. La communication série utilise le timer
//                 1. On ne pourra donc pas utiliser ce timer lorsque la communication série 
//                 sera employée.
//          
//   Paramètres d'entrée : Aucun.
//   Paramètres de sortie : Aucun.                
//   Variables utilisées : Aucun.
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
//  Date de création :  29 novembre 2023
//  Version 1.0
//
//  Description					 : Traite les touches lues sur le clavier I2C
//  Paramètres d'entrées : Touche lue sur le clavier I2C
//  Paramètres de sortie : Aucune
//
//  Notes     		       : Cette fonction est faite pour lire le clavier sans utiliser les interruptions
//												 Pour ne pas manquer de touches appuyées par l'utilisateur, il est recommandé 
//												 d'appeler cette fonction aux 10 ms.
// *************************************************************************************************
{
	switch(ucTouche)
	{
		case '1' : ucMoteur = BASE;    break;
		case '2' : ucMoteur = EPAULE;  break;
		case '3' : ucMoteur = COUDE;   break;
		case '4' : ucMoteur = POIGNET; break;
		case '5' : ucMoteur = PINCE;   break;
		case '0' : 
			if (ucIncrement < 17)
			{
				ucIncrement += 4;
			}
			else
			{
				ucIncrement = 1;
			}
		case '*' : 
			switch(ucMoteur)
			{
				case '0' : stState.ucBase    -= ucIncrement; break; 
				case '1' : stState.ucEpaule  -= ucIncrement; break; //  
				case '2' : stState.ucCoude   -= ucIncrement; break; // À
				case '3' : stState.ucPoignet -= ucIncrement; break; // Modifier
				case '4' : stState.ucPince   -= ucIncrement; break; //		
			}
		case '#' : ;break; // A modifier
		case 'A' : ;break; // A modifier
	}
}
	
