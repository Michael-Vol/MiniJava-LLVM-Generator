@.And_test.ll_vtable = global [0 x i8*] []
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

%_0 = call i8*  @calloc(i32 1,i32 16)

%_1 = bitcast i8* %_0 to i8***

%_2 = getelementptr [1 x i8*], [1 x i8*]* @.test_vtable, i32 0, i32 0

store i8** %_2, i8*** %_1
store i8* %_2, i8*** %b

ret i32 0
}
define i32 @foo(i8* %this) {
%x = alloca i32

%a = alloca i1

%b = alloca i1

store i1 1, i1* %b

store i1 0, i1* %a

%_3 = load i1, i1* %a 

br i1 %_3, label %expr_res_1, label %expr_res_0

expr_res_0:
br label %expr_res_3

expr_res_1:
%_4 = load i1, i1* %b
br label %expr_res_2

expr_res_2:
br label %expr_res_3

expr_res_3:
%_5 = phi i1 [ 0, %expr_res_0 ], [ %_4, %expr_res_2 ]
br i1 %_5, label %if_then_0, label %if_else_0
if_else_0:
store i32 1, i32* %x

br label %if_end_0
if_then_0:
store i32 0, i32* %x

br label %if_end_0
if_end_0:

%_6 = getelementptr i8, i8* %this, i32 8

%_7 = bitcast i8* %_6 to i32*

%_8 = load i32, i32* %_7

%_9 = mul i32 %_8, 3

call void (i32) @print_int(i32 %_9)

ret i32 0
}
