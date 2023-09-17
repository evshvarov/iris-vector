Class test.dc.vector.func Extends (%UnitTest.TestCase, dc.vector.func)
{

Method TestNorm()
{
    do $$$AssertEquals($fnumber(..norm("[1,2,3]"),,10), "3.7416573868")
    do $$$AssertEquals($fnumber(..norm("[0]"),,10), "0.0000000000")
    
    do $$$AssertEquals(..norm("[0]"), 0)
    do $$$AssertEquals(..norm("[10]"), 10)
}

Method Testl2()
{
    do $$$AssertEquals($fnumber(..l2Distance("[1,2,3]", "[9,8,7]"),,10), "10.7703296143")
    do $$$AssertEquals($fnumber(..l2DistancePy("[1,2,3]", "[9,8,7]"),,10), "10.7703296143")
}

Method Testcosine()
{
    do $$$AssertEquals($fnumber(..cosineDistance("[1,2,3]", "[9,8,7]"),,10), "0.1173410101")
    do $$$AssertEquals($fnumber(..cosineDistancePy("[1,2,3]", "[9,8,7]"),,10), "0.1173410101")
}

Method Testinner()
{
    do $$$AssertEquals(..innerProduct("[1,2,3]", "[9,8,7]"), 46)
    do $$$AssertEquals(..innerProductPy("[1,2,3]", "[9,8,7]"), 46)
}

Method Testadd()
{
    do $$$AssertEquals(..add("[1,2,3]", "[9,8,7]"), $listbuild(10,10,10))
    do $$$AssertEquals(..addPy("[1,2,3]", "[9,8,7]"), $listbuild(10,10,10))
}

Method Testsub()
{
    do $$$AssertEquals(..sub("[9,8,7]", "[3,2,1]"), $listbuild(6,6,6))
    do $$$AssertEquals(..subPy("[9,8,7]", "[3,2,1]"), $listbuild(6,6,6))
}

Method Testmul()
{
    do $$$AssertEquals(..mul("[1,2,3]", "[3,2,1]"), $listbuild(3,4,3))
    do $$$AssertEquals(..mulPy("[1,2,3]", "[3,2,1]"), $listbuild(3,4,3))
}

Method Testdiv()
{
    #; USER>write $lb(9/3)=$lb(3),$lb(3)=$lb(3.0),$lb(9/3)=$lb(3.0)
    #; 000
    #; USER>zw $lb(9/3,3.0,3)
    #; $lb(3,3,3)

    set v = ..div("[9,6,4]", "[3,2,1]")
    do $$$AssertEquals($listget(v, 1), 3)
    do $$$AssertEquals($listget(v, 2), 3)
    do $$$AssertEquals($listget(v, 3), 4)

    set v = ..divPy("[9,6,4]", "[3,2,1]")
    do $$$AssertEquals($listget(v, 1), 3)
    do $$$AssertEquals($listget(v, 2), 3)
    do $$$AssertEquals($listget(v, 3), 4)
}

}
