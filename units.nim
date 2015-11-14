## Units - a simple library of unit conversion.
##
## Values are entered according to the unit type, and behind the scenes
## are converted to a base unit value, then can be displayed and manipulated
## by helper procs that are named after the unity types.
##
## base units are 
## - gram (Mass)
## - litre (Volume)
## - meter (Length)
## - Kelvin (Temperature)
## - Newton (Energy)
## - degree (Angles)
## - second (Time)
##
## For each unit category, the values are converted to/from the base unit.
## Procedures are defined for each unit to 
## - convert SI multipliers to the base unit  e.g. ``var m = kilogram(2.0)``  means ``m=2000.0`` which is grams)
## - convert non-SI units to the base unit  e.g. ``var m = pound(1.0)``
##  includes: ``deka``, ``hecto``, ``kilo``, ``mega``, ``giga``, ``tera``, ``peta``, ``deci``, ``centi``, ``milli``, ``micro``, ``nano``, ``pico``, ``femto``, ``atto``
## - convert base unit to a number (proc has aq plural plural name) e.g.  ``echo m.pounds(), m.ounces()``
## - provide the unit abbreviation  e.g.  kg, l, N, lb, in, s, .... 
##  e.g., poundUnit(), inchUnit(), perchUnit(), slugUnit(), hectopascalUnit(), ....
## - numeric operators (+, -, \*, /) are also borrowed so that units can be combined using mathematical operations
##
## Using the kilogram Mass example:
## - the singlular name ``kilogram()`` converts from ``kg`` to ``g``
## - the plural name ``kilograms()`` converts from ``g`` to ``kg``
## - ``kilogramUnit()`` returns ``"kg"``
##
## So use the singular name to define a variable value, and use the plural name
## to convert or retrieve a variable as a different unit
##
## .. code-block:: Nim
##
##   var m = kilogram(2.0)
##   echo m.kilograms, kiloUnit(), " is ", m.grams, " ", gramUnit()
##   echo m.kilograms, kiloUnit(), " is ", m.pounds, " ", poundUnit()
## Further example code is also in the test assertion code at the end of the `units.nim` file

import macros, strutils, typetraits
from math import PI

{.push hints:off.}  # avoid hints about [XDeclaredButNotUsed]
const
  # MASS
  PoundToGram = 453.59237
  PoundMetricToGram = 500.0
  OunceToGram = 1.0 / 16.0 * PoundToGram
  HundredweightToGram = 100.0 * PoundToGram
  SlugToGram = 14593.9029372
  TonToGram = 907184.7399999
  GrainToGram = 0.06479891000017
  ScrupleToGram = 20.0 * GrainToGram
  StoneToGram = 12.5 * PoundToGram
  CaratToGram = 0.2
  QuintalToGram = 1.0e5   # 100 kg
  # VOLUME
  QuartUSToLitre = 0.9463529
  QuartUKToLitre = 1.1365225
  PintUSToLitre = QuartUSToLitre / 2.0
  PintUKToLitre = QuartUKToLitre / 2.0
  CupToLitre = 0.25
  CupUSToLitre = QuartUSToLitre / 4.0
  CupUKToLitre = QuartUKToLitre / 4.0
  FlOunceUSToLitre = QuartUSToLitre / 32.0
  FlOunceUKToLitre = QuartUKToLitre / 40.0
  GillUSToLitre = QuartUSToLitre / 8.0
  GillUKToLitre = QuartUKToLitre / 8.0
  MinimUSToLitre = QuartUSToLitre / 15360.0
  MinimUKToLitre = QuartUKToLitre / 19200.0
  TablespoonUSToLitre = PintUSToLitre / 32.0
  TablespoonUKToLitre = PintUKToLitre / 32.0
  TablespoonToLitre = 0.015
  TeaspoonUSToLitre = FlOunceUSToLitre / 6.0
  TeaspoonUKToLitre = FlOunceUKToLitre / 4.8
  TeaspoonToLitre = 0.015
  GallonUSToLitre = QuartUSToLitre * 4.0
  GallonUKToLitre = QuartUKToLitre * 4.0
  CcToLitre = 1.0e-3
  DropToLitre = 0.05 * CcToLitre
  BarrelUSToLitre = 31.5 * GallonUSToLitre
  BarrelUKToLitre = 31.5 * GallonUKToLitre
  HogsheadToLitre = 63.0 * GallonUSToLitre
  TunToLitre = 4.0 * HogsheadToLitre
  DramToLitre = QuartUSToLitre / 256.0

  # Length
  InchToMeter = 25.4 / 1000.0
  MilToMeter = InchToMeter / 1000.0
  FootToMeter = 12.0 * InchToMeter
  YardToMeter = 36.0 * InchToMeter
  KiloyardToMeter = 1000.0 * YardToMeter
  ChainToMeter = 22.0 * YardToMeter
  AngstromToMeter = 1.0e-10
  FathomToMeter = 2.0 * YardToMeter
  MileToMeter = 1760 * YardToMeter
  LeagueToMeter = 3.0 * MileToMeter
  NautmileToMeter = 1.1507794480235 * MileToMeter
  NautleagueToMeter = 3.0 * NautmileToMeter
  PointToMeter = 0.013888888888888 * InchToMeter
  TwipToMeter = PointToMeter / 20.0
  PicaToMeter = 12.0 * PointToMeter
  HandToMeter = 4.0 * InchToMeter
  FingerToMeter = 4.5 * InchToMeter
  NailToMeter = FingerToMeter / 2.0
  SpanToMeter = 9.0 * InchToMeter
  BarleycornToMeter = InchToMeter / 3.0
  LinkToMeter = ChainToMeter / 100.0
  FurlongToMeter = 10.0 * ChainToMeter
  ReedToMeter = 108.0 * InchToMeter
  CaliberToMeter = InchToMeter / 100.0
  CubitToMeter = 18.0 * InchToMeter
  EllToMeter = 45.0 * InchToMeter
  PoleToMeter = 198.0 * InchToMeter
  PerchToMeter = 198.0 * InchToMeter
  RodToMeter = 198.0 * InchToMeter
  RopeToMeter = 240.0 * InchToMeter
  ArpentToMeter = 58.5216
  AstrounitToMeter = 149597870691.0
  LightminuteToMeter = 17987547480.0
  LightsecondToMeter = LightminuteToMeter / 60.0
  LightdayToMeter = 60.0 * 24.0 * LightminuteToMeter
  LightyrToMeter = 365.25 * LightdayToMeter
  ParsecToMeter = 3.08567758128e+16
  CableToMeter = 185.2
  PixelToMeter = 0.01041653543307 * InchToMeter
  # TEMPERATURE
  # (is defined in procs)
  #
  # ANGLE
  RadianToDegree = 180.0 / PI
  GradToDegree = 9.0/10.0
  GonToDegree = GradToDegree
  ArcminuteToDegree = 1.0 / 60.0
  ArcSecondToDegree = ArcminuteToDegree / 60.0
  ArcsignToDegree = 30.0
  AngularmilToDegree = 0.05625
  RevolutionToDegree = 360.0
  CircleToDegree = RevolutionToDegree
  TurnToDegree = RevolutionToDegree
  QuadrantToDegree = 90.0
  RightangeleToDegree = QuadrantToDegree
  SextantToDegree = 60.0
  # TIME
  ShakeToSecond = 1.0e-8
  MinuteToSecond = 60.0
  HourToSecond = 60.0 * MinuteToSecond
  DayToSecond = 24.0 * HourToSecond
  WeekToSecond = 7.0 * DayToSecond
  FortnightToSecond = 2.0 * WeekToSecond
  YearToSecond = 365.0 * DayToSecond
  DecadeToSecond = 10.0 * YearToSecond
  CenturyToSecond = 100.0 * YearToSecond
  MilleniumToSecond = 1000.0 * YearToSecond
  SeptennialToSecond = 7.0 * YearToSecond
  OctennialToSecond = 8.0 * YearToSecond
  NovennialToSecond = 9.0 * YearToSecond
  QuindecennialToSecond = 15.0 * YearToSecond
  QuinquennialToSecond = 5.0 * YearToSecond
  YearjulianToSecond = 365.25 * DayToSecond
  YearleapToSecond = 366 * DayToSecond
  YeartropicalToSecond = 31556930.0
  YearanomalisticToSecond = 365.259636 * DayToSecond
  MonthToSecond = YearToSecond / 12.0
  MonthjulianToSecond = YearjulianToSecond / 12.0
  MonthgregorianToSecond = 365.2425 * DayToSecond
  MonthsynodicToSecond = 2551443.84
  MonthdraconicToSecond = 27.21222 * DayToSecond
  YearsiderealToSecond = 365.25636 * DayToSecond
  MonthsiderealToSeconds = YearsiderealToSecond / 13.36823970433
  DaysiderealToSecond = YearsiderealToSecond / 366.2564014777
  HoursiderealToSecond = DaysiderealToSecond / 24.0
  MinutesiderealToSecond = HoursiderealToSecond / 60.0
  SecondsiderealToSecond = MinutesiderealToSecond / 60.0

  # FORCE
  DyneToNewton = 1.0e-5
  # ENERGY
  ErgToJoule = 1.0e7
 
{.pop.}

type
  gram* = distinct float
  meter* = distinct float
  litre* = distinct float
  kelvin* = distinct float
  newton* = distinct float
  joule* = distinct float
  degree* = distinct float
  second* = distinct float

template additive(typ: typedesc): stmt =
  proc `+` *(x, y: typ): typ {.borrow.}
  proc `-` *(x, y: typ): typ {.borrow.}

  # unary operators:
  proc `+` *(x: typ): typ {.borrow.}
  proc `-` *(x: typ): typ {.borrow.}

template multiplicative(typ, base: typedesc): stmt =
  proc `*` *(x: typ, y: base): typ {.borrow.}
  proc `*` *(x: base, y: typ): typ {.borrow.}
  proc `/` *(x: typ, y: base): typ {.borrow.}
  proc `/` *(x: base, y: typ): typ {.borrow.}
  #proc `mod` *(x: typ, y: base): typ {.borrow.}

template comparable(typ, base: typedesc): stmt =
  proc `<` * (x, y: typ): bool {.borrow.}
  proc `<=` * (x, y: typ): bool {.borrow.}
  proc `>` * (x, y: typ): bool = base(x) > base(y)
  proc `>=` * (x, y: typ): bool = base(x) >= base(y)
  proc `==` * (x, y: typ): bool {.borrow.}
  proc `!=` * (x, y: typ): bool = base(x) != base(y)

template secondOrderRatio(typ1, typ2, resTyp: typedesc): stmt =
  proc `/` *(x: typ1, y: typ2): resTyp {.borrow.}
  proc `/` *(x: typ1, y: resTyp): typ2 {.borrow.}
  proc `*` *(x: resTyp, y: resTyp): resTyp {.borrow.}
  proc `*` *(x: resTyp, y: typ2): typ1 {.borrow.}
  proc `*` *(x: typ2, y: resTyp): typ1 {.borrow.}

template secondOrderSq(typ, resTyp, base: typedesc): stmt =
  proc `/` *(x: typ, y: typ): base {.borrow.}
  proc `/` *(x: resTyp, y: typ): typ {.borrow.}
  proc `*` *(x: typ, y: typ): resTyp {.borrow.}
  #proc `*` *(x: typ, y: base): typ {.borrow.}
  #proc `*` *(x: base, y: typ): typ {.borrow.}
  #proc `*` *(x: resTyp, y: base): resTyp {.borrow.}
  #proc `*` *(x: base, y: resTyp): resTyp {.borrow.}

template makeConvertProcs(baseName, name, factor: expr, typ: typedesc): stmt =
  ## conversionMetricProcs(kilo, name, 1000.0)   # where name is gram
  ## produces conversion procs kilogram() for defining values
  ## and kilo() for displaying/converting from grams to kilograms
  # defining values
  proc `baseName name`* (x: typ): name {.inline.} = cast[name](x.float * factor.float)
  proc `baseName name`* (x: name): name {.inline.} = cast[name](x * typ(factor))
  # printing values
  proc `baseName name s`* (x: typ): typ {.inline.} = x.float / factor.float
  proc `baseName name s`* (x: name): typ {.inline.} = cast[typ](x / typ(factor))

template makeUnitProcs(baseName, name, factor: expr, typ: typedesc, u: string): stmt =
  ## conversionMetricProcs(kilo, name, 1000.0)   # where name is gram
  ## produces conversion procs kilogram() for defining values
  ## and kilo() for displaying/converting from grams to kilograms
  #
  # defining values
  proc `baseName`* (x: typ): name {.inline.} = cast[name](x.float * factor.float)
  proc `baseName`* (x: name): name {.inline.} = cast[name](x * typ(factor))
  # printing values
  proc `baseName s`* (x: typ): typ {.inline.} = x.float / factor.float
  proc `baseName s`* (x: name): typ {.inline.} = cast[typ](x / typ(factor))
  # proc for displaying unit
  proc `baseName Unit`* (): string {.inline.} = (result = u)

template multipliersMetric(name: expr, typ: typedesc): stmt =
  # make kilogram, kilolitre, ... where name is gram or litre
  makeConvertProcs(deka, name, 10.0, typ)
  makeConvertProcs(hecto, name, 100.0, typ)
  makeConvertProcs(kilo, name, 1000.0, typ)
  makeConvertProcs(mega, name, 1.0e6, typ)
  makeConvertProcs(giga, name, 1.0e9, typ)
  makeConvertProcs(tera, name, 1.0e12, typ)
  makeConvertProcs(peta, name, 1.0e15, typ)

  makeConvertProcs(deci, name, 0.1, typ)
  makeConvertProcs(centi, name, 0.01, typ)
  makeConvertProcs(milli, name, 1.0e-3, typ)
  makeConvertProcs(micro, name, 1.0e-6, typ)
  makeConvertProcs(nano, name, 1.0e-9, typ)
  makeConvertProcs(pico, name, 1.0e-12, typ)
  makeConvertProcs(femto, name, 1.0e-15, typ)
  makeConvertProcs(atto, name, 1.0e-18, typ)

## forward defs for doc purposes
proc gramUnit*(): string
  ## display the unit string for gram (`g`)
proc litreUnit*(): string
  ## display the unit string for litre (`l`)
proc meterUnit*(): string
  ## display the unit string for meter (`m`)
proc jouleUnit*(): string
  ## display the unit string for joule (`J`)
proc kelvinUnit*(): string
  ## display the unit string for kelvin (`K`)
proc newtonUnit*(): string
  ## display the unit string for newton (`N`)
proc degreeUnit*(): string
  ## display the unit string for (angular) degree (`deg`)
proc secondUnit*(): string
  ## display the unit string for (time) second (`s`)
  
template defineUnitType(typ, base: expr, u: string): stmt =
  additive(typ)
  multiplicative(typ, base)
  comparable(typ, base)
  multipliersMetric(typ, base)
  proc `typ s`* (x: typ): typ = x
  proc `$`*(x: typ): string = $base(x)
  proc `typ Unit`*(): string = u

defineUnitType(gram, float, "g")
## .. code-block:: Nim
##  proc gram* (x: float): gram
##  proc grams* (x: gram): float
##  proc gramUnit* (x: gram): string
defineUnitType(litre, float, "l")
defineUnitType(meter, float, "m")
defineUnitType(kelvin, float, "K")
defineUnitType(newton, float, "N")
defineUnitType(joule, float, "J")
defineUnitType(degree, float, "deg")
defineUnitType(second, float, "s")

# -- MASS --
makeUnitProcs(pound, gram, PoundToGram, float, "lb")
makeUnitProcs(poundMetric, gram, PoundMetricToGram, float, "lb")
makeUnitProcs(ounce, gram, OunceToGram, float, "oz")
makeUnitProcs(hundredweight, gram, HundredweightToGram, float, "hw")
makeUnitProcs(slug, gram, SlugToGram, float, "slug")
makeUnitProcs(ton, gram, TonToGram, float, "t")
makeUnitProcs(grain, gram, GrainToGram, float, "gr")
makeUnitProcs(scruple, gram, ScrupleToGram, float, "scruple")
makeUnitProcs(stone, gram, StoneToGram, float, "st")
makeUnitProcs(carat, gram, CaratToGram, float, "c")
makeUnitProcs(quintal, gram, QuintalToGram, float, "quintal")
# -- VOLUME --
makeUnitProcs(quartUS, litre, QuartUSToLitre, float, "qt (US)")
makeUnitProcs(quartUK, litre, QuartUKToLitre, float, "qt (UK)")
makeUnitProcs(pintUS, litre, PintUSToLitre, float, "pt (US)")
makeUnitProcs(pintUK, litre, PintUKToLitre, float, "pt (UK)")
makeUnitProcs(cup, litre, CupToLitre, float, "cup")
makeUnitProcs(cupUS, litre, CupUSToLitre, float, "cup (US)")
makeUnitProcs(cupUK, litre, CupUKToLitre, float, "cup (UK)")
makeUnitProcs(flOunceUS, litre, FlOunceUSToLitre, float, "fl oz (US)")
makeUnitProcs(flOunceUK, litre, FlOunceUKToLitre, float, "fl oz (UK)")
makeUnitProcs(gillUS, litre, GillUSToLitre, float, "gill (US)")
makeUnitProcs(gillUK, litre, GillUKToLitre, float, "gill (UK)")
makeUnitProcs(minimUS, litre, MinimUSToLitre, float, "min (US)")
makeUnitProcs(minimUK, litre, MinimUKToLitre, float, "mil (UK)")
makeUnitProcs(tablespoonUS, litre, TablespoonUSToLitre, float, "tbsp (US)")
makeUnitProcs(tablespoonUK, litre, TablespoonUKToLitre, float, "tbsp (UK)")
makeUnitProcs(tablespoon, litre, TablespoonToLitre, float, "tbsp")
makeUnitProcs(teaspoonUS, litre, TeaspoonUSToLitre, float, "tsp (US)")
makeUnitProcs(teaspoonUK, litre, TeaspoonUKToLitre, float, "tsp (UK)")
makeUnitProcs(teaspoon, litre, TeaspoonToLitre, float, "tsp")
makeUnitProcs(gallonUS, litre, GallonUSToLitre, float, "gal (US)")
makeUnitProcs(gallonUK, litre, GallonUKToLitre, float, "gal (UK)")
makeUnitProcs(cc, litre, CcToLitre, float, "cc")
makeUnitProcs(drop, litre, DropToLitre, float, "drop")
makeUnitProcs(barrelUS, litre, BarrelUSToLitre, float, "bbl (US)")
makeUnitProcs(barrelUK, litre, BarrelUKToLitre, float, "bbl (UK)")
makeUnitProcs(hogshead, litre, HogsheadToLitre, float, "hh")
makeUnitProcs(tun, litre, TunToLitre, float, "tun")
makeUnitProcs(dram, litre, DramToLitre, float, "dram")
# -- LENGTH --
makeUnitProcs(inch, meter, InchToMeter, float, "in")
makeUnitProcs(foot, meter, FootToMeter, float, "ft")
proc feet* (x: float): float {.inline.} = x.float / FootToMeter
  ## convert from base unit to float value for `feet` and is equivalent to foots()
proc feet* (x: meter): float {.inline.} = cast[float](x / FootToMeter)
  ## convert from base unit to float value for `feet` and is equivalent to foots()
makeUnitProcs(yard, meter, YardToMeter, float, "yd")
makeUnitProcs(mil, meter, MilToMeter, float, "mil")
makeUnitProcs(kiloyard, meter, KiloyardToMeter, float, "kyd")
makeUnitProcs(angstrom, meter, AngstromToMeter, float, "Å")
makeUnitProcs(mile, meter, MileToMeter, float, "mi")
makeUnitProcs(chain, meter, ChainToMeter, float, "ch")
makeUnitProcs(league, meter, LeagueToMeter, float, "lea")
makeUnitProcs(fathom, meter, FathomToMeter, float, "ftm")
makeUnitProcs(nautmile, meter, NautmileToMeter, float, "naut mi")
makeUnitProcs(nautleague, meter, NautleagueToMeter, float, "naut lea")
makeUnitProcs(point, meter, PointToMeter, float, "pt")
makeUnitProcs(twip, meter, TwipToMeter, float, "twip")
makeUnitProcs(pica, meter, PicaToMeter, float, "pica")
makeUnitProcs(span, meter, SpanToMeter, float, "span")
makeUnitProcs(nail, meter, NailToMeter, float, "nail")
makeUnitProcs(hand, meter, HandToMeter, float, "hand")
makeUnitProcs(finger, meter, FingerToMeter, float, "finger")
makeUnitProcs(barleycorn, meter, BarleycornToMeter, float, "bcorn")
makeUnitProcs(reed, meter, ReedToMeter, float, "reed")
makeUnitProcs(caliber, meter, CaliberToMeter, float, "cl")
makeUnitProcs(furlong, meter, FurlongToMeter, float, "fur")
makeUnitProcs(link, meter, LinkToMeter, float, "li")
makeUnitProcs(cubit, meter, CubitToMeter, float, "cubit")
makeUnitProcs(ell, meter, EllToMeter, float, "ell")
makeUnitProcs(perch, meter, PerchToMeter, float, "perch")
makeUnitProcs(pole, meter, PoleToMeter, float, "pole")
makeUnitProcs(rod, meter, RodToMeter, float, "rd")
makeUnitProcs(rope, meter, RopeToMeter, float, "rope")
makeUnitProcs(arpent, meter, ArpentToMeter, float, "arpent")
makeUnitProcs(astrounit, meter, AstrounitToMeter, float, "a.u.")
makeUnitProcs(lightsecond, meter, LightsecondToMeter, float, "lsec")
makeUnitProcs(lightminute, meter, LightminuteToMeter, float, "lmin")
makeUnitProcs(lightday, meter, LightdayToMeter, float, "lday")
makeUnitProcs(lightyr, meter, LightyrToMeter, float, "lyr")
makeUnitProcs(cable, meter, CableToMeter, float, "cbl")
makeUnitProcs(parsec, meter, ParsecToMeter, float, "pc")
makeUnitProcs(pixel, meter, PixelToMeter, float, "px")
# -- TEMPERATURE --
proc celsius*(x: float|int): kelvin {.inline.} =
  result = kelvin(x.float + 274.15)
proc celsius*(x: kelvin): float {.inline.} =
  result = x.float - 274.15
proc celsiusUnit*(): string {.inline.} = (result = "degC")

proc fahrenheit*(x: float|int): kelvin {.inline.} =
  result = kelvin((5.0/9.0*(x.float - 32.0) + 274.15))
# printing values
proc fahrenheit*(x: kelvin): float {.inline.} =
  result = 9.0/5.0*(x.float - 274.15) + 32.0
# proc for displaying unit
proc fahrenheitUnit* (): string {.inline.} = (result = "degF")

proc rankine*(x: float|int): kelvin {.inline.} =
  result = kelvin(1.8 * x.float)
# printing values
proc rankine*(x: kelvin): float {.inline.} =
  result = (x.float / 1.8)
# proc for displaying unit
proc rankineUnit* (): string {.inline.} = (result = "degR")

proc reaumur*(x: float|int): kelvin {.inline.} =
  let r2c = 100.0/80.0
  result = kelvin(celsius(r2c * x.float))
# printing values
proc reaumur*(x: kelvin): float {.inline.} =
  let c2r = 80.0/100.0
  result = (celsius(x) * c2r)
# proc for displaying unit
proc reaumurUnit* (): string {.inline.} = (result = "degr")

# -- ANGLE --
makeUnitProcs(radian, degree, RadianToDegree, float, "rad")
makeUnitProcs(grad, degree, GradToDegree, float, "g")
makeUnitProcs(gon, degree, GonToDegree, float, "g")
makeUnitProcs(arcminute, degree, ArcminuteToDegree, float, "''")
makeUnitProcs(arcSecond, degree, ArcSecondToDegree, float, "\"")
makeUnitProcs(arcsign, degree, ArcsignToDegree, float, "sign")
makeUnitProcs(angularmil, degree, AngularmilToDegree, float, "mil")
makeUnitProcs(revolution, degree, RevolutionToDegree, float, "r")
makeUnitProcs(circular, degree, CircleToDegree, float, "circle")
makeUnitProcs(turn, degree, TurnToDegree, float, "trun")
makeUnitProcs(quadrant, degree, QuadrantToDegree, float, "deg90")
makeUnitProcs(rightangele, degree, RightangeleToDegree, float, "deg90")
makeUnitProcs(sextant, degree, SextantToDegree, float, "deg60")

# -- ENERGY --


# --------------- MainModule -----------------------------
when isMainModule:
  var m = kilogram(2.0)
  assert(m == gram(2000.0))
  assert($m.kilograms == "2.0")
  #echo m.kilograms, " kg is ",m.grams, gramUnit()
  var p = pound(1)
  assert($p.pounds == "1.0")
  assert($p.ounces == "16.0")
  #echo p.kilograms, " kg is ", p.pounds, poundUnit(), " and ", p.ounces, ounceUnit()
  var v = gallonUS(5)
  assert($v.pintUSs == "40.0")
  assert($v.quartUSs == "20.0")
  assert($v.litres == "18.927058")
  #echo v.litres, " Ltr is ", v.pintUSs, pintUSUnit(), " and ", v.quartUSs,
  #    quartUSUnit(), " and ", v.gallonUSs, gallonUSUnit()
  var lgth = yard(1)
  assert($lgth.meters == "0.9144")
  assert($lgth.fathoms == "0.5")
  #echo lgth.meters," meters is ", lgth.yards, " yards and ", lgth.fathoms, " fathoms"

  var t1 = celsius(100.0)
  assert($t1.fahrenheit() == "212.0")
  #echo t1.celsius," ",celsiusUnit()," is ", t1.fahrenheit()," ", fahrenheitUnit()
  t1 = fahrenheit(74)
  assert($t1.celsius() == "23.33333333333331")
  #echo t1.celsius," ",celsiusUnit()," is ", t1.fahrenheit()," ", fahrenheitUnit()
  t1 = reaumur(80)
  assert($t1.celsius() == "100.0")
  #echo t1.celsius," ",celsiusUnit()," is ", t1.reaumur()," ", reaumurUnit()
  t1 = reaumur(0)
  assert($t1.celsius() == "0.0")
  #echo t1.celsius," ",celsiusUnit()," is ", t1.reaumur()," ", reaumurUnit()

  #var m2 = mSq(10.0)
  #var f = m2 / lgth

  #echo 2.0.mSq + m2, " and ", m2
  #echo m2 / lgth, "  as feet: ", f.feet
