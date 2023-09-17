Class test.dc.vector.type Extends (%UnitTest.TestCase, dc.vector.type)
{

Method TestIsValid()
{
    do $$$AssertStatusOK(..IsValid("[1,2,3]"))
    do $$$AssertStatusOK(..IsValid("[1,2,3]", 3))

    do $$$AssertStatusOK(..IsValid($listbuild(1,2,3)))
    do $$$AssertStatusOK(..IsValid($listbuild(1,2,3), 3))

    do $$$AssertStatusNotOK(..IsValid("test"))

    do $$$AssertStatusNotOK(..IsValid($listbuild(1,2,3), 4))
    do $$$AssertStatusNotOK(..IsValid($listbuild(1,2,3), 2))
}

Method TestInTable() [ PublicList = val ]
{
    set sc = $$$OK
    try {
        &sql(drop table if exists test.items )
        &sql(create table test.items (embedding vector(3)))
        zw %msg
        quit:'$$$AssertEquals(SQLCODE, 0, "Create test table")
        set storage = ##class(%Dictionary.CompiledClass).%OpenId("test.items").Storages.GetAt(1)
        set dataLocation = storage.DataLocation
        set indexLocation = storage.IndexLocation
        
        set rs = ##class(%SQL.Statement).%ExecDirect(, "insert into test.items (embedding) values ('[1,2,3]')")
        do $$$AssertEquals(rs.%SQLCODE, 0, "Insert value")
        do $$$AssertEquals(rs.%ROWID, 1, "check inserted id")
        do $$$AssertEquals($listget(@dataLocation@(rs.%ROWID)),$listbuild(1,2,3), "Check stored value")

        set rs = ##class(%SQL.Statement).%ExecDirect(, "insert into test.items (embedding) values (?)", $listbuild(2,3,4))
        do $$$AssertEquals(rs.%SQLCODE, 0, "Insert value")
        do $$$AssertEquals(rs.%ROWID, 2, "check inserted id")
        do $$$AssertEquals($listget(@dataLocation@(rs.%ROWID)),$listbuild(2,3,4), "Check stored value")

        set rs = ##class(%SQL.Statement).%ExecDirect(, "insert into test.items (embedding) values (?)", $listbuild(2,3,4,5))
        do $$$AssertNotEquals(rs.%SQLCODE, 0, "Insert invalid value")
        do $$$AssertTrue(rs.%Message [ "failed validation")

        &sql(insert into test.items (embedding) values ('[1,2,3]'))
        do $$$AssertEquals(SQLCODE, 0, "Insert value")
        do $$$AssertEquals(%ROWID, 3, "check inserted id")
        do $$$AssertEquals($listget(@dataLocation@(%ROWID)),$listbuild(1,2,3), "Check stored value")

        set val = $listbuild(2,3,4)
        &sql(insert into test.items (embedding) values (:val))
        do $$$AssertEquals(SQLCODE, 0, "Insert value")
        do $$$AssertEquals(%ROWID, 4, "check inserted id")
        do $$$AssertEquals($listget(@dataLocation@(%ROWID)),$listbuild(2,3,4), "Check stored value")

        &sql(insert into test.items (embedding) values ('[1,2,3,4]'))
        do $$$AssertNotEquals(SQLCODE, 0, "Insert invalid value")
        do $$$AssertTrue(%msg [ "failed validation")

        set rs = ##class(%SQL.Statement).%ExecDirect(,"select embedding from test.items")
        set vals = ""
        while rs.%Next() {
            set vals = vals _ $listbuild(rs.embedding)
        }
        set expect = $listbuild(
            $lb(1,2,3), 
            $lb(2,3,4), 
            $lb(1,2,3), 
            $lb(2,3,4)
        )
        do $$$AssertEquals(vals, expect)
    } catch ex {
        do $$$AssertStatusOK(ex.AsStatus())
    }
    &sql(drop table if exists test.items )
    quit sc
}

}
