#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        int hash_value = 0;
        for (char c : name)
        {
            hash_value += c;
        }
        return hash_value % bucket_count;
    }

public:
    scope_table(){
        this->bucket_count = 0;
        this->unique_id = 0;
        this->parent_scope = NULL;
    };
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope){
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;  
        this->parent_scope = parent_scope;
        this->table.resize(bucket_count);
    };
    scope_table *get_parent_scope(){
        return this->parent_scope;
    };
    int get_unique_id(){
        return this -> unique_id;
    };
    symbol_info *lookup_in_scope(symbol_info* symbol);
    bool insert_in_scope(symbol_info* symbol){
        int index = hash_function(symbol->getname());
        for (auto it = this -> table[index].begin(); it != this -> table[index].end(); ++it)
        {
            if ((*it)->getname() == symbol->getname())
            {
                return false; // symbol already exists
            }
        }
        this->table[index].push_back(symbol);
        return true;
    };
    symbol_info *lookup_in_scope(string name){
        int index = hash_function(name);
        for (auto it = this->table[index].begin(); it != this->table[index].end(); ++it)
        {
            if ((*it)->getname() == name)
            {
                return *it; // symbol found
            }
        }
        return NULL; // symbol not found
    };
    bool delete_from_scope(symbol_info* symbol){
        int index = hash_function(symbol->getname());
        for (auto it = this->table[index].begin(); it != this->table[index].end(); ++it)
        {
            if ((*it)->getname() == symbol->getname())
            {
                this->table[index].erase(it);
                return true; // symbol deleted
            }
        }
        return false; // symbol not found
    };
    void print_scope_table(ofstream& outlog){
        outlog << "ScopeTable # " + to_string(this->unique_id) << endl;
        for (int i = 0; i < this->bucket_count; i++){
            for (auto it = this->table[i].begin(); it != this->table[i].end(); ++it){
                outlog << "Slot " + to_string(i) + " : " << endl << "< " + (*it)->getname() + " : ID >" << endl;
                outlog << (*it)->get_type() << endl;
                if ((*it)->get_type() == "func_def"){
                    outlog << "Return Type: " << (*it)->get_return_type() << endl << "Number of Parameters: " << (*it)->get_no_of_parameters() << endl << "Parameter Details: ";
                    for (int j = 0; j < (*it)->get_no_of_parameters(); j++){
                        outlog << (*it)->get_parameter_types()[j] + " " + (*it)->get_parameter_names()[j] + ", ";
                    }
                    outlog << endl << endl;
                }
                else if ((*it)->get_type() == "var"){
                    outlog << "Type: " << (*it)->get_data_type() << endl << endl;
                }
                else if ((*it)->get_type() == "array"){
                    outlog << "Type: " << (*it)->get_data_type() << endl << "Size: " << (*it)->get_array_size() << endl<<endl;
                }
            }
        }
    };
    ~scope_table(){
        for (int i = 0; i < this->bucket_count; i++)
        {
            for (auto it = this->table[i].begin(); it != this->table[i].end(); ++it)
            {
                delete *it; // delete symbol_info objects
            }
        }
        table.clear(); // clear the table
    };

    // you can add more methods if you need
};

// complete the methods of scope_table class
// void scope_table::print_scope_table(ofstream& outlog)
// {
//     outlog << "ScopeTable # "+ to_string(unique_id) << endl;

//     //iterate through the current scope table and print the symbols and all relevant information
// }