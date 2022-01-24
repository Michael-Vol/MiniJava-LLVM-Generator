import syntaxtree.*;
import visitor.*;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.FileWriter;
import java.util.*;
import java.util.jar.Attributes.Name;

import javax.lang.model.element.VariableElement;

public class Main {
    public static void main(String[] args) throws Exception {

        FileInputStream fis = null;

        for (String file : args) {
            try {
                System.out.println("\n\n\n --> " + " Currently running: " + file + "\n\n\n");
                if (fis != null) {
                    fis.close();
                }
                fis = new FileInputStream(file);
                String[] filename_tokens = file.split("\\.");
                String llFilename = filename_tokens[0] + ".ll";
                MiniJavaParser parser = new MiniJavaParser(fis);

                Goal root = parser.Goal();

                MyVisitor fillTable = new MyVisitor(false, null, null);
                root.accept(fillTable, null);
                MyVisitor generateIR = new MyVisitor(true, fillTable.getSymbolTables(), llFilename);
                generateIR.createAndPrintOffsets();

                generateIR.printVTables();
                System.out.println("-->Generating IR");
                generateIR.initIRFile();
                root.accept(generateIR, null);
                System.out.println("-->Generated IR");
                generateIR.closeWriter();
            } catch (ParseException ex) {
                System.out.println(ex.getMessage());
            } catch (FileNotFoundException ex) {
                System.err.println(ex.getMessage());
            } catch (Exception e) {
                if (!(args[args.length - 1].equals(file))) {
                    System.out.println("\n----  Running next file due to exception ----");
                } else {
                    System.out.println(e);
                }
                continue;
            }
        }
    }
}

class MyVisitor extends GJDepthFirst<String, String> {
    boolean generateIR;
    SymbolTables symbolTables;
    VTables vTables;
    FileWriter writer;
    Integer variableRegisterCounter;
    Integer methodRegisterLabel;
    Integer labelCounter;
    Integer ifCounter;
    String filename;
    String msgSendLastReturnType;
    String allocLastReturnType;

    public MyVisitor(boolean generateIR, SymbolTables symbolTables, String filename) {
        this.generateIR = generateIR;
        if (!generateIR) {
            this.symbolTables = new SymbolTables();
        } else {
            this.vTables = new VTables();
            this.symbolTables = symbolTables;
            this.variableRegisterCounter = this.methodRegisterLabel = 0;
            this.ifCounter = this.labelCounter = 0;
            msgSendLastReturnType = allocLastReturnType = "";
            try {
                this.filename = filename;
                this.writer = new FileWriter(filename);
            } catch (IOException exception) {
                System.out.println(exception);
                System.exit(1);
            }
        }

    }

    void initIRFile() {
        try {
            String[] tokens = filename.split("\\.");
            String mainClassName = tokens[0];
            int classIterator = 0;
            for (SymbolTable table : this.symbolTables.getTables()) {
                for (Class currentClass : table.getClasses()) {
                    if (classIterator == 0 || currentClass.getName().equals(mainClassName)) { //skip main class
                        classIterator++;
                        continue;
                    }
                    writer.write("@." + currentClass.getName() + "_vtable = global [" + currentClass.getNumOfAllMethods(vTables) + " x i8*] [\n");
                    int funcIterator = 0;
                    for (Function method : currentClass.getAllMethods()) {
                        String returnBitType = convertBitType(calculateBitType(method.getReturnType()));

                        writer.write("\ti8* bitcast (" + returnBitType + " (i8*");
                        int iterator = 0;
                        for (String methodReturnType : method.getArguments().values()) {
                            if (iterator == method.getArguments().size()) {
                                writer.write(convertBitType(calculateBitType(methodReturnType)));
                            } else {
                                writer.write("," + convertBitType(calculateBitType(methodReturnType)));
                            }
                            iterator++;
                        }
                        writer.write(")* @" + method.getParentName() + "." + method.getName() + " to i8*)");
                        if ((funcIterator + 1) == currentClass.getAllMethods().size()) {
                            writer.write("\n");
                        } else {
                            writer.write(",\n");
                        }
                        funcIterator++;
                    }
                    writer.write("]\n\n");
                    classIterator++;
                }
            }

            this.writer.write("declare i8* @calloc(i32, i32)\n");
            this.writer.write("declare i32 @printf(i8*, ...)\n");
            this.writer.write("declare void @exit(i32)\n");
            this.writer.write("\n");
            this.writer.write("@_cint = constant [4 x i8] c\"%d\\0a\\00\"\n");
            this.writer.write("@_cOOB = constant [15 x i8] c\"Out of bounds\\0a\\00\"\n");
            this.writer.write("@_cNSZ = constant [15 x i8] c\"Negative size\\0a\\00\"\n");
            this.writer.write("define void @print_int(i32 %i) {\n");
            this.writer.write("%_str = bitcast [4 x i8]* @_cint to i8*\n");
            this.writer.write("call i32 (i8*, ...) @printf(i8* %_str, i32 %i)\n");
            this.writer.write("ret void\n");
            this.writer.write("}\n");
            this.writer.write("\n");
            this.writer.write("define void @throw_oob() {\n");
            this.writer.write("%_str = bitcast [15 x i8]* @_cOOB to i8*\n");
            this.writer.write("call i32 (i8*, ...) @printf(i8* %_str)\n");
            this.writer.write("call void @exit(i32 1)\n");
            this.writer.write("ret void\n");
            this.writer.write("}\n");
            this.writer.write("\n");
            this.writer.write("define void @throw_nsz() {\n");
            this.writer.write("%_str = bitcast [15 x i8]* @_cNSZ to i8*\n");
            this.writer.write("call i32 (i8*, ...) @printf(i8* %_str)\n");
            this.writer.write("call void @exit(i32 1)\n");
            this.writer.write("ret void\n");
            this.writer.write("}\n");
            this.writer.write("\n");
        } catch (IOException exception) {
            System.out.println(exception);
            System.exit(1);
        }
    }

    String createLabel(Integer labelCounter) {
        return "expr_res_" + labelCounter;
    }

    String createIfLabel(Integer labelCounter, String type) {
        if (type.equals("then")) {
            return "if_then_" + labelCounter;
        } else if (type.equals("else")) {
            return "if_else_" + labelCounter;
        } else {
            return "if_end_" + labelCounter;
        }
    }

    String createLoopLabel(Integer labelCounter, String type) {
        if (type.equals("condition")) {
            return "loop" + labelCounter + "_cond";
        } else if (type.equals("body")) {
            return "loop" + labelCounter + "_body";
        } else {
            return "loop" + labelCounter + "_end";
        }
    }

    String createArrayAllocationLabel(Integer labelCounter, String type) {
        if (type.equals("size_ok")) {
            return "nsz_ok_" + labelCounter;
        } else if (type.equals("size_err")) {
            return "nsz_err_" + labelCounter;
        } else if (type.equals("bounds_ok")) {
            return "oob_ok_" + labelCounter;
        } else {
            return "oob_err_" + labelCounter;
        }
    }

    String convertBitType(String bitType) {
        if (bitType.equals("i8")) {
            return "i8*";
        }
        return bitType;
    }

    boolean isInteger(String number) {
        try {
            Integer.parseInt(number);
            return true;
        } catch (NumberFormatException excpetion) {
            return false;
        }
    }

    String calculateBitType(String type) {
        if (type.equals("boolean") || type.equals("true") || type.equals("false")) {
            return "i1";
        } else if (type.equals("int") || isInteger(type) || type.equals("plus") || type.equals("minus") || type.equals("times")) {
            return "i32";
        } else if (type.equals("int[]")) {
            return "i32*";
        } else {
            return "i8";
        }

    }

    void closeWriter() {
        try {
            this.writer.close();
        } catch (IOException exception) {
            System.out.println(exception);
            System.exit(1);
        }
    }

    SymbolTables getSymbolTables() {
        return this.symbolTables;
    }

    VTables getvTables() {
        return this.vTables;
    }

    Void createAndPrintOffsets() {
        this.symbolTables.createAndPrintOffsets(this.vTables);
        return null;
    }

    void printVTables() {
        this.vTables.print();
    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "{" f3 -> "public" f4 -> "static" f5
     * -> "void" f6 -> "main" f7 -> "(" f8 -> "String" f9 -> "[" f10 -> "]" f11 ->
     * Identifier() f12 -> ")" f13 -> "{" f14 -> ( VarDeclaration() )* f15 -> (
     * Statement() )* f16 -> "}" f17 -> "}"
     */
    @Override
    public String visit(MainClass n, String argu) throws Exception {
        String className = n.f1.accept(this, null);
        if (generateIR == false) {
            SymbolTable table = this.symbolTables.enter(); // create new symbol table
            table.enter(null); // create new empty scope
            table.insert(className, this.symbolTables); // create new class
            // Main method

            Class mainClass = table.getCurrentClass();
            String argName = n.f11.accept(this, null);
            Function mainMethod = mainClass.insertMethod("main", "void");
            mainMethod.insertArgument(argName, "String[]");
            super.visit(n, className);

            mainClass.exitFunction();

        } else {
            SymbolTable table = this.symbolTables.setCurrentTable(className);
            Class mainClass = table.setCurrentClass(className);
            mainClass.setCurrentMethod("main");
            writer.write("define i32 @main() {\n");
            super.visit(n, className);
            writer.write("ret i32 0\n");
            writer.write("}\n");
            mainClass.exitFunction();
        }

        return null;
    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "{" f3 -> ( VarDeclaration() )* f4 ->
     * ( MethodDeclaration() )* f5 -> "}"
     */
    @Override
    public String visit(ClassDeclaration n, String argu) throws Exception {
        if (generateIR == false) {
            String className = n.f1.accept(this, null);
            SymbolTable table = this.symbolTables.enter(); // create new symbol table
            table.enter(null); // create new empty scope
            table.insert(className, this.symbolTables); // create new class

            super.visit(n, className);

        } else {
            String className = n.f1.accept(this, null);
            this.symbolTables.setCurrentTable(className);

            n.f2.accept(this, argu);
            n.f4.accept(this, argu);
            n.f5.accept(this, argu);
        }

        return null;
    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "extends" f3 -> Identifier() f4 -> "{"
     * f5 -> ( VarDeclaration() )* f6 -> ( MethodDeclaration() )* f7 -> "}"
     */
    @Override
    public String visit(ClassExtendsDeclaration n, String argu) throws Exception {
        if (generateIR == false) {
            String className = n.f1.accept(this, null);
            String extendsName = n.f3.accept(this, null);

            SymbolTable table = this.symbolTables.lookupTable(extendsName); // get current table based by parent class
                                                                            // name
            if (table == null || table.lookup(extendsName) == null) {
                System.out.println("Parent Class " + extendsName + " doesn't exist.");
                throw new Exception();
            }
            table.enter(extendsName);
            table.insert(className, this.symbolTables);

            super.visit(n, className);

        } else {
            String className = n.f1.accept(this, null);
            this.symbolTables.setCurrentTable(className);

            super.visit(n, className);
        }

        return null;
    }

    /**
     * f0 -> "public" 
     * f1 -> Type()
     *  f2 -> Identifier() 
     * f3 -> "(" 
     * f4 -> (
     * FormalParameterList() )?
     *  f5 -> ")" 
     * f6 -> "{"
     *  f7 -> ( VarDeclaration() )* 
     * f8 -> ( Statement() )*
     *  f9 -> "return"
     *  f10 -> Expression()
     *  f11 -> ";" 
     * f12 -> "}"
     */
    @Override
    public String visit(MethodDeclaration n, String argu) throws Exception {

        String argumentList = n.f4.present() ? n.f4.accept(this, null) : "";

        String returnType = n.f1.accept(this, null);
        String methodName = n.f2.accept(this, null);
        if (this.generateIR == false) {
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function method = currentClass.insertMethod(methodName, returnType);

            String[] arguments = argumentList.split(", ");
            for (String argument : arguments) {
                if (!argument.replaceAll("\\s+", "").isEmpty()) { // remove whitespaces to determine if no arguments are
                                                                  // given
                    String[] argTokens = argument.split(" ");
                    method.insertArgument(argTokens[1], argTokens[0]);
                }
            }

            NodeListOptional variableDecls = n.f7; // get Variable Declarations
            for (int i = 0; i < variableDecls.size(); i++) {
                VarDeclaration variableDecl = (VarDeclaration) variableDecls.elementAt(i);
                String type = variableDecl.f0.accept(this, argu);
                String id = variableDecl.f1.accept(this, argu);
                method.insertVariable(id, type);
            }
            System.out.println("curr " + currentClass.getName());
        } else {
            //Reset Variable Registers
            variableRegisterCounter = 0;
            // Set scope to current method
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            currentClass.setCurrentMethod(methodName);
            Function currentMethod = currentClass.getCurrentMethod();

            String methodReturnID = n.f10.accept(this, null);
            String methodReturnBitType = calculateBitType(returnType);
            String returnIDType = currentMethod.getVariableType(methodReturnID);

            writer.write("define " + methodReturnBitType + " @" + currentClass.getName() + "." + methodName + "(i8* %this");
            n.f4.accept(this, null);

            String expressionList = n.f4.accept(this, argu);
            if (expressionList == null) {
                expressionList = "";
            }
            String args = "";
            Map<String, String> methodArgs = currentMethod.getArguments();
            for (Map.Entry<String, String> argument : methodArgs.entrySet()) {
                args += "," + convertBitType(calculateBitType(argument.getValue()));
                args += " %." + argument.getKey();
            }

            writer.write(args);
            writer.write(") {\n");

            //Allocate space for arguments
            for (Map.Entry<String, String> argument : methodArgs.entrySet()) {
                String bitType = convertBitType(calculateBitType(argument.getValue()));
                writer.write("%" + argument.getKey() + " = alloca " + bitType + "\n");
                writer.write("store " + bitType + " %." + argument.getKey() + ", " + bitType + "* %" + argument.getKey() + "\n\n");
            }

            n.f7.accept(this, null);
            n.f8.accept(this, null);

            String returnRegister = "%_" + variableRegisterCounter++;
            if (returnIDType == null) {
                returnIDType = currentClass.getVariableTypeAllScopes(methodReturnID);
                if (returnIDType != null) {
                    Integer returnOffset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(methodReturnID);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(returnRegister + " = getelementptr i8, i8* %this, " + methodReturnBitType + " " + (returnOffset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + returnRegister + " to " + methodReturnBitType + "*\n\n");
                    returnRegister = "%_" + variableRegisterCounter++;
                    writer.write(returnRegister + " = load " + methodReturnBitType + ", " + methodReturnBitType + "* " + bitcastRegister + "\n\n");
                } else if (methodReturnID.equals("TimesExpression") || methodReturnID.equals("PlusExpression") || methodReturnID.equals("MinusExpression") || methodReturnID.equals("NotExpression") || methodReturnID.equals("MessageSend")) {
                    //Get previous register
                    returnRegister = "%_" + (variableRegisterCounter - 2);
                } else if (isInteger(methodReturnID)) {
                    returnRegister = methodReturnID; //register is expression itself
                } else if (methodReturnID.equals("true")) {
                    returnRegister = "1";
                } else if (methodReturnID.equals("false")) {

                    returnRegister = "0";
                }

            } else { //expression  is declared in method
                writer.write(returnRegister + " = load " + methodReturnBitType + ", " + methodReturnBitType + "* %" + methodReturnID + " \n\n");
            }

            writer.write("ret " + methodReturnBitType + " " + returnRegister + "\n");
            writer.write("}\n\n");

            this.symbolTables.getCurrentTable().getCurrentClass().exitFunction();
        }
        return null;
    }

    /**
     * f0 -> Type() f1 -> Identifier() f2 -> ";"
     */

    public String visit(VarDeclaration n, String argu) throws Exception {
        SymbolTable table = this.symbolTables.getCurrentTable();
        String type = n.f0.accept(this, argu);
        String id = n.f1.accept(this, argu);
        n.f2.accept(this, argu);
        Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
        Function currentMethod = currentClass.getCurrentMethod();
        if (this.generateIR == false) {
            if (table != null) {
                currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
                Function method = currentClass.getCurrentMethod();

                if (method != null) {
                    method.insertVariable(id, type);
                } else {
                    currentClass.insert(id, type);
                }
            }
        } else {
            if (currentMethod != null) {

                String idBitType = calculateBitType(type);
                if (idBitType.equals("i8")) {
                    idBitType = "i8*";
                }
                writer.write("%" + id + " = alloca " + idBitType + "\n\n");
            }
        }

        return null;
    }

    /**
     * f0 -> FormalParameter() f1 -> FormalParameterTail()
     */
    @Override
    public String visit(FormalParameterList n, String argu) throws Exception {
        String ret = n.f0.accept(this, null);

        if (n.f1 != null) {
            ret += n.f1.accept(this, null);
        }

        return ret;
    }

    /**
     * f0 -> FormalParameter() f1 -> FormalParameterTail()
     */
    public String visit(FormalParameterTerm n, String argu) throws Exception {
        return n.f1.accept(this, argu);
    }

    /**
     * f0 -> "," f1 -> FormalParameter()
     */
    @Override
    public String visit(FormalParameterTail n, String argu) throws Exception {
        String ret = "";
        for (Node node : n.f0.nodes) {
            ret += ", " + node.accept(this, null);
        }

        return ret;
    }

    /**
     * f0 -> Type() f1 -> Identifier()
     */
    @Override
    public String visit(FormalParameter n, String argu) throws Exception {
        String type = n.f0.accept(this, null);
        String name = n.f1.accept(this, null);
        return type + " " + name;
    }

    /**
     * f0 -> Block() | AssignmentStatement() | ArrayAssignmentStatement() |
     * IfStatement() | WhileStatement() | PrintStatement()
     */
    public String visit(Statement n, String argu) throws Exception {
        return n.f0.accept(this, argu);
    }

    /**
     * f0 -> "{" f1 -> ( Statement() )* f2 -> "}"
     */
    public String visit(Block n, String argu) throws Exception {
        String _ret = null;
        n.f0.accept(this, argu);
        n.f1.accept(this, argu);
        n.f2.accept(this, argu);
        return _ret;
    }

    /**
     * f0 -> Identifier() f1 -> "=" f2 -> Expression() f3 -> ";"
     */
    public String visit(AssignmentStatement n, String argu) throws Exception {
        if (this.generateIR == false) {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            return null;
        } else {
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();
            String identifier = n.f0.accept(this, argu);
            String expression = n.f2.accept(this, argu);
            String exprBitType = "";
            String idBitType = "";
            String exprRegister = "%_" + (variableRegisterCounter - 1);
            String idRegister = "%_" + (variableRegisterCounter - 1);
            String idType = currentMethod.getVariableType(identifier);
            String exprType = currentMethod.getVariableType(expression);
            if (exprType != null) { //expression is variable defined inside of function
                exprBitType = convertBitType(calculateBitType(exprType));
                exprRegister = "%_" + variableRegisterCounter++;
                writer.write("; Load " + expression + " and store it to " + identifier + "\n");
                writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* %" + expression + "\n\n");

            } else if (expression.equals("true")) {
                exprBitType = "i1";
                exprRegister = "1";
            } else if (expression.equals("false")) {
                exprBitType = "i1";
                exprRegister = "0";
            } else if (expression.equals("AllocationExpression")) {
                exprBitType = "i8*";
                exprRegister = "%_" + (variableRegisterCounter - 3);
                idBitType = "i8*";
            } else if (expression.equals("ArrayAllocationExpression")) {
                exprRegister = "%_" + (variableRegisterCounter - 1);
                exprBitType = "i32*";
                idBitType = "i32";
            } else if (expression.equals("TimesExpression") || expression.equals("AndExpression") || expression.equals("PlusExpression") || expression.equals("MinusExpression")) {
                exprBitType = "i32";
                exprRegister = "%_" + (variableRegisterCounter - 1);
                idBitType = "i8*";
            } else if (expression.equals("NotExpression")) {
                exprBitType = "i8*";
                exprRegister = "%_" + (variableRegisterCounter - 1);
                System.out.println("alloc register " + exprRegister);
                idBitType = "i8*";
            } else if (expression.equals("ArrayLookup")) {
                exprBitType = "i32*";
            } else if (expression.equals("MessageSend")) {
                exprBitType = convertBitType(calculateBitType(msgSendLastReturnType));
                exprRegister = "%_" + (variableRegisterCounter - 1);

            } else if (currentClass.getVariableTypeAllScopes(expression) != null) { //expression is an attribute
                System.out.println("ok " + exprType);
                exprType = currentClass.getVariableTypeAllScopes(expression);
                exprBitType = convertBitType(calculateBitType(exprType));
                Integer exprOffset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression);
                String bitcastRegister = "%_" + variableRegisterCounter++;
                writer.write(exprRegister + " = getelementptr i8, i8* %this, " + exprBitType + " " + (exprOffset + 8) + "\n\n");
                writer.write(bitcastRegister + " =  bitcast i8* " + exprRegister + " to " + exprBitType + "*\n\n");
                exprRegister = bitcastRegister;
            } else if (isInteger(expression)) {
                exprBitType = "i32";
                exprRegister = expression;
            }

            if (idType != null) { //identifier is variable defined inside of function
                idBitType = convertBitType(calculateBitType(idType));
                idRegister = "%" + identifier;
                // idRegister = "%_" + variableRegisterCounter++;
                // writer.write(idRegister + " = load " + idBitType + ", " + idBitType + "* %" + identifier + "\n\n");
            } else if (currentClass.getVariableTypeAllScopes(identifier) != null) { //identifier is an attribute
                idRegister = "%_" + variableRegisterCounter++;
                idType = currentClass.getVariableTypeAllScopes(identifier);
                idBitType = convertBitType(calculateBitType(idType));
                Integer idOffset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(identifier);
                String bitcastRegister = "%_" + variableRegisterCounter++;
                writer.write(idRegister + " = getelementptr i8, i8* %this, " + idBitType + " " + (idOffset + 8) + "\n\n");
                writer.write(bitcastRegister + " =  bitcast i8* " + idRegister + " to " + idBitType + "*\n\n");
                idRegister = bitcastRegister;
            }
            if (expression.equals("ArrayAllocationExpression")) {
                idBitType = "i32*"; //reset id bit type
            }

            writer.write("store " + exprBitType + " " + exprRegister + ", " + idBitType + "* " + idRegister + "\n\n");

            return "AssignmentStatement";

        }

    }

    /**
     * f0 -> Identifier() f1 -> "[" f2 -> Expression() f3 -> "]" f4 -> "=" f5 ->
     * Expression() f6 -> ";"
     */
    public String visit(ArrayAssignmentStatement n, String argu) throws Exception {

        if (generateIR) {
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            String expr1 = n.f0.accept(this, argu);
            String expr2 = n.f2.accept(this, argu);
            String expression = n.f5.accept(this, argu);
            String arrayAddressRegister = "%_" + variableRegisterCounter++;
            String sizeLoadRegister = "%_" + variableRegisterCounter++;
            String zeroIndexCheckRegister = "%_" + variableRegisterCounter++;
            String maxIndexCheckRegister = "%_" + variableRegisterCounter++;
            String indexCondRegister = "%_" + variableRegisterCounter++;
            writer.write("; The following segment implements the array store\n\n");
            writer.write("; Load the address of the array\n");
            writer.write(arrayAddressRegister + " = load i32*, i32** %" + expr1 + "\n\n");

            writer.write("; Load the size of the array(first integer of the array)\n");
            writer.write(sizeLoadRegister + " = load i32, i32* " + arrayAddressRegister + "\n\n");

            writer.write("; Check that the index is greater than zero\n");
            writer.write(zeroIndexCheckRegister + " = icmp sge i32 " + expr2 + ", 0\n\n");

            writer.write("; Check that the index is less than the size of the array\n");
            writer.write(maxIndexCheckRegister + " = icmp slt i32 0, " + sizeLoadRegister + "\n\n");

            writer.write("; Both of these conditions must hold\n");
            writer.write(indexCondRegister + " = and i1 " + zeroIndexCheckRegister + ", " + maxIndexCheckRegister + "\n");

            String boundOkLabel = createArrayAllocationLabel(labelCounter, "bounds_ok");
            String boundErrLabel = createArrayAllocationLabel(labelCounter++, "bounds_err");
            writer.write("br i1 " + indexCondRegister + ", label %" + boundOkLabel + ", label %" + boundErrLabel + "\n\n");

            writer.write("; Else throw out of bounds exception\n");
            writer.write(boundErrLabel + ":\n");
            writer.write("call void @throw_oob()\n");
            writer.write("br label %" + boundOkLabel + "\n\n");

            writer.write("; All ok, we can safely index the array now\n");
            writer.write(boundOkLabel + ":\n\n");
            String getIndexRegister = "%_" + variableRegisterCounter++;
            writer.write("; Add one to the index since the first element holds the size.\n");
            writer.write(getIndexRegister + " = add i32 1," + expr2 + "\n\n");
            String getElementRegister = "%_" + variableRegisterCounter++;
            writer.write("; Get pointer to the i+1 element of the array.\n");
            writer.write(getElementRegister + " = getelementptr i32, i32* " + arrayAddressRegister + ", i32 " + getIndexRegister + "\n\n");

            if (isInteger(expression)) {
                writer.write("store i32 " + expression + ", i32* " + getElementRegister + "\n\n");
            }
        }
        return "ArrayAssignmentStatement";
    }

    /**
     * f0 -> "if" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> Statement() f5 ->
     * "else" f6 -> Statement()
     */
    public String visit(IfStatement n, String argu) throws Exception {
        if (generateIR) {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            String expression = n.f2.accept(this, argu);
            String phiRegister = "";
            if (expression.equals("AndExpression") || expression.equals("TimesExpression") || expression.equals("PlusExpression") || expression.equals("MinusExpression") || expression.equals("NotExpression") || expression.equals("CompareExpression")) {
                phiRegister = "%_" + (variableRegisterCounter - 1);
            }
            n.f3.accept(this, argu);

            String ifThenLabel = createIfLabel(ifCounter, "then");
            String ifElseLabel = createIfLabel(ifCounter, "else");
            String ifEndLabel = createIfLabel(ifCounter, "end");

            writer.write("br i1 " + phiRegister + ", label %" + ifThenLabel + ", label %" + ifElseLabel + "\n\n");
            writer.write(ifElseLabel + ":\n");
            n.f5.accept(this, argu);
            String elseExpression = n.f6.accept(this, argu);
            writer.write("br label %" + ifEndLabel + "\n");
            writer.write(ifThenLabel + ":\n");
            String thenExpression = n.f4.accept(this, argu);
            writer.write("br label %" + ifEndLabel + "\n");
            writer.write(ifEndLabel + ":\n\n");
        }
        return "IfStatement";
    }

    /**
     * f0 -> "while" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> Statement()
     */
    public String visit(WhileStatement n, String argu) throws Exception {
        if (generateIR) {
            String condLabel = createLoopLabel(labelCounter++, "condition");
            String bodyLabel = createLoopLabel(labelCounter++, "body");
            String endLabel = createLoopLabel(labelCounter++, "end");

            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();
            writer.write("br label %" + condLabel + "\n\n");
            writer.write(condLabel + ":\n\n");
            String expression = n.f2.accept(this, argu);
            String exprType = currentMethod.getVariableType(expression);
            String exprRegister = "%_" + variableRegisterCounter++;
            String condInitRegister = "%_" + (variableRegisterCounter - 2);
            String exprBitType;
            writer.write("br i1 " + condInitRegister + ", label %" + condLabel + ", label %" + endLabel + "\n\n");
            writer.write(bodyLabel + ":\n\n");
            if (exprType == null) {
                exprType = currentClass.getVariableTypeAllScopes(expression);
                if (exprType != null) {
                    exprBitType = calculateBitType(exprType);
                    Integer exprOffset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = getelementptr i8, i8* %this, " + exprBitType + " " + (exprOffset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + exprRegister + " to " + exprBitType + "*\n\n");
                    exprRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* " + bitcastRegister + "\n\n");
                } else if (expression.equals("TimesExpression") || expression.equals("PlusExpression") || expression.equals("MinusExpression") || expression.equals("NotExpression") || expression.equals("MessageSend")) {
                    //Get previous register
                    exprRegister = "%_" + (variableRegisterCounter - 2);
                } else if (isInteger(expression)) {
                    exprRegister = expression; //register is expression itself
                }
            } else { //expression  is declared in method
                exprBitType = calculateBitType(exprType);
                //load first expression 
                writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* %" + expression + " \n\n");
            }

            n.f4.accept(this, argu);

            writer.write("br label %" + condLabel + "\n\n");
            writer.write(endLabel + ":\n\n");
        }

        return "WhileStatement";
    }

    /**
     * f0 -> "System.out.println" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> ";"
     */
    public String visit(PrintStatement n, String argu) throws Exception {

        if (generateIR) {
            String exprBitType;
            String expression = n.f2.accept(this, argu);
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();
            String exprType = currentMethod.getVariableType(expression);
            String exprRegister = "%_" + variableRegisterCounter++;
            if (exprType == null) {
                exprType = currentClass.getVariableTypeAllScopes(expression);
                if (exprType != null) { //expression is attribute
                    exprBitType = calculateBitType(exprType);
                    Integer exprOffset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = getelementptr i8, i8* %this, " + exprBitType + " " + (exprOffset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + exprRegister + " to " + exprBitType + "*\n\n");
                    exprRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* " + bitcastRegister + "\n\n");
                    exprRegister = bitcastRegister;
                } else if (expression.equals("TimesExpression") || expression.equals("PlusExpression") || expression.equals("MinusExpression") || expression.equals("NotExpression") || expression.equals("MessageSend")) {
                    //Get previous register
                    exprRegister = "%_" + (variableRegisterCounter - 2);
                } else if (isInteger(expression)) {
                    exprRegister = expression; //register is expression itself
                } else if (expression.equals("ArrayLookup")) {
                    exprRegister = "%_" + (variableRegisterCounter - 2);
                    String loadRegister = "%_" + variableRegisterCounter++;
                    writer.write(loadRegister + " = load i32, i32* " + exprRegister + "\n");
                    exprRegister = loadRegister;
                }
            } else { //expression  is declared in method
                exprBitType = calculateBitType(exprType);
                //load first expression 
                writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* %" + expression + " \n\n");
            }

            writer.write("call void (i32) @print_int(i32 " + exprRegister + ")\n\n");
            return expression;
        }
        return "";
    }

    /**
     * f0 -> AndExpression() | CompareExpression() | PlusExpression() |
     * MinusExpression() | TimesExpression() | ArrayLookup() | ArrayLength() |
     * MessageSend() | PrimaryExpression()
     */
    public String visit(Expression n, String argu) throws Exception {
        return n.f0.accept(this, argu);
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "&&" f2 -> PrimaryExpression()
     */
    public String visit(AndExpression n, String argu) throws Exception {
        if (generateIR) {
            String expression1 = n.f0.accept(this, argu);
            String expression2 = n.f2.accept(this, argu);
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();
            String expr1BitType;
            String expr2BitType;
            String expr1Register = "%_" + variableRegisterCounter++;
            String expr2Register = "";
            String brRegister = "";

            String expr1Type = currentMethod.getVariableType(expression1);
            String expr2Type = currentMethod.getVariableType(expression2);

            if (expr1Type == null) { //expression 1 is attribute (not declared in method)
                expr1Type = currentClass.getVariableTypeAllScopes(expression1);
                expr1BitType = calculateBitType(expr1Type);
                Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression1);
                String bitcastRegister = "%_" + variableRegisterCounter++;
                writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                writer.write(bitcastRegister + " =  bitcast i8* " + expr1Register + " to " + expr1BitType + "*\n\n");
                expr1Register = "%_" + variableRegisterCounter++;
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                brRegister = bitcastRegister;
            } else { //expression 1 is declared in method
                expr1BitType = calculateBitType(expr1Type);
                //load first expression 
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expression1 + " \n\n");
                brRegister = expr1Register;
            }

            expr2Register = "%_" + variableRegisterCounter++;

            String label0 = createLabel(labelCounter++);
            String label1 = createLabel(labelCounter++);
            String label2 = createLabel(labelCounter++);
            String label3 = createLabel(labelCounter++);

            //Check result short circuit if false
            writer.write("br i1" + " " + brRegister + ", label %" + label1 + ", label %" + label0 + "\n\n");

            writer.write(label0 + ":\n");//LABEL 0

            writer.write("br label %" + label3 + "\n\n");

            writer.write(label1 + ":\n"); //LABEL 1
            if (expr2Type == null) { //expression 2 is attribute (not declared in method)
                expr2Type = currentClass.getVariableTypeAllScopes(expression1);
                expr2BitType = calculateBitType(expr1Type);
                Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression2);
                String bitcastRegister = "%_" + variableRegisterCounter++;
                writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                writer.write(bitcastRegister + " =  bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                expr1Register = "%_" + variableRegisterCounter++;
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* " + bitcastRegister + "\n\n");
                brRegister = bitcastRegister;
            } else {//expression 2 is declared in method
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expression2 + "\n");
                brRegister = expr2Register;
            }
            writer.write("br label %" + label2 + "\n\n");

            writer.write(label2 + ":\n"); //LABEL 2

            writer.write("br label %" + label3 + "\n\n");
            writer.write(label3 + ":\n");

            //Get appropriate value, depending on the predecessor block
            String phiRegister = "%_" + variableRegisterCounter++;

            //ifCounter++;
            writer.write(phiRegister + " = phi i1" + " [ 0, %" + label0 + " ], [ " + brRegister + ", %" + label2 + " ]\n");

        }
        return "AndExpression";

    }

    /**
     * f0 -> PrimaryExpression() f1 -> "<" f2 -> PrimaryExpression()
     */
    public String visit(CompareExpression n, String argu) throws Exception {
        String expression1 = n.f0.accept(this, argu);
        String expression2 = n.f2.accept(this, argu);
        Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
        Function currentMethod = currentClass.getCurrentMethod();
        if (generateIR) {

            String expr1Type = currentMethod.getVariableType(expression1);
            String expr2Type = currentMethod.getVariableType(expression2);

            String expr1BitType = "";
            String expr2BitType = "";

            String compRegisterExpr1 = "";
            String compRegisterExpr2 = "";

            if (expr1Type == null) { //expression 1 is attribute or number
                expr1Type = currentClass.getVariableTypeAllScopes(expression1);
                if (expr1Type != null) { //not a number
                    String expr1Register = "%_" + variableRegisterCounter++;
                    expr1BitType = calculateBitType(expr1Type);
                    Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression1);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8*" + expr1Register + " to " + expr1BitType + "*\n\n");
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    compRegisterExpr1 = bitcastRegister;
                }
            } else { //expression 1 is declared in method
                String expr1Register = "%_" + variableRegisterCounter++;
                expr1BitType = calculateBitType(expr1Type);
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expression1 + "\n\n");
                compRegisterExpr1 = expr1Register;
            }
            if (expr2Type == null) { //expression 2 is attribute or number
                expr2Type = currentClass.getVariableTypeAllScopes(expression2);
                if (expr2Type != null) { // not a number
                    String expr2Register = "%_" + variableRegisterCounter++;
                    expr2BitType = calculateBitType(expr2Type);
                    Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression2);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    compRegisterExpr2 = expr2Register;
                }
            } else { //expression 2 is declared in method
                String expr2Register = "%_" + variableRegisterCounter++;
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expression2 + "\n\n");
                compRegisterExpr2 = expr2Register;
            }

            String compareRegister = "%_" + variableRegisterCounter++;
            if (expr1Type != null && expr2Type != null) { //both expressions are variables
                writer.write(compareRegister + " = icmp slt i32 " + compRegisterExpr1 + ", " + compRegisterExpr2 + "\n\n");
            } else if (expr1Type != null && expr2Type == null) { //expression 1 is variable, expression 2 is numer
                writer.write(compareRegister + " = icmp slt i32 " + compRegisterExpr1 + ", " + expression2 + "\n\n");
            } else if (expr1Type == null && expr2Type != null) { //expression 1 is number, expression 2 is variable
                writer.write(compareRegister + " = icmp slt i32 " + expression1 + ", " + compRegisterExpr2 + "\n\n");
            } else { //both expressions are numbers
                writer.write(compareRegister + " = icmp slt i32 " + expression1 + ", " + expression2 + "\n\n");
            }
        }
        return "CompareExpression";

    }

    /**
     * f0 -> PrimaryExpression() f1 -> "+" f2 -> PrimaryExpression()
     */
    public String visit(PlusExpression n, String argu) throws Exception {
        if (generateIR) {
            String expression1 = n.f0.accept(this, argu);
            String expr1Register = "%_" + (variableRegisterCounter - 1);
            String expression2 = n.f2.accept(this, argu);
            String expr2Register = "%_" + (variableRegisterCounter - 1);
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();

            String expr1Type = currentMethod.getVariableType(expression1);
            String expr2Type = currentMethod.getVariableType(expression2);

            String expr1BitType = "";
            String expr2BitType = "";

            String plusRegisterExpr1 = "";
            String plusRegisterExpr2 = "";
            System.out.println(expression1);
            System.out.println(expression2);
            if (expr1Type == null) { //expression 1 is attribute or number
                expr1Type = currentClass.getVariableTypeAllScopes(expression1);
                if (expr1Type != null) { //not a number
                    expr1Register = "%_" + variableRegisterCounter++;
                    expr1BitType = calculateBitType(expr1Type);
                    Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression1);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8*" + expr1Register + " to " + expr1BitType + "*\n\n");
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    plusRegisterExpr1 = bitcastRegister;
                } else if (expression1.equals("ArrayLookup")) {
                    expr1Type = "int";
                    expr1BitType = "i32";
                    plusRegisterExpr1 = expr1Register;
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + plusRegisterExpr1 + "\n\n");
                    plusRegisterExpr1 = expr1Register;
                }
            } else { //expression 1 is declared in method
                expr1Register = "%_" + variableRegisterCounter++;
                expr1BitType = calculateBitType(expr1Type);
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expression1 + "\n\n");
                plusRegisterExpr1 = expr1Register;
            }

            if (expr2Type == null) { //expression 2 is attribute or number
                expr2Type = currentClass.getVariableTypeAllScopes(expression2);
                if (expr2Type != null) { // not a number
                    expr2Register = "%_" + variableRegisterCounter++;
                    expr2BitType = calculateBitType(expr2Type);
                    Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression2);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    plusRegisterExpr2 = bitcastRegister;
                } else if (expression2.equals("ArrayLookup")) {
                    expr2Type = "int";
                    expr2BitType = "i32";
                    plusRegisterExpr2 = expr2Register;
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* " + plusRegisterExpr2 + "\n\n");
                    plusRegisterExpr2 = expr2Register;
                    String plusRegister = "%_" + variableRegisterCounter++;
                    writer.write(plusRegister + " = add " + expr1BitType + " " + plusRegisterExpr1 + ", " + plusRegisterExpr2 + "\n\n");
                    return "PlusExpression";
                }
            } else { //expression 2 is declared in method
                expr2Register = "%_" + variableRegisterCounter++;
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expression2 + "\n\n");
                plusRegisterExpr2 = expr2Register;
            }

            String plusRegister = "%_" + variableRegisterCounter++;
            if (expr1Type != null && expr2Type != null) { //both expressions are variables
                writer.write(plusRegister + " = add " + expr1BitType + " " + plusRegisterExpr1 + ", " + expr2BitType + " " + plusRegisterExpr2 + "\n\n");
            } else if (expr1Type != null && expr2Type == null) { //expression 1 is variable, expression 2 is numer
                writer.write(plusRegister + " = add " + expr1BitType + " " + plusRegisterExpr1 + ", " + expression2 + "\n\n");
            } else if (expr1Type == null && expr2Type != null) { //expression 1 is number, expression 2 is variable
                writer.write(plusRegister + " = add " + expression1 + ", " + expr2BitType + " " + plusRegisterExpr2 + "\n\n");
            } else { //both expressions are numbers
                writer.write(plusRegister + " = add " + expression1 + ", " + expression2 + "\n\n");
            }
        }
        return "PlusExpression";
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "-" f2 -> PrimaryExpression()
     */
    public String visit(MinusExpression n, String argu) throws Exception {
        if (generateIR) {
            String expression1 = n.f0.accept(this, argu);
            String expression2 = n.f2.accept(this, argu);
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();

            String expr1Type = currentMethod.getVariableType(expression1);
            String expr2Type = currentMethod.getVariableType(expression2);

            String expr1BitType = "";
            String expr2BitType = "";

            String minusRegisterExpr1 = "";
            String minusRegisterExpr2 = "";

            if (expr1Type == null) { //expression 1 is attribute or number
                expr1Type = currentClass.getVariableTypeAllScopes(expression1);
                if (expr1Type != null) { //not a number
                    String expr1Register = "%_" + variableRegisterCounter++;
                    expr1BitType = calculateBitType(expr1Type);
                    Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression1);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8*" + expr1Register + " to " + expr1BitType + "*\n\n");
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    minusRegisterExpr1 = bitcastRegister;
                }
            } else { //expression 1 is declared in method
                String expr1Register = "%_" + variableRegisterCounter++;
                expr1BitType = calculateBitType(expr1Type);
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expression1 + "\n\n");
                minusRegisterExpr1 = expr1Register;
            }
            if (expr2Type == null) { //expression 2 is attribute or number
                expr2Type = currentClass.getVariableTypeAllScopes(expression2);
                if (expr2Type != null) { // not a number
                    String expr2Register = "%_" + variableRegisterCounter++;
                    expr2BitType = calculateBitType(expr2Type);
                    Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression2);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    minusRegisterExpr2 = bitcastRegister;
                }
            } else { //expression 2 is declared in method
                String expr2Register = "%_" + variableRegisterCounter++;
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expression2 + "\n\n");
                minusRegisterExpr2 = expr2Register;
            }

            String subRegister = "%_" + variableRegisterCounter++;
            if (expr1Type != null && expr2Type != null) { //both expressions are variables
                writer.write(subRegister + " = sub " + expr1BitType + " " + minusRegisterExpr1 + ", " + expr2BitType + " " + minusRegisterExpr2 + "\n\n");
            } else if (expr1Type != null && expr2Type == null) { //expression 1 is variable, expression 2 is numer
                writer.write(subRegister + " = sub " + expr1BitType + " " + minusRegisterExpr1 + ", " + expression2 + "\n\n");
            } else if (expr1Type == null && expr2Type != null) { //expression 1 is number, expression 2 is variable
                writer.write(subRegister + " = sub " + expression1 + ", " + expr2BitType + " " + minusRegisterExpr2 + "\n\n");
            } else { //both expressions are numbers
                writer.write(subRegister + " = sub " + expression1 + ", " + expression2 + "\n\n");
            }
        }
        return "MinusExpression";
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "*" f2 -> PrimaryExpression()
     */
    public String visit(TimesExpression n, String argu) throws Exception {
        if (generateIR) {
            String expression1 = n.f0.accept(this, argu);
            String expression2 = n.f2.accept(this, argu);
            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();

            String expr1Type = currentMethod.getVariableType(expression1);
            String expr2Type = currentMethod.getVariableType(expression2);

            String expr1BitType = "";
            String expr2BitType = "";

            String mulRegisterExpr1 = "";
            String mulRegisterExpr2 = "";
            if (expr1Type == null) { //expression 1 is attribute or number
                expr1Type = currentClass.getVariableTypeAllScopes(expression1);
                if (expr1Type != null) { //not a number
                    String expr1Register = "%_" + variableRegisterCounter++;
                    expr1BitType = calculateBitType(expr1Type);
                    System.out.println(expr1BitType + "  " + expr1Type);
                    Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression1);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr1Register + " to " + expr1BitType + "*\n\n");
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    mulRegisterExpr1 = expr1Register;
                }
            } else { //expression 1 is declared in method
                String expr1Register = "%_" + variableRegisterCounter++;
                expr1BitType = calculateBitType(expr1Type);
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expression1 + "\n\n");
                mulRegisterExpr1 = expr1Register;
            }
            if (expr2Type == null) { //expression 2 is attribute or number
                expr2Type = currentClass.getVariableTypeAllScopes(expression2);
                if (expr2Type != null) { // not a number
                    String expr2Register = "%_" + variableRegisterCounter++;
                    expr2BitType = calculateBitType(expr2Type);
                    Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expression2);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                    mulRegisterExpr2 = bitcastRegister;
                } else if (expression2.equals("MessageSend")) {
                    expr2Type = convertBitType(calculateBitType(msgSendLastReturnType));
                    String expr2Register = "%_" + (variableRegisterCounter - 2);
                    mulRegisterExpr2 = msgSendLastReturnType;
                    String timesRegister = "%_" + variableRegisterCounter++;
                    writer.write(timesRegister + " = mul " + expr1BitType + " " + mulRegisterExpr1 + ", " + expr2Register + "\n\n");
                    return "TimesExpression";

                }
            } else { //expression 2 is declared in method
                String expr2Register = "%_" + variableRegisterCounter++;
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expression2 + "\n\n");
                mulRegisterExpr2 = expr2Register;
            }

            String timesRegister = "%_" + variableRegisterCounter++;
            if (expr1Type != null && expr2Type != null) { //both expressions are variables
                writer.write(timesRegister + " = mul " + expr1BitType + " " + mulRegisterExpr1 + ", " + expr2BitType + " " + mulRegisterExpr2 + "\n\n");
            } else if (expr1Type != null && expr2Type == null) { //expression 1 is variable, expression 2 is numer
                writer.write(timesRegister + " = mul " + expr1BitType + " " + mulRegisterExpr1 + ", " + expression2 + "\n\n");
            } else if (expr1Type == null && expr2Type != null) { //expression 1 is number, expression 2 is variable
                writer.write(timesRegister + " = mul " + expression1 + ", " + expr2BitType + " " + mulRegisterExpr2 + "\n\n");
            } else { //both expressions are numbers
                writer.write(timesRegister + " = mul " + expression1 + ", " + expression2 + "\n\n");
            }
        }
        return "TimesExpression";
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "[" f2 -> PrimaryExpression() f3 -> "]"
     */
    public String visit(ArrayLookup n, String argu) throws Exception {
        if (generateIR) {
            String expr1 = n.f0.accept(this, argu);
            String expr2 = n.f2.accept(this, argu);
            String arrayAddressRegister = "%_" + variableRegisterCounter++;
            String sizeLoadRegister = "%_" + variableRegisterCounter++;
            String zeroIndexCheckRegister = "%_" + variableRegisterCounter++;
            String maxIndexCheckRegister = "%_" + variableRegisterCounter++;
            String indexCondRegister = "%_" + variableRegisterCounter++;

            Class currentClass = this.symbolTables.getCurrentTable().getCurrentClass();
            Function currentMethod = currentClass.getCurrentMethod();

            String expr1Type = currentMethod.getVariableType(expr1);
            String expr2Type = currentMethod.getVariableType(expr2);
            String expr1Register = "%_" + variableRegisterCounter++;
            String expr2Register = "%_" + variableRegisterCounter++;
            String expr1BitType = "";
            String expr2BitType = "";

            if (expr1Type == null) {
                expr1Type = currentClass.getVariableTypeAllScopes(expr1);
                if (expr2Type != null) {
                    expr1BitType = convertBitType(calculateBitType(expr2Type));
                    Integer expr1Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expr1);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = getelementptr i8, i8* %this, " + expr1BitType + " " + (expr1Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr1Register + " to " + expr1BitType + "*\n\n");
                    expr1Register = "%_" + variableRegisterCounter++;
                    writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* " + bitcastRegister + "\n\n");
                } else if (isInteger(expr1)) {
                    expr1Register = expr1;
                }
            } else {
                expr1BitType = calculateBitType(expr1Type);
                writer.write(expr1Register + " = load " + expr1BitType + ", " + expr1BitType + "* %" + expr1 + " \n\n");
            }

            if (expr2Type == null) {
                expr2Type = currentClass.getVariableTypeAllScopes(expr2);
                if (expr2Type != null) {
                    expr2BitType = convertBitType(calculateBitType(expr2Type));
                    Integer expr2Offset = vTables.getTable(currentClass.getName()).getVariableOffsets().get(expr2);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = getelementptr i8, i8* %this, " + expr2BitType + " " + (expr2Offset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + expr2Register + " to " + expr2BitType + "*\n\n");
                    expr2Register = "%_" + variableRegisterCounter++;
                    writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* " + bitcastRegister + "\n\n");
                } else if (isInteger(expr2)) {
                    expr2Register = expr2;
                }
            } else {
                expr2BitType = calculateBitType(expr2Type);
                writer.write(expr2Register + " = load " + expr2BitType + ", " + expr2BitType + "* %" + expr2 + " \n\n");
            }

            writer.write("; The following segment implements the array lookup\n\n");
            writer.write("; Load the address of the array\n");
            writer.write(arrayAddressRegister + " = load i32*, i32** %" + expr1 + "\n\n");

            writer.write("; Load the size of the array(first integer of the array)\n");
            writer.write(sizeLoadRegister + " = load i32, i32* " + arrayAddressRegister + "\n\n");

            writer.write("; Check that the index is greater than zero\n");
            writer.write(zeroIndexCheckRegister + " = icmp sge i32 " + expr2Register + ", 0\n\n");

            writer.write("; Check that the index is less than the size of the array\n");
            writer.write(maxIndexCheckRegister + " = icmp slt i32 0, " + sizeLoadRegister + "\n\n");

            writer.write("; Both of these conditions must hold\n");
            writer.write(indexCondRegister + " = and i1 " + zeroIndexCheckRegister + ", " + maxIndexCheckRegister + "\n");

            String boundOkLabel = createArrayAllocationLabel(labelCounter, "bounds_ok");
            String boundErrLabel = createArrayAllocationLabel(labelCounter++, "bounds_err");
            writer.write("br i1 " + indexCondRegister + ", label %" + boundOkLabel + ", label %" + boundErrLabel + "\n\n");

            writer.write("; Else throw out of bounds exception\n");
            writer.write(boundErrLabel + ":\n");
            writer.write("call void @throw_oob()\n");
            writer.write("br label %" + boundOkLabel + "\n\n");

            writer.write("; All ok, we can safely index the array now\n");
            writer.write(boundOkLabel + ":\n\n");
            String getIndexRegister = "%_" + variableRegisterCounter++;
            writer.write("; Add one to the index since the first element holds the size.\n");
            writer.write(getIndexRegister + " = add i32 1," + expr2Register + "\n\n");
            String getElementRegister = "%_" + variableRegisterCounter++;
            writer.write("; Get pointer to the i+1 element of the array.\n");
            writer.write(getElementRegister + " = getelementptr i32, i32* " + arrayAddressRegister + ", i32 " + getIndexRegister + "\n\n");

        }
        return "ArrayLookup";
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "." f2 -> "length"
     */
    public String visit(ArrayLength n, String argu) throws Exception {
        String expression = n.f0.accept(this, argu);
        if (generateIR) {

        }
        return "ArrayLength";
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "." f2 -> Identifier() f3 -> "(" f4 -> (
     * ExpressionList() )? f5 -> ")"
     */
    public String visit(MessageSend n, String argu) throws Exception {
        String expression = "";
        String caller = n.f0.accept(this, argu);
        String method = n.f2.accept(this, argu);
        Class currentClass = this.getSymbolTables().getCurrentTable().getCurrentClass();
        Function currentMethod = currentClass.getCurrentMethod();

        if (generateIR) {
            String exprType = currentMethod.getVariableType(caller);
            String exprRegister = "%_" + (variableRegisterCounter - 1);
            String exprBitType;

            if (exprType == null) {
                exprType = currentClass.getVariableTypeAllScopes(caller);
                if (caller.equals("this")) {
                    exprRegister = "%this";
                } else if (exprType != null) { // caller is attribute;
                    exprBitType = convertBitType(calculateBitType(exprType));
                    Integer exprOffset = vTables.getTable(exprType).getVariableOffsets().get(caller);
                    exprRegister = "%_" + variableRegisterCounter++;
                    System.out.println("caller : " + caller + " " + exprType + "   " + exprOffset);
                    String bitcastRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = getelementptr i8, i8* %this, " + exprBitType + " " + (exprOffset + 8) + "\n\n");
                    writer.write(bitcastRegister + " = bitcast i8* " + exprRegister + " to " + exprBitType + "*\n\n");
                    exprRegister = "%_" + variableRegisterCounter++;
                    writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* " + bitcastRegister + "\n\n");
                    exprRegister = bitcastRegister;
                } else if (caller.equals("MessageSend")) {
                } else if (caller.equals("AllocationExpression")) {
                    exprRegister = "%_" + (variableRegisterCounter - 3);
                    exprType = allocLastReturnType;

                }
            } else { //caller is declared in method
                exprBitType = convertBitType(calculateBitType(exprType));
                writer.write("; First load the object pointer\n");
                exprRegister = "%_" + variableRegisterCounter++;
                writer.write(exprRegister + " = load " + exprBitType + ", " + exprBitType + "* %" + caller + " \n\n");
            }
            String callerRegister = exprRegister;
            Integer methodOffset = vTables.getTable(exprType).getMethodOffsets().get(method);
            String bitcastRegister = "%_" + variableRegisterCounter++;
            String loadRegister = "%_" + variableRegisterCounter++;
            String getElementRegister = "%_" + variableRegisterCounter++;
            String load2Register = "%_" + variableRegisterCounter++;
            String bitcast2Register = "%_" + variableRegisterCounter++;
            writer.write("; Do the required bitcasts, so that we can access the vtable pointer\n");
            writer.write(bitcastRegister + " = bitcast i8* " + exprRegister + " to i8***" + "\n\n");
            writer.write(";  Load vtable_ptr\n");
            writer.write(loadRegister + " = load i8**, i8*** " + bitcastRegister + "\n\n");
            writer.write("; Get a pointer to the i-th entry in the vtable. \n");
            writer.write(getElementRegister + " = getelementptr i8*, i8** " + loadRegister + ", i32 " + (methodOffset / 8) + "\n\n");
            writer.write(";Get the actual function pointer \n");
            writer.write(load2Register + " = load i8*, i8** " + getElementRegister + "\n\n");
            writer.write("; Cast the function pointer from i8* to a function ptr type that matches its signature.\n");
            writer.write(bitcast2Register + " = bitcast i8* " + load2Register + " to i32 (");

            String bitcastArgs = "i8*";
            String callArgs = "i8* " + callerRegister;
            Map<String, String> methodArgs = this.symbolTables.lookup(exprType).getMethod(method).getArguments();
            String methodReturnType = this.symbolTables.lookup(exprType).getMethod(method).getReturnType();
            for (Map.Entry<String, String> argument : methodArgs.entrySet()) {
                bitcastArgs += ", " + convertBitType(calculateBitType(argument.getValue()));
            }
            writer.write(bitcastArgs + ")*\n\n");
            String expressionList = n.f4.accept(this, argu);
            expression = caller + "." + method + "(" + expressionList + ")";
            if (expressionList == null) {
                expressionList = "";
            }
            String[] expressionListArgs = expressionList.split(",");
            int iterator = 0;
            for (String arg : expressionListArgs) {
                String argType = currentMethod.getVariableType(arg);
                String argRegister = "%_" + variableRegisterCounter++;
                String argBitType = "";

                if (argType == null) {
                    argType = currentClass.getVariableTypeAllScopes(arg);
                    if (argType != null) {
                        argBitType = convertBitType(calculateBitType(argType));
                        Integer argOffset = vTables.getTable(argType).getVariableOffsets().get(arg);
                        String argBitcastRegister = "%_" + variableRegisterCounter++;
                        writer.write(argRegister + " = getelementptr i8, i8* %this, " + argBitType + " " + (argOffset + 8) + "\n\n");
                        writer.write(argBitcastRegister + " = bitcast i8* " + argRegister + " to " + argBitType + "*\n\n");
                        argRegister = "%_" + variableRegisterCounter++;
                        writer.write(argRegister + " = load " + argBitType + ", " + argBitType + "* " + argBitcastRegister + "\n\n");
                    } else if (arg.equals("TimesExpression") || arg.equals("PlusExpression") || arg.equals("MinusExpression") || arg.equals("NotExpression") || arg.equals("MessageSend")) {
                        //Get previous register
                        argRegister = "%_" + (variableRegisterCounter - 2);
                        argBitType = "i32";
                    } else if (isInteger(arg)) {
                        argBitType = "i32";
                        argRegister = arg; //register is expression itself
                    } else if (arg.equals("true")) {
                        argBitType = "i1";
                        argRegister = "1";
                    } else if (arg.equals("false")) {
                        argBitType = "i1";
                        argRegister = "0";
                    } else {
                        continue;
                    }
                } else { //expression  is declared in method
                    argBitType = convertBitType(calculateBitType(argType));
                    //load first expression 
                    writer.write(argRegister + " = load " + argBitType + ", " + argBitType + "* %" + arg + " \n\n");
                }
                callArgs += "," + argBitType + " " + argRegister;
            }
            String callRegister = "%_" + variableRegisterCounter++;
            writer.write(";Perform the call - note the first argument is the receiver object.\n");
            writer.write(callRegister + " = call " + convertBitType(calculateBitType(methodReturnType)) + " " + bitcast2Register + "(" + callArgs + ")\n\n\n\n");
            msgSendLastReturnType = methodReturnType;
        }
        //set last return type of method

        return "MessageSend";
    }

    /**
     * f0 -> Expression() f1 -> ExpressionTail()
     */
    public String visit(ExpressionList n, String argu) throws Exception {

        String expression = n.f0.accept(this, argu);
        if (n.f1 != null) {
            expression += n.f1.accept(this, argu);
        }
        return expression;
    }

    /**
     * f0 -> ( ExpressionTerm() )*
     */
    public String visit(ExpressionTail n, String argu) throws Exception {
        String expressionTerm = "";
        NodeListOptional types = n.f0;
        String term;

        for (int i = 0; i < types.size(); i++) {
            ExpressionTerm type = (ExpressionTerm) types.elementAt(i);
            term = type.f1.accept(this, argu);
            expressionTerm += "," + term;
        }
        return expressionTerm;
    }

    /**
     * f0 -> "," f1 -> Expression()
     */
    public String visit(ExpressionTerm n, String argu) throws Exception {
        return n.f1.accept(this, argu);

    }

    /**
     * f0 -> IntegerLiteral() | TrueLiteral() | FalseLiteral() | Identifier() |
     * ThisExpression() | ArrayAllocationExpression() | AllocationExpression() |
     * NotExpression() | BracketExpression()
     */
    public String visit(PrimaryExpression n, String argu) throws Exception {
        return n.f0.accept(this, argu);

    }

    /**
     * f0 -> <INTEGER_LITERAL>
     */
    public String visit(IntegerLiteral n, String argu) throws Exception {
        return n.f0.toString();
    }

    /**
     * f0 -> "true"
     */
    public String visit(TrueLiteral n, String argu) throws Exception {
        n.f0.accept(this, argu);
        return "true";
    }

    /**
     * f0 -> "false"
     */
    public String visit(FalseLiteral n, String argu) throws Exception {
        n.f0.accept(this, argu);
        return "false";
    }

    /**
     * f0 -> "this"
     */
    public String visit(ThisExpression n, String argu) throws Exception {
        n.f0.accept(this, argu);
        return "this";
    }

    @Override
    public String visit(Identifier n, String argu) {
        String test = n.f0.toString();
        return test;
    }

    /**
     * f0 -> "new" f1 -> "int" f2 -> "[" f3 -> Expression() f4 -> "]"
     */
    public String visit(ArrayAllocationExpression n, String argu) throws Exception {
        if (generateIR) {
            String expression = n.f3.accept(this, argu);
            String sizeRegister = "%_" + variableRegisterCounter++;
            writer.write("; Calculate size bytes to be allocated for the array (new arr[sz] -> add i32 1, sz)\n");
            writer.write(sizeRegister + " = add i32 1, " + expression + "\n");

            String notNegativeRegister = "%_" + variableRegisterCounter++;
            String sizeOkLabel = createArrayAllocationLabel(labelCounter, "size_ok");
            String sizeErrLabel = createArrayAllocationLabel(labelCounter++, "size_err");
            writer.write("; Check that the size of the array is not negative\n");
            writer.write(notNegativeRegister + " = icmp sge i32 " + sizeRegister + ", 1\n");
            writer.write("br i1 " + notNegativeRegister + ", label %" + sizeOkLabel + ", label %" + sizeErrLabel + "\n\n");

            writer.write("; Size was negative, throw negative size exception\n");
            writer.write(sizeErrLabel + ":\n");
            writer.write("call void @throw_nsz()\n");
            writer.write("br label %" + sizeOkLabel + "\n\n");

            writer.write("; All ok, we can proceed with the allocation\n");
            writer.write(sizeOkLabel + ":\n\n");
            String callocRegister = "%_" + variableRegisterCounter++;
            String bitcastRegister = "%_" + variableRegisterCounter++;
            writer.write("; Allocate sz + 1 integers (4 bytes each)\n");
            writer.write(callocRegister + " = call i8* @calloc(i32 " + sizeRegister + ", i32 4)\n\n");
            writer.write("; Cast the returned pointer\n");
            writer.write(bitcastRegister + " = bitcast i8* " + callocRegister + " to i32*\n\n");
            writer.write(" ; Store the size of the array in the first position of the array \n");
            writer.write("store i32 " + expression + ",i32* " + bitcastRegister + "\n\n");

            writer.write("; This concludes the array allocation\n\n");
        }
        return "ArrayAllocationExpression";
    }

    /**
     * f0 -> "new" f1 -> Identifier() f2 -> "(" f3 -> ")"
     */
    public String visit(AllocationExpression n, String argu) throws Exception {
        if (generateIR) {
            String id = n.f1.accept(this, argu);
            String callRegister = "%_" + variableRegisterCounter++;
            String bitcastRegister = "%_" + variableRegisterCounter++;
            String getElementRegister = "%_" + variableRegisterCounter++;
            Class currentClass = this.symbolTables.lookup(id);
            Integer sizeOfObject = currentClass.getObjectSize();
            Integer numOfMethods = currentClass.getNumOfAllMethods(vTables);

            writer.write("; First, we allocate the required memory on heap for our object.\n");
            writer.write("; We call calloc to achieve this:\n");
            writer.write(callRegister + " = call i8* @calloc(i32 1,i32 " + (sizeOfObject + 8) + ")\n\n");
            writer.write("; Next we need to set the vtable pointer to point to the correct vtable\n");
            writer.write(bitcastRegister + " = bitcast i8* " + callRegister + " to i8***\n\n");
            writer.write("; Get the address of the first element of the Base_vtable with getelementptr \n");
            writer.write(getElementRegister + " = getelementptr [" + numOfMethods + " x i8*], [" + numOfMethods + " x i8*]* @." + currentClass.getName() + "_vtable, i32 0, i32 0\n\n");
            writer.write("; Set the vtable to the correct address.\n");
            writer.write("store i8** " + getElementRegister + ", i8*** " + bitcastRegister + "\n\n");
            allocLastReturnType = id;
        }
        return "AllocationExpression";

    }

    /**
     * f0 -> "!" f1 -> PrimaryExpression()
     */
    public String visit(NotExpression n, String argu) throws Exception {
        String expression = n.f1.accept(this, argu);
        if (generateIR) {
            String expressionRegister = "%_" + (variableRegisterCounter - 1);
            String notRegister = "%_" + variableRegisterCounter++;
            writer.write(notRegister + " = xor i1 1, " + expressionRegister + "\n\n");
        }
        return "NotExpression";

    }

    /**
     * f0 -> "(" f1 -> Expression() f2 -> ")"
     */
    public String visit(BracketExpression n, String argu) throws Exception {
        return n.f1.accept(this, argu);
    }

    @Override
    public String visit(ArrayType n, String argu) {
        return "int[]";
    }

    public String visit(BooleanType n, String argu) {
        return "boolean";
    }

    public String visit(IntegerType n, String argu) {
        return "int";
    }

}

class Function {
    String name;
    String returnType;
    Class parent;
    Map<String, String> arguments; // define arguments as String list of Maps where key = argument name, value =
                                   // argument type
    Map<String, String> variables; // define variables as String list of Maps where key = variable name , value =
                                   // variable type

    public Function(String name, String returnType, Class parent) {
        this.name = name;
        this.returnType = returnType;
        this.parent = parent;
        this.arguments = new LinkedHashMap<String, String>();
        this.variables = new LinkedHashMap<String, String>();
    }

    String insertArgument(String argumentName, String argumentType) {
        this.arguments.put(argumentName, argumentType);
        return this.arguments.get(argumentName);
    }

    String insertVariable(String variableName, String variableType) throws Exception {

        this.variables.put(variableName, variableType);
        return this.variables.get(variableName);
    }

    Boolean lookup(String variable) {
        for (String name : variables.keySet()) { // search in variables
            if (name.equals(variable)) {
                return true;
            }
        }
        for (String name : arguments.keySet()) { // search in arguments
            if (name.equals(variable)) {
                return true;
            }
        }
        return false;
    }

    Void printArguments() {
        for (Map.Entry<String, String> entry : this.arguments.entrySet()) {
            System.out.print(entry.getValue() + " " + entry.getKey() + ",");
        }
        System.out.println();
        return null;
    }

    Void printVariables() {
        for (Map.Entry<String, String> entry : this.variables.entrySet()) {
            System.out.print(entry.getValue() + " " + entry.getKey() + ",");
        }
        System.out.println();

        return null;
    }

    String getName() {
        return this.name;
    }

    String getReturnType() {
        return this.returnType;
    }

    String getParentName() {
        return this.parent.getName();
    }

    Map<String, String> getArguments() {
        return this.arguments;
    }

    String getVariableType(String variable) {
        for (Map.Entry<String, String> entry : this.variables.entrySet()) { // search in variables
            if (entry.getKey().equals(variable)) { // variable names match
                return entry.getValue(); // return variable type
            }
        }
        for (Map.Entry<String, String> entry : this.arguments.entrySet()) { // search in arguments
            if (entry.getKey().equals(variable)) { // variable names match
                return entry.getValue(); // return variable type
            }
        }
        return null;
    }

    Boolean isPolymorphic(Function method) {
        List<String> methodArgsTypes = new ArrayList<String>(method.arguments.values());
        List<String> currentArgsTypes = new ArrayList<String>(this.arguments.values());

        if (methodArgsTypes.size() != currentArgsTypes.size()) { // check if number of arguments match
            return false;
        }
        if (!(method.returnType.equals(this.returnType))) { // check if return types match
            return false;
        }

        for (int i = 0; i < methodArgsTypes.size(); i++) { // check if arguments list match
            if (!(methodArgsTypes.get(i).equals(currentArgsTypes.get(i)))) { // different argument type
                return false;
            }
        }

        return true;
    }

    Class getParent() {
        return this.parent;
    }

    Void print() {
        System.out.println("Method: " + getName());
        System.out.println("Arguments:");
        printArguments();
        System.out.println("Variables:");
        printVariables();
        System.out.println();
        return null;
    }

}

class Class {
    // Class parentClass; // contains the parentClass if it exists
    // Class childClass; // contains the childClass if it exists
    String name;
    Class parent;
    List<Function> methods;
    Function currentScope;
    Integer variableOffset;
    Integer methodOffset;

    Map<String, String> variables; // define variables as String list of Maps where key = variable name , value =
                                   // variable type

    public Class(String name, Class parent) {
        this.name = name;
        this.parent = parent;
        this.methods = new ArrayList<Function>();
        this.variables = new LinkedHashMap<String, String>();
        this.variables.put("this", this.name);
        this.currentScope = null;
        this.variableOffset = this.methodOffset = 0;
    }

    Function insertMethod(String name, String returnType) throws Exception {
        // Check if method already exists
        if (lookupMethod(name)) {
            System.out.println("Method \"" + name + "\" has already been been defined.");
            throw new Exception();
        }
        Function newMethod = new Function(name, returnType, this);
        this.methods.add(newMethod);
        this.currentScope = newMethod;
        return this.methods.get(this.methods.size() - 1);
    }

    String insert(String variableName, String variableType) throws Exception {
        if (this.variables.get(variableName) != null) {
            System.out.println("Variable " + variableName + " already defined");
            throw new Exception();
        }
        this.variables.put(variableName, variableType);
        return this.variables.get(variableName);
    }

    Boolean lookup(Function method) {
        return this.methods.contains(method);
    }

    Boolean lookupMethod(String method) {
        for (Function entry : methods) {
            if (entry.getName().equals(method)) {
                return true;
            }
        }
        return false;
    }

    Boolean lookup(String variable) {
        for (String name : variables.keySet()) {
            if (name.equals(variable)) {
                return true;
            }
        }
        return false;
    }

    Boolean lookupAllScopesMethod(String method) {

        // Check current class methods
        if (this.lookupMethod(method)) {
            return true; // variable is an method of current class
        }

        // Check all parent scopes
        Class currentClass = this;
        while (currentClass != null) {
            if (currentClass.lookupMethod(method)) {
                return true; // variable is a method of parent class
            }
            currentClass = currentClass.parent;
        }
        return false;
    }

    Boolean lookupAllScopes(String variable) {
        // Check current method first (inner scope)
        if (this.getCurrentMethod() == null) {
            return false; // cannot define variable outside of method;
        }
        if (this.getCurrentMethod().lookup(variable)) {
            return true; // variable in inner method scope
        }
        // Check current class attributes
        if (this.lookup(variable)) {
            return true; // variable is an attribute of current class
        }

        // Check all parent scopes
        Class currentClass = this;
        while (currentClass != null) {
            if (currentClass.lookup(variable)) {
                return true; // variable is an attribute of parent class
            }
            currentClass = currentClass.parent;
        }
        return false;
    }

    String getVariableTypeAllScopes(String variable) {
        if (this.getCurrentMethod().lookup(variable)) {
            return this.getCurrentMethod().getVariableType(variable); // variable in inner method scope
        }

        // Check current class attributes
        if (this.lookup(variable)) {
            return this.getVariableType(variable); // variable is an attribute of current class
        }

        // Check all parent scopes
        Class currentClass = this;
        while (currentClass != null) {
            if (currentClass.lookup(variable)) {
                return currentClass.getVariableType(variable); // variable is an attribute of parent class
            }
            currentClass = currentClass.parent;
        }
        return null;
    }

    Void exitFunction() {
        this.currentScope = null;
        return null;
    }

    Boolean isPolymorphic(Function method) {
        Function parentMethod = this.parent.getMethod(method.getName());
        if (parentMethod != null && !(parentMethod.isPolymorphic(method))) {
            return false;
        }
        return true;
    }

    String getName() {
        return this.name;
    }

    String getVariableType(String variableName) {
        return this.variables.get(variableName);
    }

    Function getCurrentScope() {
        return this.currentScope;
    }

    Class getParent() {
        return this.parent;
    }

    List<Function> getMethods() {
        return this.methods;
    }

    List<Function> getAllMethods() {
        List<Function> allFunctions = new ArrayList<Function>();
        for (Function method : this.methods) {
            allFunctions.add(method);
        }
        if (parent != null) {
            List<Function> parentFunctions = this.parent.getAllMethods();
            for (Function parentFunction : parentFunctions) {
                Boolean isOverriden = false;
                for (Function function : this.methods) {
                    if (function.getName().equals(parentFunction.getName())) {
                        isOverriden = true;
                    }
                }
                if (!isOverriden) {
                    allFunctions.add(parentFunction);
                }
            }
        }
        return allFunctions;
    }

    Integer getNumOfAllMethods(VTables vTables) {
        return vTables.getTable(name).getMethodOffsets().size();

    }

    Integer getObjectSize() {
        Integer objectSize = 0;
        Class currentClass = this;
        while (currentClass != null) {
            for (Map.Entry<String, String> entry : currentClass.variables.entrySet()) {
                String type = entry.getValue();
                if (entry.getKey().equals("this")) {
                    continue;
                }
                if (type.equals("boolean")) {
                    objectSize += 1;
                } else if (type.equals("int")) {
                    objectSize += 4;
                } else {
                    objectSize += 8;
                }
            }
            currentClass = currentClass.parent;
        }
        return objectSize;
    }

    Function getMethod(String methodName) {

        // Check currentclass and all parent scopes
        Class currentClass = this;
        while (currentClass != null) {
            for (Function method : currentClass.getMethods()) {
                if (method.getName().equals(methodName)) {
                    return method;
                }
            }
            currentClass = currentClass.parent;
        }
        return null;
    }

    Function setCurrentMethod(String methodName) {
        this.currentScope = this.getMethod(methodName);
        return this.currentScope;
    }

    Class existsParent(String parent) {
        Class current = this.parent;
        while (current != null) {

            if (current.getName().equals(parent)) {
                return current;
            }
            current = current.parent;
        }
        return null;
    }

    String getParentName() {
        return this.parent.getName();
    }

    Function getCurrentMethod() {
        return this.currentScope;
    }

    Void printAttributes() {
        for (Map.Entry<String, String> entry : this.variables.entrySet()) {
            System.out.print(entry.getValue() + " " + entry.getKey() + ",");
        }
        System.out.println();

        return null;
    }

    Void printVariables() {
        System.out.println("Attributes:");
        this.printAttributes();
        System.out.println("Methods:");
        for (Function method : methods) {
            method.printVariables();
        }
        return null;
    }

    Void print() {
        if (parent != null) {
            System.out.println("Parent: " + parent.getName());
        } else {
            System.out.println("Class has no parent.");
        }
        System.out.println("\nAttributes:\n");
        this.printAttributes();
        System.out.println("\nMethods:\n");
        for (Function method : methods) {
            method.print();
        }
        return null;
    }

    void createAndPrintOffsets(VTables vTables) {
        VTable vTable = vTables.addTable(this.name);
        Integer[] offsets = new Integer[2];
        if (this.parent != null) {
            offsets[0] = this.parent.variableOffset;
            offsets[1] = this.parent.methodOffset;

        } else {
            offsets[0] = offsets[1] = 0;
        }
        System.out.println("-- Class: " + this.name + " --");
        System.out.println("\n-- Variables --");
        for (Map.Entry<String, String> variable : this.variables.entrySet()) {
            if (variable.getKey().equals("this")) { // exclude this variable
                continue;
            }
            String type = variable.getValue();
            System.out.println(type + " " + this.name + "." + variable.getKey() + " : " + offsets[0]);
            vTable.addVariable(variable.getKey(), offsets[0]);
            if (type.equals("boolean")) {
                offsets[0] += 1;
            } else if (type.equals("int")) {
                offsets[0] += 4;
            } else {
                offsets[0] += 8;
            }
        }
        System.out.println("\n -- Methods --");

        for (Function method : this.methods) {
            if (parent != null && parent.lookupMethod(method.getName())) {
                Function parentMethod = parent.getMethod(method.getName());
                VTable parentTable = vTables.getTable(parent.getName());
                Integer offset = parentTable.getMethodOffsets().get(method.getName());
                vTable.addMethod(method.getName(), offset, this.name);
            } else {
                System.out.println(this.name + "." + method.getName() + " : " + offsets[1]);
                vTable.addMethod(method.getName(), offsets[1], this.name);
                offsets[1] += 8;
            }
        }
        if (this.parent != null) {
            VTable parentVTable = vTables.getTable(this.parent.getName());

            for (Map.Entry<String, Integer> variableEntry : parentVTable.getVariableOffsets().entrySet()) {
                if (!this.lookup(variableEntry.getKey())) {
                    vTable.addVariable(variableEntry.getKey(), variableEntry.getValue());
                }
            }
            for (Map.Entry<String, Integer> methodEntry : parentVTable.getMethodOffsets().entrySet()) {
                if (!this.lookupMethod(methodEntry.getKey())) {
                    String owner = parentVTable.getOwnerClasses().get(methodEntry.getKey());
                    vTable.addMethod(methodEntry.getKey(), methodEntry.getValue(), owner);
                }
            }
        }
        this.variableOffset = offsets[0];
        this.methodOffset = offsets[1];
        System.out.println("\n\n");
    }

}

class SymbolTable {
    // create String table as String list of classes
    List<Class> classes;
    Class currentScope;
    Class currentClass;

    // Integer currentScopeLevel;
    public SymbolTable() {
        this.classes = new ArrayList<Class>();
        this.currentScope = null;
        this.currentClass = null;
    }

    Class enter(String extendsName) {
        this.currentScope = this.lookup(extendsName);
        return this.currentScope;
    }

    Class insert(String name, SymbolTables tables) throws Exception {
        // Check if class already exists
        Class newEntry = new Class(name, this.currentScope);
        this.classes.add(newEntry);
        this.currentClass = newEntry;
        return this.currentClass;
    }

    Class lookup(String className) {
        for (Class classIterator : classes) {
            if (classIterator.getName().equals(className)) {
                return classIterator;
            }
        }
        return null;
    }

    String lookupVariableType(String VariableName) {
        for (Class classIterator : classes) {
            String type = classIterator.getVariableType(VariableName);
            if (type != null) {
                return type;
            }
        }
        return null;
    }

    Class getCurrentScope() {
        return this.currentScope;
    }

    String getCurrentScopeName() {
        if (this.currentScope != null) {
            return this.currentScope.getName();
        }
        return "null";
    }

    Class getCurrentClass() {
        return this.currentClass;
    }

    Class setCurrentClass(String className) {
        this.currentClass = lookup(className);
        return this.currentClass;
    }

    String getCurrentClassName() {
        return this.currentClass.getName();
    }

    String getCurrentClassParent() {

        return this.currentClass.getParentName();
    }

    List<Class> getClasses() {
        return this.classes;
    }

    Void print() {
        System.out.println();
        if (currentScope != null) {
            System.out.println("Current Scope: " + currentScope.getName());
        } else {
            System.out.println("No Current Scope");
        }

        if (currentClass != null) {
            System.out.println("Current Class: " + currentClass.getName());
        } else {
            System.out.println("No Current Class");
        }
        System.out.println("\n Classes \n");
        for (Class cl : classes) {
            System.out.println("Class: " + cl.getName());
            cl.print();
        }
        System.out.println();
        return null;

    }

    void createAndPrintOffsets(VTables vTables) {
        for (Class classIterator : classes) {
            if (classIterator.lookupMethod("main")) { // exclude class with main method
                continue;
            }
            classIterator.createAndPrintOffsets(vTables);
        }
    }
}

class SymbolTables {
    // create String list of tables where each table contains its own scope
    List<SymbolTable> tables;
    SymbolTable currentTable;

    public SymbolTables() {
        this.tables = new ArrayList<SymbolTable>();
        this.currentTable = null;
    }

    SymbolTable getCurrentTable() {
        return this.currentTable;
    }

    List<SymbolTable> getTables() {
        return this.tables;
    }

    SymbolTable enter() {
        SymbolTable table = new SymbolTable();
        this.tables.add(table);
        this.currentTable = table;
        return this.currentTable;
    }

    Class lookup(String className) {
        for (SymbolTable tableIterator : tables) {
            Class found = tableIterator.lookup(className);
            if (found != null) {
                return found;
            }
        }
        return null;
    }

    SymbolTable setCurrentTable(String className) {
        this.currentTable = this.lookupTable(className);
        this.currentTable.setCurrentClass(className);
        return this.currentTable;

    }

    SymbolTable lookupTable(String className) {
        for (SymbolTable tableIterator : tables) {
            Class found = tableIterator.lookup(className);
            if (found != null) {
                return tableIterator;
            }
        }
        return null;
    }

    String lookupVariableType(String variableName) {
        for (SymbolTable tableIterator : tables) {
            String type = tableIterator.lookupVariableType(variableName);
            if (type != null) {
                return type;
            }
        }
        return null;
    }

    void createAndPrintOffsets(VTables vTables) {
        for (SymbolTable tableIterator : tables) {
            tableIterator.createAndPrintOffsets(vTables);
        }
    }

    Void print() {
        int tableCounter = 1;
        for (SymbolTable table : tables) {
            System.out.println("\n--> Symbol Table " + tableCounter);
            table.print();
            tableCounter++;
            System.out.println();
        }
        return null;
    }

}

class VTable {
    String name;
    Map<String, Integer> methodOffsets;
    Map<String, Integer> variableOffsets;
    Map<String, String> ownerClass;

    public VTable(String name) {
        this.name = name;
        this.methodOffsets = new LinkedHashMap<String, Integer>();
        this.variableOffsets = new LinkedHashMap<String, Integer>();
        this.ownerClass = new LinkedHashMap<String, String>();
    }

    String getName() {
        return this.name;
    }

    Map<String, Integer> getMethodOffsets() {
        return methodOffsets;
    }

    Map<String, Integer> getVariableOffsets() {
        return variableOffsets;
    }

    Map<String, String> getOwnerClasses() {
        return ownerClass;
    }

    void addMethod(String methodName, Integer offset, String owner) {
        this.methodOffsets.put(methodName, offset);
        this.ownerClass.put(methodName, owner);
    }

    void addVariable(String variableName, Integer offset) {
        this.variableOffsets.put(variableName, offset);
    }

    void print() {
        System.out.println(" VTable " + name);
        System.out.println("___ Variable Offsets ___");
        for (Map.Entry<String, Integer> entry : variableOffsets.entrySet()) {
            System.out.println(entry.getKey() + " : " + entry.getValue());
        }
        System.out.println("\n ___ Method Offsets ___");
        for (Map.Entry<String, Integer> entry : methodOffsets.entrySet()) {
            System.out.println(entry.getKey() + " : " + entry.getValue());
        }
        System.out.println("\n ___ Owner Classes: ___");
        for (Map.Entry<String, String> entry : ownerClass.entrySet()) {
            System.out.println(entry.getKey() + " : " + entry.getValue());
        }
        System.out.println("\n\n");
    }

    Integer getNumOfAllMethods() {
        return methodOffsets.size();

    }

}

class VTables {
    // create list of virtual tables
    List<VTable> tables;

    public VTables() {
        this.tables = new ArrayList<VTable>();
    }

    VTable addTable(String className) {
        VTable table = new VTable(className);
        this.tables.add(table);
        return table;
    }

    VTable getTable(String tableName) {
        for (VTable table : tables) {
            if (table.getName() == tableName) {
                return table;
            }
        }
        return null;
    }

    List<VTable> getTables() {
        return tables;
    }

    void print() {
        System.out.println("--> Printing Vtables");

        for (VTable table : tables) {
            table.print();
        }
    }

}
