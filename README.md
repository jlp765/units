# units
Units is a simple library of unit conversion (Mass, Volume, Length, ...)

Values are entered according to the unit type, and behind the scenes
are converted to a base unit value, then can be displayed and manipulated
by helper procs that are named after the unity types.

base units are 
- gram (Mass)
- litre (Volume)
- meter (Length)
- Kelvin (Temperature)
- Newton (Energy)
- degree (Angles)
- second (Time)

For each unit category, the values are converted to/from the base unit.
Procedures are defined for each unit to 
- convert SI multipliers to the base unit  e.g. ``var m = kilogram(2.0)``  means ``m=2000.0`` which is grams)
- convert non-SI units to the base unit  e.g. ``var m = pound(1.0)``

 includes: ``deka``, ``hecto``, ``kilo``, ``mega``, ``giga``, ``tera``, ``peta``, ``deci``, ``centi``, ``milli``, ``micro``, ``nano``, ``pico``, ``femto``, ``atto``
- convert base unit to a number (proc has aq plural plural name) e.g.  ``echo m.pounds(), m.ounces()``

 Note: where US and Imperial differ you will need to use gallonUS and gallonUK, pintUS, pintUK, etc
- provide the unit abbreviation  e.g.  kg, l, N, lb, in, s, .... 

 e.g., poundUnit(), inchUnit(), perchUnit(), slugUnit(), hectopascalUnit(), ....
- numeric operators (+, -, \*, /) are also borrowed so that units can be combined using mathematical operations

Using the kilogram Mass example:
- the singlular name ``kilogram()`` converts from ``kg`` to ``g``
- the plural name ``kilograms()`` converts from ``g`` to ``kg``
- ``kilogramUnit()`` returns ``"kg"``

So use the singular name to define a variable value, and use the plural name
to convert or retrieve a variable as a different unit

#### Examples
```
import units
var m = kilogram(2.0)
echo m.kilograms, " kg is ",m.grams, gramUnit()
var p = pound(1)
echo p.kilograms, " kg is ", p.pounds, poundUnit(), " and ", p.ounces, ounceUnit()
var v = gallonUS(5)
echo v.litres, " Ltr is ", v.pintUSs, pintUSUnit(), " and ", v.quartUSs,
    quartUSUnit(), " and ", v.gallonUSs, gallonUSUnit()
var lgth = yard(1)
echo lgth.meters," meters is ", lgth.yards, " yards and ", lgth.fathoms, " fathoms"
var t1 = celsius(100.0)
echo t1.celsius," ",celsiusUnit()," is ", t1.fahrenheit()," ", fahrenheitUnit()
t1 = fahrenheit(74)
echo t1.celsius," ",celsiusUnit()," is ", t1.fahrenheit()," ", fahrenheitUnit()
t1 = reaumur(80)
echo t1.celsius," ",celsiusUnit()," is ", t1.reaumur()," ", reaumurUnit()
t1 = reaumur(0)
echo t1.celsius," ",celsiusUnit()," is ", t1.reaumur()," ", reaumurUnit()
```

