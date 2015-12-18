; $1: Temp
; $2: RAM Starting Address
; $3: RAM Terminate Address
; $4: Adder


; Read address
lb $1 COMCache($0)
addu $2 $0 $1
lb $1 COMCache($0)
sll $1 $1 8
addu $2 $2 $1
lb $1 COMCache($0)
sll $1 $1 16
addu $2 $2 $1
lb $1 COMCache($0)
sll $1 $1 24
addu $2 $2 $1

; Write to RAM and count
Write_to_RAM:
	addiu $3 $2 65536
	addu $4 $0 $0
	lb $1 COMCache($0)
	sb $1 0($2)
	addiu $2 $2 1
	addu $4 $4 $1
	
	bne $2 $3 Write_to_RAM

; Return total count
sb $4 COMCache($0)
srl $4 8
sb $4 COMCache($0)
srl $4 8
sb $4 COMCache($0)
srl $4 8
sb $4 COMCache($0)