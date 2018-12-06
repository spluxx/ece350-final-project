module adder8bit(
	a7, a6, a5, a4, a3, a2, a1, a0,
	b7, b6, b5, b4, b3, b2, b1, b0, cin, 
	s7, s6, s5, s4, s3, s2, s1, s0, 
	P, G, isOvf, isNeg, 
	p7, p6, p5, p4, p3, p3, p2, p1, p0,
	g7, g6, g5, g4, g3, g3, g2, g1, g0
);
	input a7, a6, a5, a4, a3, a2, a1, a0;
	input b7, b6, b5, b4, b3, b2, b1, b0, cin;
	
	output s7, s6, s5, s4, s3, s2, s1, s0;
	output P, G, isOvf, isNeg;
	output p7, p6, p5, p4, p3, p2, p1, p0;
	output g7, g6, g5, g4, g3, g2, g1, g0;

	wire c7, c6, c5, c4, c3, c2, c1, c0;
	wire g7, g6, g5, g4, g3, g2, g1, g0;
	wire p7, p6, p5, p4, p3, p2, p1, p0;
	
	wire propi0, propi1, propi2, propi3, propi4, propi5, propi6, propi7;
	wire prop01, prop02, prop03, prop04, prop05, prop06, prop07;
	wire prop12, prop13, prop14, prop15, prop16, prop17;
	wire prop23, prop24, prop25, prop26, prop27;
	wire prop34, prop35, prop36, prop37;
	wire prop45, prop46, prop47;
	wire prop56, prop57;
	wire prop67;
	
	and andG0(g0, a0, b0);
	and andG1(g1, a1, b1);
	and andG2(g2, a2, b2);
	and andG3(g3, a3, b3);
	and andG4(g4, a4, b4);
	and andG5(g5, a5, b5);
	and andG6(g6, a6, b6);
	and andG7(g7, a7, b7);
	
	or orP0(p0, a0, b0);
	or orP1(p1, a1, b1);
	or orP2(p2, a2, b2);
	or orP3(p3, a3, b3);
	or orP4(p4, a4, b4);
	or orP5(p5, a5, b5);
	or orP6(p6, a6, b6);
	or orP7(p7, a7, b7);
	
	and and00(propi0, cin, p0);           
	and and01(propi1, cin, p0, p1);     
	and and02(propi2, cin, p0, p1, p2);     
	and and03(propi3, cin, p0, p1, p2, p3);            
	and and04(propi4, cin, p0, p1, p2, p3, p4);
	and and05(propi5, cin, p0, p1, p2, p3, p4, p5);  
	and and06(propi6, cin, p0, p1, p2, p3, p4, p5, p6);    
	and and07(propi7, cin, p0, p1, p2, p3, p4, p5, p6, p7);       
	and and11(prop01, g0, p1);                              
	and and12(prop02, g0, p1, p2); 
	and and13(prop03, g0, p1, p2, p3);  
	and and14(prop04, g0, p1, p2, p3, p4);
	and and15(prop05, g0, p1, p2, p3, p4, p5);
	and and16(prop06, g0, p1, p2, p3, p4, p5, p6);
	and and17(prop07, g0, p1, p2, p3, p4, p5, p6, p7); 
	and and22(prop12, g1, p2);                           
	and and23(prop13, g1, p2, p3);           
	and and24(prop14, g1, p2, p3, p4);    
	and and25(prop15, g1, p2, p3, p4, p5); 
	and and26(prop16, g1, p2, p3, p4, p5, p6);  
	and and27(prop17, g1, p2, p3, p4, p5, p6, p7);      
	and and33(prop23, g2, p3);  
	and and34(prop24, g2, p3, p4);         
	and and35(prop25, g2, p3, p4, p5);  
	and and36(prop26, g2, p3, p4, p5, p6); 
	and and37(prop27, g2, p3, p4, p5, p6, p7);  
	and and44(prop34, g3, p4);                       
	and and45(prop35, g3, p4, p5);                  
	and and46(prop36, g3, p4, p5, p6);            
	and and47(prop37, g3, p4, p5, p6, p7);      
	and and55(prop45, g4, p5);                        
	and and56(prop46, g4, p5, p6);               
	and and57(prop47, g4, p5, p6, p7);         
	and and66(prop56, g5, p6);                     
	and and67(prop57, g5, p6, p7);              
	and and77(prop67, g6, p7); 	
	
	or or0(c0, propi0, g0);
	or or1(c1, propi1, prop01, g1);
	or or2(c2, propi2, prop02, prop12, g2);
	or or3(c3, propi3, prop03, prop13, prop23, g3);
	or or4(c4, propi4, prop04, prop14, prop24, prop34, g4);
	or or5(c5, propi5, prop05, prop15, prop25, prop35, prop45, g5);
	or or6(c6, propi6, prop06, prop16, prop26, prop36, prop46, prop56, g6);
	or or7(c7, propi7, prop07, prop17, prop27, prop37, prop47, prop57, prop67, g7);
	
	xor xorS0(s0, a0, b0, cin);
	xor xorS1(s1, a1, b1, c0);
	xor xorS2(s2, a2, b2, c1);
	xor xorS3(s3, a3, b3, c2);
	xor xorS4(s4, a4, b4, c3);
	xor xorS5(s5, a5, b5, c4);
	xor xorS6(s6, a6, b6, c5);
	xor xorS7(s7, a7, b7, c6);
	xor xorSN(isNeg, a7, b7, c6);
	
	xor xor0(isOvf, c6, c7);
	and andP(P, p7, p6, p5, p4, p3, p2, p1, p0);
	or  orG(G, prop07, prop17, prop27, prop37, prop47, prop57, prop67, g7);
endmodule
