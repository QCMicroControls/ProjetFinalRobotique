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
#include "Dallas.h"
#include "I2C.h"



// *************************************************************************************************
void vInitPortSerie(void)
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
	SCON0 = 0x50;        	// Selectione mode 1, 8-bit avec reception      
   TMOD  = TMOD | 0x20; // timer 1, mode 2, 8-bit auto reload        
   TH1   = 0xFF;        // a 11.0592MHz: FA=4800,FD=9600,FE=14400 et FF=28800    
   PCON  = PCON | 0x80; // Le bit SMOD = 1 pour vitesse * 2 du port serie 
   TR1   = 1;           // Active le timer 1                          
   TI_0  = 1;           // Pour pouvoir envoyer un premier charactere    
}

// *************************************************************************************************
// Auteur : Alain Champagne		           Date de cr�ation : 30-05-2007				      
// Modification : Pierre Chouinard 21/08/2009
// Description :  Fonction de transmission d'un octet de donn�e 
//                provenant de la m�moire I2C.
//							
		
// Param�tres d'entr�e :  ucData - Octet � �crire
//												iAdresse - Addresse o� l'on veut �crire dans la m�moire.		
// Param�tres de sortie : Aucun		
// 						
void vEcrireMemI2C(unsigned char ucData, unsigned int uiAdr)
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
// Auteur : Alain Champagne		     Date de cr�ation : 30-05-2007				      
// Modification : Pierre Chouinard   21/08/2009
//              : Fran�ois Cardinal  29/08/2018
// Description  : Fonction de r�ception d'un octet de donn�e provenant de la
//                m�moire I2C. Si le circuit ne r�pond pas, on l'indique
//                � l'�cran.  
// Param�tres d'entr�e :  iAdr (adresse o� l'on veut lire)		
// Param�tres de sortie : ucData (Valeur lue)		
// 					

unsigned char ucLireMemI2C(unsigned int uiAdr)
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
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  24 sept 2019
//  Version 1.0
//
//  Description: Initialise le timer 0 pour qu'il fonctionne sur 16 bits
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		 			 : Aucun
//
// ************************************************************************************************
{
	TMOD |= 0x01;        //0x01 set le timer 0 as a 16-bit timer
	TH0   = 0x4C;        //Initialize le timer 0 pour 10ms
  TL0   = 0x00;
	TR0   = 1;           //start timer 0
	TF0   = 0;
}

// ************************************************************************************************
void vInitIntTimer0(void)
//
//  Auteur: St�phane Desch�nes 	
//  Date de cr�ation :  24 sept 2019
//  Version 1.0
//
//  Description: active l'interuption du timer 0
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		 			 : Aucun
//
// ************************************************************************************************
{
	TF0 = 1;          //Enable timer 0 interruption
}
// ************************************************************************************************