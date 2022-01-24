@.Fac_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @Fac.ComputeFac to i8*)
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
; First, we allocate the required memory on heap for our object.
; We call calloc to achieve this:
%_0 = call i8* @calloc(i32 1,i32 8)

; Next we need to set the vtable pointer to point to the correct vtable
%_1 = bitcast i8* %_0 to i8***

; Get the address of the first element of the Base_vtable with getelementptr 
%_2 = getelementptr [1 x i8*], [1 x i8*]* @.Fac_vtable, i32 0, i32 0

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
define i32 @Fac.ComputeFac(i8* %this,i32 %.num) {
%num = alloca i32
store i32 %.num, i32* %num

%num_aux = alloca i32

%_0 = load i32, i32* %num

%_1 = icmp slt i32 %_0, 1

br i1 %_1, label %if_then_0, label %if_else_0

if_else_0:
; Do the required bitcasts, so that we can access the vtable pointer
%_2 = bitcast i8* %this to i8***

;  Load vtable_ptr
%_3 = load i8**, i8*** %_2

; Get a pointer to the i-th entry in the vtable. 
%_4 = getelementptr i8*, i8** %_3, i32 0

;Get the actual function pointer 
%_5 = load i8*, i8** %_4

; Cast the function pointer from i8* to a function ptr type that matches its signature.
%_6 = bitcast i8* %_5 to i32 (i8*, i32)*

%_7 = load i32, i32* %num

%_8 = sub i32 %_7, 1

;Perform the call - note the first argument is the receiver object.
%_10 = call i32 %_6(i8* %this,i32 %_8)



%_11 = load i32, i32* %num

%_12 = mul i32 %_11, %_10

store i32 %_12, i32* %num_aux

br label %if_end_0
if_then_0:
store i32 1, i32* %num_aux

br label %if_end_0
if_end_0:

%_13 = load i32, i32* %num_aux 

ret i32 %_13
}

