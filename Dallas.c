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
#include "Dallas.h"
#include "I2C.h"



// *************************************************************************************************
void vInitPortSerie(void)
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
   SCON0 = 0x50;        // Selectione mode 1, 8-bit avec reception      
   TMOD  = TMOD | 0x20; // timer 1, mode 2, 8-bit auto reload        
   TH1   = 0xFF;        // a 11.0592MHz: FA=4800,FD=9600,FE=14400 et FF=28800    
   PCON  = PCON | 0x80; // Le bit SMOD = 1 pour vitesse * 2 du port serie 
   TR1   = 1;           // Active le timer 1                          
   TI_0  = 1;           // Pour pouvoir envoyer un premier charactere    
}

// *************************************************************************************************
void vEcrireMemI2C(unsigned char ucData, unsigned int uiAdr)
// Auteur : Xavier Champoux		           Date de création : 10-12-2023				      
// Modification : Harlod Malbrouck & Charles-Olivier Lemelin
// Description :  Fonction de transmission d'un octet de donnée 
//                provenant de la mémoire I2C.
//							
// Paramètres d'entrée :  Octet à écrire et Addresse à laquelle on veut l'écrire
//														
// Paramètres de sortie : Aucun		
// 						
// *************************************************************************************************
{
	unsigned char ucTemp;
	unsigned int i;
	vI2CStartBit();
	vI2CEcrire8Bits (0xA0);
	ucTemp = uiAdr >> 8;
	vI2CEcrire8Bits (ucTemp);
	ucTemp = uiAdr;
	vI2CEcrire8Bits (ucTemp);
	vI2CEcrire8Bits (ucData);	
	vI2CStopBit();
	for(i=0 ; i<5000 ; i++);
}

// *************************************************************************************************
unsigned char ucLireMemI2C(unsigned int uiAdr)
// Auteur : Xavier Champoux		     Date de création : 10-12-2023				      
// Modification : Harold Malbrouck & Charles-Olivier Lemelin
// Description  : Fonction de réception d'un octet de donnée provenant de la
//                mémoire I2C. Si le circuit ne répond pas, on l'indique
//                à l'écran.  
//
// Paramètres d'entrée :  uiAdr (adresse où l'on veut lire)		
// Paramètres de sortie : ucRecu (Valeur lue)		
// 					
// *************************************************************************************************
{
	unsigned char ucTemp;
	unsigned char ucRecu;
	vI2CStartBit();
	vI2CEcrire8Bits(0xA0);
	ucTemp = uiAdr >> 8;
	vI2CEcrire8Bits (ucTemp);
	ucTemp = uiAdr;
	vI2CEcrire8Bits (ucTemp);	
	vI2CStopBit();
	vI2CStartBit();
	vI2CEcrire8Bits(0xA1);
	ucRecu = ucI2CLire8Bits(1);
	vI2CStopBit();
	return ucRecu;
}

// ************************************************************************************************
void vInitTimer0(void)
//
//  Auteur: Stéphane Deschênes 	
//  Date de création :  24 sept 2019
//  Version 1.0
//
//  Description: Initialise le timer 0 pour qu'il fonctionne sur 16 bits
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		 			 : Aucun
//
// ************************************************************************************************
{
	TMOD |= 0x01;        //0x01 set le timer 0 as a 16-bit timer
	TH0   = 0x4C;        //Initialize le timer 0 pour 10ms
        TL0   = 0x00;        //^^^^^^^^
	TR0   = 1;           //start timer 0
	TF0   = 0;           //met le flag a 0
}

// ************************************************************************************************
void vInitIntTimer0(void)
//
//  Auteur:Xavier Champoux 	
//  Date de création :  10/12/2023
//  Version 1.0
//
//  Description: active l'interuption du timer 0
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		 			 : Aucun
//
// ************************************************************************************************
{
	TF0 = 1;          //Enable timer 0 interruption
}
// ************************************************************************************************
