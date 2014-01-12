LSFML
=====

Current supported SFML version: **2.1**

LSFML is an attempt to implement the popular [C++ multimedia library SFML](http://www.sfml-dev.org) seemlessly into Lua via LuaJIT's powerful FFI library. LSFML is based of the CSFML library (SFML's C binding,) but attempts to resemble the original C++ SFML as closely as possible. If you wish to view example code using LSFML, check out the examples folder.

*NOTE: LSFML will not work with the vanilla/standard Lua interpretter. LSFML was designed for use with [LuaJIT](http://luajit.org/).*


How to use:
-----

LSFML is modular, similar to SFML itself. This means if you aren't using one or more SFML modules, simply don't include them in your project and those modules will not be loaded.

Some modules depend on other modules. All modules depend on sfml-system, but sfml-graphics also depends on sfml-window.

For example, if you wanted to use the sfml-graphics module, you must include the sfml-window and sfml-system with your project as well, but in your Lua code you only have to `require 'ffi/sfml-graphics'`. After that, all you have to do now is include the required [CSFML binaries](http://www.sfml-dev.org/download/csfml/) (.dll, .so, etc.,) with your project.
Easy, right?


Roadmap:
-----
✓ System API (sfml-system)      - Usable, near completed

✓ Windowing API (sfml-window)   - Completed

✓ Audio API (sfml-audio)        - Usable, near completed

✗ Networking API (sfml-network) - 25%

✓ Graphics API (sfml-graphics)  - Usable, near completed
