@.BT_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*)* @BT.Start to i8*)
]

@.Tree_vtable = global [20 x i8*] [
	i8* bitcast (i1 (i8*,i32)* @Tree.Init to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.SetRight to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.SetLeft to i8*),
	i8* bitcast (i8* (i8*)* @Tree.GetRight to i8*),
	i8* bitcast (i8* (i8*)* @Tree.GetLeft to i8*),
	i8* bitcast (i32 (i8*)* @Tree.GetKey to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.SetKey to i8*),
	i8* bitcast (i1 (i8*)* @Tree.GetHas_Right to i8*),
	i8* bitcast (i1 (i8*)* @Tree.GetHas_Left to i8*),
	i8* bitcast (i1 (i8*,i1)* @Tree.SetHas_Left to i8*),
	i8* bitcast (i1 (i8*,i1)* @Tree.SetHas_Right to i8*),
	i8* bitcast (i1 (i8*,i32,i32)* @Tree.Compare to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.Insert to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.Delete to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.Remove to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.RemoveRight to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.RemoveLeft to i8*),
	i8* bitcast (i32 (i8*,i32)* @Tree.Search to i8*),
	i8* bitcast (i1 (i8*)* @Tree.Print to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.RecPrint to i8*)
]

@.BinaryTree.ll_vtable = global [0 x i8*] []
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
%_0 = call i8* @calloc(i32 1,i32 8)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [1 x i8*], [1 x i8*]* @.BT_vtable, i32 0, i32 0

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
%_7 = bitcast i8* %_6 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_9 = call i32 %_7(i8* %_0)



call void (i32) @print_int(i32 %_9)

ret i32 0
}
define i32 @BT.Start(i8* %this) {
%root = alloca i8*

%ntb = alloca i1

%nti = alloca i32

; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_0 = call i8* @calloc(i32 1,i32 38)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [20 x i8*], [20 x i8*]* @.Tree_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_2, i8*** %_1

store i8* %_0, i8** %root

; First load the object pointer
%_2 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_3 = bitcast i8* %_2 to i8***

;  Load vtable_ptr
%_4 = load i8**, i8*** %_3

; Get a pointer to the i-th entry in the vtable. 
%_5 = getelementptr i8*, i8** %_4, i32 0

;Get the actual function pointer 
%_6 = load i8*, i8** %_5

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_7 = bitcast i8* %_6 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_9 = call i1 %_7(i8* %_2,i32 16)



store i1 %_9, i1* %ntb

; First load the object pointer
%_9 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_10 = bitcast i8* %_9 to i8***

;  Load vtable_ptr
%_11 = load i8**, i8*** %_10

; Get a pointer to the i-th entry in the vtable. 
%_12 = getelementptr i8*, i8** %_11, i32 18

;Get the actual function pointer 
%_13 = load i8*, i8** %_12

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_14 = bitcast i8* %_13 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_16 = call i1 %_14(i8* %_9)



store i1 %_16, i1* %ntb

call void (i32) @print_int(i32 100000000)

; First load the object pointer
%_17 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_18 = bitcast i8* %_17 to i8***

;  Load vtable_ptr
%_19 = load i8**, i8*** %_18

; Get a pointer to the i-th entry in the vtable. 
%_20 = getelementptr i8*, i8** %_19, i32 12

;Get the actual function pointer 
%_21 = load i8*, i8** %_20

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_22 = bitcast i8* %_21 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_24 = call i1 %_22(i8* %_17,i32 8)



store i1 %_24, i1* %ntb

; First load the object pointer
%_24 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_25 = bitcast i8* %_24 to i8***

;  Load vtable_ptr
%_26 = load i8**, i8*** %_25

; Get a pointer to the i-th entry in the vtable. 
%_27 = getelementptr i8*, i8** %_26, i32 18

;Get the actual function pointer 
%_28 = load i8*, i8** %_27

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_29 = bitcast i8* %_28 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_31 = call i1 %_29(i8* %_24)



store i1 %_31, i1* %ntb

; First load the object pointer
%_31 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_32 = bitcast i8* %_31 to i8***

;  Load vtable_ptr
%_33 = load i8**, i8*** %_32

; Get a pointer to the i-th entry in the vtable. 
%_34 = getelementptr i8*, i8** %_33, i32 12

;Get the actual function pointer 
%_35 = load i8*, i8** %_34

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_36 = bitcast i8* %_35 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_38 = call i1 %_36(i8* %_31,i32 24)



store i1 %_38, i1* %ntb

; First load the object pointer
%_38 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_39 = bitcast i8* %_38 to i8***

;  Load vtable_ptr
%_40 = load i8**, i8*** %_39

; Get a pointer to the i-th entry in the vtable. 
%_41 = getelementptr i8*, i8** %_40, i32 12

;Get the actual function pointer 
%_42 = load i8*, i8** %_41

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_43 = bitcast i8* %_42 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_45 = call i1 %_43(i8* %_38,i32 4)



store i1 %_45, i1* %ntb

; First load the object pointer
%_45 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_46 = bitcast i8* %_45 to i8***

;  Load vtable_ptr
%_47 = load i8**, i8*** %_46

; Get a pointer to the i-th entry in the vtable. 
%_48 = getelementptr i8*, i8** %_47, i32 12

;Get the actual function pointer 
%_49 = load i8*, i8** %_48

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_50 = bitcast i8* %_49 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_52 = call i1 %_50(i8* %_45,i32 12)



store i1 %_52, i1* %ntb

; First load the object pointer
%_52 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_53 = bitcast i8* %_52 to i8***

;  Load vtable_ptr
%_54 = load i8**, i8*** %_53

; Get a pointer to the i-th entry in the vtable. 
%_55 = getelementptr i8*, i8** %_54, i32 12

;Get the actual function pointer 
%_56 = load i8*, i8** %_55

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_57 = bitcast i8* %_56 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_59 = call i1 %_57(i8* %_52,i32 20)



store i1 %_59, i1* %ntb

; First load the object pointer
%_59 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_60 = bitcast i8* %_59 to i8***

;  Load vtable_ptr
%_61 = load i8**, i8*** %_60

; Get a pointer to the i-th entry in the vtable. 
%_62 = getelementptr i8*, i8** %_61, i32 12

;Get the actual function pointer 
%_63 = load i8*, i8** %_62

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_64 = bitcast i8* %_63 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_66 = call i1 %_64(i8* %_59,i32 28)



store i1 %_66, i1* %ntb

; First load the object pointer
%_66 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_67 = bitcast i8* %_66 to i8***

;  Load vtable_ptr
%_68 = load i8**, i8*** %_67

; Get a pointer to the i-th entry in the vtable. 
%_69 = getelementptr i8*, i8** %_68, i32 12

;Get the actual function pointer 
%_70 = load i8*, i8** %_69

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_71 = bitcast i8* %_70 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_73 = call i1 %_71(i8* %_66,i32 14)



store i1 %_73, i1* %ntb

; First load the object pointer
%_73 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_74 = bitcast i8* %_73 to i8***

;  Load vtable_ptr
%_75 = load i8**, i8*** %_74

; Get a pointer to the i-th entry in the vtable. 
%_76 = getelementptr i8*, i8** %_75, i32 18

;Get the actual function pointer 
%_77 = load i8*, i8** %_76

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_78 = bitcast i8* %_77 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_80 = call i1 %_78(i8* %_73)



store i1 %_80, i1* %ntb

; First load the object pointer
%_80 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_81 = bitcast i8* %_80 to i8***

;  Load vtable_ptr
%_82 = load i8**, i8*** %_81

; Get a pointer to the i-th entry in the vtable. 
%_83 = getelementptr i8*, i8** %_82, i32 17

;Get the actual function pointer 
%_84 = load i8*, i8** %_83

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_85 = bitcast i8* %_84 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_87 = call i32 %_85(i8* %_80,i32 24)



call void (i32) @print_int(i32 %_87)

; First load the object pointer
%_88 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_89 = bitcast i8* %_88 to i8***

;  Load vtable_ptr
%_90 = load i8**, i8*** %_89

; Get a pointer to the i-th entry in the vtable. 
%_91 = getelementptr i8*, i8** %_90, i32 17

;Get the actual function pointer 
%_92 = load i8*, i8** %_91

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_93 = bitcast i8* %_92 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_95 = call i32 %_93(i8* %_88,i32 12)



call void (i32) @print_int(i32 %_95)

; First load the object pointer
%_96 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_97 = bitcast i8* %_96 to i8***

;  Load vtable_ptr
%_98 = load i8**, i8*** %_97

; Get a pointer to the i-th entry in the vtable. 
%_99 = getelementptr i8*, i8** %_98, i32 17

;Get the actual function pointer 
%_100 = load i8*, i8** %_99

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_101 = bitcast i8* %_100 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_103 = call i32 %_101(i8* %_96,i32 16)



call void (i32) @print_int(i32 %_103)

; First load the object pointer
%_104 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_105 = bitcast i8* %_104 to i8***

;  Load vtable_ptr
%_106 = load i8**, i8*** %_105

; Get a pointer to the i-th entry in the vtable. 
%_107 = getelementptr i8*, i8** %_106, i32 17

;Get the actual function pointer 
%_108 = load i8*, i8** %_107

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_109 = bitcast i8* %_108 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_111 = call i32 %_109(i8* %_104,i32 50)



call void (i32) @print_int(i32 %_111)

; First load the object pointer
%_112 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_113 = bitcast i8* %_112 to i8***

;  Load vtable_ptr
%_114 = load i8**, i8*** %_113

; Get a pointer to the i-th entry in the vtable. 
%_115 = getelementptr i8*, i8** %_114, i32 17

;Get the actual function pointer 
%_116 = load i8*, i8** %_115

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_117 = bitcast i8* %_116 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_119 = call i32 %_117(i8* %_112,i32 12)



call void (i32) @print_int(i32 %_119)

; First load the object pointer
%_120 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_121 = bitcast i8* %_120 to i8***

;  Load vtable_ptr
%_122 = load i8**, i8*** %_121

; Get a pointer to the i-th entry in the vtable. 
%_123 = getelementptr i8*, i8** %_122, i32 13

;Get the actual function pointer 
%_124 = load i8*, i8** %_123

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_125 = bitcast i8* %_124 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_127 = call i1 %_125(i8* %_120,i32 12)



store i1 %_127, i1* %ntb

; First load the object pointer
%_127 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_128 = bitcast i8* %_127 to i8***

;  Load vtable_ptr
%_129 = load i8**, i8*** %_128

; Get a pointer to the i-th entry in the vtable. 
%_130 = getelementptr i8*, i8** %_129, i32 18

;Get the actual function pointer 
%_131 = load i8*, i8** %_130

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_132 = bitcast i8* %_131 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_134 = call i1 %_132(i8* %_127)



store i1 %_134, i1* %ntb

; First load the object pointer
%_134 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_135 = bitcast i8* %_134 to i8***

;  Load vtable_ptr
%_136 = load i8**, i8*** %_135

; Get a pointer to the i-th entry in the vtable. 
%_137 = getelementptr i8*, i8** %_136, i32 17

;Get the actual function pointer 
%_138 = load i8*, i8** %_137

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_139 = bitcast i8* %_138 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_141 = call i32 %_139(i8* %_134,i32 12)



call void (i32) @print_int(i32 %_141)

ret i32 0
}

define i1 @Tree.Init(i8* %this,i32 %.v_key) {
%v_key = alloca i32
store i32 %.v_key, i32* %v_key

; Load v_key and store it to key
%_0 = load i32, i32* %v_key

%_1 = getelementptr i8, i8* %this, i32 24

%_2 =  bitcast i8* %_1 to i32*

store i32 %_0, i32* %_2

%_3 = getelementptr i8, i8* %this, i1 28

%_4 =  bitcast i8* %_3 to i1*

store i1 0, i1* %_4

%_5 = getelementptr i8, i8* %this, i1 29

%_6 =  bitcast i8* %_5 to i1*

store i1 0, i1* %_6

ret i1 1
}

define i1 @Tree.SetRight(i8* %this,i8* %.rn) {
%rn = alloca i8*
store i8* %.rn, i8** %rn

; Load rn and store it to right
%_0 = load i8*, i8** %rn

%_1 = getelementptr i8, i8* %this, i8* 16

%_2 =  bitcast i8* %_1 to i8**

sto