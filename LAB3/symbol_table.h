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
        this->current_scope = NULL;
        this->current_scope_id = 0;
    };
    ~symbol_table();
    void enter_scope(ofstream& outlog){
        this->current_scope_id++;
        scope_table *new_scope = new scope_table(this->bucket_count, this->current_scope_id,  this->current_scope);
        this->current_scope = new_scope;
        outlog << "ScopeTable with ID " + to_string(this->current_scope_id) + " created" << endl << endl;
    };
    void exit_scope(ofstream& outlog){
        outlog << "ScopeTable with ID " + to_string(this->current_scope->get_unique_id()) + " removed" << endl << endl;
        if (current_scope != NULL) {
            scope_table *temp = this->current_scope;
            this->current_scope = current_scope->get_parent_scope();
            delete temp;
        }
    };
    bool insert(symbol_info* symbol){
        if (this->current_scope->insert_in_scope(symbol)){
            return true;
        }
        else{
            return false;
        }
    };
    symbol_info* lookup(symbol_info* symbol){
        scope_table *temp = this->current_scope;
        while (temp != NULL)
        {
            symbol_info *found_symbol = temp->lookup_in_scope(symbol);
            if (found_symbol != NULL)
            {
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        return NULL;
    };
    symbol_info* lookup(string name){
        scope_table *temp = this->current_scope;
        while (temp != NULL)
        {
            symbol_info *found_symbol = temp->lookup_in_scope(name);
            if (found_symbol != NULL)
            {
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        return NULL;
    };
    symbol_info* lookup_in_current_scope(string name){
        return this->current_scope->lookup_in_scope(name);
    };
    void print_current_scope(ofstream& outlog){ 
        if (this->current_scope != NULL) {
            this->current_scope->print_scope_table(outlog);
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