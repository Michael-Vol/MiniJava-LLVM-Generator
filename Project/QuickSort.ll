@.QS_vtable = global [4 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @QS.Start to i8*),
	i8* bitcast (i32 (i8*,i32,i32)* @QS.Sort to i8*),
	i8* bitcast (i32 (i8*)* @QS.Print to i8*),
	i8* bitcast (i32 (i8*,i32)* @QS.Init to i8*)
]

@.QuickSort.ll_vtable = global [0 x i8*] []
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
%_2 = getelementptr [4 x i8*], [4 x i8*]* @.QS_vtable, i32 0, i32 0

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
define i32 @QS.Start(i8* %this,i32 %.sz) {
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

call void (i32) @print_int(i32 9999)

%_15 = getelementptr i8, i8* %this, i32 16

%_16 = bitcast i8*%_15 to i32*

%_17 = load i32, i32* %_16

%_18 = sub i32 %_16, 1

store i32 %_18, i32* %aux01

; Do the required bitcasts, so that we can access the vtable pointer
%_19 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_20 = load i8**, i8*** %_19

; Get a pointer to the i-th entry in the vtable. 
%_21 = getelementptr i8*, i8** %_20, i32 1

;Get the actual function pointer 
%_22 = load i8*, i8** %_21

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_23 = bitcast i8* %_22 to i32 (i8*, i32, i32)*

%_25 = load i32, i32* %aux01 

;Perform the call - note the first argument is the receiver object.
%_26 = call i32 %_23(i8* %this,i32 0,i32 %_25)



store i32 %_26, i32* %aux01

; Do the required bitcasts, so that we can access the vtable pointer
%_27 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_28 = load i8**, i8*** %_27

; Get a pointer to the i-th entry in the vtable. 
%_29 = getelementptr i8*, i8** %_28, i32 2

;Get the actual function pointer 
%_30 = load i8*, i8** %_29

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_31 = bitcast i8* %_30 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_33 = call i32 %_31(i8* %this)



store i32 %_33, i32* %aux01

ret i32 0
}

define i32 @QS.Sort(i8* %this,i32 %.left,i32 %.right) {
%left = alloca i32
store i32 %.left, i32* %left

%right = alloca i32
store i32 %.right, i32* %right

%v = alloca i32

%i = alloca i32

%j = alloca i32

%nt = alloca i32

%t = alloca i32

%cont01 = alloca i1

%cont02 = alloca i1

%aux03 = alloca i32

store i32 0, i32* %t

%_0 = load i32, i32* %left

%_1 = load i32, i32* %right

%_2 = icmp slt i32 %_0, %_1

br i1 %_2, label %if_then_0, label %if_else_0

if_else_0:
store i32 0, i32* %nt

br label %if_end_0
if_then_0:
%_8 = getelementptr i8, i8* %this, i32 8

%_10 = bitcast i8* %_8 to i32*

%_11 = load i32, i32* %_10

%_9 = load i32, i32* %right 

; The following segment implements the array lookup

; Load the address of the array
%_3 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_4 = load i32, i32* %_3

; Check that the index is greater than zero
%_5 = icmp sge i32 %_9, 0

; Check that the index is less than the size of the array
%_6 = icmp slt i32 0, %_4

; Both of these conditions must hold
%_7 = and i1 %_5, %_6
br i1 %_7, label %oob_ok_0, label %oob_err_0

; Else throw out of bounds exception
oob_err_0:
call void @throw_oob()
br label %oob_ok_0

; All ok, we can safely index the array now
oob_ok_0:

; Add one to the index since the first element holds the size.
%_12 = add i32 1,%_9

; Get pointer to the i+1 element of the array.
%_13 = getelementptr i32, i32* %_3, i32 %_12

store i32* %_13, i32* %v

%_14 = load i32, i32* %left

%_15 = sub i32 %_14, 1

store i32 %_15, i32* %i

; Load right and store it to j
%_16 = load i32, i32* %right

store i32 %_16, i32* %j

store i1 1, i1* %cont01

br label %loop1_cond

loop1_cond:

br i1 %_16, label %loop1_cond, label %loop3_end

loop2_body:

%_17 = load i1, i1* %cont01 

store i1 1, i1* %cont02

br label %loop4_cond

loop4_cond:

br i1 %_17, label %loop4_cond, label %loop6_end

loop5_body:

%_18 = load i1, i1* %cont02 

%_19 = load i32, i32* %i

%_20 = add i32 %_19, 1

store i32 %_20, i32* %i

%_26 = getelementptr i8, i8* %this, i32 8

%_28 = bitcast i8* %_26 to i32*

%_29 = load i32, i32* %_28

%_27 = load i32, i32* %i 

; The following segment implements the array lookup

; Load the address of the array
%_21 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_22 = load i32, i32* %_21

; Check that the index is greater than zero
%_23 = icmp sge i32 %_27, 0

; Check that the index is less than the size of the array
%_24 = icmp slt i32 0, %_22

; Both of these conditions must hold
%_25 = and i1 %_23, %_24
br i1 %_25, label %oob_ok_7, label %oob_err_7

; Else throw out of bounds exception
oob_err_7:
call void @throw_oob()
br label %oob_ok_7

; All ok, we can safely index the array now
oob_ok_7:

; Add one to the index since the first element holds the size.
%_30 = add i32 1,%_27

; Get pointer to the i+1 element of the array.
%_31 = getelementptr i32, i32* %_21, i32 %_30

store i32* %_31, i32* %aux03

%_32 = load i32, i32* %aux03

%_33 = load i32, i32* %v

%_34 = icmp slt i32 %_32, %_33

%_35 = xor i1 1, %_34

br i1 %_35, label %if_then_0, label %if_else_0

if_else_0:
store i1 1, i1* %cont02

br label %if_end_0
if_then_0:
store i1 0, i1* %cont02

br label %if_end_0
if_end_0:

br label %loop4_cond

loop6_end:

store i1 1, i1* %cont02

br label %loop8_cond

loop8_cond:

br i1 %_35, label %loop8_cond, label %loop10_end

loop9_body:

%_36 = load i1, i1* %cont02 

%_37 = load i32, i32* %j

%_38 = sub i32 %_37, 1

store i32 %_38, i32* %j

%_44 = getelementptr i8, i8* %this, i32 8

%_46 = bitcast i8* %_44 to i32*

%_47 = load i32, i32* %_46

%_45 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_39 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_40 = load i32, i32* %_39

; Check that the index is greater than zero
%_41 = icmp sge i32 %_45, 0

; Check that the index is less than the size of the array
%_42 = icmp slt i32 0, %_40

; Both of these conditions must hold
%_43 = and i1 %_41, %_42
br i1 %_43, label %oob_ok_11, label %oob_err_11

; Else throw out of bounds exception
oob_err_11:
call void @throw_oob()
br label %oob_ok_11

; All ok, we can safely index the array now
oob_ok_11:

; Add one to the index since the first element holds the size.
%_48 = add i32 1,%_45

; Get pointer to the i+1 element of the array.
%_49 = getelementptr i32, i32* %_39, i32 %_48

store i32* %_49, i32* %aux03

%_50 = load i32, i32* %v

%_51 = load i32, i32* %aux03

%_52 = icmp slt i32 %_50, %_51

%_53 = xor i1 1, %_52

br i1 %_53, label %if_then_0, label %if_else_0

if_else_0:
store i1 1, i1* %cont02

br label %if_end_0
if_then_0:
store i1 0, i1* %cont02

br label %if_end_0
if_end_0:

br label %loop8_cond

loop10_end:

%_59 = getelementptr i8, i8* %this, i32 8

%_61 = bitcast i8* %_59 to i32*

%_62 = load i32, i32* %_61

%_60 = load i32, i32* %i 

; The following segment implements the array lookup

; Load the address of the array
%_54 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_55 = load i32, i32* %_54

; Check that the index is greater than zero
%_56 = icmp sge i32 %_60, 0

; Check that the index is less than the size of the array
%_57 = icmp slt i32 0, %_55

; Both of these conditions must hold
%_58 = and i1 %_56, %_57
br i1 %_58, label %oob_ok_12, label %oob_err_12

; Else throw out of bounds exception
oob_err_12:
call void @throw_oob()
br label %oob_ok_12

; All ok, we can safely index the array now
oob_ok_12:

; Add one to the index since the first element holds the size.
%_63 = add i32 1,%_60

; Get pointer to the i+1 element of the array.
%_64 = getelementptr i32, i32* %_54, i32 %_63

store i32* %_64, i32* %t

%_70 = getelementptr i8, i8* %this, i32 8

%_72 = bitcast i8* %_70 to i32*

%_73 = load i32, i32* %_72

%_71 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_65 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_66 = load i32, i32* %_65

; Check that the index is greater than zero
%_67 = icmp sge i32 %_71, 0

; Check that the index is less than the size of the array
%_68 = icmp slt i32 0, %_66

; Both of these conditions must hold
%_69 = and i1 %_67, %_68
br i1 %_69, label %oob_ok_13, label %oob_err_13

; Else throw out of bounds exception
oob_err_13:
call void @throw_oob()
br label %oob_ok_13

; All ok, we can safely index the array now
oob_ok_13:

; Add one to the index since the first element holds the size.
%_74 = add i32 1,%_71

; Get pointer to the i+1 element of the array.
%_75 = getelementptr i32, i32* %_65, i32 %_74

; The following segment implements the array store

; Load the address of the array
%_76 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_77 = load i32, i32* %_76

; Check that the index is greater than zero
%_78 = icmp sge i32 i, 0

; Check that the index is less than the size of the array
%_79 = icmp slt i32 0, %_77

; Both of these conditions must hold
%_80 = and i1 %_78, %_79
br i1 %_80, label %oob_ok_14, label %oob_err_14

; Else throw out of bounds exception
oob_err_14:
call void @throw_oob()
br label %oob_ok_14

; All ok, we can safely index the array now
oob_ok_14:

; Add one to the index since the first element holds the size.
%_81 = add i32 1,i

; Get pointer to the i+1 element of the array.
%_82 = getelementptr i32, i32* %_76, i32 %_81

; The following segment implements the array store

; Load the address of the array
%_83 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_84 = load i32, i32* %_83

; Check that the index is greater than zero
%_85 = icmp sge i32 j, 0

; Check that the index is less than the size of the array
%_86 = icmp slt i32 0, %_84

; Both of these conditions must hold
%_87 = and i1 %_85, %_86
br i1 %_87, label %oob_ok_15, label %oob_err_15

; Else throw out of bounds exception
oob_err_15:
call void @throw_oob()
br label %oob_ok_15

; All ok, we can safely index the array now
oob_ok_15:

; Add one to the index since the first element holds the size.
%_88 = add i32 1,j

; Get pointer to the i+1 element of the array.
%_89 = getelementptr i32, i32* %_83, i32 %_88

%_90 = load i32, i32* %i

%_91 = add i32 %_90, 1

%_92 = load i32, i32* %j

%_93 = icmp slt i32 %_92, PlusExpression

br i1 %_93, label %if_then_0, label %if_else_0

if_else_0:
store i1 1, i1* %cont01

br label %if_end_0
if_then_0:
store i1 0, i1* %cont01

br label %if_end_0
if_end_0:

br label %loop1_cond

loop3_end:

%_99 = getelementptr i8, i8* %this, i32 8

%_101 = bitcast i8* %_99 to i32*

%_102 = load i32, i32* %_101

%_100 = load i32, i32* %i 

; The following segment implements the array lookup

; Load the address of the array
%_94 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_95 = load i32, i32* %_94

; Check that the index is greater than zero
%_96 = icmp sge i32 %_100, 0

; Check that the index is less than the size of the array
%_97 = icmp slt i32 0, %_95

; Both of these conditions must hold
%_98 = and i1 %_96, %_97
br i1 %_98, label %oob_ok_16, label %oob_err_16

; Else throw out of bounds exception
oob_err_16:
call void @throw_oob()
br label %oob_ok_16

; All ok, we can safely index the array now
oob_ok_16:

; Add one to the index since the first element holds the size.
%_103 = add i32 1,%_100

; Get pointer to the i+1 element of the array.
%_104 = getelementptr i32, i32* %_94, i32 %_103

; The following segment implements the array store

; Load the address of the array
%_105 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_106 = load i32, i32* %_105

; Check that the index is greater than zero
%_107 = icmp sge i32 j, 0

; Check that the index is less than the size of the array
%_108 = icmp slt i32 0, %_106

; Both of these conditions must hold
%_109 = and i1 %_107, %_108
br i1 %_109, label %oob_ok_17, label %oob_err_17

; Else throw out of bounds exception
oob_err_17:
call void @throw_oob()
br label %oob_ok_17

; All ok, we can safely index the array now
oob_ok_17:

; Add one to the index since the first element holds the size.
%_110 = add i32 1,j

; Get pointer to the i+1 element of the array.
%_111 = getelementptr i32, i32* %_105, i32 %_110

%_117 = getelementptr i8, i8* %this, i32 8

%_119 = bitcast i8* %_117 to i32*

%_120 = load i32, i32* %_119

%_118 = load i32, i32* %right 

; The following segment implements the array lookup

; Load the address of the array
%_112 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_113 = load i32, i32* %_112

; Check that the index is greater than zero
%_114 = icmp sge i32 %_118, 0

; Check that the index is less than the size of the array
%_115 = icmp slt i32 0, %_113

; Both of these conditions must hold
%_116 = and i1 %_114, %_115
br i1 %_116, label %oob_ok_18, label %oob_err_18

; Else throw out of bounds exception
oob_err_18:
call void @throw_oob()
br label %oob_ok_18

; All ok, we can safely index the array now
oob_ok_18:

; Add one to the index since the first element holds the size.
%_121 = add i32 1,%_118

; Get pointer to the i+1 element of the array.
%_122 = getelementptr i32, i32* %_112, i32 %_121

; The following segment implements the array store

; Load the address of the array
%_123 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_124 = load i32, i32* %_123

; Check that the index is greater than zero
%_125 = icmp sge i32 i, 0

; Check that the index is less than the size of the array
%_126 = icmp slt i32 0, %_124

; Both of these conditions must hold
%_127 = and i1 %_125, %_126
br i1 %_127, label %oob_ok_19, label %oob_err_19

; Else throw out of bounds exception
oob_err_19:
call void @throw_oob()
br label %oob_ok_19

; All ok, we can safely index the array now
oob_ok_19:

; Add one to the index since the first element holds the size.
%_128 = add i32 1,i

; Get pointer to the i+1 element of the array.
%_129 = getelementptr i32, i32* %_123, i32 %_128

; The following segment implements the array store

; Load the address of the array
%_130 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_131 = load i32, i32* %_130

; Check that the index is greater than zero
%_132 = icmp sge i32 right, 0

; Check that the index is less than the size of the array
%_133 = icmp slt i32 0, %_131

; Both of these conditions must hold
%_134 = and i1 %_132, %_133
br i1 %_134, label %oob_ok_20, label %oob_err_20

; Else throw out of bounds exception
oob_err_20:
call void @throw_oob()
br label %oob_ok_20

; All ok, we can safely index the array now
oob_ok_20:

; Add one to the index since the first element holds the size.
%_135 = add i32 1,right

; Get pointer to the i+1 element of the array.
%_136 = getelementptr i32, i32* %_130, i32 %_135

; Do the required bitcasts, so that we can access the vtable pointer
%_137 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_138 = load i8**, i8*** %_137

; Get a pointer to the i-th entry in the vtable. 
%_139 = getelementptr i8*, i8** %_138, i32 1

;Get the actual function pointer 
%_140 = load i8*, i8** %_139

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_141 = bitcast i8* %_140 to i32 (i8*, i32, i32)*

%_142 = load i32, i32* %i

%_143 = sub i32 %_142, 1

%_144 = load i32, i32* %left 

;Perform the call - note the first argument is the receiver object.
%_146 = call i32 %_141(i8* %this,i32 %_144,i32 %_144)



store i32 %_146, i32* %nt

; Do the required bitcasts, so that we can access the vtable pointer
%_147 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_148 = load i8**, i8*** %_147

; Get a pointer to the i-th entry in the vtable. 
%_149 = getelementptr i8*, i8** %_148, i32 1

;Get the actual function pointer 
%_150 = load i8*, i8** %_149

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_151 = bitcast i8* %_150 to i32 (i8*, i32, i32)*

%_152 = load i32, i32* %i

%_153 = add i32 %_152, 1

%_155 = load i32, i32* %right 

;Perform the call - note the first argument is the receiver object.
%_156 = call i32 %_151(i8* %this,i32 %_153,i32 %_155)



store i32 %_156, i32* %nt

br label %if_end_0
if_end_0:

ret i32 0
}

define i32 @QS.Print(i8* %this) {
%j = alloca i32

store i32 0, i32* %j

br label %loop21_cond

loop21_cond:

%_0 = load i32, i32* %j

%_1 = getelementptr i8, i8* %this, i32 16

%_2 = bitcast i8* %_1 to i32*

%_3 = load i32, i32* %_2

%_4 = icmp slt i32 %_0, %_3

br i1 %_4, label %loop21_cond, label %loop23_end

loop22_body:

%_11 = getelementptr i8, i8* %this, i32 8

%_13 = bitcast i8* %_11 to i32*

%_14 = load i32, i32* %_13

%_12 = load i32, i32* %j 

; The following segment implements the array lookup

; Load the address of the array
%_6 = load i32*, i32** %number

; Load the size of the array(first integer of the array)
%_7 = load i32, i32* %_6

; Check that the index is greater than zero
%_8 = icmp sge i32 %_12, 0

; Check that the index is less than the size of the array
%_9 = icmp slt i32 0, %_7

; Both of these conditions must hold
%_10 = and i1 %_8, %_9
br i1 %_10, label %oob_ok_24, label %oob_err_24

; Else throw out of bounds exception
oob_err_24:
call void @throw_oob()
br label %oob_ok_24

; All ok, we can safely index the array now
oob_ok_24:

; Add one to the index since the first element holds the size.
%_15 = add i32 1,%_12

; Get pointer to the i+1 element of the array.
%_16 = getelementptr i32, i32* %_6, i32 %_15

%_18 = load i32, i32* %_16
call void (i32) @print_int(i32 %_18)

%_19 = load i32, i32* %j

%_20 = add i32 %_19, 1

store i32 %_20, i32* %j

br label %loop21_cond

loop23_end:

ret i32 0
}

define i32 @QS.Init(i8* %this,i32 %.sz) {
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
br i1 %_4, label %nsz_ok_25, label %nsz_err_25

; Size was negative, throw negative size exception
nsz_err_25:
call void @throw_nsz()
br label %nsz_ok_25

; All ok, we can proceed with the allocation
nsz_ok_25:

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
br i1 %_13, label %oob_ok_26, label %oob_err_26

; Else throw out of bounds exception
oob_err_26:
call void @throw_oob()
br label %oob_ok_26

; All ok, we can safely index the array now
oob_ok_26:

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
br i1 %_20, label %oob_ok_27, label %oob_err_27

; Else throw out of bounds exception
oob_err_27:
call void @throw_oob()
br label %oob_ok_27

; All ok, we can safely index the array now
oob_ok_27:

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
br i1 %_27, label %oob_ok_28, label %oob_err_28

; Else throw out of bounds exception
oob_err_28:
call void @throw_oob()
br label %oob_ok_28

; All ok, we can safely index the array now
oob_ok_28:

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
br i1 %_34, label %oob_ok_29, label %oob_err_29

; Else throw out of bounds exception
oob_err_29:
call void @throw_oob()
br label %oob_ok_29

; All ok, we can safely index the array now
oob_ok_29:

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
br i1 %_41, label %oob_ok_30, label %oob_err_30

; Else throw out of bounds exception
oob_err_30:
call void @throw_oob()
br label %oob_ok_30

; All ok, we can safely index the array now
oob_ok_30:

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
br i1 %_48, label %oob_ok_31, label %oob_err_31

; Else throw out of bounds exception
oob_err_31:
call void @throw_oob()
br label %oob_ok_31

; All ok, we can safely index the array now
oob_ok_31:

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
br i1 %_55, label %oob_ok_32, label %oob_err_32

; Else throw out of bounds exception
oob_err_32:
call void @throw_oob()
br label %oob_ok_32

; All ok, we can safely index the array now
oob_ok_32:

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
br i1 %_62, label %oob_ok_33, label %oob_err_33

; Else throw out of bounds exception
oob_err_33:
call void @throw_oob()
br label %oob_ok_33

; All ok, we can safely index the array now
oob_ok_33:

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
br i1 %_69, label %oob_ok_34, label %oob_err_34

; Else throw out of bounds exception
oob_err_34:
call void @throw_oob()
br label %oob_ok_34

; All ok, we can safely index the array now
oob_ok_34:

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
br i1 %_76, label %oob_ok_35, label %oob_err_35

; Else throw out of bounds exception
oob_err_35:
call void @throw_oob()
br label %oob_ok_35

; All ok, we can safely index the array now
oob_ok_35:

; Add one to the index since the first element holds the size.
%_77 = add i32 1,9

; Get pointer to the i+1 element of the array.
%_78 = getelementptr i32, i32* %_72, i32 %_77

store i32 5, i32* %_78

ret i32 0
}

