Class dc.vector.index Extends %FunctionalIndex [ System = 2 ]
{

Parameter M = 50;

ClassMethod gref(glb) [ Language = python ]
{
import iris
return iris.gref(glb)
}

/// Algorithm 1 
ClassMethod Insert(self, index, id, q, M, Mmax, ef, mL) [ Language = python ]
{
import math
import random

from iris_dollar_list import DollarList
if index.data([]):
    meta = DollarList.from_bytes(index.getAsBytes([])).to_list()
else:
    meta = [0,0]
    index.set([], DollarList.from_list(meta).to_bytes())
[topLayer, _] = meta
print(meta)
qlb = q
q = DollarList.from_bytes(bytes(q, 'latin-1')).to_list()
print(q)
print(self)

element = {}
layer = int(-math.log(random.uniform(0, 1)) * mL)
ep = []

for lc in range(topLayer, layer, -1):
    w = self.SearchLayer(self, index, q, ep, 1, lc, M)
    ep = w

for lc in range(layer, -1, -1):
    lm = M * 2 if lc == 0 else M
    
    w = self.SearchLayer(self, index, q, ep, ef, lc, M)
    lw = w

    neighbors = self.SelectNeighbors(self, index, lw, lm, lc)
    self.AddConnections(self, index, element, neighbors, lm, lc);

    index[lc, id] = qlb
}

/// Algorithm 2 
ClassMethod SearchLayer(self, index, q, ep, ef, lc, M) [ Language = python ]
{
from iris_dollar_list import DollarList

w = []
print('SearchLayer', [ep, ef, lc, M, q])
id = ''
while (id := index.order([lc, id])):
    v = DollarList.from_bytes(index.getAsBytes([lc, id])).to_list()
    
    #; d = self.l2_distance(self, q, v)
    d = self.cosine_distance(self, q, v)
    
    w.append({
        'distance': d,
        'vector': v,
        'id': id,
    })
    print('order', id, d)
return sorted(w, key=lambda d: d['distance'])[:ef]
}

ClassMethod "l2_distance"(self, v1, v2) [ Language = python ]
{
import math

distance = 0

for (val1, val2) in zip(v1, v2):
    diff = val1 - val2
    distance += (diff * diff)

return math.sqrt(distance)
}

ClassMethod "cosine_distance"(self, v1, v2) [ Language = python ]
{
import math

distance = norm1 = norm2 = 0

for (val1, val2) in zip(v1, v2):
    distance += (val1 * val2)
    norm1 += (val1 * val1)
    norm2 += (val2 * val2)

similarity = distance / math.sqrt(norm1 * norm2)    
similarity = 1 if similarity > 1 else -1 if similarity < -1 else similarity

return 1 - similarity
}

ClassMethod SelectNeighbors(self, index, lw, lm, lc) [ Language = python ]
{
neighbors = []
print('SelectNeighbors', [lw, lm, lc])
return neighbors
}

ClassMethod AddConnections(self, index, element, neighbors, lm, lc) [ Language = python ]
{
print('AddConnections', [neighbors, lm, lc])
for n in neighbors:
    pass
}

ClassMethod Test(cnt = 1, purge = 0)
{
    kill:purge ^tmpD,^tmpI

    set indexer = ##class(%SYS.Python).Import("iris_vector").IRISVectorIndexer("^tmpI")
    zw indexer
    #; set index = ..gref("^tmpI")    
    #; set dims = 10
    #; set M = 50
    #; set Mmax = 50
    #; set efConstruction = 1
    #; set mL = 1 / $zln(M)
    #; set self = ##class(%SYS.Python).Import("iris").cls($classname())

    #; for j=1:1:cnt {
    #;     set q = ""
    #;     for i=1:1:dims {
    #;         set q = q _ $listbuild($random(1e6))
    #;     }
    #;     set id = $increment(^tmpD)
    #;     set ^tmpD(id) = q

    #;     do ..Insert(self, index, id, q, M, Mmax, efConstruction, mL)
    #; }

    zwrite ^tmpI
}

ClassMethod InsertIndex(pID As %RawString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {
        set tGN = %objcompiledclass.Storages.GetAt(1).IndexLocation
        set tGN = $name(@tGN@(%property))
        zwrite tGN
        $$$GENERATE($char(9) _ "set i = $i(^tmp), ^tmp(i) = $lb(""Insert"", pID)")
        $$$GENERATE($char(9) _ "set vector = $get(pArg(0)) if '$listvalid(vector) throw")
        $$$GENERATE($char(9) _ "merge ^tmp(i, ""args"") = pArg")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod UpdateIndex(pID As %RawString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {
        $$$GENERATE($char(9) _ "set i = $i(^tmp), ^tmp(i) = $lb(""Update"", pID)")        
        $$$GENERATE($char(9) _ "merge ^tmp(i, ""args"") = pArg")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod DeleteIndex(pID As %RawString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {        
        $$$GENERATE($char(9) _ "set i = $i(^tmp), ^tmp(i) = $lb(""Delete"", pID)")
        $$$GENERATE($char(9) _ "merge ^tmp(i, ""args"") = pArg")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod PurgeIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {
		$$$GENERATE($char(9) _ "set i = $i(^tmp), ^tmp(i) = $lb(""Purge"")")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod SortBeginIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {
        $$$GENERATE($char(9) _ "set i = $i(^tmp), ^tmp(i) = $lb(""SortBegin"")")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod SortEndIndex(pCommit As %Integer = 1) [ CodeMode = generator, ServerOnly = 1 ]
{
	if %mode '= "method" {
        $$$GENERATE($char(9) _ "set ^tmp($i(^tmp)) = $lb(""SortEnd"")")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

ClassMethod Find(pSearch As %Binary) As %Library.Binary [ CodeMode = generator, ServerOnly = 1, SqlProc ]
{
	if %mode '= "method" {
        $$$GENERATE($char(9) _ "set ^tmp($i(^tmp)) = $lb(""Find"")")
        $$$GENERATE($char(9) _ "quit $$$OK")
	}
	quit $$$OK
}

}
