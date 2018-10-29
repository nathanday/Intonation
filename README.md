Intonation
=================

The application Intonation is for generating and comparing different musical
intervals.

I have made this project public for the purpose of review by potential
employers, if you have any interest with it beyond that contact me.

## Motivation

The notes we use in music represent harmonic rations, the interval we call the
fifth represents the ratio 3:2, which means even time one string vibrates twice
the other string vibrates three times. The problem with using pure ratios,
just intonation, like this is they have to be relative to one key, this creates
a problem for fixed tuning instruments like the piano as you would need a
different set of notes for ever key you are interested in, so a compromise
system was developed where the octave is divided into equal divisions, with 12
choosen as it gives us notes close to our perfect ratios from the major and
minor scales.

## What Intonation Does

Intonation lets you experiment with some different tuning systems, you can then
compare how the same intervals in these different systems sound, generate new
intervals not available to us with our modern tuning. Even if you are not
interested in alternative tuning systems you can use a just intonation tuning to
understand why the intervals we are trying to aproximate with our modern
tuning sound the way they do, Intonation gives you
different graphical representations to help you visualise what is going on,
what the intervals look like as waves, where they lie in the natural harmonic
series, what there spectrum would looks like.

The methods used to generate tunings are;

### Limits
This is based on the work of Harry Partch, you can generate every ratio
constrained by some given limits, for example all ratios whose numerator and
denominator are the product of prime numbers no greater than 5 etc.

Reference [Limit (music)](https://en.wikipedia.org/wiki/Limit_(music))

### Stacked Interval
This is based on how the Ancient Greeks generated notes, multiple the
ratio 3/2 by itself a few times and you get some musical ratios as used by the
ancient greeks, multiple the ratio 3:2 by itself 12 times and you end up very
close to 7 octaves up, stretch it a little to make it a perfect 7 octaves and
you have our modern 12 Tone Equal Temperament.

Reference [Pythagorean tuning](https://en.wikipedia.org/wiki/Pythagorean_tuning)

### Equal Temperament
12 Tone Equal Temperament is what we use today, each note is the ratio 2^(1/12) 
from the next, there are many other number of divisions that produce good
results, there are many more that don't.

Reference [Equal temperament](https://en.wikipedia.org/wiki/Equal_temperament)

### Natural Harmonic Series
All harmonic sounds, musical instruments etc, can be understood as the sum of pure
tones, sine waves, whose frequencies are integer multiples of the fundamental
frequency, this is related to how our ear interpret sound and why we like
harmony in music, so one way to choose notes to use all ratios from the Harmonic
Harmonic series up to arbitrary point, up to the 8th harmonic and we have all the notes of a
[Dominant seventh chord](https://en.wikipedia.org/wiki/Dominant_seventh_chord#Harmonic_seventh).

Reference [Harmonic series (music)](https://en.wikipedia.org/wiki/Harmonic_series_(music))

Each method is pretty much self contained and so adding new methods is straight
forward, look in the Generators section of the Xcode project to see how its
done.

### Whats incomplete
* The sound synthesis engine is inefficient, its envelope ends so abruptly that
there is audible click and the Arpeggio feature doesn't work.
* Some tuning systems can generate large integers that are expensive to deal
with, factorise, wave view.
* The spectrum view doesn't scroll horizontally.
* Midi control doesn't work.
* Binary Export doesn't work, can probable be removed.
* No built in help.
* "Use Selection for Find" doesn't work.
* Needs to be more choices in presents and a way for user to add there own.
* Equal temperament is not supported as well as the just intonation, some of the information is based
around just intonation.
