/****************************************************************************************
   Nom du fichier : I2C.h
   Auteur : Xavier Champoux                  
      Date de création : 06 septembre 2023
        Fichier de déclaration et de définition pour les fonctions de traitement du 
        I2C.
  
****************************************************************************************/

#ifndef I2C_H
  #define I2C_H


// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************
//Definitions de parametres. 
#define SDA P3_4
#define SCL P3_5
#define INT P3_2

#define I2C_DELAI 1
 
// *************************************************************************************************
//  LES PROTOTYPES DES FONCTIONS
// *************************************************************************************************
  
// *************************************************************************************************
//  Auteur: Xavier Champoux, basé sur des fonctions faites par Stéphane Deschenes le 28 mai 2021
//  Date de création :  06 septembre 2023
//
//  Description: provoque un "start-condition" I2C sur les lignes SDA et SCL
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		 	 : Aucune
//
void vI2CStartBit(void);
// *************************************************************************************************

// *************************************************************************************************
//  Auteur: Xavier Champoux, basé sur des fonctions faites par Stéphane Deschenes le 28 mai 2021
//  Date de création :  06 septembre 2023
//
//  Description: provoque un "stop-condition" I2C sur les lignes SDA et SCL
//  Paramètres d'entrées : Aucun
//  Paramètres de sortie : Aucun
//  Notes     		 : Aucune
//
void vI2CStopBit(void);
// *************************************************************************************************


// *************************************************************************************************
//	Auteur: Xavier Champoux, basé sur des fonctions faites par Stéphane Deschenes le 28 mai 2021
//  Date de création : 06 septembre 2023
//
//	Description :	Fonction de réception de 8 bits de donnée 
//			          provenant d'une communication I2C.
//
//	Modification - Stéphane Deschênes 	
//	30-07-2019  Ajout de la valeur du ACK en paramètre
//
//	Paramètres d'entrée : 	Valeur du ack voulu 0 = Ack  1 = NACK		
//	Paramètres de sortie : 	Byte reçu.		
//
unsigned char ucI2CLire8Bits (bit bAckValue);
// *************************************************************************************************



// *************************************************************************************************
//  Auteur: Xavier Champoux, basé sur des fonctions faites par Stéphane Deschenes le 28 mai 2021
//  Date de création :  06 septembre 2023
//  
//	Modification:
//
//  Description          : Fonction d'envoi de 8 bits de données en I2C.
//  Paramètres d'entrées : Octet que l'on veut envoyer
//  Paramètres de sortie : État du ack venant de l'esclave
//  Notes     		 			 : Aucune
//
void vI2CEcrire8Bits(unsigned char ucTxData);
// *************************************************************************************************


#endif 

















