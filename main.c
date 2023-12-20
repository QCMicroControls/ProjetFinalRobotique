/**************************************************************************************************
Nom du fichier : main.c
Auteur : Xavier Champoux, Charles-Olivier Lemelin & Harold Malbrouck                  
Date de création : 8 decembre 2023
	Ce programme contient le main du rpojet final de 3eme session de l'equipe numero 4
	
***************************************************************************************************/

// *************************************************************************************************
//  INCLUDES
// *************************************************************************************************	

#include "ds89c450.h"	    // Définition des bits et des registres du microcontrôleur
#include <stdio.h>          // Prototype de declarations des fonctions I/O	
#include "Dallas.h"         // Header file pour les fonctions liees a la carte dallas
#include "LCD.h"            // Header file pour les fonctions liees a l'ecran LCD
#include "ClavierI2C.h"     // Header file pour les fonctions liees au clavier I2C
#include "I2C.h"            // Header file pour les fonctions liees a la commnication I2C

// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************
#define MILIEU 0x66
#define FERME  0x00
#define OUVERT 0xFF
// *************************************************************************************************
//  FONCTIONS LOCALES
// *************************************************************************************************

// *************************************************************************************************
//  STRUCTURES ET UNIONS
// *************************************************************************************************
struct STServoPosition
	{
		unsigned char ucBase;
		unsigned char ucEpaule;
		unsigned char ucCoude;
		unsigned char ucPoignet;
		unsigned char ucPince;
	}stState;
// *************************************************************************************************
// VARIABLES GLOBALES
// *************************************************************************************************

// *************************************************************************************************
// VARIABLES LOCALES
// *************************************************************************************************
unsigned char ucIncrement;		
unsigned int i;
unsigned char ucSequenceActive;
unsigned char ucTouche;
unsigned char ucComptTimer;
unsigned char ucSeq = 0;
unsigned char xdata ucEcranDebutTab [4][21] = { {"1:66 2:66 3:66 4:66 "},
                                                {"5:66 X:FF Y:FF P:FF "},
					        {"B:FF Bloc:--        "},
					        {"05 Seq:0 Step:0 OffL"}
								         };
//unsigned char xdata ucSeqData [][][];																				
// *************************************************************************************************
void main (void)
//
//  Auteur: Stéphane Deschênes 
//
//  Description: Appelé lorsque le programme démarre
//  Paramètres d'entrées 	: Aucun
//  Paramètres de sortie 	: Aucun
//  Notes     		 				: Aucune
//
// *************************************************************************************************
{ 
//////////////INITIALISATIONS///////////////////////////////////////////////////////////////////////
	ucIncrement = 5;
	stState.ucBase = MILIEU;      //PINCE OUVERTE, 4 AUTRES SERVOS AU MILIEU
	stState.ucEpaule = MILIEU;    //^^^^^^^^^^^^^^^^^^^^^^^^
	stState.ucCoude = MILIEU;     //^^^^^^^^^^^^^^^^^^^^^^^^
	stState.ucPoignet = MILIEU;   //^^^^^^^^^^^^^^^^^^^^^^^^
	stState.ucPince = OUVERT;     //^^^^^^^^^^^^^^^^^^^^^^^^
if (ucComptTimer == 4)
{
vInitPortSerie();
vInitTimer0();        //TIMER0 À 50MS
vInitialiseLCD();     //INITIALISE LE LCD
vEcrireMemI2C(0x47, 0x20); //ENVOIE GO POUR DEBUT TRAME
vEcrireMemI2C(0x4F, 0x21); //^^^^^^^^

vEcrireMemI2C(0x42, 0x22); //INITIALISATION POSITION DU BRAS
vEcrireMemI2C(0x42, 0x23); //INITIALISATION POSITION DU BRAS
vEcrireMemI2C(0x42, 0x24); //INITIALISATION POSITION DU BRAS
vEcrireMemI2C(0x42, 0x25); //INITIALISATION POSITION DU BRAS
vEcrireMemI2C(0xFF, 0x26); //INITIALISATION POSITION DU BRAS

vAfficheLCDComplet (ucEcranDebutTab);    //AFFICHAGE DE L'ECRAN DE BASE
}
//////////////PROGRAMME PRINCIPAL///////////////////////////////////////////////////////////////////
	while (1)
	{
		if (ucSequenceActive == 1)
		{
//			stState.ucBase     = SeqData [Seq] [Step] [0];
//			stState.ucEpaule   = SeqData [Seq] [Step] [1];
//			stState.ucCoude    = SeqData [Seq] [Step] [2];
//			stState.ucPoignet  = SeqData [Seq] [Step] [3];
//			stState.ucPince    = SeqData [Seq] [Step] [4];
		}
		ucTouche = ucReadKeyI2C();
		if (ucTouche == 0x20)
		{
			//TRAITER LA TOUCHE
		}
		
		//if(TRAME RECUE)
		{
			vLcdEcrireCaract('O', LIGNE3, 16);
			vLcdEcrireCaract('N', LIGNE3, 17);
			vLcdEcrireCaract('L', LIGNE3, 18);
			vLcdEcrireCaract(' ', LIGNE3, 19);
			//TRAITEMENT DE LA TRAME
		}
		if (ucComptTimer == 6)  //SI 300 MS DE PASSEES
		{
			vLcdEcrireCaract('O', LIGNE3, 16);
			vLcdEcrireCaract('F', LIGNE3, 17);
			vLcdEcrireCaract('F', LIGNE3, 18);
			vLcdEcrireCaract('L', LIGNE3, 19);
		}	
		if (ucComptTimer == 4)  //SI 200 MS DE PASSEES
		{
//			vAfficheEtat();       //AFFICHE L'ETAT DU SYSTEME
	  }
		if (ucSequenceActive == 0)     //si pas de sequence active
		{
			if (ucTouche != 0) //SUPPOSE ETRE SI TOUCHE PESEE, MAIS JE CROIS PAS QUE CE SOIT LA BONNE CONDITION
			{
//				ucSeq = 0,1 ou 2; //ACTIVE LA SEQUENCE EN FONCTION DE LA CASE
				ucSequenceActive = 1;    //SERA REMIS A 0 APRES LE RETOUR AU REPOS
			}
		}
		if (ucComptTimer == 40)  //SI 2 SECONDES PASSEES
		{
//			vTraiteSequence();    //TRAITEMENT DE LA SEQUENCE
		}
	}
}
// *************************************************************************************************
// FONCTIONS lOCALES
// *************************************************************************************************
