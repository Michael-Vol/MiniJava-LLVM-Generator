@.Base_vtable = global [2 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @Base.set to i8*),
	i8* bitcast (i32 (i8*)* @Base.get to i8*)
]

@.Derived_vtable = global [2 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @Derived.set to i8*),
	i8* bitcast (i32 (i8*)* @Base.get to i8*)
]

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
%b = alloca i8*

%d = alloca i8*

; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_0 = call i8* @calloc(i32 1,i32 12)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [2 x i8*], [2 x i8*]* @.Base_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_2, i8*** %_1

store i8* %_0, i8** %b

; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_3 = call i8* @calloc(i32 1,i32 12)

; Next we need to set the vtable pointer to point to the correct vtable
%_4 = bitcast i8* %_3 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_5 = getelementptr [2 x i8*], [2 x i8*]* @.Derived_vtable, i32 0, i32 0

; Set the vtable to the correct address.
store i8** %_5, i8*** %_4

store i8* %_3, i8** %d

; First load the object pointer
%_6 = load i8*, i8** %b 

; Do the required bitcasts, so that we can access the vtable pointer
%_7 = bitcast i8* %_6 to i8***

;  Load vtable_ptr
%_8 = load i8**, i8*** %_7

; Get a pointer to the i-th entry in the vtable. 
%_9 = getelementptr i8*, i8** %_8, i32 0

;Get the actual function pointer 
%_10 = load i8*, i8** %_9

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_11 = bitcast i8* %_10 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_13 = call i32 %_11(i8* %_6,i32 1)



call void (i32) @print_int(i32 %_13)

; Load d and store it to b
%_15 = load i8*, i8** %d

store i8* %_15, i8** %b

; First load the object pointer
%_16 = load i8*, i8** %b 

; Do the required bitcasts, so that we can access the vtable pointer
%_17 = bitcast i8* %_16 to i8***

;  Load vtable_ptr
%_18 = load i8**, i8*** %_17

; Get a pointer to the i-th entry in the vtable. 
%_19 = getelementptr i8*, i8** %_18, i32 0

;Get the actual function pointer 
%_20 = load i8*, i8** %_19

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_21 = bitcast i8* %_20 to i32 (i8*, i32)*

;Perform the call - note the first argument is the receiver object.
%_23 = call i32 %_21(i8* %_16,i32 3)



call void (i32) @print_int(i32 %_23)

ret i32 0
}
define i32 @Base.set(i8* %this,i32 %.x) {
%x = alloca i32
store i32 %.x, i32* %x

; Load x and store it to data
%_0 = load i32, i32* %x

%_1 = getelementptr i8, i8* %this, i32 8

%_2 =  bitcast i8* %_1 to i32*

store i32 %_0, i32* %_2

%_3 = getelementptr i8, i8* %this, i32 8

%_4 = bitcast i8* %_3 to i32*

%_5 = load i32, i32* %_4

ret i32 %_5
}

define i32 @Base.get(i8* %this) {
%_0 = getelementptr i8, i8* %this, i32 8

%_1 = bitcast i8* %_0 to i32*

%_2 = load i32, i32* %_1

ret i32 %_2
}

define i32 @Derived.set(i8* %this,i32 %.x) {
%x = alloca i32
store i32 %.x, i32* %x

%_0 = load i32, i32* %x

%_1 = mul i32 %_0, 2

%_2 = getelementptr i8, i8* %this, i32 8

%_3 =  bitcast i8* %_2 to i32*

store i32 %_1, i32* %_3

%_4 = getelementptr i8, i8* %this, i32 8

%_5 = bitcast i8* %_4 to i32*

%_6 = load i32, i32* %_5

ret i32 %_6
}

