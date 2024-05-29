# How to write a wrapper for a python class using PythonCall

- Define a struct with the same name as the python class
- The struct holds a PythonCall.Core.Py object, which is a refference to the python instance of this class
- It also contains properties with the same names as the attributes of the python class, as type Nothing (solely for autocompletion)
- Write constructors analog to the python class constructors, which just parse the arguments to the python instructor (multiple dispatch makes this easy)

- Overwrite the show function for the struct to print the python class instance stored in it instead

- Overwrite the getproperty() function for the struct to get the properties for the python class instance stored in it instead
- One probably wants to convert the types to julia types here, so the julia types for each attribute of the python class should be stored in a constant Dict{Symbol, Type}

- Overwrite the setproperty!() function for the struct to set the properties for the python class instance stored in it instead
- A check for the argument type against the above defined attribute type makes sense here (though any type can be passed in theory since python...)

- Define type conversion rules for custom python classes that have their own wrapper structs.



