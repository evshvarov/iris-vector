Class dc.vector.init
{

ClassMethod Init() As %Status
{
    set sc = $$$OK
    new $namespace
    set ^oddPKG("DC.VECTOR","name") = "dc.vector"
    set ^oddPKG("DC.VECTOR","sqlname") = "vector"
    set $namespace = "%SYS"
    set Name = "VECTOR(%1)"
    if '##Class(Config.SqlUserDatatypes).Exists(Name) {
        set Properties("Datatype") = "dc.vector.type(DIMENSIONS=%1)"
        set sc = ##Class(Config.SqlUserDatatypes).Create(Name,.Properties)
    }
    quit sc
}

}
