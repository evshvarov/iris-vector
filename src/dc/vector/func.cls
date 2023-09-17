Class dc.vector.func
{

ClassMethod NormalizeAndCheck(ByRef v1, ByRef v2, Output dims = 0) [ Internal ]
{
    set v1 = ##class(dc.vector.type).Normalize($get(v1))
    set dims = $listlength(v1)    

    if $data(v2) {
        set v2 = ##class(dc.vector.type).Normalize(v2)
        set dims2 = $listlength(v2)

        if v1 = "" {
            set dims = dims2
            set v1 = ""
            for i=1:1:dims { set v1 = v1 _ $listbuild(0) }
        }

        if dims '= dims2 {
            #; throw ##class(%Exception.SQL).CreateFromSQLCODE(400, "different vector dimensions: " _ dims _ " '= " _ dims2)
        }
    }
}

ClassMethod normpy(val As %String) As %Decimal(SCALE=10) [ Language = python, SqlName = norm_py, SqlProc ]
{
    import iris 
    import math
    
    vector_type = iris.cls('dc.vector.type')
    vector = iris.cls('%SYS.Python').ToList(vector_type.Normalize(val))
    
    return math.sqrt(sum([v * v for v in vector]))
}

ClassMethod norm(v1 As %String) As %Decimal(SCALE=10) [ SqlName = norm, SqlProc ]
{
    do ..NormalizeAndCheck(.v1, , .dims)
    set result = 0
    for i=1:1:dims {
        set val = $list(v1, i)
        set result = result + (val * val)
    }
    return $zsqr(result)
}

ClassMethod l2Distance(v1 As dc.vector.type, v2 As dc.vector.type) As %Decimal(SCALE=10) [ SqlName = l2_distance, SqlProc ]
{
    do ..NormalizeAndCheck(.v1, .v2, .dims)

    set distance = 0
    for i=1:1:dims {
        set diff = $list(v1, i) - $list(v2, i)
        set distance = distance + (diff * diff)
    }

    quit $zsqr(distance)
}

ClassMethod cosineDistance(v1 As dc.vector.type, v2 As dc.vector.type) As %Decimal(SCALE=10) [ SqlName = cosine_distance, SqlProc ]
{
    do ..NormalizeAndCheck(.v1, .v2, .dims)

    set (distance, norm1, norm2, similarity) = 0

    for i=1:1:dims {
        set val1 = $list(v1, i)
        set val2 = $list(v2, i)

        set distance = distance + (val1 * val2)
        set norm1 = norm1 + (val1 * val1)
        set norm2 = norm2 + (val2 * val2)
    }

    set similarity = distance / $zsqr(norm1 * norm2)    
    set similarity = $select(similarity > 1: 1, similarity < -1: -1, 1: similarity)
    quit 1 - similarity
}

ClassMethod innerProduct(v1 As dc.vector.type, v2 As dc.vector.type) As %Decimal(SCALE=10) [ SqlName = inner_product, SqlProc ]
{
    do ..NormalizeAndCheck(.v1, .v2, .dims)

    set distance = 0

    for i=1:1:dims {
        set val1 = $list(v1, i)
        set val2 = $list(v2, i)

        set distance = distance + (val1 * val2)
    }

    quit distance
}

/// CREATE or REPLACE AGGREGATE vector_sum(arg vector) ITERATE WITH vector.vector_add
/// 
/// NOTE: does work as AGGREGATE at all
ClassMethod add(v1 As dc.vector.type, v2 As dc.vector.type) As dc.vector.type [ SqlName = vector_add, SqlProc ]
{
    do ..NormalizeAndCheck(.v1, .v2, .dims)

    for i=1:1:dims {
        set $list(v1, i) = $list(v1, i) + $list(v2, i)
    }

    quit v1
}

}
