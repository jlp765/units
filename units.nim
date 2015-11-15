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
## - degree (Angles)
## - second (Time)
## - gMPerS (Force) (newton is kgm/s = 1000 * gm/s)
## - Joule (Energy)
## - Watt (Power)
##
## For each unit category, the values are converted to/from the base unit.
## Procedures are defined for each unit to
## - convert SI multipliers to the base unit  e.g. ``var m = kilogram(2.0)``  means ``m=2000.0`` which is grams)
## - convert non-SI units to the base unit  e.g. ``var m = pound(1.0)``
##  includes: ``deka``, ``hecto``, ``kilo``, ``mega``, ``giga``, ``tera``, ``peta``, ``deci``, ``centi``, ``milli``, ``micro``, ``nano``, ``pico``, ``femto``, ``atto``
## - convert base unit to a number (proc has aq plural plural name) e.g.  ``echo m.pounds(), m.ounces()``
##  Note: where US and Imperial differ you will need to use gallonUS and gallonUK, pintUS, pintUK, etc
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

type
  gram* = distinct float    ## Mass
  meter* = distinct float   ## Distance (or Length)
  m2* = distinct float      ## Area = meter * meter = Length * Length
  m3* = distinct float      ## Volume = meter * meter * meter = Area * Length
  kelvin* = distinct float  ## Temperature
  degree* = distinct float  ## Angular (rotation)
  second* = distinct float  ## Time
  mPerS* = distinct float   ## Speed = meter / second = Mass / Time
  mPerS2* = distinct float  ## Acceleration = meter / second / second = Speed / Time
  gMPerS2* = distinct float  ## Force = g * m / s / s = Mass * Acceleration
  #newton* = distinct float  ## Force = kg * m / s / s = Mass * Acceleration
  gM2PerS2* = distinct float ## Energy = gm/s * meter = Force * Distance = Mass * Speed * Speed
  #joule* = distinct float   ## Energy = Newton * meter = Force * Distance
  watt* = distinct float    ## Power = Joule/sec = Energy / Time = Force * Speed


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
  LitreToM3 = 1.0e-3
  QuartUSToM3 = 0.9463529 / 1000.0
  QuartUKToM3 = 1.1365225 / 1000.0
  PintUSToM3 = QuartUSToM3 / 2.0
  PintUKToM3 = QuartUKToM3 / 2.0
  CupToM3 = 0.25 / 1000.0
  CupUSToM3 = QuartUSToM3 / 4.0
  CupUKToM3 = QuartUKToM3 / 4.0
  FlOunceUSToM3 = QuartUSToM3 / 32.0
  FlOunceUKToM3 = QuartUKToM3 / 40.0
  GillUSToM3 = QuartUSToM3 / 8.0
  GillUKToM3 = QuartUKToM3 / 8.0
  MinimUSToM3 = QuartUSToM3 / 15360.0
  MinimUKToM3 = QuartUKToM3 / 19200.0
  TablespoonUSToM3 = PintUSToM3 / 32.0
  TablespoonUKToM3 = PintUKToM3 / 32.0
  TablespoonToM3 = 0.015 / 1000.0
  TeaspoonUSToM3 = FlOunceUSToM3 / 6.0
  TeaspoonUKToM3 = FlOunceUKToM3 / 4.8
  TeaspoonToM3 = 0.015 / 1000.0
  GallonUSToM3 = QuartUSToM3 * 4.0
  GallonUKToM3 = QuartUKToM3 * 4.0
  CcToM3 = 1.0e-6
  DropToM3 = 0.05 * CcToM3
  BarrelUSToM3 = 31.5 * GallonUSToM3
  BarrelUKToM3 = 31.5 * GallonUKToM3
  HogsheadToM3 = 63.0 * GallonUSToM3
  TunToM3 = 4.0 * HogsheadToM3
  DramToM3 = QuartUSToM3 / 256.0

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
  #proc `/` *(x: base, y: typ): typ {.borrow.}
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

template secondOrderMul(typ1, typ2, resTyp: typedesc): stmt =
  proc `/` *(x: resTyp, y: typ1): typ2 {.borrow.}
  proc `/` *(x: resTyp, y: typ2): typ1 {.borrow.}
  proc `/` *(x: resTyp, y: resTyp): float {.borrow.}
  proc `*` *(x: typ1, y: typ2): resTyp {.borrow.}
  proc `*` *(x: typ2, y: typ1): resTyp {.borrow.}

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
proc meterUnit*(): string
  ## display the unit string for meter (`m`)
proc m2Unit*(): string
  ## display the unit string for square meter (`m2`)
proc m3Unit*(): string
  ## display the unit string for cubic meter (`m3`)

#proc jouleUnit*(): string
#  ## display the unit string for joule (`J`)
proc kelvinUnit*(): string
  ## display the unit string for kelvin (`K`)
#proc newtonUnit*(): string
#  ## display the unit string for newton (`N`)
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
defineUnitType(meter, float, "m")
defineUnitType(m2, float, "m2")     # meter squared  Area
secondOrderSq(meter, m2, float)
defineUnitType(m3, float, "m3")     # meter cubed    Volume
secondOrderSq(m2, m3, meter)
defineUnitType(kelvin, float, "K")
defineUnitType(degree, float, "deg")
defineUnitType(second, float, "s")

defineUnitType(mPerS, float, "m/s")
secondOrderRatio(meter, second, mPerS)  # relate second order term to first order terms

defineUnitType(mPerS2, float, "m/s2")
secondOrderRatio(mPerS, second, mPerS2)  # relate 3rd order term to 2nd order terms

defineUnitType(gMPerS2, float, "gm/s")
secondOrderMul(gram, mPerS2, gMPerS2)  # relate 3rd order term to 2nd order terms
makeUnitProcs(newton, gMPerS2, 1.0e-3, float, "N")

#proc newton(x: float|int): gMPerS {.inline.} = cast[gMPerS](1000.0 * x)
#  ## define a newton in terms of the base
#proc newtons(x: gMPerS): float {.inline.} = (result = x.float / 1000.0)

defineUnitType(gM2PerS2, float, "gm2/s2")
defineUnitType(watt, float, "W")

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
makeUnitProcs(litre, m3, LitreToM3, float, "l")
makeUnitProcs(quartUS, m3, QuartUSToM3, float, "qt (US)")
makeUnitProcs(quartUK, m3, QuartUKToM3, float, "qt (UK)")
makeUnitProcs(pintUS, m3, PintUSToM3, float, "pt (US)")
makeUnitProcs(pintUK, m3, PintUKToM3, float, "pt (UK)")
makeUnitProcs(cup, m3, CupToM3, float, "cup")
makeUnitProcs(cupUS, m3, CupUSToM3, float, "cup (US)")
makeUnitProcs(cupUK, m3, CupUKToM3, float, "cup (UK)")
makeUnitProcs(flOunceUS, m3, FlOunceUSToM3, float, "fl oz (US)")
makeUnitProcs(flOunceUK, m3, FlOunceUKToM3, float, "fl oz (UK)")
makeUnitProcs(gillUS, m3, GillUSToM3, float, "gill (US)")
makeUnitProcs(gillUK, m3, GillUKToM3, float, "gill (UK)")
makeUnitProcs(minimUS, m3, MinimUSToM3, float, "min (US)")
makeUnitProcs(minimUK, m3, MinimUKToM3, float, "mil (UK)")
makeUnitProcs(tablespoonUS, m3, TablespoonUSToM3, float, "tbsp (US)")
makeUnitProcs(tablespoonUK, m3, TablespoonUKToM3, float, "tbsp (UK)")
makeUnitProcs(tablespoon, m3, TablespoonToM3, float, "tbsp")
makeUnitProcs(teaspoonUS, m3, TeaspoonUSToM3, float, "tsp (US)")
makeUnitProcs(teaspoonUK, m3, TeaspoonUKToM3, float, "tsp (UK)")
makeUnitProcs(teaspoon, m3, TeaspoonToM3, float, "tsp")
makeUnitProcs(gallonUS, m3, GallonUSToM3, float, "gal (US)")
makeUnitProcs(gallonUK, m3, GallonUKToM3, float, "gal (UK)")
makeUnitProcs(cc, m3, CcToM3, float, "cc")
makeUnitProcs(drop, m3, DropToM3, float, "drop")
makeUnitProcs(barrelUS, m3, BarrelUSToM3, float, "bbl (US)")
makeUnitProcs(barrelUK, m3, BarrelUKToM3, float, "bbl (UK)")
makeUnitProcs(hogshead, m3, HogsheadToM3, float, "hh")
makeUnitProcs(tun, m3, TunToM3, float, "tun")
makeUnitProcs(dram, m3, DramToM3, float, "dram")
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
proc celsius*(c: float|int): kelvin {.inline.} =
  ## convert a celsius value `c` to the base unit `K`
  result = kelvin(c.float + 274.15)
proc celsius*(K: kelvin): float {.inline.} =
  ## return the celsius temperature value stored in `K`
  result = K.float - 274.15
proc celsiusUnit*(): string {.inline.} = (result = "degC")
  ## return `degC` string

proc fahrenheit*(f: float|int): kelvin {.inline.} =
  ## convert a fahrenheit value to the base unit `K`
  result = kelvin((5.0/9.0*(f.float - 32.0) + 274.15))
# printing values
proc fahrenheit*(K: kelvin): float {.inline.} =
  ## return the fahrenheit temperature value of the base unit `K`
  result = 9.0/5.0*(K.float - 274.15) + 32.0
# proc for displaying unit
proc fahrenheitUnit* (): string {.inline.} = (result = "degF")
  ## return `degF` string

proc rankine*(r: float|int): kelvin {.inline.} =
  ## convert a rankine value to the base unit `K`
  result = kelvin(1.8 * r.float)
proc rankine*(K: kelvin): float {.inline.} =
  ## return the rankine temperature value of the base unit `K`
  result = (K.float / 1.8)
proc rankineUnit* (): string {.inline.} = (result = "degR")
  ## return `degR` string

proc reaumur*(r: float|int): kelvin {.inline.} =
  ## convert a reaumur value to the base unit `K`
  let r2c = 100.0/80.0
  result = celsius(r2c * r.float)
proc reaumur*(K: kelvin): float {.inline.} =
  ## return the reaumur temperature value of the base unit `K`
  let c2r = 80.0/100.0
  result = (celsius(K) * c2r)
proc reaumurUnit* (): string {.inline.} = (result = "degr")
  ## return `degr` string

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

  var mtr2 = m2(10.0)
  var f = mtr2 / lgth
  assert(2.0.m2 + mtr2 == m2(12.0))
  #echo mtr2, "/", lgth, " = ", mtr2 / lgth, "  as feet: ", f.feet
  assert(meter(10.93613298337708) - (mtr2 / lgth) <  meter(2.0e-15))
  assert(f.feet - 35.87970138903241 < 2.0e-15)

  var mps = meter(10.0) / second(10.0)
  assert(mps == mPerS(1.0))

  var newt = kilogram(1.0) * mPerS2(1.0)
  echo newt.newton, " ", newt
