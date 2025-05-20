#include<bits/stdc++.h>
using namespace std;

class symbol_info
{
private:
    string name;
    string type;
    string data_type; // int, float, char, etc.
    string return_type; // for functions
    vector<string> parameter_types; // for functions
    vector<string> parameter_names; // for functions
    int no_of_parameters; // for functions
    int array_size; // for arrays

    // Write necessary attributes to store what type of symbol it is (variable/array/function)
    // Write necessary attributes to store the type/return type of the symbol (int/float/void/...)
    // Write necessary attributes to store the parameters of a function
    // Write necessary attributes to store the array size if the symbol is an array

public:
    symbol_info(string name, string type)
    {
        this->name = name;
        this->type = type;
    }
    string getname()
    {
        return this->name;
    }
    string get_type()
    {
        return this->type;
    }
    string get_data_type()
    {
        return this->data_type;
    }
    string get_return_type()
    {
        return this->return_type;
    }
    vector<string> get_parameter_types()
    {
        return this->parameter_types;
    }
    vector<string> get_parameter_names()
    {
        return this->parameter_names;
    }
    int get_no_of_parameters()
    {
        return this->no_of_parameters;
    }
    int get_array_size()
    {
        return this->array_size;
    }


    void set_name(string name)
    {
        this->name = name;
    }
    void set_type(string type)
    {
        this->type = type;
    }
    void set_data_type(string data_type)
    {
        this->data_type = data_type;
    }
    void set_return_type(string return_type)
    {
        this->return_type = return_type;
    }
    void set_parameter_types(vector<string> parameter_types)
    {
        this->parameter_types = parameter_types;
    }
    void set_parameter_names(vector<string> parameter_names)
    {
        this->parameter_names = parameter_names;
    }
    void set_no_of_parameters(int no_of_parameters)
    {
        this->no_of_parameters = no_of_parameters;
    }
    void set_array_size(int array_size)
    {
        this->array_size = array_size;
    }
    // Write necessary functions to set and get the attributes

    ~symbol_info()
    {
        // Write necessary code to deallocate memory, if necessary
    }
};