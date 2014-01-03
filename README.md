LSFML
=====

An SFML 2.x FFI binding for LuaJIT.

LSFML is an attempt to implement the popular C++ multimedia library SFML (http://www.sfml-dev.org) seemlessly into Lua via CSFML (the SFML C binding) and LuaJIT's FFI magic.

How to use:
-----

LSFML is modular, similar to SFML itself. This means if you aren't using one or more SFML modules, simply don't include them in your project and those modules will not be loaded.

Some modules depend on other modules. All modules depend on sfml-system, but sfml-graphics also depends on sfml-window.

For example, if you wanted to use the sfml-graphics module, you must include the sfml-window and sfml-system with your project as well, but in your Lua code you only have to `require 'sfml-graphics'`. After that, all you have to do now is include the required CSFML binaries (.dll, .so, etc., which you can find here: http://www.sfml-dev.org/download/csfml/) with your project. Easy, right?

Roadmap:
-----
System API (sfml-system) - Near completed

Windowing API (sfml-window) - Near completed

Audio API (sfml-audio) - Near completed

Networking API (sfml-network)

Graphics API (sfml-graphics)
