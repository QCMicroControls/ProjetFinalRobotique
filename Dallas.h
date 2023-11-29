/****************************************************************************************
   Nom du fichier : I2C.h
   Auteur : St�phane Desch�nes                  
      Date de cr�ation : 19-03-2006 
        Fichier de d�claration et de d�finition pour les fonctions de traitement du 
        I2C.
  
****************************************************************************************/

#ifndef Dallas_H
  #define Dallas_H


// *************************************************************************************************
//  CONSTANTES
// *************************************************************************************************

 
// *************************************************************************************************
//  LES PROTOTYPES DES FONCTIONS
// ************************************************************************************************* 
void vInitPortSerie(void);
void vEcrireMemI2C(unsigned char ucData, unsigned int uiAdr);
unsigned char ucLireMemI2C(unsigned int uiAdr);
void vInitTimer0(void);
void vInitIntTimer0(void);

#endif 