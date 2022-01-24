@.LS_vtable = global [4 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @LS.Start to i8*),
	i8* bitcast (i32 (i8*)* @LS.Print to i8*),
	i8* bitcast (i32 (i8*,i32)* @LS.Search to i8*),
	i8* bitcast (i32 (i8*,i32)* @LS.Init to i8*)
]

@.LinearSearch.ll_vtable = global [0 x i8*] []
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
%_2 = getelementptr [4 x i8*], [4 x i8*]* @.LS_vtable, i32 0, i32 0

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
define i32 @LS.Start(i8* %this,i32 %.sz) {
%sz = alloca i32
store i32 %.sz, i32* %sz

%aux01 = alloca i32

%aux02 = alloca i32

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
%_9 = getelementptr i8*, i8** %_8, i32 1

;Get the actual function pointer 
%_10 = load i8*, i8** %_9

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_11 = bitcast i8* %_10 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_13 = call i32 %_11(i8* %this)



store i32 %_13, i32* %aux02

call void (i32) @print_int(i32 9999)

; Do the required bitcasts, so that we can access the vtable pointer
%_15 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_16 = load i8**, i8*** %_15

; Get a pointer to the i-th entry in the vtable. 
%_17 = getelementptr i8*, i8** %_16, i32 2

;Get the actual function pointer 
%_18 = load i8*, i8** %_17

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_19 = bitcast i8* %_18 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_21 = call i32 %_19(i8* %this,i32 8)



call void (i32) @print_int(i32 %_21)

; Do the required bitcasts, so that we can access the vtable pointer
%_23 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_24 = load i8**, i8*** %_23

; Get a pointer to the i-th entry in the vtable. 
%_25 = getelementptr i8*, i8** %_24, i32 2

;Get the actual function pointer 
%_26 = load i8*, i8** %_25

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_27 = bitcast i8* %_26 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_29 = call i32 %_27(i8* %this,i32 12)



call void (i32) @print_int(i32 %_29)

; Do the required bitcasts, so that we can access the vtable pointer
%_31 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_32 = load i8**, i8*** %_31

; Get a pointer to the i-th entry in the vtable. 
%_33 = getelementptr i8*, i8** %_32, i32 2

;Get the actual function pointer 
%_34 = load i8*, i8** %_33

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_35 = bitcast i8* %_34 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_37 = call i32 %_35(i8* %this,i32 17)



call void (i32) @print_int(i32 %_37)

; Do the required bitcasts, so that we can access the vtable pointer
%_39 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_40 = load i8**, i8*** %_39

; Get a pointer to the i-th entry in the vtable. 
%_41 = getelementptr i8*, i8** %_40, i32 2

;Get the actual function pointer 
%_42 = load i8*, i8** %_41

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_43 = bitcast i8* %_42 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_45 = call i32 %_43(i8* %this,i32 50)



call void (i32) @print_int(i32 %_45)

ret i32 55
}

define i32 @LS.Print(i8* %this) {
%j = alloca i32

store i32 1, i32* %j

br label %loop0_cond

loop0_cond:

%_0 = load i32, i32* %j

%_1 = getelementptr i8, i8* %this, i32 16

%_2 = bitcast i8* %_1 to i32*

%_3 = load i32, i32* %_2

%_4 = icmp slt i32 %_0, %_3

br i1 %_4, label %loop0_cond, label %loop2_end

loop1_body:

%_11 = getelementptr i8, i8* %this, i32 8

%_13 = bitcast i8* %_11 to i32*

%_14 = load i32, i32* %_13

%_12 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_6 = load i32*, i32* %_14

; Load the size of the array(first integer of the array)
%_7 = load i32, i32* %_6

; Check that the index is greater than zero
%_8 = icmp sge i32 %_12, 0

; Check that the index is less than the size of the array
%_9 = icmp slt i32 0, %_7

; Both of these conditions must hold
%_10 = and i1 %_8, %_9
br i1 %_10, label %oob_ok_3, label %oob_err_3

; Else throw out of bounds exception
oob_err_3:
call void @throw_oob()
br label %oob_ok_3

; All ok, we can safely index the array now
oob_ok_3:

; Add one to the index since the first element holds the size.
%_15 = add i32 1,%_12

; Get pointer to the i+1 element of the array.
%_16 = getelementptr i32, i32* %_6, i32 %_15

%_18 = load i32, i32* %_16
call void (i32) @print_int(i32 %_18)

%_19 = load i32, i32* %j

%_20 = add i32 %_19, 1

store i32 %_20, i32* %j

br label %loop0_cond

loop2_end:

ret i32 0
}

define i32 @LS.Search(i8* %this,i32 %.num) {
%num = alloca i32
store i32 %.num, i32* %num

%j = alloca i32

%ls01 = alloca i1

%ifound = alloca i32

%aux01 = alloca i32

%aux02 = alloca i32

%nt = alloca i32

store i32 1, i32* %j

store i1 0, i1* %ls01

store i32 0, i32* %ifound

br label %loop4_cond

loop4_cond:

%_0 = load i32, i32* %j

%_1 = getelementptr i8, i8* %this, i32 16

%_2 = bitcast i8* %_1 to i32*

%_3 = load i32, i32* %_2

%_4 = icmp slt i32 %_0, %_3

br i1 %_4, label %loop4_cond, label %loop6_end

loop5_body:

%_11 = getelementptr i8, i8* %this, i32 8

%_13 = bitcast i8* %_11 to i32*

%_14 = load i32, i32* %_13

%_12 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_6 = load i32*, i32* %_14

; Load the size of the array(first integer of the array)
%_7 = load i32, i32* %_6

; Check that the index is greater than zero
%_8 = icmp sge i32 %_12, 0

; Check that the index is less than the size of the array
%_9 = icmp slt i32 0, %_7

; Both of these conditions must hold
%_10 = and i1 %_8, %_9
br i1 %_10, label %oob_ok_7, label %oob_err_7

; Else throw out of bounds exception
oob_err_7:
call void @throw_oob()
br label %oob_ok_7

; All ok, we can safely index the array now
oob_ok_7:

; Add one to the index since the first element holds the size.
%_15 = add i32 1,%_12

; Get pointer to the i+1 element of the array.
%_16 = getelementptr i32, i32* %_6, i32 %_15

store i32* %_16, i32* %aux01

%_17 = load i32, i32* %num

%_18 = add i32 %_17, 1

store i32 %_18, i32* %aux02

%_19 = load i32, i32* %aux01

%_20 = load i32, i32* %num

%_21 = icmp slt i32 %_19, %_20

br i1 %_21, label %if_then_0, label %if_else_0

if_else_0:
%_22 = load i32, i32* %aux01

%_23 = load i32, i32* %aux02

%_24 = icmp slt i32 %_22, %_23

%_25 = xor i1 1, %_24

br i1 %_25, label %if_then_0, label %if_else_0

if_else_0:
store i1 1, i1* %ls01

store i32 1, i32* %ifound

%_25 = getelementptr i8, i8* %this, i32 16

%_26 =  bitcast i8* %_25 to i32*

store i32 %_26, i32* %j

store i32 1, i32* %j

br label %if_end_0
if_then_0:
store i32 0, i32* %nt

br label %if_end_0
if_end_0:

br label %if_end_0
if_then_0:
store i32 0, i32* %nt

br label %if_end_0
if_end_0:

%_27 = load i32, i32* %j

%_28 = add i32 %_27, 1

store i32 %_28, i32* %j

br label %loop4_cond

loop6_end:

%_29 = load i32, i32* %ifound 

ret i32 %_29
}

define i32 @LS.Init(i8* %this,i32 %.sz) {
%sz = alloca i32
store i32 %.sz, i32* %sz

%j = alloca i32

%k = alloca i32

%aux01 = alloca i32

%aux02 = alloca i32

; Load sz and store it to size
%_0 = load i32, i32* %sz

%_1 = getelementptr i8, i8* %this, i32 16

%_2 =  bitcast i8* %_1 to i32*

store i32 %_0, i32* %_2

; Calculate size bytes to be allocated for the array (new arr[sz] -> add i32 1, sz)
%_3 = add i32 1, sz
; Check that the size of the array is not negative
%_4 = icmp sge i32 %_3, 1
br i1 %_4, label %nsz_ok_8, label %nsz_err_8

; Size was negative, throw negative size exception
nsz_err_8:
call void @throw_nsz()
br label %nsz_ok_8

; All ok, we can proceed with the allocation
nsz_ok_8:

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

store i32 1, i32* %j

%_9 = getelementptr i8, i8* %this, i32 16

%_10 = bitcast i8*%_9 to i32*

%_11 = load i32, i32* %_10

%_12 = add i32 %_10, 1

store i32 %_12, i32* %k

br label %loop9_cond

loop9_cond:

%_13 = load i32, i32* %j

%_14 = getelementptr i8, i8* %this, i32 16

%_15 = bitcast i8* %_14 to i32*

%_16 = load i32, i32* %_15

%_17 = icmp slt i32 %_13, %_16

br i1 %_17, label %loop9_cond, label %loop11_end

loop10_body:

%_19 = load i32, i32* %j

%_20 = mul 2, i32 %_19

store i32 %_20, i32* %aux01

%_21 = load i32, i32* %k

%_22 = sub i32 %_21, 3

store i32 %_22, i32* %aux02

%_23 = load i32, i32* %aux01

%_24 = load i32, i32* %aux02

%_25 = add i32 %_23, i32 %_24

; The following segment implements the array store

; Load the address of the array
%_26 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_27 = load i32, i32* %_26

; Check that the index is greater than zero
%_28 = icmp sge i32 j, 0

; Check that the index is less than the size of the array
%_29 = icmp slt i32 0, %_27

; Both of these conditions must hold
%_30 = and i1 %_28, %_29
br i1 %_30, label %oob_ok_12, label %oob_err_12

; Else throw out of bounds exception
oob_err_12:
call void @throw_oob()
br label %oob_ok_12

; All ok, we can safely index the array now
oob_ok_12:

; Add one to the index since the first element holds the size.
%_31 = add i32 1,j

; Get pointer to the i+1 element of the array.
%_32 = getelementptr i32, i32* %_26, i32 %_31

%_33 = load i32, i32* %j

%_34 = add i32 %_33, 1

store i32 %_34, i32* %j

%_35 = load i32, i32* %k

%_36 = sub i32 %_35, 1

store i32 %_36, i32* %k

br label %loop9_cond

loop11_end:

ret i32 0
}

