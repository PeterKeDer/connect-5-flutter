typedef void HandlerFunction<T>(T value);
typedef T ReturnFunction<T>();
typedef R ComputeFunction<T, R>(T value);

/// If value is of type T, returns value. Otherwise returns null
T guardType<T>(dynamic value) => value is T ? value : null;

/// If value of type T, returns value. Otherwise throws error
T guardTypeNotNull<T>(dynamic value) => guardType(value) ?? (throw 'Invalid Value');
