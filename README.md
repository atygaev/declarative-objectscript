# Declarative ObjectScript 
[![Gitter](https://img.shields.io/static/v1?label=Vote%20for%20my%20App&message=InterSystems%20IRIS%20Contest&labelColor=%23333695&color=%2300b2a9)](https://openexchange.intersystems.com/contest/current)

## Work with collections like a boss
Declarative ObjectScript - a proof-of-concept to show how to use declarative programming on ObjectScript.

> [Declarative programming](https://en.wikipedia.org/wiki/Declarative_programming) - a style of building the structure and elements of computer programs—that expresses the logic of a computation without describing its control flow. **(c) Wikipedia**

## Demo
Just compare two variants: **RunWithDeclarativeOS** and **RunWithLegacyCode**.

```objectscript
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
```
## Play yourself in Docker:
```shell
$ docker pull docker.pkg.github.com/atygaev/declarative-objectscript/demo:latest
$ docker run --name declarative-os-demo -d docker.pkg.github.com/atygaev/declarative-objectscript/demo:latest
$ docker exec -it declarative-os-demo iris session iris
```
```objectscript
USER> zn "IRISAPP"
IRISAPP>
IRISAPP> // run legacy code
IRISAPP> do ##class(Demo.App).RunWithLegacyCode()
IRISAPP>
IRISAPP> // run DeclarativeOS code
IRISAPP> do ##class(Demo.App).RunWithDeclarativeOS()
```

## Content
- [Installation](#installation)
  - [Use ZPM](#use-zpm)
  - [Use Docker](#use-docker)
  - [Use XML](#use-xml)
- [Examples](#examples)
  - [Iterate](#iterate) (zforeach)
  - [Join](#join) ($zjoin)
  - [Filter](#filter) ($zfilter)
  - [Find](#find) ($zfind)
  - [Exist](#exists) ($zexists)
  - [Count](#count) ($zcount)
- [How It works](#how-it-works)
- [License](#mit-license) (MIT)

## Installation
### Use ZPM
You can install the DeclarativeOS by using [ZPM](https://github.com/intersystems-community/zpm)
```objectscript
ZPM: USER>install declarative-os
```

### Use Docker
```bash
$ git clone https://github.com/atygaev/declarative-objectscript
$ cd declarative-objectscript
$ docker-compose up -d
$ docker-compose exec iris iris session iris
```

### Use XML
Download the [install.declarative-os.xml](https://github.com/atygaev/declarative-objectscript/releases/download/v1.0.2/install.declarative-os.xml) from latest release.
```
https://github.com/atygaev/declarative-objectscript/releases/download/v1.0.2/install.declarative-os.xml
```

Install the project via terminal:
```objectscript
USER> set installFile = "<path to downloaded install.declarative-os.xml>"
USER> do $system.OBJ.Load(installFile)
```

## Examples
Let me show some examples.

### Iterate
Applies given action to every item in collection.
```objectscript
USER> set words = ##class(%ListOfDataTypes).%New()
USER> do words.Insert("Hello ")
USER> do words.Insert("World!")
USER>
USER> // Output collection
USER> zforeach $zbind(words, "io:print")
```
```
Hello world!
```
### Join
Joins collection items to a string by using given separator.
```objectscript
USER> set words = ##class(%ListOfDataTypes).%New()
USER> do words.Insert("Tic")
USER> do words.Insert("Tac")
USER> do words.Insert("Toe")
USER>
USER> // Concat words by using "-"
USER> write $zjoin(words, "-")
```
```
Tic-Tac-Toe
```
### Filter
Returns new collection with filtered items only.
```objectscript
USER> set numbers = ##class(%ListOfDataTypes).%New()
USER> do numbers.Insert(1)
USER> do numbers.Insert(2)
USER> do numbers.Insert(3)
USER> do numbers.Insert(4)
USER>
USER> // Filter collection to find even numbers
USER> set evenNumbers = $zfilter(numbers, "examples:isEven")
USER>
USER> // Output even numbers
USER> write "Even numbers: " _ $zjoin(evenNumbers, ", "), !
```
```
Even numbers: 2, 4
```
### Find
Finds first item which satisfies given criteria.
```objectscript
USER> set numbers = ##class(%ListOfDataTypes).%New()
USER> do numbers.Insert(4)
USER> do numbers.Insert(5)
USER> do numbers.Insert(6)
USER>
USER> // Find prime number
USER> set primeNumber = $zfind(numbers, "examples:isPrime")
USER>
USER> write "Prime number: " _ primeNumber
```
```
Prime number: 5
```
### Exists
Returns $$$YES if collection contains at least one item which satisfies the given criteria.

Otherwise, returns $$$NO.
```objectscript
USER> set numbers = ##class(%ListOfDataTypes).%New()
USER> do numbers.Insert(13)
USER> do numbers.Insert(12)
USER> do numbers.Insert(11)
USER> do numbers.Insert(10)
USER>
USER> // Check whether collection contains at least one palindromic number.
USER> set hasPalindromicNumbers = $zexists(numbers, "examples:isPalindromic")
USER>
USER> write "Collection has palindromic numbers? " _ $case(hasPalindromicNumbers, 1:"YES", 0:"NO")
```
```
Collection has palindromic numbers? YES
```

### Count
Counts items which satisfy the given criteria.
```objectscript
USER> set numbers = ##class(%ListOfDataTypes).%New()
USER> do numbers.Insert(2)
USER> do numbers.Insert(3)
USER> do numbers.Insert(4)
USER> do numbers.Insert(5)
USER>
USER> // Counts prime numbers in given collection of numbers.
USER> set primeNumbersCount = $zcount(numbers, "examples:isPrime")
USER>
USER> write "Count of prime numbers: " _ primeNumbersCount
```
```
Count of prime numbers: 3
```

## How it works
In two words: call [$classmethod](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_fclassmethod).

But $classmethod requires class name and method name.

And it looks really long and weird. So I invented aliases.

Alias is a string identifier for pair of Class and ClassMethod.

```objectscript
USER> // instead of this
USER> set evenNumbers = $zmap(numbers, "Test.DeclarativeOS.MathDeclaratives", "isEven")
USER>
USER> // using alias
USER> set evenNumbers = $zmap(numbers, "math:isEven")
```

### How define own declaratives
You can define your own declaratives.

Just follow 3 steps:
- Extend from DeclarativeOS.RegistryHelper;
- Implement class method;
- Mark the method.

### Step 1. Extends from DeclarativeOS.RegistryHelper
```objectscript
Class Demo.MathDeclaratives extens DeclarativeOS.RegistryHelper
{
}
```

### Step 2. Implement class method
```objectscript
Class Demo.MathDeclaratives extens DeclarativeOS.RegistryHelper
{

ClassMethod sqrt(value As %Numeric)
{
    return $zsqr(value)
}

ClassMethod square(value As %Numeric)
{
    return $zpower(value, 2)
}

}
```

### Step 3. Mark the method
```objectscript
Class Demo.MathDeclaratives extens DeclarativeOS.RegistryHelper
{

/// @Declarative("math:sqrt")
ClassMethod sqrt(value As %Numeric)
{
    return $zsqr(value)
}

/// @Declarative("math:square")
ClassMethod square(value As %Numeric)
{
    return $zpower(value, 2)
}

}
```

### Step 4. Try it
```objectscript
s numbers = ##class(%ListOfDataTypes).%New()
d numbers.Insert(4)
d numbers.Insert(9)

w "Sqrt every number: " _ $zjoin($zmap(numbers, "math:sqrt"), ", "), !
w "Square every number: " _ $zjoin($zmap(numbers, "math:square"), ", "), !
```
```
Sqrt every number: 2 3
Square every number: 16 81
```

# Contribution
Any contribution is really welcome.

# MIT License
Copyright (c) 2017 InterSystems Developer Community

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
