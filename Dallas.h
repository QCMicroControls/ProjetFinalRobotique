//****************************************************************************************
//   Nom du fichier : I2C.h
//   Auteur : Xavier Champoux, Harold Malbrouck & Charles-Olivier Lemelin                  
//      Date de création : 11 décembre 2023 
//       
//        Fichier de déclaration et de définition pour les fonctions ayant trait 
//        au controle de la Dallas.
//  
//****************************************************************************************

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
