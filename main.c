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
                unsigned char ucX;
                unsigned char ucY;
                unsigned char ucBalance;
                unsigned char ucReserve;
		unsigned char ucCheckSum;
	}struct STServoPosition stState;
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
                      // Seq 0  (case A3)
unsigned char xdata ucSeqPick[7][10][5] = {{{0x66,0x40,0x01,0x5B,0x01}, 
                                            {0x6A,0x52,0x1B,0x61,0x01},  
                                            {0x6A,0x69,0x1F,0x4D,0x01}, 
                                            {0x6A,0x69,0x2D,0x87,0x01},
                                            {0x6B,0x74,0x29,0x87,0x01},
                                            {0x6B,0x74,0x29,0x87,0x57},
                                            {0x6B,0x74,0x29,0x87,0x83},  
                                            {0x6B,0x74,0x29,0x87,0x93},  
                                            {0x6B,0x62,0x2A,0x95,0x93},  
                                            {0x69,0x6D,0x3B,0x95,0x93}}, 
                      // Seq 1   (case B5)
                                           {{0x66,0x40,0x01,0x5B,0x01},  
                                            {0x6A,0x52,0x1B,0x61,0x01},
                                            {0x72,0x68,0x1E,0x4D,0x01},  
                                            {0x72,0x67,0x1E,0x8A,0x01}, 
                                            {0x72,0x6C,0x1D,0x84,0x01},
                                            {0x72,0x6C,0x1D,0x84,0x57},
                                            {0x72,0x6C,0x1D,0x84,0x83},
                                            {0x72,0x6C,0x1D,0x84,0x93},
                                            {0x72,0x62,0x2A,0x95,0x93},                               
                                            {0x69,0x6D,0x3B,0x95,0x93}},
                      // Seq 2  (case C4)      
                                           {{0x66,0x40,0x01,0x5B,0x01},
                                            {0x5a,0x72,0x0f,0x39,0x01},
                                            {0x5a,0x72,0x0f,0x39,0x4c},
                                            {0x5a,0x63,0x01,0x39,0x4c},
                                            {0x81,0x6d,0x07,0x39,0x4c},
                                            {0x81,0x6d,0x07,0x39,0x01},
                                            {0x81,0x60,0x04,0x37,0x01},
                                            {0x68,0x66,0x01,0x38,0x01},
                                            {0x68,0x66,0x01,0x38,0x01},
                                            {0x68,0x66,0x01,0x38,0x01}},
                      // Seq 3  (Balance)     
                                           {{0x65,0x69,0x30,0x95,0x93},
                                            {0x65,0x72,0x3B,0x95,0x93},
                                            {0x65,0x79,0x49,0x9B,0x93},
                                            {0x65,0x80,0x58,0xA0,0x93},
                                            {0x65,0x8C,0x5D,0x9C,0x93},
                                            {0x65,0x8C,0x5D,0x9C,0x01},
                                            {0x65,0x8C,0x5D,0x9C,0x01}, 
                                            {0x65,0x8C,0x5D,0x9C,0x93},
                                            {0x65,0x83,0x5A,0x9C,0x93},                     
                                            {0x6A,0x83,0x5A,0x9C,0x93}},                                                       
                      // Seq 4  (20g)
                                           {{0x6A,0x78,0x4E,0x9C,0x93},
                                            {0x6A,0x78,0x4E,0x9C,0x93},
                                            {0x73,0x78,0x4E,0x9C,0x93},
                                            {0x73,0x7E,0x53,0x9C,0x93},
                                            {0x73,0x81,0x55,0x9C,0x93},
                                            {0x73,0x83,0x45,0x8F,0x93},
                                            {0x73,0x83,0x45,0x8F,0x01},
                                            {0x73,0x7A,0x47,0x8F,0x01},  
                                            {0x73,0x65,0x47,0x8F,0x01},
                                            {0x66,0x40,0x01,0x5B,0x01}},
                      // Seq 5  (50g)
                                           {{0x6A,0x78,0x4E,0x9C,0x93},
                                            {0x6A,0x78,0x4E,0x9C,0x93}, 
                                            {0x78,0x78,0x4E,0x9C,0x93},
                                            {0x78,0x7E,0x53,0x9C,0x93},
                                            {0x78,0x82,0x54,0x9A,0x93},
                                            {0x78,0x84,0x48,0x8F,0x93},
                                            {0x78,0x84,0x48,0x8F,0x01},
                                            {0x78,0x7A,0x48,0x8F,0x01},   
                                            {0x78,0x65,0x48,0x8F,0x01},
                                            {0x66,0x40,0x01,0x5B,0x01}},
                      // Seq 6  (80g)
                                           {{0x6A,0x78,0x4E,0x9C,0x93}, 
                                            {0x6A,0x78,0x4E,0x9C,0x93},  
                                            {0x7C,0x78,0x4E,0x9C,0x93}, 
                                            {0x7C,0x7E,0x53,0x9C,0x93}, 
                                            {0x7C,0x83,0x52,0x9A,0x93}, 
                                            {0x7C,0x88,0x50,0x91,0x93}, 
                                            {0x7C,0x88,0x50,0x91,0x01}, 
                                            {0x7C,0x7A,0x50,0x91,0x01},  
                                            {0x7C,0x65,0x50,0x91,0x01},
                                            {0x66,0x40,0x01,0x5B,0x01}},
                                }; 																			
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
 vInitTimer0();        //TIMER0 À 50MS
 if (ucComptTimer == 4)
 {
 vInitPortSerie();     //INITIALISE LE PORT SERIE
 vInitialiseLCD();     //INITIALISE LE LCD

 SBUF0 = 'G';                //ENVOI DU 'G'
 ucCheckSum = ucCheckSum + 'G';
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'O';                //ENVOI DU 'O'
 ucCheckSum = ucCheckSum + 'O';
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'MILIEU';           //ENVOI DE 0X66 POUR BASE AU MILIEU
 ucCheckSum = ucCheckSum + 0x66;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'MILIEU';           //ENVOI DE 0X66 POUR EPAULE AU MILIEU
 ucCheckSum = ucCheckSum + 0x66;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'MILIEU';           //ENVOI DE 0X66 POUR COUDE AU MILIEU
 ucCheckSum = ucCheckSum + 0x66;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'MILIEU';           //ENVOI DE 0X66 POUR POIGNET AU MILIEU
 ucCheckSum = ucCheckSum + 0x66;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'OUVERT';           //ENVOI DE 0X66 POUR PINCE OUVERTE
 ucCheckSum = ucCheckSum + 0x00;
 while (!TI_0);
 TI_0 = 0;

 vAfficheLCDComplet (ucEcranDebutTab);    //AFFICHAGE DE L'ECRAN DE BASE
 }
//////////////PROGRAMME PRINCIPAL///////////////////////////////////////////////////////////////////
	while (1)
	{
		if (ucSequenceActive == 1)
		{
			stState.ucBase     = SeqData [ucSeq] [Step] [0];
			stState.ucEpaule   = SeqData [ucSeq] [Step] [1];
			stState.ucCoude    = SeqData [ucSeq] [Step] [2];
			stState.ucPoignet  = SeqData [ucSeq] [Step] [3];
			stState.ucPince    = SeqData [ucSeq] [Step] [4];
		}
		ucTouche = ucReadKeyI2C();
		if (ucTouche != 0x20)
		{
		  vTraiteTouche (ucTouche);
		}
		
		//if(TRAME RECUE)
		{
			vLcdEcrireCaract('O', LIGNE3, 16);
			vLcdEcrireCaract('N', LIGNE3, 17);
			vLcdEcrireCaract('L', LIGNE3, 18);
			vLcdEcrireCaract(' ', LIGNE3, 19);
			vTraiteTrame ();
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
// **************************************************************************************************
void vTraiteSequence()
//  Auteur: Xavier Champoux 	
//  Date de création :  20 décembre 2023
//  Version 1.0
//
//  Description					 : Traite la trame recue du pic
//  Paramètres d'entrées : Aucune
//  Paramètres de sortie : Aucune
//
//  Notes     		       : Aucune
// *************************************************************************************************
{
	
}
// **************************************************************************************************
void vTraiteTrame ()
//  Auteur: Xavier Champoux 	
//  Date de création :  20 décembre 2023
//  Version 1.0
//
//  Description					 : Traite la trame recue du pic
//  Paramètres d'entrées : Aucune
//  Paramètres de sortie : Aucune
//
//  Notes     		       : Aucune
// *************************************************************************************************
{
 static unsigned char ucComptBuffer = 0;
 static unsigned char ucTrameRecieve [8];
 static unsigned char ucCheckSum;
 ucComptTouche = 0;
 if (ucComptBuffer < 8)
 {
	ucTrameRecieve [ucComptBuffer] = SBUF0;
	if (ucTrameRecieve [0] == 'G'
	{
		ucComptBuffer++;
	}
	else {ucComptBuffer = 0;}
 }
 if (ucComptBuffer == 8)
 {
	 stState.ucX = ucTrameRecieve[2];
	 stState.ucY = ucTrameRecieve[3];
	 stState.ucPince = ucTrameRecieve[4];
	 stState.ucBalance = ucTrameRecieve[5];
	 stState.ucReserve = ucTrameRecieve[6];
         stState.ucCheckSum = ucTrameRecieve[7];
 }	
 SBUF0 = 'G';                      //ENVOI DU 'G'
 ucCheckSum = ucCheckSum + 'G';
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'O';                      //ENVOI DU 'O'
 ucCheckSum = ucCheckSum + 'O';
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = 'stState.Base';           //ENVOI DE Base
 ucCheckSum = ucCheckSum + stState.Base;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = stState.Epaule;          //ENVOI DE Epaule
 ucCheckSum = ucCheckSum + stState.Epaule;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = stState.Coude;           //ENVOI DE Coude
 ucCheckSum = ucCheckSum + stState.Coude;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = stState.Poignet;         //ENVOI DE Poignet
 ucCheckSum = ucCheckSum + stState.Poignet;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = stState.Pince;           //ENVOI DE Pince
 ucCheckSum = ucCheckSum + stState.Pince;
 while (!TI_0);
 TI_0 = 0;

 SBUF0 = ucCheckSum;              //ENVOI DE CheckSum
 while (!TI_0);
 TI_0 = 0;
}
