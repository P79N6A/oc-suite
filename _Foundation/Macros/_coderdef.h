
#define encodeof_object(coder, object)      [coder encodeObject:object forKey:stringify(object)]
#define encodeof_bool(coder, value)         [coder encodeBool:[NSNumber numberWithBool:value] forKey:stringify(value)]
#define encodeof_int(coder, value)          [coder encodeInt:[NSNumber numberWithInt:value] forKey:stringify(value)]
#define encodeof_int32(coder, value)        [coder encodeInt32:[NSNumber numberWithLong:value] forKey:stringify(value)]
#define encodeof_int64(coder, value)        [coder encodeInt64:[NSNumber numberWithLongLong:value] forKey:stringify(value)]
#define encodeof_float(coder, value)        [coder encodeFloat:[NSNumber numberWithFloat:value] forKey:stringify(value)]
#define encodeof_double(coder, value)       [coder encodeDouble:[NSNumber numberWithFloat:value] forKey:stringify(value)]
#define encodeof_bytes(coder, bytesp, lenv) [coder encodeBytes:bytesp length:bytesp forKey:stringify(bytesp)]

#define decodefor_object(decoder, object)   _object_ = [_decoder_ decodeObjectForKey:stringify(_object_)]
#define decodefor_bool(_decoder_, _value_)  _value_ = [_decoder_ decodeBoolForKey:stringify(_value_)]
