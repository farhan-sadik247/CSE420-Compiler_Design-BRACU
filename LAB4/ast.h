#ifndef AST_H
#define AST_H

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <map>

using namespace std;

class ASTNode {
public:
    virtual ~ASTNode() {}
    virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp, int& temp_count, int& label_count) const = 0;
};

// Expression node types

class ExprNode : public ASTNode {
protected:
    string node_type; // Type information (int, float, void, etc.)
public:
    ExprNode(string type) : node_type(type) {}
    virtual string get_type() const { return node_type; }
};

// Variable node (for ID references)

class VarNode : public ExprNode {
private:
    string name;
    ExprNode* index; // For array access, nullptr for simple variables

public:
    VarNode(string name, string type, ExprNode* idx = nullptr)
        : ExprNode(type), name(name), index(idx) {}
    
    ~VarNode() { if(index) delete index; }
    
    bool has_index() const { return index != nullptr; }
    
    string generate_index_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                              int& temp_count, int& label_count) const {
        if (!index) return "";
        string index_temp = index->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string result_temp = "t" + to_string(temp_count++);
        outcode << result_temp << " = " << index_temp << " * 4" << endl;  // Assuming 4 bytes per element
        return result_temp;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        if (symbol_to_temp.find(name) == symbol_to_temp.end()) {
            symbol_to_temp[name] = "t" + to_string(temp_count++);
        }
        
        if (has_index()) {
            string index_temp = generate_index_code(outcode, symbol_to_temp, temp_count, label_count);
            string result_temp = "t" + to_string(temp_count++);
            outcode <<result_temp << " = " << symbol_to_temp[name] << "[" << index_temp << "]" << endl;
            return result_temp;
        }
        
        return symbol_to_temp[name];
    }
    
    string get_name() const { return name; }
};

// Constant node

class ConstNode : public ExprNode {
private:
    string value;

public:
    ConstNode(string val, string type) : ExprNode(type), value(val) {}
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string result_temp = "t" + to_string(temp_count++);
        outcode << result_temp << " = " << value << endl;
        return result_temp;
    }
};

// Binary operation node

class BinaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* left;
    ExprNode* right;

public:
    BinaryOpNode(string op, ExprNode* left, ExprNode* right, string result_type)
        : ExprNode(result_type), op(op), left(left), right(right) {}
    
    ~BinaryOpNode() {
        delete left;
        delete right;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
        int& temp_count, int& label_count) const override {      
    string left_temp = left->generate_code(outcode, symbol_to_temp, temp_count, label_count);
    string left_result = "t" + to_string(temp_count++);
    outcode << left_result << " = " << left_temp << endl;

    string right_temp = right->generate_code(outcode, symbol_to_temp, temp_count, label_count);
    string right_result;

    if (right_temp[0] != 't') {
        right_result = "t" + to_string(temp_count++);
        outcode << right_result << " = " << right_temp << endl;}
    else {
        right_result = right_temp;}

    string result_temp = "t" + to_string(temp_count++);
    outcode << result_temp << " = " << left_result << " " << op << " " << right_result << endl;
    if (op == "<") {
        outcode << "If "<<result_temp ;
    }
    return result_temp;
    }
};

// Unary operation node

class UnaryOpNode : public ExprNode {
private:
    string op;
    ExprNode* expr;

public:
    UnaryOpNode(string op, ExprNode* expr, string result_type)
        : ExprNode(result_type), op(op), expr(expr) {}
    
    ~UnaryOpNode() { delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string expr_temp = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string result_temp = "t" + to_string(temp_count++);
        
        outcode <<result_temp << " = " << op << expr_temp << endl;
        return result_temp;
    }
};

// Assignment node

class AssignNode : public ExprNode {
private:
    VarNode* lhs;
    ExprNode* rhs;

public:
    AssignNode(VarNode* lhs, ExprNode* rhs, string result_type)
        : ExprNode(result_type), lhs(lhs), rhs(rhs) {}
    
    ~AssignNode() {
        delete lhs;
        delete rhs;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string rhs_temp = rhs->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string lhs_temp = lhs->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << lhs_temp << " = " << rhs_temp << endl;
        return lhs_temp;
    }
};

// Statement node types

class StmtNode : public ASTNode {
public:
    virtual string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                                int& temp_count, int& label_count) const = 0;
};

// Expression statement node

class ExprStmtNode : public StmtNode {
private:
    ExprNode* expr;

public:
    ExprStmtNode(ExprNode* e) : expr(e) {}
    ~ExprStmtNode() { if(expr) delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        if (expr) {
            expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        return "";
    }
};

// Block (compound statement) node

class BlockNode : public StmtNode {
private:
    vector<StmtNode*> statements;

public:
    ~BlockNode() {
        for (auto stmt : statements) {
            delete stmt;
        }
    }
    
    void add_statement(StmtNode* stmt) {
        if (stmt) statements.push_back(stmt);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        for (auto stmt : statements) {
            stmt->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        return "";
    }
};

// If statement node

class IfNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* then_block;
    StmtNode* else_block; // nullptr if no else part

public:
    IfNode(ExprNode* cond, StmtNode* then_stmt, StmtNode* else_stmt = nullptr)
        : condition(cond), then_block(then_stmt), else_block(else_stmt) {}
    
    ~IfNode() {
        delete condition;
        delete then_block;
        if (else_block) delete else_block;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        string else_label = "L" + to_string(label_count++);
        string end_label = "L" + to_string(label_count++);
        
        outcode << "if " << cond_temp << " goto " << end_label << endl;
        end_label = "L" + to_string(label_count);
        outcode <<"Goto " << end_label << endl;
        else_label = "L" + to_string(label_count-1);
        label_count++;
        outcode << else_label << ":" << endl;
        then_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << "goto " << end_label << endl;
        outcode << else_label << ":" << endl;
        if (else_block) {
            else_block->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        outcode << end_label << ":" << endl;
        return "";
    }
};

// While statement node

class WhileNode : public StmtNode {
private:
    ExprNode* condition;
    StmtNode* body;

public:
    WhileNode(ExprNode* cond, StmtNode* body_stmt)
        : condition(cond), body(body_stmt) {}
    
    ~WhileNode() {
        delete condition;
        delete body;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        string start_label = "L" + to_string(label_count++);
        string end_label = "L" + to_string(label_count++);
        
        outcode << start_label << ":" << endl;
        string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << cond_temp << " == 0 goto " << end_label << endl;
        body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        outcode << "goto " << start_label << endl;
        outcode << end_label << ":" << endl;
        return "";
    }
};

// For statement node

class ForNode : public StmtNode {
private:
    ExprNode* init;
    ExprNode* condition;
    ExprNode* update;
    StmtNode* body;

public:
    ForNode(ExprNode* init_expr, ExprNode* cond_expr, ExprNode* update_expr, StmtNode* body_stmt)
        : init(init_expr), condition(cond_expr), update(update_expr), body(body_stmt) {}
    
    ~ForNode() {
        if (init) delete init;
        if (condition) delete condition;
        if (update) delete update;
        delete body;
    }
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for for loops
        if (init) {
            init->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        string start_label = "L" + to_string(label_count++);
        string end_label = "L" + to_string(label_count++);

        outcode << start_label << ":" << endl;
        if (condition) {
            string cond_temp = condition->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << " go to " << end_label << endl;
            end_label = "L" + to_string(label_count);
            outcode << "Goto " << end_label << endl;
            start_label = "L" + to_string(label_count-1);
            outcode << start_label << ":" << endl;
        }

        body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        if (update) {
            update->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        outcode << "Goto " << start_label << endl;
        outcode << end_label << ":" << endl;
        
        return "";
    }
};

// Return statement node

class ReturnNode : public StmtNode {
private:
    ExprNode* expr;

public:
    ReturnNode(ExprNode* e) : expr(e) {}
    ~ReturnNode() { if (expr) delete expr; }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        if (expr) {
            string expr_temp = expr->generate_code(outcode, symbol_to_temp, temp_count, label_count);
            outcode << "return " << expr_temp << endl;
        }
        return "";
    }
};

// Declaration node

class DeclNode : public StmtNode {
private:
    string type;
    vector<pair<string, int>> vars; // Variable name and array size (0 for regular vars)

public:
    DeclNode(string t) : type(t) {}
    
    void add_var(string name, int array_size = 0) {
        vars.push_back(make_pair(name, array_size));
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for variable declarations
        for (const auto& var : vars) {
            string name = var.first;
            int array_size = var.second;
            
            if (array_size == 0) {
                outcode << "// Declaration: " << type << " " << name << endl;
                //symbol_to_temp[name] = "t" + to_string(temp_count);
                symbol_to_temp[name] = name;
            } else {
                outcode << "// Declaration: " << type << " " << name << "[" << array_size << "]" << endl;
                symbol_to_temp[name] = "t" + to_string(temp_count);
            }
        }
        return "";
    }
    
    string get_type() const { return type; }
    const vector<pair<string, int>>& get_vars() const { return vars; }
};

// Function declaration node

class FuncDeclNode : public ASTNode {
private:
    string return_type;
    string name;
    vector<pair<string, string>> params; // Parameter type and name
    BlockNode* body;

public:
    FuncDeclNode(string ret_type, string n) : return_type(ret_type), name(n), body(nullptr) {}
    ~FuncDeclNode() { if (body) delete body; }
    
    void add_param(string type, string name) {
        params.push_back(make_pair(type, name));
    }
    
    void set_body(BlockNode* b) {
        body = b;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // TODO: Implement this method
        // Should generate code for function declarations
        outcode << "// Function: " << return_type << " " << name << "(";
        for (size_t i = 0; i < params.size(); i++) {
            if (i > 0) outcode << ", ";
            outcode << params[i].first << " " << params[i].second;
        }
        outcode << ")" << endl;
        

        int local_temp_count = temp_count;
        
  
        for (const auto& param : params) {
            symbol_to_temp[param.second] = param.second;
        }
        

        if (body) {
            body->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        
        outcode << endl;

        return "";
    }
};

// Helper class for function arguments

class ArgumentsNode : public ASTNode {
private:
    vector<ExprNode*> args;

public:
    ~ArgumentsNode() {
        // Don't delete args here - they'll be transferred to FuncCallNode
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) args.push_back(arg);
    }
    
    ExprNode* get_argument(int index) const {
        if (index >= 0 && index < args.size()) {
            return args[index];
        }
        return nullptr;
    }
    
    size_t size() const {
        return args.size();
    }
    
    const vector<ExprNode*>& get_arguments() const {
        return args;
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        // This node doesn't generate code directly
        return "";
    }
};

// Function call node

class FuncCallNode : public ExprNode {
private:
    string func_name;
    vector<ExprNode*> arguments;

public:
    FuncCallNode(string name, string result_type)
        : ExprNode(result_type), func_name(name) {}
    
    ~FuncCallNode() {
        for (auto arg : arguments) {
            delete arg;
        }
    }
    
    void add_argument(ExprNode* arg) {
        if (arg) arguments.push_back(arg);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
            int count = 0;
            vector<string> arg_temps;
            for (auto arg : arguments) {
                count+=1;
                string arg_temp = arg->generate_code(outcode, symbol_to_temp, temp_count, label_count);
                string temp_param = "t" + to_string(temp_count);
                outcode << "t" <<to_string(temp_count++)<<"="<<" "<< arg_temp << endl;
                outcode << "param " << temp_param << endl;
                arg_temps.push_back(arg_temp);
        }
        
        string result_temp = "t" + to_string(temp_count++);
        outcode << result_temp << " = call " << func_name <<", "<<to_string(count)<< endl;
        return result_temp;
    }
};

// Program node (root of AST)

class ProgramNode : public ASTNode {
private:
    vector<ASTNode*> units;

public:
    ~ProgramNode() {
        for (auto unit : units) {
            delete unit;
        }
    }
    
    void add_unit(ASTNode* unit) {
        if (unit) units.push_back(unit);
    }
    
    string generate_code(ofstream& outcode, map<string, string>& symbol_to_temp,
                        int& temp_count, int& label_count) const override {
        for (auto unit : units) {
            unit->generate_code(outcode, symbol_to_temp, temp_count, label_count);
        }
        return "";
    }
};

#endif // AST_H