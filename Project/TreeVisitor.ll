@.TV_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*)* @TV.Start to i8*)
]

@.Tree_vtable = global [21 x i8*] [
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
	i8* bitcast (i1 (i8*,i8*)* @Tree.RecPrint to i8*),
	i8* bitcast (i32 (i8*,i8*)* @Tree.accept to i8*)
]

@.Visitor_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*,i8*)* @Visitor.visit to i8*)
]

@.MyVisitor_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*,i8*)* @MyVisitor.visit to i8*)
]

@.TreeVisitor.ll_vtable = global [0 x i8*] []
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
%_2 = getelementptr [1 x i8*], [1 x i8*]* @.TV_vtable, i32 0, i32 0

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
define i32 @TV.Start(i8* %this) {
%root = alloca i8*

%ntb = alloca i1

%nti = alloca i32

%v = alloca i8*

; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_0 = call i8* @calloc(i32 1,i32 38)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [21 x i8*], [21 x i8*]* @.Tree_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_2, i8*** %_1

store i8* %_0, i8** %root

; First load the object pointer
%_3 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_4 = bitcast i8* %_3 to i8***

;  Load vtable_ptr
%_5 = load i8**, i8*** %_4

; Get a pointer to the i-th entry in the vtable. 
%_6 = getelementptr i8*, i8** %_5, i32 0

;Get the actual function pointer 
%_7 = load i8*, i8** %_6

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_8 = bitcast i8* %_7 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_10 = call i1 %_8(i8* %_3,i32 16)



store i1 %_10, i1* %ntb

; First load the object pointer
%_11 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_12 = bitcast i8* %_11 to i8***

;  Load vtable_ptr
%_13 = load i8**, i8*** %_12

; Get a pointer to the i-th entry in the vtable. 
%_14 = getelementptr i8*, i8** %_13, i32 18

;Get the actual function pointer 
%_15 = load i8*, i8** %_14

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_16 = bitcast i8* %_15 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_18 = call i1 %_16(i8* %_11)



store i1 %_18, i1* %ntb

call void (i32) @print_int(i32 100000000)

; First load the object pointer
%_20 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_21 = bitcast i8* %_20 to i8***

;  Load vtable_ptr
%_22 = load i8**, i8*** %_21

; Get a pointer to the i-th entry in the vtable. 
%_23 = getelementptr i8*, i8** %_22, i32 12

;Get the actual function pointer 
%_24 = load i8*, i8** %_23

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_25 = bitcast i8* %_24 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_27 = call i1 %_25(i8* %_20,i32 8)



store i1 %_27, i1* %ntb

; First load the object pointer
%_28 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_29 = bitcast i8* %_28 to i8***

;  Load vtable_ptr
%_30 = load i8**, i8*** %_29

; Get a pointer to the i-th entry in the vtable. 
%_31 = getelementptr i8*, i8** %_30, i32 12

;Get the actual function pointer 
%_32 = load i8*, i8** %_31

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_33 = bitcast i8* %_32 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_35 = call i1 %_33(i8* %_28,i32 24)



store i1 %_35, i1* %ntb

; First load the object pointer
%_36 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_37 = bitcast i8* %_36 to i8***

;  Load vtable_ptr
%_38 = load i8**, i8*** %_37

; Get a pointer to the i-th entry in the vtable. 
%_39 = getelementptr i8*, i8** %_38, i32 12

;Get the actual function pointer 
%_40 = load i8*, i8** %_39

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_41 = bitcast i8* %_40 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_43 = call i1 %_41(i8* %_36,i32 4)



store i1 %_43, i1* %ntb

; First load the object pointer
%_44 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_45 = bitcast i8* %_44 to i8***

;  Load vtable_ptr
%_46 = load i8**, i8*** %_45

; Get a pointer to the i-th entry in the vtable. 
%_47 = getelementptr i8*, i8** %_46, i32 12

;Get the actual function pointer 
%_48 = load i8*, i8** %_47

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_49 = bitcast i8* %_48 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_51 = call i1 %_49(i8* %_44,i32 12)



store i1 %_51, i1* %ntb

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
%_60 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_61 = bitcast i8* %_60 to i8***

;  Load vtable_ptr
%_62 = load i8**, i8*** %_61

; Get a pointer to the i-th entry in the vtable. 
%_63 = getelementptr i8*, i8** %_62, i32 12

;Get the actual function pointer 
%_64 = load i8*, i8** %_63

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_65 = bitcast i8* %_64 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_67 = call i1 %_65(i8* %_60,i32 28)



store i1 %_67, i1* %ntb

; First load the object pointer
%_68 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_69 = bitcast i8* %_68 to i8***

;  Load vtable_ptr
%_70 = load i8**, i8*** %_69

; Get a pointer to the i-th entry in the vtable. 
%_71 = getelementptr i8*, i8** %_70, i32 12

;Get the actual function pointer 
%_72 = load i8*, i8** %_71

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_73 = bitcast i8* %_72 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_75 = call i1 %_73(i8* %_68,i32 14)



store i1 %_75, i1* %ntb

; First load the object pointer
%_76 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_77 = bitcast i8* %_76 to i8***

;  Load vtable_ptr
%_78 = load i8**, i8*** %_77

; Get a pointer to the i-th entry in the vtable. 
%_79 = getelementptr i8*, i8** %_78, i32 18

;Get the actual function pointer 
%_80 = load i8*, i8** %_79

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_81 = bitcast i8* %_80 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_83 = call i1 %_81(i8* %_76)



store i1 %_83, i1* %ntb

call void (i32) @print_int(i32 100000000)

; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_85 = call i8* @calloc(i32 1,i32 24)

; Next we need to set the vtable pointer to point to the correct vtable
%_86 = bitcast i8* %_85 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_87 = getelementptr [1 x i8*], [1 x i8*]* @.MyVisitor_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_87, i8*** %_86

store i8* %_85, i8** %v

call void (i32) @print_int(i32 50000000)

; First load the object pointer
%_89 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_90 = bitcast i8* %_89 to i8***

;  Load vtable_ptr
%_91 = load i8**, i8*** %_90

; Get a pointer to the i-th entry in the vtable. 
%_92 = getelementptr i8*, i8** %_91, i32 20

;Get the actual function pointer 
%_93 = load i8*, i8** %_92

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_94 = bitcast i8* %_93 to i32 (i8*, i8*)*

%_95 = load i8*, i8** %v 

;Perform the call - note the first argument is the receiver object.
%_96 = call i32 %_94(i8* %_89,i8* %_95)



store i32 %_96, i32* %nti

call void (i32) @print_int(i32 100000000)

; First load the object pointer
%_98 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_99 = bitcast i8* %_98 to i8***

;  Load vtable_ptr
%_100 = load i8**, i8*** %_99

; Get a pointer to the i-th entry in the vtable. 
%_101 = getelementptr i8*, i8** %_100, i32 17

;Get the actual function pointer 
%_102 = load i8*, i8** %_101

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_103 = bitcast i8* %_102 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_105 = call i32 %_103(i8* %_98,i32 24)



call void (i32) @print_int(i32 %_105)

; First load the object pointer
%_107 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_108 = bitcast i8* %_107 to i8***

;  Load vtable_ptr
%_109 = load i8**, i8*** %_108

; Get a pointer to the i-th entry in the vtable. 
%_110 = getelementptr i8*, i8** %_109, i32 17

;Get the actual function pointer 
%_111 = load i8*, i8** %_110

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_112 = bitcast i8* %_111 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_114 = call i32 %_112(i8* %_107,i32 12)



call void (i32) @print_int(i32 %_114)

; First load the object pointer
%_116 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_117 = bitcast i8* %_116 to i8***

;  Load vtable_ptr
%_118 = load i8**, i8*** %_117

; Get a pointer to the i-th entry in the vtable. 
%_119 = getelementptr i8*, i8** %_118, i32 17

;Get the actual function pointer 
%_120 = load i8*, i8** %_119

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_121 = bitcast i8* %_120 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_123 = call i32 %_121(i8* %_116,i32 16)



call void (i32) @print_int(i32 %_123)

; First load the object pointer
%_125 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_126 = bitcast i8* %_125 to i8***

;  Load vtable_ptr
%_127 = load i8**, i8*** %_126

; Get a pointer to the i-th entry in the vtable. 
%_128 = getelementptr i8*, i8** %_127, i32 17

;Get the actual function pointer 
%_129 = load i8*, i8** %_128

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_130 = bitcast i8* %_129 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_132 = call i32 %_130(i8* %_125,i32 50)



call void (i32) @print_int(i32 %_132)

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

; First load the object pointer
%_143 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_144 = bitcast i8* %_143 to i8***

;  Load vtable_ptr
%_145 = load i8**, i8*** %_144

; Get a pointer to the i-th entry in the vtable. 
%_146 = getelementptr i8*, i8** %_145, i32 13

;Get the actual function pointer 
%_147 = load i8*, i8** %_146

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_148 = bitcast i8* %_147 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_150 = call i1 %_148(i8* %_143,i32 12)



store i1 %_150, i1* %ntb

; First load the object pointer
%_151 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_152 = bitcast i8* %_151 to i8***

;  Load vtable_ptr
%_153 = load i8**, i8*** %_152

; Get a pointer to the i-th entry in the vtable. 
%_154 = getelementptr i8*, i8** %_153, i32 18

;Get the actual function pointer 
%_155 = load i8*, i8** %_154

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_156 = bitcast i8* %_155 to i32 (i8*)*

;Perform the call - note the first argument is the receiver object.
%_158 = call i1 %_156(i8* %_151)



store i1 %_158, i1* %ntb

; First load the object pointer
%_159 = load i8*, i8** %root 

; Do the required bitcasts, so that we can access the vtable pointer
%_160 = bitcast i8* %_159 to i8***

;  Load vtable_ptr
%_161 = load i8**, i8*** %_160

; Get a pointer to the i-th entry in the vtable. 
%_162 = getelementptr i8*, i8** %_161, i32 17

;Get the actual function pointer 
%_163 = load i8*, i8** %_162

; Cast the function 