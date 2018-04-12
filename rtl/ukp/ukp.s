; USB keyboard interface for UKP

label0:
	ldi	9	; inturrupt transfer interval (10-1mS)
label1:
	wait
	bc	label11
	bz	label0

	; wait 200mS after device attached

	ldi	200
label2:
	wait
	djnz	label2

	; USB bus reset

	out0
	ldi	10
label3:
	wait
	djnz	label3
	hiz

	; 40mS wait

	ldi	40
label4:
	wait
	out0
	out0
	out2
	out2
	hiz
	djnz	label4

	wait

	; send set address 1

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out0
	out0
	out2
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out2
	out2
	out2
	out2
	out1
	out1
	out2
	out1
	out1
	out2
	out1
	out0
	out0
	out2
	out2
	hiz

	; recieve

	ldi	64
	start
	in
label5:
	ldi	8
label6:
	bz	label5
	djnz	label6

	; send IN(0,0)
label7:
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out1
	out1
	out2
	out2
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out0
	out0
	out2
	out2
	hiz

	; recieve

	ldi	64
	start
	in
label8:
	ldi	8
label9:
	bz	label8
	djnz	label9
	bnak	label7

	; send ACK

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out1
	out2
	out2
	out1
	out1
	out1
	out0
	out0
	out2
	out2
	hiz

	; wait 1mS

	wait

	; send set configuration 1

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out2
	out2
	out0
	out0
	out2
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out2
	out2
	out2
	out1
	out2
	out2
	out1
	out2
	out2
	out1
	out1
	out2
	out1
	out1
	out2
	out1
	out0
	out0
	out2
	out2
	hiz

	; recieve

	ldi	64
	start
	in
label18:
	ldi	8
label19:
	bz	label18
	djnz	label19

	; send IN(1,0)
label10:
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out1
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out2
	out2
	out0
	out0
	out2
	out2
	hiz

	; recieve

	ldi	64
	start
	in
label28:
	ldi	8
label29:
	bz	label28
	djnz	label29
	bnak	label10

	; send ACK

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out1
	out2
	out2
	out1
	out1
	out1
	out0
	out0
	out2
	out2
	hiz

	toggle
	ldi	0
	djnz	label0

	; when connected

label11:
	bz	label12

	out0
	out0
	out2
	out2
	hiz
	djnz	label1

	wait

	; IN(1,1) (interrupt transfer)

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out1
	out2
	out1
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out1
	out2
	out2
	out2
	out1
	out1
	out2
	out0
	out0
	out2
	out2
	hiz

	; recieve

	ldi	64
	start
	in
label38:
	ldi	8
label39:
	bz	label38
	djnz	label39
	bnak	label0

	; send ACK

	out1
	out2
	out1
	out2
	out1
	out2
	out1
	out1
	out2
	out2
	out1
	out2
	out2
	out1
	out1
	out1
	out0
	out0
	out2
	out2
	hiz

	ldi	0
	djnz	label0

label12:
	toggle
	ldi	0
	djnz	label0

