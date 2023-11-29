/****************************************************************************************
   Nom du fichier : ClavierI2C.h
   Auteur : Stéphane Deschênes                  
   Date de création : 30 oct 2019 
        Fichier de déclaration et de définition pour les fonctions de traitement du 
        clavier I2C.
  
****************************************************************************************/

#ifndef CLAVIER_I2C_H
  #define CLAVIER_I2C_H





// *************************************************************************************************
//  Auteur: Stéphane Deschênes 	
//  Date de création :  11 novembre 2022
//  Version 1.0
//
//  Description					 : Lit les touches lues sur le clavier I2C
//  Paramètres d'entrées : Aucune
//  Paramètres de sortie : La valeur de la touches appuyée en ASCII.  Retourne ' ' si aucune touche est appuyée.
//
//  Notes     		       : Cette fonction est faite pour lire le clavier sans utiliser les interruptions
//												 Pour ne pas manquer de touches appuyées par l'utilisateur, il est recommandé 
//												 d'appeler cette fonction aux 10 ms.
// *************************************************************************************************
unsigned char ucReadKeyI2C(void);
// *************************************************************************************************
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
void vTraiteTouche (unsigned char ucTouche);

#endif 

















