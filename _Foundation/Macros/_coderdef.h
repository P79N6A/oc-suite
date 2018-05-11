
/**
 *  为了避免冲突，则加上前缀下划线
 
 *  推荐度：不高，@fallenink 请改进
 */
#define _encode_object(coder, object)      [coder encodeObject:object forKey:stringify(object)]
#define _encode_bool(coder, value)         [coder encodeBool:[NSNumber numberWithBool:value] forKey:stringify(value)]
#define _encode_int(coder, value)          [coder encodeInt:[NSNumber numberWithInt:value] forKey:stringify(value)]
#define _encode_int32(coder, value)        [coder encodeInt32:[NSNumber numberWithLong:value] forKey:stringify(value)]
#define _encode_int64(coder, value)        [coder encodeInt64:[NSNumber numberWithLongLong:value] forKey:stringify(value)]
#define _encode_float(coder, value)        [coder encodeFloat:[NSNumber numberWithFloat:value] forKey:stringify(value)]
#define _encode_double(coder, value)       [coder encodeDouble:[NSNumber numberWithFloat:value] forKey:stringify(value)]
#define _encode_bytes(coder, bytesp, lenv) [coder encodeBytes:bytesp length:bytesp forKey:stringify(bytesp)]

#define _decode_object(_decoder_, _object_) _object_ = [_decoder_ decodeObjectForKey:stringify(_object_)]
#define _decode_bool(_decoder_, _value_)    _value_ = [_decoder_ decodeBoolForKey:stringify(_value_)]
