function create_test_tables()

load patients

patients = table(Age,Gender,Height,Weight,Smoker,...
    'RowNames',LastName);

putvar(patients);

ugly_data = readtable(which('ugly_data.csv'));

putvar(ugly_data);