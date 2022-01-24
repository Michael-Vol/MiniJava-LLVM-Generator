@.BBS_vtable = global [4 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @BBS.Start to i8*),
	i8* bitcast (i32 (i8*)* @BBS.Sort to i8*),
	i8* bitcast (i32 (i8*)* @BBS.Print to i8*),
	i8* bitcast (i32 (i8*,i32)* @BBS.Init to i8*)
]

@.BubbleSort.ll_vtable = global [0 x i8*] []
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
; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_0 = call i8* @calloc(i32 1,i32 20)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [4 x i8*], [4 x i8*]* @.BBS_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_2, i8*** %_1

; Do the required bitcasts, so that we can access the vtable pointer
%_3 = bitcast i8* %_0 to i8***

;  Load vtable_ptr
%_4 = load i8**, i8*** %_3

; Get a pointer to the i-th entry in the vtable. 
%_5 = getelementptr i8*, i8** %_4, i32 0

;Get the actual function pointer 
%_6 = load i8*, i8** %_5

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_7 = bitcast i8* %_6 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_9 = call i32 %_7(i8* %_0,i32 10)



call void (i32) @print_int(i32 %_9)

ret i32 0
}
define i32 @BBS.Start(i8* %this,i32 %.sz) {
%sz = alloca i32
store i32 %.sz, i32* %sz

%aux01 = alloca i32

; Do the required bitcasts, so that we can access the vtable pointer
%_0 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_1 = load i8**, i8*** %_0

; Get a pointer to the i-th entry in the vtable. 
%_2 = getelementptr i8*, i8** %_1, i32 3

;Get the actual function pointer 
%_3 = load i8*, i8** %_2

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_4 = bitcast i8* %_3 to i32 (i8*, i32)*

%_5 = load i32, i32* %sz 

;Perform the call - note the first argument is the receiver object.
%_6 = call i32 %_4(i8* %this,i32 %_5)



store i32 %_6, i32* %aux01

; Do the required bitcasts, so that we can access the vtable pointer
%_7 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_8 = load i8**, i8*** %_7

; Get a pointer to the i-th entry in the vtable. 
%_9 = getelementptr i8*, i8** %_8, i32 2

;Get the actual function pointer 
%_10 = load i8*, i8** %_9

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_11 = bitcast i8* %_10 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_13 = call i32 %_11(i8* %this)



store i32 %_13, i32* %aux01

call void (i32) @print_int(i32 99999)

; Do the required bitcasts, so that we can access the vtable pointer
%_15 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_16 = load i8**, i8*** %_15

; Get a pointer to the i-th entry in the vtable. 
%_17 = getelementptr i8*, i8** %_16, i32 1

;Get the actual function pointer 
%_18 = load i8*, i8** %_17

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_19 = bitcast i8* %_18 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_21 = call i32 %_19(i8* %this)



store i32 %_21, i32* %aux01

; Do the required bitcasts, so that we can access the vtable pointer
%_22 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_23 = load i8**, i8*** %_22

; Get a pointer to the i-th entry in the vtable. 
%_24 = getelementptr i8*, i8** %_23, i32 2

;Get the actual function pointer 
%_25 = load i8*, i8** %_24

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_26 = bitcast i8* %_25 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_28 = call i32 %_26(i8* %this)



store i32 %_28, i32* %aux01

ret i32 0
}

define i32 @BBS.Sort(i8* %this) {
%nt = alloca i32

%i = alloca i32

%aux02 = alloca i32

%aux04 = alloca i32

%aux05 = alloca i32

%aux06 = alloca i32

%aux07 = alloca i32

%j = alloca i32

%t = alloca i32

%_0 = getelementptr i8, i8* %this, i32 16

%_1 = bitcast i8*%_0 to i32*

%_2 = load i32, i32* %_1

%_3 = sub i32 %_1, 1

store i32 %_3, i32* %i

%_4 = sub 0, 1

store i32 %_4, i32* %aux02

%_5 = load i32, i32* %aux02

%_6 = load i32, i32* %i

%_7 = icmp slt i32 %_5, %_6

br label %loop0_end

loop0_end:

br i1 %_8, label %loop1_body, label %loop2_end

store i32 1, i32* %j

%_9 = load i32, i32* %i

%_10 = add i32 %_9, 1

%_11 = load i32, i32* %j

%_12 = icmp slt i32 %_11, PlusExpression

br label %loop3_end

loop3_end:

br i1 %_13, label %loop4_body, label %loop5_end

%_14 = load i32, i32* %j

%_15 = sub i32 %_14, 1

store i32 %_15, i32* %aux07

%_21 = load i32, i32* %aux07 

; The following segment implements the array lookup

; Load the address of the array
%_16 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_17 = load i32, i32* %_16

; Check that the index is greater than zero
%_18 = icmp sge i32 %_21, 0

; Check that the index is less than the size of the array
%_19 = icmp slt i32 0, %_17

; Both of these conditions must hold
%_20 = and i1 %_18, %_19
br i1 %_20, label %oob_ok_6, label %oob_err_6

; Else throw out of bounds exception
oob_err_6:
call void @throw_oob()
br label %oob_ok_6

; All ok, we can safely index the array now
oob_ok_6:

; Add one to the index since the first element holds the size.
%_22 = add i32 1,%_21

; Get pointer to the i+1 element of the array.
%_23 = getelementptr i32, i32* %_16, i32 %_22

store i32* %_23, i32* %aux04

%_29 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_24 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_25 = load i32, i32* %_24

; Check that the index is greater than zero
%_26 = icmp sge i32 %_29, 0

; Check that the index is less than the size of the array
%_27 = icmp slt i32 0, %_25

; Both of these conditions must hold
%_28 = and i1 %_26, %_27
br i1 %_28, label %oob_ok_7, label %oob_err_7

; Else throw out of bounds exception
oob_err_7:
call void @throw_oob()
br label %oob_ok_7

; All ok, we can safely index the array now
oob_ok_7:

; Add one to the index since the first element holds the size.
%_30 = add i32 1,%_29

; Get pointer to the i+1 element of the array.
%_31 = getelementptr i32, i32* %_24, i32 %_30

store i32* %_31, i32* %aux05

%_32 = load i32, i32* %aux05

%_33 = load i32, i32* %aux04

%_34 = icmp slt i32 %_32, %_33

br i1 %_34, label %if_then_0, label %if_else_0

if_else_0:
store i32 0, i32* %nt

br label %if_end_0
if_then_0:
%_35 = load i32, i32* %j

%_36 = sub i32 %_35, 1

store i32 %_36, i32* %aux06

%_42 = load i32, i32* %aux06 

; The following segment implements the array lookup

; Load the address of the array
%_37 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_38 = load i32, i32* %_37

; Check that the index is greater than zero
%_39 = icmp sge i32 %_42, 0

; Check that the index is less than the size of the array
%_40 = icmp slt i32 0, %_38

; Both of these conditions must hold
%_41 = and i1 %_39, %_40
br i1 %_41, label %oob_ok_8, label %oob_err_8

; Else throw out of bounds exception
oob_err_8:
call void @throw_oob()
br label %oob_ok_8

; All ok, we can safely index the array now
oob_ok_8:

; Add one to the index since the first element holds the size.
%_43 = add i32 1,%_42

; Get pointer to the i+1 element of the array.
%_44 = getelementptr i32, i32* %_37, i32 %_43

store i32* %_44, i32* %t

%_50 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_45 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_46 = load i32, i32* %_45

; Check that the index is greater than zero
%_47 = icmp sge i32 %_50, 0

; Check that the index is less than the size of the array
%_48 = icmp slt i32 0, %_46

; Both of these conditions must hold
%_49 = and i1 %_47, %_48
br i1 %_49, label %oob_ok_9, label %oob_err_9

; Else throw out of bounds exception
oob_err_9:
call void @throw_oob()
br label %oob_ok_9

; All ok, we can safely index the array now
oob_ok_9:

; Add one to the index since the first element holds the size.
%_51 = add i32 1,%_50

; Get pointer to the i+1 element of the array.
%_52 = getelementptr i32, i32* %_45, i32 %_51

; The following segment implements the array store

; Load the address of the array
%_53 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_54 = load i32, i32* %_53

; Check that the index is greater than zero
%_55 = icmp sge i32 aux06, 0

; Check that the index is less than the size of the array
%_56 = icmp slt i32 0, %_54

; Both of these conditions must hold
%_57 = and i1 %_55, %_56
br i1 %_57, label %oob_ok_10, label %oob_err_10

; Else throw out of bounds exception
oob_err_10:
call void @throw_oob()
br label %oob_ok_10

; All ok, we can safely index the array now
oob_ok_10:

; Add one to the index since the first element holds the size.
%_58 = add i32 1,aux06

; Get pointer to the i+1 element of the array.
%_59 = getelementptr i32, i32* %_53, i32 %_58

; The following segment implements the array store

; Load the address of the array
%_60 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_61 = load i32, i32* %_60

; Check that the index is greater than zero
%_62 = icmp sge i32 j, 0

; Check that the index is less than the size of the array
%_63 = icmp slt i32 0, %_61

; Both of these conditions must hold
%_64 = and i1 %_62, %_63
br i1 %_64, label %oob_ok_11, label %oob_err_11

; Else throw out of bounds exception
oob_err_11:
call void @throw_oob()
br label %oob_ok_11

; All ok, we can safely index the array now
oob_ok_11:

; Add one to the index since the first element holds the size.
%_65 = add i32 1,j

; Get pointer to the i+1 element of the array.
%_66 = getelementptr i32, i32* %_60, i32 %_65

br label %if_end_0
if_end_0:

%_67 = load i32, i32* %j

%_68 = add i32 %_67, 1

store i32 %_68, i32* %j

br label %loop3_end

loop5_end:

%_69 = load i32, i32* %i

%_70 = sub i32 %_69, 1

store i32 %_70, i32* %i

br label %loop0_end

loop2_end:

ret i32 0
}

define i32 @BBS.Print(i8* %this) {
%j = alloca i32

store i32 0, i32* %j

%_0 = load i32, i32* %j

%_1 = getelementptr i8, i8* %this, i32 16

%_2 = bitcast i8* %_1 to i32*

%_3 = load i32, i32* %_2

%_4 = icmp slt i32 %_0, %_3

br label %loop12_end

loop12_end:

br i1 %_5, label %loop13_body, label %loop14_end

%_11 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_6 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_7 = load i32, i32* %_6

; Check that the index is greater than zero
%_8 = icmp sge i32 %_11, 0

; Check that the index is less than the size of the array
%_9 = icmp slt i32 0, %_7

; Both of these conditions must hold
%_10 = and i1 %_8, %_9
br i1 %_10, label %oob_ok_15, label %oob_err_15

; Else throw out of bounds exception
oob_err_15:
call void @throw_oob()
br label %oob_ok_15

; All ok, we can safely index the array now
oob_ok_15:

; Add one to the index since the first element holds the size.
%_12 = add i32 1,%_11

; Get pointer to the i+1 element of the array.
%_13 = getelementptr i32, i32* %_6, i32 %_12

%_15 = load i32, i32* %_13
call void (i32) @print_int(i32 %_15)

%_16 = load i32, i32* %j

%_17 = add i32 %_16, 1

store i32 %_17, i32* %j

br label %loop12_end

loop14_end:

ret i32 0
}

define i32 @BBS.Init(i8* %this,i32 %.sz) {
%sz = alloca i32
store i32 %.sz, i32* %sz

; Load sz and store it to size
%_0 = load i32, i32* %sz

%_1 = getelementptr i8, i8* %this, i32 16

%_2 =  bitcast i8* %_1 to i32*

store i32 %_0, i32* %_2

; Calculate size bytes to be allocated for the array (new arr[sz] -> add i32 1, sz)
%_3 = add i32 1, sz
; Check that the size of the array is not negative
%_4 = icmp sge i32 %_3, 1
br i1 %_4, label %nsz_ok_16, label %nsz_err_16

; Size was negative, throw negative size exception
nsz_err_16:
call void @throw_nsz()
br label %nsz_ok_16

; All ok, we can proceed with the allocation
nsz_ok_16:

; Allocate sz + 1 integers (4 bytes each)
%_5 = call i8* @calloc(i32 %_3, i32 4)

; Cast the returned pointer
%_6 = bitcast i8* %_5 to i32*

 ; Store the size of the array in the first position of the array 
store i32 sz,i32* %_6

; This concludes the array allocation

%_7 = getelementptr i8, i8* %this, i32* 8

%_8 =  bitcast i8* %_7 to i32**

store i32* %_6, i32** %_8

; The following segment implements the array store

; Load the address of the array
%_9 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_10 = load i32, i32* %_9

; Check that the index is greater than zero
%_11 = icmp sge i32 0, 0

; Check that the index is less than the size of the array
%_12 = icmp slt i32 0, %_10

; Both of these conditions must hold
%_13 = and i1 %_11, %_12
br i1 %_13, label %oob_ok_17, label %oob_err_17

; Else throw out of bounds exception
oob_err_17:
call void @throw_oob()
br label %oob_ok_17

; All ok, we can safely index the array now
oob_ok_17:

; Add one to the index since the first element holds the size.
%_14 = add i32 1,0

; Get pointer to the i+1 element of the array.
%_15 = getelementptr i32, i32* %_9, i32 %_14

store i32 20, i32* %_15

; The following segment implements the array store

; Load the address of the array
%_16 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_17 = load i32, i32* %_16

; Check that the index is greater than zero
%_18 = icmp sge i32 1, 0

; Check that the index is less than the size of the array
%_19 = icmp slt i32 0, %_17

; Both of these conditions must hold
%_20 = and i1 %_18, %_19
br i1 %_20, label %oob_ok_18, label %oob_err_18

; Else throw out of bounds exception
oob_err_18:
call void @throw_oob()
br label %oob_ok_18

; All ok, we can safely index the array now
oob_ok_18:

; Add one to the index since the first element holds the size.
%_21 = add i32 1,1

; Get pointer to the i+1 element of the array.
%_22 = getelementptr i32, i32* %_16, i32 %_21

store i32 7, i32* %_22

; The following segment implements the array store

; Load the address of the array
%_23 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_24 = load i32, i32* %_23

; Check that the index is greater than zero
%_25 = icmp sge i32 2, 0

; Check that the index is less than the size of the array
%_26 = icmp slt i32 0, %_24

; Both of these conditions must hold
%_27 = and i1 %_25, %_26
br i1 %_27, label %oob_ok_19, label %oob_err_19

; Else throw out of bounds exception
oob_err_19:
call void @throw_oob()
br label %oob_ok_19

; All ok, we can safely index the array now
oob_ok_19:

; Add one to the index since the first element holds the size.
%_28 = add i32 1,2

; Get pointer to the i+1 element of the array.
%_29 = getelementptr i32, i32* %_23, i32 %_28

store i32 12, i32* %_29

; The following segment implements the array store

; Load the address of the array
%_30 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_31 = load i32, i32* %_30

; Check that the index is greater than zero
%_32 = icmp sge i32 3, 0

; Check that the index is less than the size of the array
%_33 = icmp slt i32 0, %_31

; Both of these conditions must hold
%_34 = and i1 %_32, %_33
br i1 %_34, label %oob_ok_20, label %oob_err_20

; Else throw out of bounds exception
oob_err_20:
call void @throw_oob()
br label %oob_ok_20

; All ok, we can safely index the array now
oob_ok_20:

; Add one to the index since the first element holds the size.
%_35 = add i32 1,3

; Get pointer to the i+1 element of the array.
%_36 = getelementptr i32, i32* %_30, i32 %_35

store i32 18, i32* %_36

; The following segment implements the array store

; Load the address of the array
%_37 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_38 = load i32, i32* %_37

; Check that the index is greater than zero
%_39 = icmp sge i32 4, 0

; Check that the index is less than the size of the array
%_40 = icmp slt i32 0, %_38

; Both of these conditions must hold
%_41 = and i1 %_39, %_40
br i1 %_41, label %oob_ok_21, label %oob_err_21

; Else throw out of bounds exception
oob_err_21:
call void @throw_oob()
br label %oob_ok_21

; All ok, we can safely index the array now
oob_ok_21:

; Add one to the index since the first element holds the size.
%_42 = add i32 1,4

; Get pointer to the i+1 element of the array.
%_43 = getelementptr i32, i32* %_37, i32 %_42

store i32 2, i32* %_43

; The following segment implements the array store

; Load the address of the array
%_44 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_45 = load i32, i32* %_44

; Check that the index is greater than zero
%_46 = icmp sge i32 5, 0

; Check that the index is less than the size of the array
%_47 = icmp slt i32 0, %_45

; Both of these conditions must hold
%_48 = and i1 %_46, %_47
br i1 %_48, label %oob_ok_22, label %oob_err_22

; Else throw out of bounds exception
oob_err_22:
call void @throw_oob()
br label %oob_ok_22

; All ok, we can safely index the array now
oob_ok_22:

; Add one to the index since the first element holds the size.
%_49 = add i32 1,5

; Get pointer to the i+1 element of the array.
%_50 = getelementptr i32, i32* %_44, i32 %_49

store i32 11, i32* %_50

; The following segment implements the array store

; Load the address of the array
%_51 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_52 = load i32, i32* %_51

; Check that the index is greater than zero
%_53 = icmp sge i32 6, 0

; Check that the index is less than the size of the array
%_54 = icmp slt i32 0, %_52

; Both of these conditions must hold
%_55 = and i1 %_53, %_54
br i1 %_55, label %oob_ok_23, label %oob_err_23

; Else throw out of bounds exception
oob_err_23:
call void @throw_oob()
br label %oob_ok_23

; All ok, we can safely index the array now
oob_ok_23:

; Add one to the index since the first element holds the size.
%_56 = add i32 1,6

; Get pointer to the i+1 element of the array.
%_57 = getelementptr i32, i32* %_51, i32 %_56

store i32 6, i32* %_57

; The following segment implements the array store

; Load the address of the array
%_58 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_59 = load i32, i32* %_58

; Check that the index is greater than zero
%_60 = icmp sge i32 7, 0

; Check that the index is less than the size of the array
%_61 = icmp slt i32 0, %_59

; Both of these conditions must hold
%_62 = and i1 %_60, %_61
br i1 %_62, label %oob_ok_24, label %oob_err_24

; Else throw out of bounds exception
oob_err_24:
call void @throw_oob()
br label %oob_ok_24

; All ok, we can safely index the array now
oob_ok_24:

; Add one to the index since the first element holds the size.
%_63 = add i32 1,7

; Get pointer to the i+1 element of the array.
%_64 = getelementptr i32, i32* %_58, i32 %_63

store i32 9, i32* %_64

; The following segment implements the array store

; Load the address of the array
%_65 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_66 = load i32, i32* %_65

; Check that the index is greater than zero
%_67 = icmp sge i32 8, 0

; Check that the index is less than the size of the array
%_68 = icmp slt i32 0, %_66

; Both of these conditions must hold
%_69 = and i1 %_67, %_68
br i1 %_69, label %oob_ok_25, label %oob_err_25

; Else throw out of bounds exception
oob_err_25:
call void @throw_oob()
br label %oob_ok_25

; All ok, we can safely index the array now
oob_ok_25:

; Add one to the index since the first element holds the size.
%_70 = add i32 1,8

; Get pointer to the i+1 element of the array.
%_71 = getelementptr i32, i32* %_65, i32 %_70

store i32 19, i32* %_71

; The following segment implements the array store

; Load the address of the array
%_72 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_73 = load i32, i32* %_72

; Check that the index is greater than zero
%_74 = icmp sge i32 9, 0

; Check that the index is less than the size of the array
%_75 = icmp slt i32 0, %_73

; Both of these conditions must hold
%_76 = and i1 %_74, %_75
br i1 %_76, label %oob_ok_26, label %oob_err_26

; Else throw out of bounds exception
oob_err_26:
call void @throw_oob()
br label %oob_ok_26

; All ok, we can safely index the array now
oob_ok_26:

; Add one to the index since the first element holds the size.
%_77 = add i32 1,9

; Get pointer to the i+1 element of the array.
%_78 = getelementptr i32, i32* %_72, i32 %_77

store i32 5, i32* %_78

ret i32 0
}

