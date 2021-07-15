	AREA myproject,CODE,READWRITE
	
	ENTRY
	 
	
	LDR r0,=array
	LDR r1,=0x40000100
	MOV r3,#0 				; counter 
							; push pop icin 0xFFFF0000,0xFFFFFFFF
	MOV r4,#0  				; anlik parent node 
	MOV r6,#2  				; carpmada kullaniliyor sabit
	
loop
	LDR r2,[r0,#4]! 		;diziyi 2. elemandan itibaren dön
			
	CMP r2,-1	   			;dizinin sonunu kontrol et
	BNE addHeap
	BEQ endBuild

addHeap
	LDR r8,[r1,r4,LSL#2]	;rootdaki eleman r8	
	
	LDR r7,[r0]				;siradaki eleman	
	STR r7,[r1,r3,LSL#2]
	
	MUL	r5,r4,r6 
	ADD r5,r5,#3			; r5= 2xnode + 3
	CMP r5,r3				; r5 ile total node sayisi kontrol ediliyor
	ADDEQ r4,r4,#1			; istenen degerdeyse parent bir sonraki elemana geciyor.
	
	
	MOV r9,r4				;	temproot r4	
	MOV r11,r3				;		tempSonIndex r3
	CMP r3,#0
	BNE kontrolet			; kontrol ve swap kismina gidiyor
	
ic_kisim

	ADD r3,r3,#1 			; counter-eleman sayisi surekli artar
	B loop 					;  ekleme bitince basa don
	
kontrolet
	
	LDR r10,[r1,r9,LSL#2]	;	temproot r8		
	LDR r12,[r1,r11,LSL#2]	;	tempSonIndex r7
	
	CMP r10,r12				;  r10:temp_parent r12:temp_deger
	BGT	parentla_degis
	B ic_kisim
	
parentla_degis
	;swap
	STR r12,[r1,r9,LSL#2]	; tempIndex'deki degeri, tempKok Adresine atama
	STR r10,[r1,r11,LSL#2]	; tempKok'deki degeri, tempIndex Adresine atama 
	
	CMP	r9,#0				;zaten temp kok 0 ise degistirmeye gerek yok.
	BEQ	ic_kisim
	
	MOV r11,r9				; sonraki kontrol icin yenikok=index
	AND r5,r9,#1	
	CMP r5,#1
	BEQ tek_sayi_index
	SUBS r9,r9,#2			;	index tek ise -1 ve saga shift, cift ise -2 ve saga shift 
	CMP  r9,#0				; kök 0 sa direkt dön
	BEQ kontrolet			
	LSR  r9,r9,#1			; yeniIndex=eskikok
	B kontrolet
tek_sayi_index			
	SUBS r9,r9,#1	
	CMP  r9,#0				; kök 0 sa direkt dön, burasi biraz kod tekrarina girdi
	BEQ kontrolet	
	LSR  r9,r9,#1			; yeniIndex=eskikok
	B kontrolet
	

endBuild



findInHeap
	LDR r5,=array
	LDR r2,[r5]				; r2=size
	MOV r0,#3				; Aradigim deger
	MOV r3,#0				; i,counter
findLoop
	LDR r4,[r1,r3,LSL#2]	; r= minHeap'teki i.eleman
	CMP r4,r0
	BEQ	findSuccess
	ADD r3,r3,#1	
	CMP r3,r2
	BNE findLoop
	B findFail
findSuccess
	MOV r0,#1
	B findSon
findFail
	MOV r0,#0
	B findSon
findSon

sortHeap
	SUBS r0,r2,#1			;r2'de daha onceden size vardi 1 eksiltip r0'a atadim
	MOV r3,#0	; 
	SUBS r4,r0,#1 ;			 r4=bir onceki eleman
sortLoop
	LDR r5,[r1,r0,LSL#2]	; r5= heap'teki i.eleman, sondan basliyor
	LDR r6,[r1,r4,LSL#2]	; r5= heap'teki i-1.eleman, son-1'den basliyor
	CMP r5,r6
	BLT doSwap
sortDevam	
	SUBS r0,r0,#1			;	i-1
	SUBS r4,r0,#1 			;	i'den önceki deger - 1
	CMP r3,r0				; 	sonlanmaDurumu
	BNE sortLoop
	B bitir

doSwap
	STR r5,[r1,r4,LSL#2]	; swaplar yapilip tekrar donguye devam ediliyor.
	STR r6,[r1,r0,LSL#2]	
	B sortDevam


	B bitir
bitir
	
array DCD 7,5,6,7,4,3,8,2,-1
	END
