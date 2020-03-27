Class Demo.App Extends DeclarativeOS.RegistryHelper
{

/// @Declarative("examples:isEven")
ClassMethod IsEven(number As %Numeric) As %Boolean
{
    return number # 2 = 0
}

ClassMethod RunWithDeclarativeOS()
{
    set numbers = ##class(%ListOfDataTypes).%New()
    for i=1:1:4 { do numbers.Insert(i) }

    set evenNumbers = $zfilter(numbers, "examples:isEven")

    write "Even numbers: " _ $zjoin(evenNumbers, " ")
}

ClassMethod RunWithLegacyCode()
{
    set numbers = ##class(%ListOfDataTypes).%New()
    for i=1:1:4 { do numbers.Insert(i) }

    set evenNumbers = ##class(%ListOfDataTypes).%New()

    set index = ""
    for {
        set index = numbers.Next(index)
        quit:index=""
        set item = numbers.GetAt(index)
        if (item # 2 = 0) {
            do evenNumbers.Insert(item)
        }
    }

    write "Even numbers: "

    for i=1:1:evenNumbers.Count() { write evenNumbers.GetAt(i) _ " " }
}

}
