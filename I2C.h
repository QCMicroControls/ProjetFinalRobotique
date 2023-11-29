/****************************************************************************************
   Nom du fichier : I2C.h
   Auteur : St�phane Desch�nes                  
      Date de cr�ation : 19-03-2006 
        Fichier de d�claration et de d�finition pour les fonctions de traitement du 
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
//  Auteur: St�phane Desch�nes, bas� sur des fonctions faites par Alain Champagne le 30 mai 2007
//  Date de cr�ation :  28 mai 2021
//
//  Description: provoque un "start-condition" I2C sur les lignes SDA et SCL
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		 	 : Aucune
//
void vI2CStartBit(void);
// *************************************************************************************************

// *************************************************************************************************
//  Auteur: St�phane Desch�nes, bas� sur des fonctions faites par Alain Champagne le 30 mai 2007
//  Date de cr�ation :  28 mai 2021
//
//  Description: provoque un "stop-condition" I2C sur les lignes SDA et SCL
//  Param�tres d'entr�es : Aucun
//  Param�tres de sortie : Aucun
//  Notes     		 : Aucune
//
void vI2CStopBit(void);
// *************************************************************************************************


// *************************************************************************************************
//	Auteur: St�phane Desch�nes, bas� sur des fonctions faites par Alain Champagne le 30 mai 2007
//  Date de cr�ation :  28 mai 2021
//
//	Description :	Fonction de r�ception de 8 bits de donn�e 
//			          provenant d'une communication I2C.
//
//	Modification - St�phane Desch�nes 	
//	30-07-2019  Ajout de la valeur du ACK en param�tre
//
//	Param�tres d'entr�e : 	Valeur du ack voulu 0 = Ack  1 = NACK		
//	Param�tres de sortie : 	Byte re�u.		
//
unsigned char ucI2CLire8Bits (bit bAckValue);
// *************************************************************************************************



// *************************************************************************************************
//  Auteur: St�phane Desch�nes, bas� sur des fonctions faites par Alain Champagne le 30 mai 2007
//  Date de cr�ation :  28 mai 2021
//  
//	Modification - St�phane Desch�nes 	
//	30-07-2019  Ajout du retour du ACK
//
//  Description          : Fonction d'envoie de 8 bits de donn�es en I2C.
//  Param�tres d'entr�es : Octet que l'on veut envoyer
//  Param�tres de sortie : �tat du ack venant de l'esclave
//  Notes     		 			 : Aucune
//
void vI2CEcrire8Bits(unsigned char ucTxData);
// *************************************************************************************************


#endif 

















