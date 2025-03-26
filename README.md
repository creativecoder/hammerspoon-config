# macOS Window Management with Hammerspoon

This is an example [hammerspoon](http://www.hammerspoon.org/) config for managing window position and size in macOS using keyboard shortcuts.

I based it on [Rectangle](https://rectangleapp.com/), which is an excellent app. However, the free version of Rectangle lacks the ability to have window location presets, which are very useful to return windows to where I want them after disconnecting and reconnecting external monitors, something I do frequently with a laptop. This is easily configurable with Hammerspoon.

There are several "spoons" that have window management features, but I found it easier just to write some custom functions using the built in hammerspoon APIs. There are many subtle edge cases for window management that I wanted to customize, like positioning a window based on it's size when moving to a larger monitor. I found this customization easire without working through other spoons.

Feel free to reuse or remix the code, as desired.

