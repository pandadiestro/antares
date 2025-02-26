## Source code analysis for Combat (1977) based on the binary sample

```asm
0:	    SEI                 ;; set interrupt disable
1:	    CLD                 ;; turns the decimal arithmetics mode off
2:	    LDX #ff             ;; x = 0xff
4:	    TXS                 ;; now sp = 0xff virtually (page 1)
5:	    LDX #5d             ;; x = 0x5d
7:	    JSR $f5bd abs       ;; push -> 0x05, push 0x00, jump to 0xf5bd (0x5bd in rom)
a:	    LDA #10
c:	    STA $283 abs
f:	    STA $88 zp
11:	    JSR $f1a3 abs
14:	    JSR $f032 abs
17:	    JSR $f157 abs
1a:	    JSR $f572 abs
1d:	    JSR $f2da abs
20:	    JSR $f444 abs
23:	    JSR $f214 abs
26:	    JSR $f2a9 abs
29:	    JSR $f1f2 abs
2c:	    JSR $f054 abs
2f:	    JMP $f014 abs
32:	    INC $86 zp
34:	    STA $2b zp
36:	    LDA #2
38:	    STA $2 zp
3a:	    STA $1 zp
3c:	    STA $2 zp
3e:	    STA $2 zp
40:	    STA $2 zp
42:	    STA $0 zp
44:	    STA $2 zp
46:	    STA $2 zp
48:	    LDA #0
4a:	    STA $2 zp
4c:	    STA $0 zp
4e:	    LDA #2b
50:	    STA $296 abs
53:	    RTS
54:	    LDA #20
56:	    STA $b4 zp
58:	    STA $2 zp
5a:	    STA $2a zp
5c:	    LDA $284 abs
5f:	    BNE $-5 rel
61:	    STA $2 zp
63:	    STA $2c zp
65:	    STA $1 zp
67:	    TSX
68:	    STX $d3 zp
6a:	    LDA #2
6c:	    STA $a zp
6e:	    LDX $dc zp
70:	    STA $2 zp
72:	    DEX
73:	    BNE $-5 rel
75:	    LDA $dc zp
77:	    CMP #e
79:	    BEQ $82 rel
7b:	    LDX #5
7d:	    LDA #0
7f:	    STA $de zp
81:	    STA $df zp
83:	    STA $2 zp
85:	    LDA $de zp
87:	    STA $e zp
89:	    LDY $e2 zp
8b:	    LDA $f5c5,Y abs
8e:	    AND #f0
90:	    STA $de zp
92:	    LDY $e0 zp
94:	    LDA $f5c5,Y abs
97:	    AND #f
99:	    ORA $de zp
9b:	    STA $de zp
9d:	    LDA $df zp
9f:	    STA $e zp
a1:	    LDY $e3 zp
a3:	    LDA $f5c5,Y abs
a6:	    AND #f0
a8:	    STA $df zp
aa:	    LDY $e1 zp
ac:	    LDA $f5c5,Y abs
af:	    AND $87 zp
b1:	    STA $2 zp
b3:	    ORA $df zp
b5:	    STA $df zp
b7:	    LDA $de zp
b9:	    STA $e zp
bb:	    DEX
bc:	    BMI $15 rel
be:	    INC $e0 zp
c0:	    INC $e2 zp
c2:	    INC $e1 zp
c4:	    INC $e3 zp
c6:	    LDA $df zp
c8:	    STA $e zp
ca:	    JMP $f083 abs
cd:	    LDA #0
cf:	    STA $e zp
d1:	    STA $2 zp
d3:	    LDA #5
d5:	    STA $a zp
d7:	    LDA $d6 zp
d9:	    STA $6 zp
db:	    LDA $d7 zp
dd:	    STA $7 zp
df:	    LDX #1e
e1:	    TXS
e2:	    SEC
e3:	    LDA $a4 zp
e5:	    SBC $b4 zp
e7:	    AND #fe
e9:	    TAX
ea:	    AND #f0
ec:	    BEQ $4 rel
ee:	    LDA #0
f0:	    BEQ $2 rel
f2:	    LDA $bd,X zp
f4:	    STA $2 zp
f6:	    STA $1b zp
f8:	    LDA $a7 zp
fa:	    EOR $b4 zp
fc:	    AND #fe
fe:	    PHP
ff:	    LDA $a6 zp
101:    EOR $b4 zp
103:    AND #fe
105:    PHP
106:    LDA $b4 zp
108:    BPL $2 rel
10a:    EOR #f8
10c:    CMP #20
10e:    BCC $4 rel
110:    LSR A
111:    LSR A
112:    LSR A
113:    TAY
114:    LDA $a5 zp
116:    SEC
117:    SBC $b4 zp
119:    INC $b4 zp
11b:    NOP
11c:    ORA #1
11e:    TAX
11f:    AND #f0
121:    BEQ $4 rel
123:    LDA #0
125:    BEQ $2 rel
127:    LDA $bd,X zp
129:    BIT $82 zp
12b:    STA $1c zp
12d:    BMI $12 rel
12f:    LDA ($b5,Y)
131:    STA $d zp
133:    LDA ($b7,Y)
135:    STA $e zp
137:    LDA ($b9,Y)
139:    STA $f zp
13b:    INC $b4 zp
13d:    LDA $b4 zp
13f:    EOR #ec
141:    BNE $-100 rel
143:    LDX $d3 zp
145:    TXS
146:    STA $1d zp
148:    STA $1e zp
14a:    STA $1b zp
14c:    STA $1c zp
14e:    STA $1b zp
150:    STA $d zp
152:    STA $e zp
154:    STA $f zp
156:    RTS
157:    LDA $282 abs
15a:    LSR A
15b:    BCS $19 rel
15d:    LDA #f
15f:    STA $87 zp
161:    LDA #ff
163:    STA $88 zp
165:    LDA #80
167:    STA $dd zp
169:    LDX #e6
16b:    JSR $f5bd abs
16e:    BEQ $96 rel
170:    LDY #2
172:    LDA $dd zp
174:    AND $88 zp
176:    CMP #f0
178:    BCC $8 rel
17a:    LDA $86 zp
17c:    AND #30
17e:    BNE $2 rel
180:    LDY #e
182:    STY $dc zp
184:    LDA $86 zp
186:    AND #3f
188:    BNE $8 rel
18a:    STA $89 zp
18c:    INC $dd zp
18e:    BNE $2 rel
190:    STA $88 zp
192:    LDA $282 abs
195:    AND #2
197:    BEQ $4 rel
199:    STA $89 zp
19b:    BNE $84 rel
19d:    BIT $89 zp
19f:    BMI $80 rel
1a1:    INC $80 zp
1a3:    LDX #df
1a5:    JSR $f5bd abs
1a8:    LDA #ff
1aa:    STA $89 zp
1ac:    LDY $80 zp
1ae:    LDA $f7d8,Y abs
1b1:    STA $a3 zp
1b3:    EOR #ff
1b5:    BNE $4 rel
1b7:    LDX #dd
1b9:    BNE $-22 rel
1bb:    LDA $81 zp
1bd:    SED
1be:    CLC
1bf:    ADC #1
1c1:    STA $81 zp
1c3:    STA $a1 zp
1c5:    CLD
1c6:    BIT $a3 zp
1c8:    BPL $6 rel
1ca:    INC $85 zp
1cc:    BVC $2 rel
1ce:    INC $85 zp
1d0:    JSR $f525 abs
1d3:    LDA #32
1d5:    STA $a5 zp
1d7:    LDA #86
1d9:    STA $a4 zp
1db:    BIT $a3 zp
1dd:    BMI $18 rel
1df:    STA $a5 zp
1e1:    STA $11 zp
1e3:    LDA #8
1e5:    STA $96 zp
1e7:    LDA #20
1e9:    STA $20 zp
1eb:    STA $21 zp
1ed:    STA $2 zp
1ef:    STA $2a zp
1f1:    RTS
1f2:    LDX #1
1f4:    LDA $a1,X zp
1f6:    AND #f
1f8:    STA $d2 zp
1fa:    ASL A
1fb:    ASL A
1fc:    CLC
1fd:	ADC $d2 zp
1ff:	STA $e0,X zp
201:	LDA $a1,X zp
203:	AND #f0
205:	LSR A
206:	LSR A
207:	STA $d2 zp
209:	LSR A
20a:	LSR A
20b:	CLC
20c:	ADC $d2 zp
20e:	STA $e2,X zp
210:	DEX
211:	BPL $-31 rel
213:	RTS
214:	BIT $83 zp
216:	BVC $4 rel
218:	LDA #30
21a:	BPL $2 rel
21c:	LDA #20
21e:	STA $b1 zp
220:	LDX #3
222:	JSR $f254 abs
225:	DEX
226:	JSR $f254 abs
229:	DEX
22a:	LDA $8d,X zp
22c:	AND #8
22e:	LSR A
22f:	LSR A
230:	STX $d1 zp
232:	CLC
233:	ADC $d1 zp
235:	TAY
236:	LDA $a8,Y abs
239:	SEC
23a:	BMI $1 rel
23c:	CLC
23d:	ROL A
23e:	STA $a8,Y abs
241:	BCC $13 rel
243:	LDA $ac,X zp
245:	AND #1
247:	ASL A
248:	ASL A
249:	ASL A
24a:	ASL A
24b:	STA $b1 zp
24d:	JSR $f254 abs
250:	DEX
251:	BEQ $-41 rel
253:	RTS
254:	INC $ac,X zp
256:	LDA $95,X zp
258:	AND #f
25a:	CLC
25b:	ADC $b1 zp
25d:	TAY
25e:	LDA $f5f7,Y abs
261:	STA $b0 zp
263:	BIT $82 zp
265:	BVS $19 rel
267:	LDA $95,X zp
269:	SEC
26a:	SBC #2
26c:	AND #3
26e:	BNE $10 rel
270:	LDA $ac,X zp
272:	AND #3
274:	BNE $4 rel
276:	LDA #8
278:	STA $b0 zp
27a:	LDA $b0 zp
27c:	STA $20,X zp
27e:	AND #f
280:	SEC
281:	SBC #8
283:	STA $d4 zp
285:	CLC
286:	ADC $a4,X zp
288:	BIT $a3 zp
28a:	BMI $4 rel
28c:	CPX #2
28e:	BCS $16 rel
290:	CMP #db
292:	BCS $4 rel
294:	CMP #25
296:	BCS $8 rel
298:	LDA #d9
29a:	BIT $d4 zp
29c:	BMI $2 rel
29e:	LDA #28
2a0:	STA $a4,X zp
2a2:	CPX #2
2a4:	BCS $2 rel
2a6:	STA $25,X zp
2a8:	RTS
2a9:	LDA #1
2ab:	AND $86 zp
2ad:	TAX
2ae:	LDA $95,X zp
2b0:	STA $b,X zp
2b2:	AND #f
2b4:	TAY
2b5:	BIT $83 zp
2b7:	BPL $2 rel
2b9:	STY $97,X zp
2bb:	TXA
2bc:	EOR #e
2be:	TAX
2bf:	TYA
2c0:	ASL A
2c1:	ASL A
2c2:	ASL A
2c3:	CMP #3f
2c5:	CLC
2c6:	BMI $3 rel
2c8:	SEC
2c9:	EOR #47
2cb:	TAY
2cc:	LDA ($bb,Y)
2ce:	STA $bd,X zp
2d0:	BCC $2 rel
2d2:	DEY
2d3:	DEY
2d4:	INY
2d5:	DEX
2d6:	DEX
2d7:	BPL $-13 rel
2d9:	RTS
2da:	LDA $8a zp
2dc:	SEC
2dd:	SBC #2
2df:	BCC $43 rel
2e1:	STA $8a zp
2e3:	CMP #2
2e5:	BCC $36 rel
2e7:	AND #1
2e9:	TAX
2ea:	INC $95,X zp
2ec:	LDA $d8,X zp
2ee:	STA $d6,X zp
2f0:	LDA $8a zp
2f2:	CMP #f7
2f4:	BCC $3 rel
2f6:	JSR $f508 abs
2f9:	LDA $8a zp
2fb:	BPL $14 rel
2fd:	LSR A
2fe:	LSR A
2ff:	LSR A
300:	STA $19,X zp
302:	LDA #8
304:	STA $15,X zp
306:	LDA $f7fe,X abs
309:	STA $17,X zp
30b:	RTS
30c:	LDX #1
30e:	LDA $282 abs
311:	STA $d5 zp
313:	LDA $280 abs
316:	BIT $88 zp
318:	BMI $2 rel
31a:	LDA #ff
31c:	EOR #ff
31e:	AND #f
320:	STA $d2 zp
322:	LDY $85 zp
324:	LDA $f70f,Y abs
327:	CLC
328:	ADC $d2 zp
32a:	TAY
32b:	LDA $f712,Y abs
32e:	AND #f
330:	STA $d1 zp
332:	BEQ $4 rel
334:	CMP $91,X zp
336:	BNE $4 rel
338:	DEC $93,X zp
33a:	BNE $13 rel
33c:	STA $91,X zp
33e:	LDA #f
340:	STA $93,X zp
342:	LDA $d1 zp
344:	CLC
345:	ADC $95,X zp
347:	STA $95,X zp
349:	INC $8d,X zp
34b:	BMI $30 rel
34d:	LDA $f712,Y abs
350:	LSR A
351:	LSR A
352:	LSR A
353:	LSR A
354:	BIT $d5 zp
356:	BMI $35 rel
358:	STA $8b,X zp
35a:	ASL A
35b:	TAY
35c:	LDA $f637,Y abs
35f:	STA $a8,X zp
361:	INY
362:	LDA $f637,Y abs
365:	STA $aa,X zp
367:	LDA #f0
369:	STA $8d,X zp
36b:	JSR $f380 abs
36e:	LDA $280 abs
371:	LSR A
372:	LSR A
373:	LSR A
374:	LSR A
375:	ASL $d5 zp
377:	DEX
378:	BEQ $-100 rel
37a:	RTS
37b:	SEC
37c:	SBC $85 zp
37e:	BPL $-40 rel
380:	LDA $a3 zp
382:	BMI $8 rel
384:	AND #1
386:	BEQ $4 rel
388:	LDA $db zp
38a:	STA $d6,X zp
38c:	LDA $99,X zp
38e:	BEQ $39 rel
390:	LDA $d8,X zp
392:	STA $d6,X zp
394:	LDA $99,X zp
396:	CMP #7
398:	BCC $20 rel
39a:	BIT $d5 zp
39c:	BPL $4 rel
39e:	CMP #1c
3a0:	BCC $12 rel
3a2:	CMP #30
3a4:	BCC $31 rel
3a6:	CMP #37
3a8:	BCS $33 rel
3aa:	BIT $83 zp
3ac:	BVC $29 rel
3ae:	LDA #0
3b0:	STA $99,X zp
3b2:	LDA #ff
3b4:	STA $28,X zp
3b6:	RTS
3b7:	BIT $88 zp
3b9:	BPL $4 rel
3bb:	LDA $3c,X zp
3bd:	BPL $55 rel
3bf:	JSR $f410 abs
3c2:	JMP $f3ae abs
3c5:	JSR $f410 abs
3c8:	JMP $f3de abs
3cb:	LDA $9f,X zp
3cd:	BEQ $10 rel
3cf:	JSR $f410 abs
3d2:	LDA #30
3d4:	STA $99,X zp
3d6:	JMP $f3de abs
3d9:	LDA $99,X zp
3db:	JSR $f300 abs
3de:	LDA $86 zp
3e0:	AND #3
3e2:	BEQ $12 rel
3e4:	BIT $84 zp
3e6:	BVS $10 rel
3e8:	BIT $82 zp
3ea:	BVC $4 rel
3ec:	AND #1
3ee:	BNE $2 rel
3f0:	DEC $99,X zp
3f2:	LDA #0
3f4:	BEQ $-66 rel
3f6:	LDA #3f
3f8:	STA $99,X zp
3fa:	SEC
3fb:	LDA $a4,X zp
3fd:	SBC #6
3ff:	STA $a6,X zp
401:	LDA $95,X zp
403:	STA $97,X zp
405:	LDA #1f
407:	STA $9b,X zp
409:	LDA #0
40b:	STA $9d,X zp
40d:	JMP $f3cb abs
410:	LDA $9f,X zp
412:	BEQ $13 rel
414:	LDA #4
416:	STA $15,X zp
418:	LDA #7
41a:	STA $19,X zp
41c:	LDA $9b,X zp
41e:	STA $17,X zp
420:	RTS
421:	LDY $85 zp
423:	LDA $f733,Y abs
426:	AND $88 zp
428:	STA $19,X zp
42a:	LDA $f736,Y abs
42d:	STA $15,X zp
42f:	CLC
430:	LDA #0
432:	DEY
433:	BMI $4 rel
435:	ADC #c
437:	BPL $-7 rel
439:	ADC $8b,X zp
43b:	TAY
43c:	TXA
43d:	ASL A
43e:	ADC $f739,Y abs
441:	STA $17,X zp
443:	RTS
444:	LDX #1
446:	LDA $30,X zp
448:	BPL $44 rel
44a:	BIT $84 zp
44c:	BVC $6 rel
44e:	LDA $9b,X zp
450:	CMP #1f
452:	BEQ $34 rel
454:	INC $95,X zp
456:	INC $97,X zp
458:	SED
459:	LDA $a1,X zp
45b:	CLC
45c:	ADC #1
45e:	STA $a1,X zp
460:	CLD
461:	TXA
462:	CLC
463:	ADC #fd
465:	STA $8a zp
467:	LDA #ff
469:	STA $28 zp
46b:	STA $29 zp
46d:	LDA #0
46f:	STA $19,X zp
471:	STA $99 zp
473:	STA $9a zp
475:	RTS
476:	BIT $a3 zp
478:	BPL $3 rel
47a:	JMP $f501 abs
47d:	LDA $9f,X zp
47f:	BEQ $10 rel
481:	CMP #4
483:	INC $9f,X zp
485:	BCC $4 rel
487:	LDA #0
489:	STA $9f,X zp
48b:	LDA $34,X zp
48d:	BMI $7 rel
48f:	LDA #0
491:	STA $9d,X zp
493:	JMP $f4d6 abs
496:	BIT $82 zp
498:	BVC $54 rel
49a:	LDA $9d,X zp
49c:	BNE $25 rel
49e:	INC $9f,X zp
4a0:	DEC $9b,X zp
4a2:	LDA $97,X zp
4a4:	STA $b2,X zp
4a6:	EOR #ff
4a8:	STA $97,X zp
4aa:	INC $97,X zp
4ac:	LDA $97,X zp
4ae:	AND #3
4b0:	BNE $2 rel
4b2:	INC $97,X zp
4b4:	JMP $f4d4 abs
4b7:	CMP #1
4b9:	BEQ $11 rel
4bb:	CMP #3
4bd:	BCC $21 rel
4bf:	BNE $19 rel
4c1:	LDA $b2,X zp
4c3:	JMP $f4c8 abs
4c6:	LDA $97,X zp
4c8:	CLC
4c9:	ADC #8
4cb:	STA $97,X zp
4cd:	JMP $f4d4 abs
4d0:	LDA #1
4d2:	STA $99,X zp
4d4:	INC $9d,X zp
4d6:	LDA $32,X zp
4d8:	BMI $4 rel
4da:	LDA $37 zp
4dc:	BPL $9 rel
4de:	LDA $8a zp
4e0:	CMP #2
4e2:	BCC $9 rel
4e4:	JSR $f508 abs
4e7:	LDA #3
4e9:	STA $e4,X zp
4eb:	BNE $20 rel
4ed:	DEC $e4,X zp
4ef:	BMI $6 rel
4f1:	LDA $8b,X zp
4f3:	BEQ $12 rel
4f5:	BNE $2 rel
4f7:	INC $95,X zp
4f9:	LDA $95,X zp
4fb:	CLC
4fc:	ADC #8
4fe:	JSR $f50f abs
501:	DEX
502:	BMI $3 rel
504:	JMP $f446 abs
507:	RTS
508:	TXA
509:	EOR #1
50b:	TAY
50c:	LDA $97,Y abs
50f:	AND #f
511:	TAY
512:	LDA $f627,Y abs
515:	JSR $f27c abs
518:	LDA #0
51a:	STA $a8,X zp
51c:	STA $aa,X zp
51e:	STA $8d,X zp
520:	LDA $d8,X zp
522:	STA $d6,X zp
524:	RTS
525:	LDX $85 zp
527:	LDA $f7c6,X abs
52a:	STA $bb zp
52c:	LDA $f7c9,X abs
52f:	STA $bc zp
531:	LDA $a3 zp
533:	LSR A
534:	LSR A
535:	AND #3
537:	TAX
538:	LDA $a3 zp
53a:	BPL $10 rel
53c:	AND #8
53e:	BEQ $4 rel
540:	LDX #3
542:	BPL $4 rel
544:	LDA #80
546:	STA $82 zp
548:	LDA $a3 zp
54a:	ASL A
54b:	ASL A
54c:	BIT $a3 zp
54e:	BMI $6 rel
550:	STA $2 zp
552:	STA $84 zp
554:	AND #80
556:	STA $83 zp
558:	LDA #f7
55a:	STA $b6 zp
55c:	STA $b8 zp
55e:	STA $ba zp
560:	LDA $f7cc,X abs
563:	STA $10 zp
565:	STA $b5 zp
567:	LDA $f7d0,X abs
56a:	STA $b7 zp
56c:	LDA $f7d4,X abs
56f:	STA $b9 zp
571:	RTS
572:	LDA $a3 zp
574:	AND #87
576:	BMI $2 rel
578:	LDA #0
57a:	ASL A
57b:	TAX
57c:	LDA $f75d,X abs
57f:	STA $4 zp
581:	LDA $f75e,X abs
584:	STA $5 zp
586:	LDA $a3 zp
588:	AND #c0
58a:	LSR A
58b:	LSR A
58c:	LSR A
58d:	LSR A
58e:	TAY
58f:	LDA $88 zp
591:	STA $282 abs
594:	EOR #ff
596:	AND $dd zp
598:	STA $d1 zp
59a:	LDX #ff
59c:	LDA $282 abs
59f:	AND #8
5a1:	BNE $4 rel
5a3:	LDY #10
5a5:	LDX #f
5a7:	STX $d2 zp
5a9:	LDX #3
5ab:	LDA $f765,Y abs
5ae:	EOR $d1 zp
5b0:	AND $d2 zp
5b2:	STA $6,X zp
5b4:	STA $d6,X zp
5b6:	STA $d8,X zp
5b8:	INY
5b9:	DEX
5ba:	BPL $-17 rel
5bc:	RTS
5bd:	LDA #0
5bf:	INX
5c0:	STA $a2,X zp
5c2:	BNE $-5 rel
5c4:	RTS
5c5:	ASL $a0a abs
5c8:	ASL A
5c9:	ASL $2222 abs
5cc:	HLT
5cd:	HLT
5ce:	HLT
5cf:	INC $ee22 abs
5d2:	DEY
5d3:	INC $22ee abs
5d6:	ROR $22 zp
5d8:	INC $aaaa abs
5db:	INC $2222 abs
5de:	INC $ee88 abs
5e1:	HLT
5e2:	INC $88ee abs
5e5:	INC $eeaa abs
5e8:	INC $2222 abs
5eb:	HLT
5ec:	HLT
5ed:	INC $eeaa abs
5f0:	TAX
5f1:	INC $aaee abs
5f4:	INC $ee22 abs
5f7:	SED
5f8:	ISC $f6,X zp
5fa:	ASL $6 zp
5fc:	ASL $16 zp
5fe:	SLO $18,X zp
600:	ORA $a1a,Y abs
603:	ASL A
604:	ASL A
605:	NOP2
606:	SBC $f7f8,Y abs
609:	INC $f6,X zp
60b:	ASL $16 zp
60d:	ASL $17,X zp
60f:	CLC
610:	ORA $1a1a,Y abs
613:	ASL A
614:	NOP2
615:	NOP2
616:	SBC $e6e8,Y abs
619:	CPX $f4 zp
61b:	NOP2 $14 zp
61d:	BIT $26 zp
61f:	PLP
620:	ROL A
621:	BIT $c1c abs
624:	NOP2 $eaec,X abs
627:	INY
628:	CPY $c0 zp
62a:	CPX #0
62c:	JSR $4440 abs
62f:	PHA
630:	JMP $2f4f abs
633:	SLO $cfef abs
636:	CPY $0 abs
639:	NOP2 #80
63b:	STY $20 zp
63d:	DEY
63e:	DEY
63f:	HLT
640:	PHA
641:	LDY $a4 zp
643:	LDA #52
645:	TAX
646:	TAX
647:	CMP $aa,X zp
649:	NOP2
64a:	NOP2
64b:	DCP $ee6d,Y abs
64e:	INC $fc00 abs
651:	NOP2 $3f38,X abs
654:	SEC
655:	NOP2 $1cfc,X abs
658:	SEI
659:	ISC $1c7c,Y abs
65c:	SLO $183e,X abs
65f:	ORA $7c3a,Y abs
662:	ISC $edf,X abs
665:	NOP2 $2418,X abs
668:	NOP2 $79 zp
66a:	ISC $4eff,X abs
66d:	ASL $804 abs
670:	PHP
671:	ARR #7f
673:	RRA $637f,X abs
676:	RRA ($24,X)
678:	ROL $9e zp
67a:	ISC $72ff,X abs
67d:	BVS $32 rel
67f:	TYA
680:	NOP2 $ff3e,X abs
683:	ISC $3870,Y abs
686:	CLC
687:	SEC
688:	ASL $3edf,X abs
68b:	SEC
68c:	SED
68d:	NOP2 $6018,X abs
690:	BVS $120 rel
692:	ISC $7078,X abs
695:	RTS
696:	BRK
697:	BRK
698:	CMP ($fe,X)
69a:	NOP2 $3078,X abs
69d:	BMI $48 rel
69f:	BRK
6a0:	SLO ($6,X)
6a2:	NOP2 $3cfc,X abs
6a5:	NOP2 $20c abs
6a8:	NOP2 $c zp
6aa:	NOP2 $fcfc,X abs
6ad:	ASL $1006,X abs
6b0:	BPL $16 rel
6b2:	SEC
6b3:	NOP2 $fefe,X abs
6b6:	BPL $64 rel
6b8:	JSR $3830 abs
6bb:	RLA $783f,X abs
6be:	RTS
6bf:	RTI
6c0:	RTS
6c1:	RLA $1e1f,X abs
6c4:	ASL $1818,X abs
6c7:	BRK
6c8:	SAX ($7f,X)
6ca:	ROL $c1e,X abs
6cd:	NOP2 $c abs
6d0:	STX $ff84 abs
6d3:	ISC $e04,X abs
6d6:	BRK
6d7:	BRK
6d8:	ASL $8f04 abs
6db:	RRA $772,X abs
6de:	BRK
6df:	BPL $54 rel
6e1:	ROL $1f0c abs
6e4:	HLT
6e5:	CPX #40
6e7:	BIT $2c zp
6e9:	EOR $1a1a,X abs
6ec:	BMI $-16 rel
6ee:	RTS
6ef:	CLC
6f0:	NOP2
6f1:	ROR $185a,X abs
6f4:	CLC
6f5:	CLC
6f6:	SEI
6f7:	NOP2 $36,X zp
6f9:	NOP2
6fa:	SEI
6fb:	BIT $60c abs
6fe:	NOP2 $6c08 abs
701:	BVS $-72 rel
703:	NOP2 $74e,X abs
706:	ASL $38 zp
708:	BPL $-16 rel
70a:	NOP2 $e34f,X abs
70d:	HLT
70e:	BRK
70f:	BRK
710:	ANC #16
712:	BRK
713:	BPL $0 rel
715:	ISC $1101,X abs
718:	ORA ($ff,X)
71a:	SLO $f1f abs
71d:	BVC $95 rel
71f:	EOR ($ff,Y)
721:	BMI $63 rel
723:	AND ($ff,Y)
725:	BVS $127 rel
727:	ADC ($90,Y)
729:	BCS $112 rel
72b:	ISC $b191,X abs
72e:	ADC ($ff,Y)
730:	SHA $7fbf,Y abs
733:	PHP
734:	HLT
735:	HLT
736:	HLT
737:	SLO ($8,X)
739:	ORA $5,X abs
73c:	BRK
73d:	BRK
73e:	BRK
73f:	BRK
740:	BRK
741:	BRK
742:	BRK
743:	BRK
744:	BRK
745:	BRK
746:	BRK
747:	ORA $161d,X abs
74a:	ASL $f,X zp
74c:	SLO $0 abs
74f:	BRK
750:	BRK
751:	BRK
752:	BRK
753:	BRK
754:	BRK
755:	BRK
756:	HLT
757:	BPL $16 rel
759:	NOP2 $70c abs
75c:	SLO $0 zp
75e:	BRK
75f:	ORA ($1,X)
761:	BRK
762:	SLO ($27,X)
764:	SLO ($ea,X)
766:	NOP2 $4482,X abs
769:	HLT
76a:	BIT $da8a abs
76d:	NOP2 #9c
76f:	NOP2
770:	NOP2
771:	NOP2 $a8 zp
773:	NOP2
774:	LSR A
775:	PHP
776:	NOP2 $0 zp
778:	ASL $10f0 abs
77b:	BPL $16 rel
77d:	BPL $16 rel
77f:	BPL $16 rel
781:	BPL $16 rel
783:	BPL $16 rel
785:	ISC $0,X abs
788:	BRK
789:	SEC
78a:	BRK
78b:	BRK
78c:	BRK
78d:	RTS
78e:	JSR $2320 abs
791:	ISC $8080,X abs
794:	BRK
795:	BRK
796:	BRK
797:	NOP2 $4,X abs
79a:	BRK
79b:	BRK
79c:	BRK
79d:	ISC $0,X abs
7a0:	BRK
7a1:	BRK
7a2:	BRK
7a3:	BRK
7a4:	BRK
7a5:	BRK
7a6:	BRK
7a7:	BRK
7a8:	BRK
7a9:	BRK
7aa:	SLO $1f zp
7ac:	RLA $ff7f,X abs
7af:	BRK
7b0:	BRK
7b1:	BRK
7b2:	BRK
7b3:	BRK
7b4:	BRK
7b5:	BRK
7b6:	BRK
7b7:	RTS
7b8:	JSR $ff21 abs
7bb:	BRK
7bc:	BRK
7bd:	BRK
7be:	NOP2 #80
7c0:	NOP2 #80
7c2:	BRK
7c3:	BRK
7c4:	BRK
7c5:	SLO $4f zp
7c7:	DCP $f68f abs
7ca:	INC $f6,X zp
7cc:	ADC $75,X zp
7ce:	ADC $9a,X zp
7d0:	STA ($99,X)
7d2:	TAX
7d3:	STA $998d,X abs
7d6:	LDX $9d,Y zp
7d8:	BIT $28 zp
7da:	PHP
7db:	JSR $4800 abs
7de:	RTI
7df:	NOP2 $58,X zp
7e1:	AND $29 zp
7e3:	EOR #55
7e5:	EOR $88a8,Y abs
7e8:	TYA
7e9:	BCC $-95 rel
7eb:	SAX ($e8,X)
7ed:	INY
7ee:	CPX #c0
7f0:	SBC #e2
7f2:	CMP ($ff,X)
7f4:	BRK
7f5:	BRK
7f6:	BRK
7f7:	BRK
7f8:	BRK
7f9:	BRK
7fa:	BRK
7fb:	BRK
7fc:	BRK
7fd:	BEQ $15 rel
7ff:	ORA ($0,Y)
```

