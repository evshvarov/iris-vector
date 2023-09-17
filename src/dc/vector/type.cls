Class dc.vector.type [ ClassType = datatype, ClientDataType = LIST, OdbcType = STRUCT, System = 2 ]
{

Parameter INDEXNULLMARKER = {$listbuild()};

Parameter DIMENSIONS;

Parameter JSONTYPE = "array";

ClassMethod IsValid(%val As %RawString, dimensions) As %Status [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
    do %code.WriteLine(" set vector = %val, display = $select(vector="""":vector, $listvalid(vector):""["" _ $listtostring(vector,,7) _ ""]"", 1: vector)")
    do %code.WriteLine(" if '$ListValid(vector) { quit:(($extract(vector)'=""["")||($extract(vector,*)'=""]"")) $$$ERROR($$$DTFailure,display) set vector = $listfromstring($extract(vector,2,*-1),,3) }")
    if $data(%parameter("DIMENSIONS"), dimensions),dimensions>0 {
        do %code.WriteLine(" set dimensions = " _ dimensions)
    }
    do %code.WriteLine(" if $get(dimensions)>0, $listlength(vector)'=dimensions quit $$$ERROR($$$DTFailure,display)")
    do %code.WriteLine(" for i=1:1:$listlength(vector) { return:(($listget(vector, i)="""")||($list(vector, i)'=+$list(vector, i))) $$$ERROR($$$DTFailure,display) set $list(vector, i) = +$list(vector, i)}")
    do %code.WriteLine(" quit $$$OK")
    quit $$$OK
}

ClassMethod Normalize(%val As %RawString) As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
    do %code.WriteLine(" set vector = %val")
    do %code.WriteLine(" if '$ListValid(vector) { set vector = $listfromstring($extract(vector,2,*-1),,3) }")
    do %code.WriteLine(" for i=1:1:$listlength(vector) { set $list(vector, i) = +$list(vector, i)}")
    do %code.WriteLine(" quit vector")
    quit $$$OK
}

ClassMethod LogicalToDisplay(%val As %RawString) As %String [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
	do %code.WriteLine(" quit $select($listvalid(%val): ""["" _ $listtostring(%val) _ ""]"", 1: %val)")
    quit $$$OK
}

ClassMethod DisplayToLogical(%val As %RawString) As %String [ CodeMode = objectgenerator, ServerOnly = 0 ]
{
    do %code.WriteLine(" set vector = %val, display = $select(vector="""":vector, $listvalid(vector):""["" _ $listtostring(vector,,7) _ ""]"", 1: vector)")
    do %code.WriteLine(" if '$ListValid(vector) { if (($extract(vector)'=""["")||($extract(vector,*)'=""]"")) { return %val } set vector = $listfromstring($extract(vector,2,*-1),,3) }")
    if $data(%parameter("DIMENSIONS"), dimensions),dimensions>0 {
        do %code.WriteLine(" set dimensions = " _ dimensions)
    }
    do %code.WriteLine(" if $get(dimensions)>0, $listlength(vector)'=dimensions quit %val")
    do %code.WriteLine(" for i=1:1:$listlength(vector) { if (($listget(vector, i)="""")||($list(vector, i)'=+$list(vector, i))) { return %val } set $list(vector, i) = +$list(vector, i)}")
    do %code.WriteLine(" quit vector")
    quit $$$OK
}

ClassMethod LogicalToOdbc(%val As %String = "") As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
	do %code.WriteLine(" quit $select($listvalid(%val): ""["" _ $listtostring(%val) _ ""]"", 1: %val)")
    quit $$$OK
}

ClassMethod OdbcToLogical(%val As %String = "") As %String [ CodeMode = objectgenerator, ServerOnly = 1 ]
{
    set dimensions = %parameter("DIMENSIONS")
    do %code.WriteLine(" set vector = %val, display = $select(vector="""":vector, $listvalid(vector):""["" _ $listtostring(vector,,7) _ ""]"", 1: vector)")
    do %code.WriteLine(" if '$ListValid(vector) { if (($extract(vector)'=""["")||($extract(vector,*)'=""]"")) { return %val } set vector = $listfromstring($extract(vector,2,*-1),,3) }")
    if $data(%parameter("DIMENSIONS"), dimensions),dimensions>0 {
        do %code.WriteLine(" set dimensions = " _ dimensions)
    }
    do %code.WriteLine(" if $get(dimensions)>0, $listlength(vector)'=dimensions quit %val")
    do %code.WriteLine(" for i=1:1:$listlength(vector) { if (($listget(vector, i)="""")||($list(vector, i)'=+$list(vector, i))) { return %val } set $list(vector, i) = +$list(vector, i)}")
    do %code.WriteLine(" quit vector")
    quit $$$OK
}

ClassMethod LogicalToStorage(%val As dc.vector.type) As %String
{
	quit %val
}

ClassMethod StorageToLogical(%val As %String) As dc.vector.type
{
	quit %val
}

}
