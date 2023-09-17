Class test.dc.vector.func Extends (%UnitTest.TestCase, dc.vector.func)
{

Method TestNorm()
{
    do $$$AssertEquals($fnumber(..norm("[1,2,3]"),,10), "3.7416573868")
    do $$$AssertEquals($fnumber(..norm("[0]"),,10), "0.0000000000")
    do $$$AssertEquals(..norm("[0]"), 0)
    do $$$AssertEquals(..norm("[10]"), 10)
}

}
