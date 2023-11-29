/*--------------------------------------------------------------------------
DS89C4xx.H
Registers definition for Dallas Semiconductors DS89C420/430/440/450

Copyright (c) 2004 Keil Elektronik GmbH and Keil Software, Inc.
All rights reserved.
-------------------------------------------------------------------------- */
#ifndef __DS89C4xx_H__
#define __DS89C4xx_H__
/* Byte Addresses */
sfr   P0   	   = 0x80;
sfr   SP   	   = 0x81;
sfr   DPL   	 = 0x82;
sfr   DPH   	 = 0x83;
sfr   DPL1   	 = 0x84;
sfr   DPH1   	 = 0x85;
sfr   DPS   	 = 0x86;
sfr   PCON   	 = 0x87;
sfr   TCON   	 = 0x88;
sfr   TMOD   	 = 0x89;
sfr   TL0   	 = 0x8A;
sfr   TL1   	 = 0x8B;
sfr   TH0   	 = 0x8C;
sfr   TH1   	 = 0x8D;
sfr   CKCON    = 0x8E;
sfr   P1   	   = 0x90;
sfr   EXIF   	 = 0x91;
sfr   CKMOD    = 0x96;
sfr   SCON0     = 0x98;
sfr   SBUF0     = 0x99;
sfr   ACON   	 = 0x9D;
sfr   P2   	   = 0xA0;
sfr   IE   	   = 0xA8;
sfr   SADDR0   = 0xA9;
sfr   SADDR1   = 0xAA;
sfr   P3   	   = 0xB0;
sfr   IP1   	 = 0xB1;
sfr   IP0   	 = 0xB8;
sfr   SADEN0   = 0xB9;
sfr   SADEN1   = 0xBA;
sfr   SCON1    = 0xC0;
sfr   SBUF1    = 0xC1;
sfr   ROMSIZE  = 0xC2;
sfr   PMR   	 = 0xC4;
sfr   STATUS   = 0xC5;
sfr   TA   	   = 0xC7;
sfr   T2CON    = 0xC8;
sfr   T2MOD    = 0xC9;
sfr   RCAP2L   = 0xCA;
sfr   RCAP2H   = 0xCB;
sfr   TL2   	 = 0xCC;
sfr   TH2   	 = 0xCD;
sfr   PSW   	 = 0xD0;
sfr   FCNTL    = 0xD5;
sfr   FDATA    = 0xD6;
sfr   WDCON    = 0xD8;
sfr   ACC   	 = 0xE0;
sfr   EIE   	 = 0xE8;
sfr   B   	   = 0xF0;
sfr   EIP1   	 = 0xF1;
sfr   EIP0   	 = 0xF8;

/* Bit Addresses */

/* TCON */
sbit   IT0   	 = TCON^0;
sbit   IE0   	 = TCON^1;
sbit   IT1   	 = TCON^2;
sbit   IE1   	 = TCON^3;
sbit   TR0   	 = TCON^4;
sbit   TF0   	 = TCON^5;
sbit   TR1   	 = TCON^6;
sbit   TF1   	 = TCON^7;

/* SCON0 */
sbit   RI_0      = SCON0^0;
sbit   TI_0      = SCON0^1;
sbit   RB8_0   	 = SCON0^2;
sbit   TB8_0   	 = SCON0^3;
sbit   REN_0   	 = SCON0^4;
sbit   SM2_0   	 = SCON0^5;
sbit   SM1_0   	 = SCON0^6;
sbit   FE_0   	 = SCON0^7;

/* IE */
sbit   EX0   	 = IE^0;
sbit   ET0   	 = IE^1;
sbit   EX1   	 = IE^2;
sbit   ET1   	 = IE^3;
sbit   ES0    	 = IE^4;
sbit   ET2   	 = IE^5;
sbit   ES1   	 = IE^6;
sbit   EA   	 = IE^7;

/* IP0 */
sbit   PX0   	 = IP0^0;
sbit   PT0   	 = IP0^1;
sbit   PX1   	 = IP0^2;
sbit   PT1   	 = IP0^3;
sbit   PS   	 = IP0^4;

/* SCON1 */
sbit   RI_1   	 = SCON1^0;
sbit   TI_1   	 = SCON1^1;
sbit   RB8_1   	 = SCON1^2;
sbit   TB8_1   	 = SCON1^3;
sbit   REN_1   	 = SCON1^4;
sbit   SM2_1   	 = SCON1^5;
sbit   SM1_1   	 = SCON1^6;
sbit   FE_1   	 = SCON1^7;

/* T2CON */
sbit   CP   	 = T2CON^0;

sbit   TR2   	 = T2CON^2;
sbit   EXEN2   = T2CON^3;
sbit   TCLK    = T2CON^4;
sbit   RCLK    = T2CON^5;
sbit   EXF2    = T2CON^6;
sbit   TF2   	 = T2CON^7;

/* PSW */
sbit   P   	   = PSW^0;
sbit   F1   	 = PSW^1;
sbit   OV   	 = PSW^2;
sbit   RS0   	 = PSW^3;
sbit   RS1   	 = PSW^4;
sbit   F0   	 = PSW^5;
sbit   AC   	 = PSW^6;
sbit   CY   	 = PSW^7;

/* WDCON */
sbit   RWT   	 = WDCON^0;
sbit   EWT   	 = WDCON^1;
sbit   WTRF    = WDCON^2;
sbit   WDIF    = WDCON^3;
sbit   PFI   	 = WDCON^4;
sbit   EPFI    = WDCON^5;
sbit   POR   	 = WDCON^6;
sbit   SMOD_1  = WDCON^7;

/* EIE */
sbit   EX2   	 = EIE^0;
sbit   EX3   	 = EIE^1;
sbit   EX4   	 = EIE^2;
sbit   EX5   	 = EIE^3;
sbit   EWDI    = EIE^4;

/* EIP0 */
sbit   LPX2   	 = EIP0^0;
sbit   LPX3   	 = EIP0^1;
sbit   LPX4   	 = EIP0^2;
sbit   LPX5   	 = EIP0^3;
sbit   LPXWDI    = EIP0^4;

/*    P0 GPIO   */
sbit P0_7   = P0^7;	// bit 7 of P0
sbit P0_6   = P0^6;	// bit 6 of P0
sbit P0_5   = P0^5;	// bit 5 of P0
sbit P0_4   = P0^4;	// bit 4 of P0
sbit P0_3   = P0^3;	// bit 3 of P0
sbit P0_2   = P0^2;	// bit 2 of P0
sbit P0_1   = P0^1;	// bit 1 of P0
sbit P0_0   = P0^0;	// bit 0 of P0

/*    P1 GPIO   */
sbit P1_7   = P1^7;	// bit 7 of P1
sbit P1_6   = P1^6;	// bit 6 of P1
sbit P1_5   = P1^5;	// bit 5 of P1
sbit P1_4   = P1^4;	// bit 4 of P1
sbit P1_3   = P1^3;	// bit 3 of P1
sbit P1_2   = P1^2;	// bit 2 of P1
sbit P1_1   = P1^1;	// bit 1 of P1
sbit P1_0   = P1^0;	// bit 0 of P1

 /*    P2 GPIO   */
sbit P2_7	= P2^7; // bit 7 of P2
sbit P2_6	= P2^6; // bit 6 of P2
sbit P2_5	= P2^5; // bit 5 of P2
sbit P2_4	= P2^4; // bit 4 of P2
sbit P2_3	= P2^3; // bit 3 of P2
sbit P2_2	= P2^2; // bit 2 of P2
sbit P2_1	= P2^1; // bit 1 of P2   
sbit P2_0	= P2^0; // bit 0 of P2
   
/*    P3 GPIO   */
sbit P3_7   = P3^7;	// bit 7 of P3
sbit P3_6   = P3^6;	// bit 6 of P3
sbit P3_5   = P3^5;	// bit 5 of P3
sbit P3_4   = P3^4;	// bit 4 of P3
sbit P3_3   = P3^3;	// bit 3 of P3
sbit P3_2   = P3^2;	// bit 2 of P3
sbit P3_1   = P3^1;	// bit 1 of P3
sbit P3_0   = P3^0;	// bit 0 of P3




  

 

#endif