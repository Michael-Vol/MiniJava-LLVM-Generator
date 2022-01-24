declare i8* @calloc(i32, i32)
declare i32 @printf(i8*, ...)
declare void @exit(i32)

@_cint = constant [4 x i8] c"%d\0a\00"
@_cOOB = constant [15 x i8] c"Out of bounds\0a\00"
@_cNSZ = constant [15 x i8] c"Negative size\0a\00"
define void @print_int(i32 %i) {
%_str = bitcast [4 x i8]* @_cint to i8*
call i32 (i8*, ...) @printf(i8* %_str, i32 %i)
ret void
}

define void @throw_oob() {
%_str = bitcast [15 x i8]* @_cOOB to i8*
call i32 (i8*, ...) @printf(i8* %_str)
call void @exit(i32 1)
ret void
}

define void @throw_nsz() {
%_str = bitcast [15 x i8]* @_cNSZ to i8*
call i32 (i8*, ...) @printf(i8* %_str)
call void @exit(i32 1)
ret void
}

define i32 @main() {
%x = alloca i32*

; Calculate size bytes to be allocated for the array (new arr[sz] -> add i32 1, sz)
%_0 = add i32 1, 2
; Check that the size of the array is not negative
%_1 = icmp sge i32 %_0, 1
br i1 %_1, label %nsz_ok_0, label %nsz_err_0

; Size was negative, throw negative size exception
nsz_err_0:
call void @throw_nsz()
br label %nsz_ok_0

; All ok, we can proceed with the allocation
nsz_ok_0:

; Allocate sz + 1 integers (4 bytes each)
%_2 = call i8* @calloc(i32 %_0, i32 4)

; Cast the returned pointer
%_3 = bitcast i8* %_2 to i32*

 ; Store the size of the array in the first position of the array 
store i32 2,i32* %_3

; This concludes the array allocation

store i32* %_3, i32** %x

; The following segment implements the array store

; Load the address of the array
%_4 = load i32*, i32** %x

; Load the size of the array(first integer of the array)
%_5 = load i32, i32* %_4

; Check that the index is greater than zero
%_6 = icmp sge i32 0, 0

; Check that the index is less than the size of the array
%_7 = icmp slt i32 0, %_5

; Both of these conditions must hold
%_8 = and i1 %_6, %_7
br i1 %_8, label %oob_ok_1, label %oob_err_1

; Else throw out of bounds exception
oob_err_1:
call void @throw_oob()
br label %oob_ok_1

; All ok, we can safely index the array now
oob_ok_1:

; Add one to the index since the first element holds the size.
%_9 = add i32 1,0

; Get pointer to the i+1 element of the array.
%_10 = getelementptr i32, i32* %_4, i32 %_9

store i32 1, i32* %_10

; The following segment implements the array store

; Load the address of the array
%_11 = load i32*, i32** %x

; Load the size of the array(first integer of the array)
%_12 = load i32, i32* %_11

; Check that the index is greater than zero
%_13 = icmp sge i32 1, 0

; Check that the index is less than the size of the array
%_14 = icmp slt i32 0, %_12

; Both of these conditions must hold
%_15 = and i1 %_13, %_14
br i1 %_15, label %oob_ok_2, label %oob_err_2

; Else throw out of bounds exception
oob_err_2:
call void @throw_oob()
br label %oob_ok_2

; All ok, we can safely index the array now
oob_ok_2:

; Add one to the index since the first element holds the size.
%_16 = add i32 1,1

; Get pointer to the i+1 element of the array.
%_17 = getelementptr i32, i32* %_11, i32 %_16

store i32 2, i32* %_17

%_23 = load i32*, i32** %x 

; The following segment implements the array lookup

; Load the address of the array
%_18 = load i32*, i32** %x

; Load the size of the array(first integer of the array)
%_19 = load i32, i32* %_18

; Check that the index is greater than zero
%_20 = icmp sge i32 0, 0

; Check that the index is less than the size of the array
%_21 = icmp slt i32 0, %_19

; Both of these conditions must hold
%_22 = and i1 %_20, %_21
br i1 %_22, label %oob_ok_3, label %oob_err_3

; Else throw out of bounds exception
oob_err_3:
call void @throw_oob()
br label %oob_ok_3

; All ok, we can safely index the array now
oob_ok_3:

; Add one to the index since the first element holds the size.
%_25 = add i32 1,0

; Get pointer to the i+1 element of the array.
%_26 = getelementptr i32, i32* %_18, i32 %_25

%_32 = load i32*, i32** %x 

; The following segment implements the array lookup

; Load the address of the array
%_27 = load i32*, i32** %x

; Load the size of the array(first integer of the array)
%_28 = load i32, i32* %_27

; Check that the index is greater than zero
%_29 = icmp sge i32 1, 0

; Check that the index is less than the size of the array
%_30 = icmp slt i32 0, %_28

; Both of these conditions must hold
%_31 = and i1 %_29, %_30
br i1 %_31, label %oob_ok_4, label %oob_err_4

; Else throw out of bounds exception
oob_err_4:
call void @throw_oob()
br label %oob_ok_4

; All ok, we can safely index the array now
oob_ok_4:

; Add one to the index since the first element holds the size.
%_34 = add i32 1,1

; Get pointer to the i+1 element of the array.
%_35 = getelementptr i32, i32* %_27, i32 %_34

%_36 = load i32, i32* %_26

%_37 = load i32, i32* %_35

%_38 = add i32 %_36, %_37

call void (i32) @print_int(i32 %_38)

ret i32 0
}
