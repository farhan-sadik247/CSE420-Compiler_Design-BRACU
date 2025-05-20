%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.
// You can store the pointer to your symbol table in a global variable
// or you can create an object

symbol_table *table;

int lines = 1;

ofstream outlog;
ofstream error;
int error_count = 0;
vector<string> var_list;
vector<string> var_types;
vector<int> arr_size;
vector<string> param_names;
vector<string> param_types;
int no__of_params = 0;
symbol_info *func = NULL;
vector<string> value_list;
vector<string> value_types;

// you may declare other necessary variables here to store necessary info
// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.

void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;

    // you may need to reinitialize variables if you find an error
}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print your whole symbol table here
		table->print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1->getname()+"\n"+$2->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
		$$ = new symbol_info($1->getname(),"unit");
	 }
     ;

func_definition : type_specifier ID
        {
            func = new symbol_info($2->getname(),"func_def");
        }
        LPAREN parameter_list RPAREN 
		{
			func->set_return_type($1->getname());
			func->set_parameter_names(param_names);
			func->set_parameter_types(param_types);
			func->set_no_of_parameters(no__of_params);
            if (table->lookup($2->getname())){
                error<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl<<endl;
                outlog<<"At line no: "<<lines<<" Multiple declaration of function "<<$2->getname()<<endl<<endl;
                error_count++;
            }
            table->insert(func);
		}
		compound_statement
		{	
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<"("+$5->getname()+")\n"<<$8->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+"("+$5->getname()+")\n"+$8->getname(),"func_def");	
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.
		}
        // | type_specifier ID 
        // {
        //     func = new symbol_info($2->getname(),"func_def");
        // }
        // LPAREN RPAREN 
        // {
        //     func->set_return_type($1->getname());
        //     table->insert(func);
        // }
        // compound_statement
        // {
            
        //     outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
        //     outlog<<$1->getname()<<" "<<$2->getname()<<"()\n"<<$7->getname()<<endl<<endl;
            
        //     $$ = new symbol_info($1->getname()+" "+$2->getname()+"()\n"+$7->getname(),"func_def");	
            
        //     // The function definition is complete.
        //     // You can now insert necessary information about the function into the symbol table
        //     // However, note that the scope of the function and the scope of the compound statement are different.
        // }
        // ;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<" "<<$4->getname()<<endl<<endl;
					
			$$ = new symbol_info($1->getname()+","+$3->getname()+" "+$4->getname(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
            for(int i=0; i<param_names.size(); i++){
                if(param_names[i] == $4->getname()){
                    error<<"At line no: "<<lines<<" Multiple declaration of variable "<<$4->getname()<<"in parameter of "<<func->getname()<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" Multiple declaration of variable "<<$4->getname()<<"in parameter of "<<func->getname()<<endl<<endl;
                    error_count++;
                }
            }
			param_names.push_back($4->getname());
			param_types.push_back($3->getname());
			no__of_params++;
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+","+$3->getname(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname(),"param_list");

            for(int i=0; i<param_names.size(); i++){
                if(param_names[i] == $2->getname()){
                    error<<"At line no: "<<lines<<" Multiple declaration of variable "<<$2->getname()<<"in parameter of "<<func->getname()<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" Multiple declaration of variable "<<$2->getname()<<"in parameter of "<<func->getname()<<endl<<endl;
                    error_count++;
                }
            }
			param_names.push_back($2->getname());
			param_types.push_back($1->getname());
			no__of_params++;
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
		}
        | 
 		;

compound_statement : LCURL
			{
				table->enter_scope(outlog);
			}
			statements RCURL
			{ 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
				outlog<<"{\n"+$3->getname()+"\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n"+$3->getname()+"\n}","comp_stmnt");
				
                // The compound statement is complete.
                // Print the symbol table here and exit the scope
                // Note that function parameters should be in the current scope
				for(int i=0; i<param_names.size(); i++)
				{
					symbol_info *param = new symbol_info(param_names[i],"var");
					param->set_data_type(param_types[i]);
					table->insert(param);
				}
				param_names.clear();
				param_types.clear();
				no__of_params = 0;
				table->print_all_scopes(outlog);
				table->exit_scope(outlog);
 		    }
 		    | LCURL RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");
				
				// The compound statement is complete.
                // Print the symbol table here and exit the scope
 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
		 {
			outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
			outlog<<$1->getname()<<" "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+" "+$2->getname()+";","var_dec");
			
			// Insert necessary information about the variables in the symbol table
            string var_type = $1->getname();
            if ($1->getname() == "void"){
                error<<"At line no: "<<lines<<" variable type cannot be void "<<endl<<endl;
                outlog<<"At line no: "<<lines<<" variable type cannot be void "<<endl<<endl;
                error_count++;
                var_type = "error";
            }
            for(int i=0; i<var_list.size(); i++){
                if(table->lookup_in_current_scope(var_list[i])){
                    error<<"At line no: "<<lines<<" Multiple declaration of variable "<<var_list[i]<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" Multiple declaration of variable "<<var_list[i]<<endl<<endl;
                    error_count++;
                }
                else{
                    symbol_info *var = new symbol_info(var_list[i],var_types[i]);
                    var->set_data_type(var_type);
                    if (var_types[i] == "array"){
						printf("yes");
                        var->set_array_size(arr_size[i]);
                    }
                    table->insert(var);    
                }
            }
			var_list.clear();
			var_types.clear();
			arr_size.clear();
		 }
 		 ;

type_specifier : INT
		{
			outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
			outlog<<"int"<<endl<<endl;
			
			$$ = new symbol_info("int","type");
	    }
 		| FLOAT
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
			outlog<<"float"<<endl<<endl;
			
			$$ = new symbol_info("float","type");
	    }
 		| VOID
 		{
			outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
			outlog<<"void"<<endl<<endl;
			
			$$ = new symbol_info("void","type");
	    }
 		;

declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<endl<<endl;
            $$ = new symbol_info($1->getname()+","+$3->getname(),"decl_list");

            // you may need to store the variable names to insert them in symbol table here or later
			var_list.push_back($3->getname());
            var_types.push_back("var");
            arr_size.push_back(0);
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD //array after some declaration
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1->getname()+","<<$3->getname()<<"["<<$5->getname()<<"]"<<endl<<endl;
            $$ = new symbol_info($1->getname()+","+$3->getname()+"["+$5->getname()+"]","decl_list");

            // you may need to store the variable names to insert them in symbol table here or later
			var_list.push_back($3->getname());
            var_types.push_back("array");
            arr_size.push_back((stoi($5->getname())));
			for(int i=0; i<var_types.size(); i++){
				printf("%s %s\n",var_list[i].c_str(),var_types[i].c_str());
			}
		  }
 		  |ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
            $$ = new symbol_info($1->getname(),"decl_list");

            // you may need to store the variable names to insert them in symbol table here or later
			var_list.push_back($1->getname());
            var_types.push_back("var");
            arr_size.push_back(0);
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD //array
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;
            $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","decl_list");

            // you may need to store the variable names to insert them in symbol table here or later
			var_list.push_back($1->getname());
            var_types.push_back("array");
            arr_size.push_back((stoi($3->getname())));
 		  }
 		  ;
 		  

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1->getname()<<"\n"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+"\n"+$2->getname(),"stmnts");
	   }
	   ;
	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1->getname()<<endl<<endl;

            $$ = new symbol_info($1->getname(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3->getname()<<$4->getname()<<$5->getname()<<")\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3->getname()+$4->getname()+$5->getname()+")\n"+$7->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3->getname()<<")\n"<<$5->getname()<<"\nelse\n"<<$7->getname()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3->getname()+")\n"+$5->getname()+"\nelse\n"+$7->getname(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3->getname()<<")\n"<<$5->getname()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3->getname()+")\n"+$5->getname(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3->getname()<<");"<<endl<<endl; 
			
			$$ = new symbol_info("printf("+$3->getname()+");","stmnt");

            if (!table->lookup($3->getname())){
                error<<"At line no: "<<lines<<" Undeclared variable "<<$3->getname()<<endl<<endl;
                outlog<<"At line no: "<<lines<<" Undeclared variable "<<$3->getname()<<endl<<endl;
                error_count++;
            }
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2->getname()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2->getname()+";","stmnt");
	  }
	  ;
	  
expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1->getname()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1->getname()+";","expr_stmt");
	        }
			;
	  
variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"varbl");
        if (!table->lookup($1->getname())){
            bool found = false;
            for (int i=0; i<param_names.size(); i++){
                if (param_names[i] == $1->getname()){
                    found = true;
                    break;
                }
            }
            if (!found){
                error<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl<<endl;
                outlog<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl<<endl;
                error_count++;
            }
        }
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1->getname()<<"["<<$3->getname()<<"]"<<endl<<endl;

        if(table->lookup($1->getname())->get_data_type() == "int"){
            $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","int_varbl");
        }
        else{
            $$ = new symbol_info($1->getname()+"["+$3->getname()+"]","float_varbl");
        }
            
        if (!table->lookup($1->getname())){
            bool found = false;
            for (int i=0; i<param_names.size(); i++){
                if (param_names[i] == $1->getname()){
                    found = true;
                    break;
                }
            }
            if (!found){
                error<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl<<endl;
                outlog<<"At line no: "<<lines<<" Undeclared variable "<<$1->getname()<<endl<<endl;
                error_count++;
            }
        }
        else if (table->lookup($1->getname())->get_type() != "array"){
            error<<"At line no: "<<lines<<" variable is not of array type :"<<$1->getname()<<endl<<endl;
            outlog<<"At line no: "<<lines<<" variable is not of array type :"<<$1->getname()<<endl<<endl;
            error_count++;
        }

        for(int i=0; i<value_list.size(); i++){
            if (value_list[i] == $3->getname()){
                if (value_types[i] != "int"){
                    error<<"At line no: "<<lines<<" array index is not of integer type : "<<$1->getname()<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" array index is not of integer type : "<<$1->getname()<<endl<<endl;
                    error_count++;
                    break;
                }
            }
        }                    
     }
	 ;
	 
expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"expr");
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

            if ($3->get_type() == "void_lgc_expr"){
                $$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
                error<<"At line no: "<<lines<<" operation on void type"<<endl<<endl;
                outlog<<"At line no: "<<lines<<" operation on void type"<<endl<<endl;
                error_count++;
            }
            else{
                for(int i=0; i<value_list.size(); i++){
                    if (value_list[i] == $3->getname()){
                        if (value_types[i] == "float" && $1->get_type() == "int_varbl"){
                            error<<"At line no: "<<lines<<" Warning: Assignment of float into variable of integr type"<<endl<<endl;
                            outlog<<"At line no: "<<lines<<" Warning: Assignment of float into variable of integr type"<<endl<<endl;
                            error_count++;
                        }
                    }
                }
                $$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
            }
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

            if ($1->get_type() == "void_rel_expr"){
                $$ = new symbol_info($1->getname(),"void_lgc_expr");
            }
            else{
                $$ = new symbol_info($1->getname(),"lgc_expr");
            }
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"lgc_expr");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

            if ($1->get_type() == "void_simp_expr"){
                $$ = new symbol_info($1->getname(),"void_rel_expr");
            }
            else{
                $$ = new symbol_info($1->getname(),"rel_expr");
            }
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"rel_expr");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

            if ($1->get_type() == "void_term"){
                $$ = new symbol_info($1->getname(),"void_simp_expr");
            }
            else{
			    $$ = new symbol_info($1->getname(),"simp_expr");
            }
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"simp_expr");
	      }
		  ;
					
term :	unary_expression //term can be void because of un_expr->factor
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;

            if ($1->get_type() == "void_un_expr"){
                $$ = new symbol_info($1->getname(),"void_term");
            }
            else{
                $$ = new symbol_info($1->getname(),"term");
            }			
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<$3->getname()<<endl<<endl;
			

            if ($3->get_type() == "void_un_expr"){
                $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"void_term");
                error<<"At line no: "<<lines<<" operation on void type "<<endl<<endl;
                outlog<<"At line no: "<<lines<<" operation on void type "<<endl<<endl;
                error_count++;
            }
            else{
                if ($3->get_type() == "0_un_expr"){
                    error<<"At line no: "<<lines<<" Modulus by 0"<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" Modulus by 0"<<endl<<endl;
                    error_count++;
                }
                else if ($3->get_type() == "float_un_expr"){
                    error<<"At line no: "<<lines<<" Modulus operator on non integer type"<<endl<<endl;
                    outlog<<"At line no: "<<lines<<" Modulus operator on non integer type"<<endl<<endl;
                    error_count++;
                }
                $$ = new symbol_info($1->getname()+$2->getname()+$3->getname(),"term");
            }			
	 }
     ;

unary_expression : ADDOP unary_expression  // un_expr can be void because of factor
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1->getname()<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname()+$2->getname(),"un_expr");
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2->getname()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2->getname(),"un_expr");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
            if ($1->get_type() == "void_fctr"){
			    $$ = new symbol_info($1->getname(),"void_un_expr");
            }
            else if ($1->get_type() == "0_fctr"){
                $$ = new symbol_info($1->getname(),"0_un_expr");
            }
            else if ($1->get_type() == "float_fctr"){
                $$ = new symbol_info($1->getname(),"float_un_expr");
            }
            else{
                $$ = new symbol_info($1->getname(),"un_expr");
            }
         }
		 ;
	
factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"fctr");
        
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1->getname()<<"("<<$3->getname()<<")"<<endl<<endl;

        vector<string> arg_list;
        string arg = $3->getname();
        stringstream ss(arg);
        string token;
        while (getline(ss, token, ',')){
            arg_list.push_back(token);
        }


        if (table->lookup($1->getname())){
            if (table->lookup($1->getname())->get_return_type() == "void"){
                $$ = new symbol_info($1->getname()+"("+$3->getname()+")","void_fctr");
            }
            else{
                $$ = new symbol_info($1->getname()+"("+$3->getname()+")","fctr");
            }
                
            if (table->lookup($1->getname())->get_no_of_parameters() != arg_list.size()){
                error<<"At line no: "<<lines<<" Inconsistancy in number of arguments in function call: "<<$1->getname()<<endl<<endl;
                outlog<<"At line no: "<<lines<<" Inconsistancy in number of arguments in function call: "<<$1->getname()<<endl<<endl;
                error_count++;
            }
            for (int i=0; i<arg_list.size(); i++){
                if (table->lookup(arg_list[i])){
                    if (table->lookup(arg_list[i])->get_type() == "array"){
                        error<<"At line no: "<<lines<<" variable is of "<<table->lookup(arg_list[i])->get_data_type()<<" type : "<<arg_list[i]<<endl<<endl;
                        outlog<<"At line no: "<<lines<<" variable is of "<<table->lookup(arg_list[i])->get_data_type()<<" type : "<<arg_list[i]<<endl<<endl;
                        error_count++;
                    }
                    else if (table->lookup(arg_list[i])->get_data_type() != table->lookup($1->getname())->get_parameter_types()[i]){
                        error<<"At line no: "<<lines<<" argument "<<i+1<<" type mismatch in function call: "<<$1->getname()<<endl<<endl;
                        outlog<<"At line no: "<<lines<<" argument "<<i+1<<" type mismatch in function call: "<<$1->getname()<<endl<<endl;                            error_count++;
                    }
                }
                else{
                    for (int j=0; j<value_list.size(); j++){
                        if (arg_list[i] == value_list[j]){
                            if (value_types[j] != table->lookup($1->getname())->get_parameter_types()[i]){
                                error<<"At line no: "<<lines<<" argument "<<i+1<<" type mismatch in function call: "<<$1->getname()<<endl<<endl;
                                outlog<<"At line no: "<<lines<<" argument "<<i+1<<" type mismatch in function call: "<<$1->getname()<<endl<<endl;
                                error_count++;
                            }
                        }
                    }
                }
            }
        }
        else{
            error<<"At line no: "<<lines<<" Undeclared function "<<$1->getname()<<endl<<endl;
            outlog<<"At line no: "<<lines<<" Undeclared function "<<$1->getname()<<endl<<endl;
            error_count++;
        }
        arg_list.clear();
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2->getname()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2->getname()+")","fctr");
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
		
        if ($1->getname() == "0"){
            $$ = new symbol_info($1->getname(),"0_fctr");
        }
        else{
            $$ = new symbol_info($1->getname(),"fctr");
        }
        value_list.push_back($1->getname());
        value_types.push_back("int");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1->getname()<<endl<<endl;
			
		$$ = new symbol_info($1->getname(),"float_fctr");
        value_list.push_back($1->getname());
        value_types.push_back("float");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1->getname()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"++","fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1->getname()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1->getname()+"--","fctr");
	}
	;
	
argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1->getname()<<endl<<endl;
						
					$$ = new symbol_info($1->getname(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<","<<$3->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname()+","+$3->getname(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1->getname()<<endl<<endl;
						
				$$ = new symbol_info($1->getname(),"arg");
		  }
	      ;
 

%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("logfile.txt", ios::trunc);
	error.open("error.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	// Enter the global or the first scope here
	table = new symbol_table(10);
	table->enter_scope(outlog);

	yyparse();

	
	outlog<<endl<<"Total lines: "<<lines<<endl;
    error<<endl<<"Total errors: "<<error_count<<endl;
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}