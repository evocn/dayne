
Dayne Log

# 5/11/2024
Assumptions made for pixel games:

* Discrete positions of pixels on-screen.
* Lack of AA.
* Fonts are wonky.
  * Screen-based sizing is harder.
* Physics totally falls apart. Pixel Physics is super easy. Continuous physics is harder.
  * Instead of my sneaky method from Celeste, we have to do the wonky Swept AABB approach.
* Sprite scaling has to be more robust. Samplers, etc.

...Not all that much, in the grand scheme of things.
Plus, considering the kinds of games I want to make with this right now, most of this stuff just kind of goes away.
