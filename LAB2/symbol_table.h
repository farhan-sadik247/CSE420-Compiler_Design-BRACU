#include "scope_table.h"

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count){
        this->bucket_count = bucket_count;
        current_scope = NULL;
        current_scope_id = 0;
    };
    ~symbol_table();
    void enter_scope(ofstream& outlog){
        current_scope_id++;
        scope_table *new_scope = new scope_table(bucket_count, current_scope_id,  current_scope);
        current_scope = new_scope;
        outlog << "ScopeTable with ID " + to_string(current_scope_id) + " created" << endl << endl;
    };
    void exit_scope(ofstream& outlog){
        if (current_scope != NULL) {
            scope_table *temp = current_scope;
            current_scope = current_scope->get_parent_scope();
            delete temp;
        }
        outlog << "ScopeTable with ID " + to_string(current_scope_id) + " removed" << endl << endl;
    };
    bool insert(symbol_info* symbol){
        if (current_scope->insert_in_scope(symbol)){
            return true;
        }
        else{
            cout << "Error: Symbol " << symbol->getname() << " already exists in the current scope." << endl;
            return false;
        }
    };
    symbol_info* lookup(symbol_info* symbol){
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            symbol_info *found_symbol = temp->lookup_in_scope(symbol);
            if (found_symbol != NULL)
            {
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        cout << "Error: Symbol " << symbol->getname() << " not found in any scope." << endl;
        return NULL;
    };
    symbol_info* lookup(string name){
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            symbol_info *found_symbol = temp->lookup_in_scope(name);
            if (found_symbol != NULL)
            {
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        cout << "Error: Symbol " << name << " not found in any scope." << endl;
        return NULL;
    };
    void print_current_scope(ofstream& outlog){ 
        if (current_scope != NULL) {
            current_scope->print_scope_table(outlog);
        } else {
            outlog << "No current scope." << endl;
        }
    };
    void print_all_scopes(ofstream& outlog){
        outlog << "################################" << endl << endl;
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }
        outlog << "################################" << endl << endl;
    };

    // you can add more methods if you need 
};

// complete the methods of symbol_table class


// void symbol_table::print_all_scopes(ofstream& outlog)
// {
//     outlog<<"################################"<<endl<<endl;
//     scope_table *temp = current_scope;
//     while (temp != NULL)
//     {
//         temp->print_scope_table(outlog);
//         temp = temp->get_parent_scope();
//     }
//     outlog<<"################################"<<endl<<endl;
// }