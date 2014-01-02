--=================================--
-- 
-- LuaJIT/FFI wrapper for SFML 2.x
-- Author: Nathan Cousins
-- 
-- 
-- Released under the zlib/libpng license:
-- 
-- Copyright (c) 2014 Nathan Cousins
-- 
-- This software is provided 'as-is', without any express or implied warranty. In
-- no event will the authors be held liable for any damages arising from the use
-- of this software.
-- 
-- Permission is granted to anyone to use this software for any purpose, including
-- commercial applications, and to alter it and redistribute it freely, subject to
-- the following restrictions:
-- 
-- 1. The origin of this software must not be misrepresented; you must not claim 
--    that you wrote the original software. If you use this software in a product,
--    an acknowledgment in the product documentation would be appreciated but is
--    not required.
--
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 
-- 3. This notice may not be removed or altered from any source distribution.
-- 
--=================================--

local ffi = require 'ffi';

local setmetatable = setmetatable;
local getmetatable = getmetatable;
local pcall = pcall;
local rawget = rawget;
local rawset = rawset;
local pairs = pairs;
local type = type;
local tostring = tostring;
local print = print; -- TODO: should not require print

module 'sf';


local function newObj(cl, obj)
	local gc = rawget(cl, '__gc');
	if gc ~= nil then
		ffi.gc(obj, gc);
	end
	return obj;
	
	--[[
	local t = { __sf = obj };
	return setmetatable(t, cl);
	]]
	--[[
	local mt = {
		__index = function(tbl, k)
			print("0")
			local v = rawget(t, k);
			if v ~= nil then
				print("1", tostring(v))
				return v;
			end
			v = getmetatable(getmetatable(tbl)).__index;
			if v ~= nil then
				print("2")
				if type(v) == 'function' then
					print("3")
					return v(tbl, k);
				end
				return v[k];
			end
			return rawget(t, '__sf')[k];
		end,
		__newindex = function(tbl, k, v)
			local obj = rawget(tbl, '__sf');
			if obj[k] == nil then
				rawset(t, k, v);
			else
				obj[k] = v;
			end
		end
	};
	
	--t.__index = t.__sf;
	return setmetatable(t, setmetatable(mt, cl));
	]]
end


local function getObj(obj) -- TODO, unnecessary?
	return rawget(obj, '__sf');
end


ffi.cdef [[
typedef int             sfBool;
typedef int8_t          sfInt8;
typedef uint8_t         sfUint8;
typedef int16_t         sfInt16;
typedef uint16_t        sfUint16;
typedef int32_t         sfInt32;
typedef uint32_t        sfUint32;
typedef int64_t         sfInt64;
typedef uint64_t        sfUint64;

typedef enum {
	CSFML_VERSION_MAJOR = 2,
	CSFML_VERSION_MINOR = 1,
};

enum {
   sfFalse = 0,
   sfTrue = 1,
};


/*******************/
/** System module **/
/*******************/

typedef struct
{
	int x;
	int y;
} sfVector2i;

typedef struct
{
	unsigned int x;
	unsigned int y;
} sfVector2u;

typedef struct
{
	float x;
	float y;
} sfVector2f;

typedef struct
{
	float x;
	float y;
	float z;
} sfVector3f;

typedef struct
{
	sfInt64 microseconds;
} sfTime;

typedef struct sfClock  sfClock;
typedef struct sfMutex  sfMutex;
typedef struct sfThread sfThread;

typedef sfInt64 (*sfInputStreamReadFunc)    (void* data, sfInt64 size, void* userData);
typedef sfInt64 (*sfInputStreamSeekFunc)    (sfInt64 position, void* userData);
typedef sfInt64 (*sfInputStreamTellFunc)    (void* userData);
typedef sfInt64 (*sfInputStreamGetSizeFunc) (void* userData);

typedef struct sfInputStream
{
	sfInputStreamReadFunc    read;     ///< Function to read data from the stream
	sfInputStreamSeekFunc    seek;     ///< Function to set the current read position
	sfInputStreamTellFunc    tell;     ///< Function to get the current read position
	sfInputStreamGetSizeFunc getSize;  ///< Function to get the total number of bytes in the stream
	void*                    userData; ///< User data that will be passed to the callbacks
} sfInputStream;

sfClock*  sfClock_create(void);
sfClock*  sfClock_copy(const sfClock* clock);
void      sfClock_destroy(sfClock* clock);
sfTime    sfClock_getElapsedTime(const sfClock* clock);
sfTime    sfClock_restart(sfClock* clock);

sfTime  sfTime_Zero;
float   sfTime_asSeconds(sfTime time);
sfInt32 sfTime_asMilliseconds(sfTime time);
sfInt64 sfTime_asMicroseconds(sfTime time);
sfTime  sfSeconds(float amount);
sfTime  sfMilliseconds(sfInt32 amount);
sfTime  sfMicroseconds(sfInt64 amount);

sfMutex* sfMutex_create(void);
void     sfMutex_destroy(sfMutex* mutex);
void     sfMutex_lock(sfMutex* mutex);
void     sfMutex_unlock(sfMutex* mutex);

void sfSleep(sfTime duration);

sfThread* sfThread_create(void (*function)(void*), void* userData);
void      sfThread_destroy(sfThread* thread);
void      sfThread_launch(sfThread* thread);
void      sfThread_wait(sfThread* thread);
void      sfThread_terminate(sfThread* thread);


/*******************/
/** Window module **/
/*******************/

typedef struct sfContext sfContext;
typedef struct sfWindow sfWindow;

typedef enum
{
	sfEvtClosed,
	sfEvtResized,
	sfEvtLostFocus,
	sfEvtGainedFocus,
	sfEvtTextEntered,
	sfEvtKeyPressed,
	sfEvtKeyReleased,
	sfEvtMouseWheelMoved,
	sfEvtMouseButtonPressed,
	sfEvtMouseButtonReleased,
	sfEvtMouseMoved,
	sfEvtMouseEntered,
	sfEvtMouseLeft,
	sfEvtJoystickButtonPressed,
	sfEvtJoystickButtonReleased,
	sfEvtJoystickMoved,
	sfEvtJoystickConnected,
	sfEvtJoystickDisconnected
} sfEventType;

enum
{
	sfJoystickCount       = 8,  ///< Maximum number of supported joysticks
	sfJoystickButtonCount = 32, ///< Maximum number of supported buttons
	sfJoystickAxisCount   = 8   ///< Maximum number of supported axes
};

typedef enum
{
    sfJoystickX,    ///< The X axis
    sfJoystickY,    ///< The Y axis
    sfJoystickZ,    ///< The Z axis
    sfJoystickR,    ///< The R axis
    sfJoystickU,    ///< The U axis
    sfJoystickV,    ///< The V axis
    sfJoystickPovX, ///< The X axis of the point-of-view hat
    sfJoystickPovY  ///< The Y axis of the point-of-view hat
} sfJoystickAxis;

typedef enum
{
	sfKeyUnknown = -1, ///< Unhandled key
	sfKeyA,            ///< The A key
	sfKeyB,            ///< The B key
	sfKeyC,            ///< The C key
	sfKeyD,            ///< The D key
	sfKeyE,            ///< The E key
	sfKeyF,            ///< The F key
	sfKeyG,            ///< The G key
	sfKeyH,            ///< The H key
	sfKeyI,            ///< The I key
	sfKeyJ,            ///< The J key
	sfKeyK,            ///< The K key
	sfKeyL,            ///< The L key
	sfKeyM,            ///< The M key
	sfKeyN,            ///< The N key
	sfKeyO,            ///< The O key
	sfKeyP,            ///< The P key
	sfKeyQ,            ///< The Q key
	sfKeyR,            ///< The R key
	sfKeyS,            ///< The S key
	sfKeyT,            ///< The T key
	sfKeyU,            ///< The U key
	sfKeyV,            ///< The V key
	sfKeyW,            ///< The W key
	sfKeyX,            ///< The X key
	sfKeyY,            ///< The Y key
	sfKeyZ,            ///< The Z key
	sfKeyNum0,         ///< The 0 key
	sfKeyNum1,         ///< The 1 key
	sfKeyNum2,         ///< The 2 key
	sfKeyNum3,         ///< The 3 key
	sfKeyNum4,         ///< The 4 key
	sfKeyNum5,         ///< The 5 key
	sfKeyNum6,         ///< The 6 key
	sfKeyNum7,         ///< The 7 key
	sfKeyNum8,         ///< The 8 key
	sfKeyNum9,         ///< The 9 key
	sfKeyEscape,       ///< The Escape key
	sfKeyLControl,     ///< The left Control key
	sfKeyLShift,       ///< The left Shift key
	sfKeyLAlt,         ///< The left Alt key
	sfKeyLSystem,      ///< The left OS specific key: window (Windows and Linux), apple (MacOS X), ...
	sfKeyRControl,     ///< The right Control key
	sfKeyRShift,       ///< The right Shift key
	sfKeyRAlt,         ///< The right Alt key
	sfKeyRSystem,      ///< The right OS specific key: window (Windows and Linux), apple (MacOS X), ...
	sfKeyMenu,         ///< The Menu key
	sfKeyLBracket,     ///< The [ key
	sfKeyRBracket,     ///< The ] key
	sfKeySemiColon,    ///< The ; key
	sfKeyComma,        ///< The , key
	sfKeyPeriod,       ///< The . key
	sfKeyQuote,        ///< The ' key
	sfKeySlash,        ///< The / key
	sfKeyBackSlash,    ///< The \ key
	sfKeyTilde,        ///< The ~ key
	sfKeyEqual,        ///< The = key
	sfKeyDash,         ///< The - key
	sfKeySpace,        ///< The Space key
	sfKeyReturn,       ///< The Return key
	sfKeyBack,         ///< The Backspace key
	sfKeyTab,          ///< The Tabulation key
	sfKeyPageUp,       ///< The Page up key
	sfKeyPageDown,     ///< The Page down key
	sfKeyEnd,          ///< The End key
	sfKeyHome,         ///< The Home key
	sfKeyInsert,       ///< The Insert key
	sfKeyDelete,       ///< The Delete key
	sfKeyAdd,          ///< +
	sfKeySubtract,     ///< -
	sfKeyMultiply,     ///< *
	sfKeyDivide,       ///< /
	sfKeyLeft,         ///< Left arrow
	sfKeyRight,        ///< Right arrow
	sfKeyUp,           ///< Up arrow
	sfKeyDown,         ///< Down arrow
	sfKeyNumpad0,      ///< The numpad 0 key
	sfKeyNumpad1,      ///< The numpad 1 key
	sfKeyNumpad2,      ///< The numpad 2 key
	sfKeyNumpad3,      ///< The numpad 3 key
	sfKeyNumpad4,      ///< The numpad 4 key
	sfKeyNumpad5,      ///< The numpad 5 key
	sfKeyNumpad6,      ///< The numpad 6 key
	sfKeyNumpad7,      ///< The numpad 7 key
	sfKeyNumpad8,      ///< The numpad 8 key
	sfKeyNumpad9,      ///< The numpad 9 key
	sfKeyF1,           ///< The F1 key
	sfKeyF2,           ///< The F2 key
	sfKeyF3,           ///< The F3 key
	sfKeyF4,           ///< The F4 key
	sfKeyF5,           ///< The F5 key
	sfKeyF6,           ///< The F6 key
	sfKeyF7,           ///< The F7 key
	sfKeyF8,           ///< The F8 key
	sfKeyF9,           ///< The F8 key
	sfKeyF10,          ///< The F10 key
	sfKeyF11,          ///< The F11 key
	sfKeyF12,          ///< The F12 key
	sfKeyF13,          ///< The F13 key
	sfKeyF14,          ///< The F14 key
	sfKeyF15,          ///< The F15 key
	sfKeyPause,        ///< The Pause key
	
	sfKeyCount      ///< Keep last -- the total number of keyboard keys
} sfKeyCode;

typedef enum
{
	sfMouseLeft,       ///< The left mouse button
	sfMouseRight,      ///< The right mouse button
	sfMouseMiddle,     ///< The middle (wheel) mouse button
	sfMouseXButton1,   ///< The first extra mouse button
	sfMouseXButton2,   ///< The second extra mouse button
	
	sfMouseButtonCount ///< Keep last -- the total number of mouse buttons
} sfMouseButton;

typedef struct
{
	sfEventType type;
	sfKeyCode   code;
	sfBool      alt;
	sfBool      control;
	sfBool      shift;
	sfBool      system;
} sfKeyEvent;

typedef struct
{
	sfEventType type;
	sfUint32    unicode;
} sfTextEvent;

typedef struct
{
	sfEventType type;
	int         x;
	int         y;
} sfMouseMoveEvent;

typedef struct
{
	sfEventType   type;
	sfMouseButton button;
	int           x;
	int           y;
} sfMouseButtonEvent;

typedef struct
{
    sfEventType type;
    int         delta;
    int         x;
    int         y;
} sfMouseWheelEvent;

typedef struct
{
	sfEventType    type;
	unsigned int   joystickId;
	sfJoystickAxis axis;
	float          position;
} sfJoystickMoveEvent;

typedef struct
{
	sfEventType  type;
	unsigned int joystickId;
	unsigned int button;
} sfJoystickButtonEvent;

typedef struct
{
	sfEventType  type;
	unsigned int joystickId;
} sfJoystickConnectEvent;

typedef struct
{
	sfEventType  type;
	unsigned int width;
	unsigned int height;
} sfSizeEvent;

typedef union
{
	sfEventType            type; ///< Type of the event
	sfSizeEvent            size;
	sfKeyEvent             key;
	sfTextEvent            text;
	sfMouseMoveEvent       mouseMove;
	sfMouseButtonEvent     mouseButton;
	sfMouseWheelEvent      mouseWheel;
	sfJoystickMoveEvent    joystickMove;
	sfJoystickButtonEvent  joystickButton;
	sfJoystickConnectEvent joystickConnect;
} sfEvent;

typedef struct
{
    unsigned int width;        ///< Video mode width, in pixels
    unsigned int height;       ///< Video mode height, in pixels
    unsigned int bitsPerPixel; ///< Video mode pixel depth, in bits per pixels
} sfVideoMode;

enum
{
    sfNone         = 0,      ///< No border / title bar (this flag and all others are mutually exclusive)
    sfTitlebar     = 1 << 0, ///< Title bar + fixed border
    sfResize       = 1 << 1, ///< Titlebar + resizable border + maximize button
    sfClose        = 1 << 2, ///< Titlebar + close button
    sfFullscreen   = 1 << 3, ///< Fullscreen mode (this flag and all others are mutually exclusive)
    sfDefaultStyle = sfTitlebar | sfResize | sfClose ///< Default window style
};

typedef struct
{
    unsigned int depthBits;         ///< Bits of the depth buffer
    unsigned int stencilBits;       ///< Bits of the stencil buffer
    unsigned int antialiasingLevel; ///< Level of antialiasing
    unsigned int majorVersion;      ///< Major number of the context version to create
    unsigned int minorVersion;      ///< Minor number of the context version to create
} sfContextSettings;

typedef void* sfWindowHandle;

sfContext* sfContext_create(void);
void       sfContext_destroy(sfContext* context);
void       sfContext_setActive(sfContext* context, sfBool active);

sfBool       sfJoystick_isConnected(unsigned int joystick);
unsigned int sfJoystick_getButtonCount(unsigned int joystick);
sfBool       sfJoystick_hasAxis(unsigned int joystick, sfJoystickAxis axis);
sfBool       sfJoystick_isButtonPressed(unsigned int joystick, unsigned int button);
float        sfJoystick_getAxisPosition(unsigned int joystick, sfJoystickAxis axis);
void         sfJoystick_update(void);

sfBool sfKeyboard_isKeyPressed(sfKeyCode key);

sfBool     sfMouse_isButtonPressed(sfMouseButton button);
sfVector2i sfMouse_getPosition(const sfWindow* relativeTo);
void       sfMouse_setPosition(sfVector2i position, const sfWindow* relativeTo);

sfVideoMode        sfVideoMode_getDesktopMode(void);
const sfVideoMode* sfVideoMode_getFullscreenModes(size_t* Count);
sfBool             sfVideoMode_isValid(sfVideoMode mode);

sfWindow*         sfWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
sfWindow*         sfWindow_createUnicode(sfVideoMode mode, const sfUint32* title, sfUint32 style, const sfContextSettings* settings); // *
sfWindow*         sfWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
void              sfWindow_destroy(sfWindow* window);
void              sfWindow_close(sfWindow* window);
sfBool            sfWindow_isOpen(const sfWindow* window);
sfContextSettings sfWindow_getSettings(const sfWindow* window);
sfBool            sfWindow_pollEvent(sfWindow* window, sfEvent* event);
sfBool            sfWindow_waitEvent(sfWindow* window, sfEvent* event);
sfVector2i        sfWindow_getPosition(const sfWindow* window);
void              sfWindow_setPosition(sfWindow* window, sfVector2i position);
sfVector2u        sfWindow_getSize(const sfWindow* window);
void              sfWindow_setSize(sfWindow* window, sfVector2u size);
void              sfWindow_setTitle(sfWindow* window, const char* title);
void              sfWindow_setUnicodeTitle(sfWindow* window, const sfUint32* title); // *
void              sfWindow_setIcon(sfWindow* window, unsigned int width, unsigned int height, const sfUint8* pixels);
void              sfWindow_setVisible(sfWindow* window, sfBool visible);
void              sfWindow_setMouseCursorVisible(sfWindow* window, sfBool visible);
void              sfWindow_setVerticalSyncEnabled(sfWindow* window, sfBool enabled);
void              sfWindow_setKeyRepeatEnabled(sfWindow* window, sfBool enabled);
sfBool            sfWindow_setActive(sfWindow* window, sfBool active);
void              sfWindow_display(sfWindow* window);
void              sfWindow_setFramerateLimit(sfWindow* window, unsigned int limit);
void              sfWindow_setJoystickThreshold(sfWindow* window, float threshold);
sfWindowHandle    sfWindow_getSystemHandle(const sfWindow* window);
]];


local function bool(b)
	-- Convert sfBool to Lua boolean.
	return b ~= ffi.C.sfFalse;
end


--[=[
Version.Major = CSFML_VERSION_MAJOR
Version.Minor = CSFML_VERSION_MINOR
]=]

Version = {};
Version.Major = ffi.C.CSFML_VERSION_MAJOR;
Version.Minor = ffi.C.CSFML_VERSION_MINOR;



local sfSystem = ffi.load('csfml-system-2');
if sfSystem then

Clock = {};       Clock.__index = Clock;
Time = {};        Time.__index = Time;
InputStream = {}; InputStream.__index = InputStream;
Mutex = {};       Mutex.__index = Mutex;
Thread = {};      Thread.__index = Thread;
Vector2i = {};    Vector2i.__index = Vector2i;
Vector2u = {};    Vector2u.__index = Vector2u;
Vector2f = {};    Vector2f.__index = Vector2f;
Vector3f = {};    Vector3f.__index = Vector3f;


--[=[
Clock()
Clock Clock:copy(Clock clk)
Time  Clock:getElapsedTime()
Time  Clock:restart()
]=]

setmetatable(Clock, { __call = function(cl)
	return newObj(Clock, sfSystem.sfClock_create());
end });
function Clock:__gc()
	sfSystem.sfClock_destroy(self);
end
function Clock:copy()
	return newObj(Time, sfSystem.sfClock_copy(self));
end
function Clock:getElapsedTime()
	return newObj(Time, sfSystem.sfClock_getElapsedTime(self));
end
function Clock:restart()
	return newObj(Time, sfSystem.sfClock_restart(self));
end
ffi.metatype('sfClock', Clock);


--[=[
Time.Zero = microseconds(0)
Time   seconds(number seconds)
Time   milliseconds(number millis)
Time   microseconds(number micros)
number Time:asSeconds()
number Time:asMilliseconds()
number Time:asMicroseconds()
bool   Time:operator < (Time right)
bool   Time:operator <= (Time right)
bool   Time:operator > (Time right)
bool   Time:operator >= (Time right)
bool   Time:operator == (Time right)
bool   Time:operator != (Time right)
Time   Time:operator + (Time right)
Time   Time:operator - (Time right)
Time   Time:operator * (number right)
Time   Time:operator / (number right)
]=]

Time.Zero = sfSystem.sfTime_Zero;
function seconds(amount)
	return sfSystem.sfSeconds(amount);
end
function milliseconds(amount)
	return sfSystem.sfMilliseconds(amount);
end
function microseconds(amount)
	return sfSystem.sfMicroseconds(amount);
end
function Time:asSeconds()
	return sfSystem.sfTime_asSeconds(self);
end
function Time:asMilliseconds()
	return sfSystem.sfTime_asMilliseconds(self);
end
function Time:asMicroseconds()
	return sfSystem.sfTime_asMicroseconds(self);
end
function Time:__lt(rhs)
	return self.microseconds < rhs.microseconds;
end
function Time:__le(rhs)
	return self.microseconds <= rhs.microseconds;
end
function Time:__eq(rhs)
	return self.microseconds == rhs.microseconds;
end
function Time:__add(rhs)
	return sfSystem.sfMicroseconds(self.microseconds + rhs.microseconds);
end
function Time:__sub(rhs)
	return sfSystem.sfMicroseconds(self.microseconds - rhs.microseconds);
end
function Time:__mul(rhs)
	return sfSystem.sfMicroseconds(self.microseconds * rhs);
end
function Time.__div(rhs)
	return sfSystem.sfMicroseconds(self.microseconds / rhs);
end
ffi.metatype('sfTime', Time);


--[=[
InputStream()
function    InputStream.read    => function(cdata data, number size, cdata userData)
function    InputStream.seek    => function(number position, cdata userData)
function    InputStream.tell    => function(cdata data)
function    InputStream.getSize => function(cdata userData)
userdata    InputStream.userData
]=]

setmetatable(InputStream, { __call = function(cl)
	return ffi.new('sfInputStream');
end });
ffi.metatype('sfInputStream', InputStream);


--[=[
Mutex()
nil   Mutex:lock()
nil   Mutex:unlock()
]=]

setmetatable(Mutex, { __call = function(cl)
	return newObj(Mutex, sfSystem.sfMutex_create());
end });
function Mutex:__gc()
	sfSystem.sfMutex_destroy(self);
end
function Mutex:lock()
	sfSystem.sfMutex_lock(self);
end
function Mutex:unlock()
	sfSystem.sfMutex_unlock(self);
end
ffi.metatype('sfMutex', Mutex);


--[=[
nil sleep(Time timeToSleep)
]=]

function sleep(obj)
	sfSystem.sfSleep(obj);
end


--[=[
Thread(function func, cdata userData = nil)
nil    Thread:launch()
nil    Thread:wait()
nil    Thread:terminate()
]=]

setmetatable(Thread, { __call = function(cl, func, userdata)
	return newObj(Thread, sfSystem.sfThread_create(func, userdata));
end });
function Thread:__gc()
	sfSystem.sfThread_destroy(self);
end
function Thread:launch()
	sfSystem.sfThread_launch(self);
end
function Thread:wait()
	sfSystem.sfThread_wait(self);
end
function Thread:terminate()
	sfSystem.sfThread_terminate(self);
end
ffi.metatype('sfThread', Thread);


--[=[
Vector2i(number x = 0, number y = 0)
number   Vector2i.x
number   Vector2i.y
]=]

setmetatable(Vector2i, { __call = function(cl, x, y)
	local obj = ffi.new('sfVector2i');
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
ffi.metatype('sfVector2i', Vector2i);


--[=[
Vector2u(number x = 0, number y = 0)
number   Vector2u.x
number   Vector2u.y
]=]

setmetatable(Vector2u, { __call = function(cl, x, y)
	local obj = ffi.new('sfVector2u');
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
ffi.metatype('sfVector2u', Vector2u);


--[=[
Vector2f(number x = 0, number y = 0)
number   Vector2f.x
number   Vector2f.y
]=]

setmetatable(Vector2f, { __call = function(cl, x, y)
	local obj = ffi.new('sfVector2f');
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
ffi.metatype('sfVector2f', Vector2f);


--[=[
Vector3f(number x = 0, number y = 0, number z = 0)
number   Vector3f.x
number   Vector3f.y
number   Vector3f.z
]=]

setmetatable(Vector3f, { __call = function(cl, x, y, z)
	local obj = ffi.new('sfVector3f');
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	if z == nil then obj.z = 0; else obj.z = z; end
	return obj;
end });
ffi.metatype('sfVector3f', Vector3f);

end -- sfSystem



local sfWindow = ffi.load('csfml-window-2');
if sfWindow then

Context = {};         Context.__index = Context;
ContextSettings = {}; ContextSettings.__index = ContextSettings;
Event = {};           Event.__index = Event;
Event.KeyEvent = {};             Event.KeyEvent.__index = Event.KeyEvent;
Event.TextEvent = {};            Event.TextEvent.__index = Event.TextEvent;
Event.MouseMoveEvent = {};       Event.MouseMoveEvent.__index = Event.MouseMoveEvent;
Event.MouseButtonEvent = {};     Event.MouseButtonEvent.__index = Event.MouseButtonEvent;
Event.MouseWheelEvent = {};      Event.MouseWheelEvent.__index = Event.MouseWheelEvent;
Event.JoystickMoveEvent = {};    Event.JoystickMoveEvent.__index = Event.JoystickMoveEvent;
Event.JoystickButtonEvent = {};  Event.JoystickButtonEvent.__index = Event.JoystickButtonEvent;
Event.JoystickConnectEvent = {}; Event.JoystickConnectEvent.__index = Event.JoystickConnectEvent;
Event.SizeEvent = {};            Event.KeyEvent.__index = Event.KeyEvent;
Joystick = {};        Joystick.__index = Joystick;
Keyboard = {};        Keyboard.__index = Keyboard;
Mouse = {};           Mouse.__index = Mouse;
Style = {};           Style.__index = Style;
VideoMode = {};       VideoMode.__index = VideoMode;
Window = {};          Window.__index = Window;


--[=[
Context()
Context Context:setActive(bool active = true)
]=]

setmetatable(Context, { __call = function(cl)
	return newObj(Context, sfWindow.sfContext_create());
end });
function Context:__gc()
	sfWindow.sfContext_destroy(self);
end
function Context:setActive(active)
	if active == nil then
		active = true;
	end
	sfWindow.sfContext_setActive(self, active);
end
ffi.metatype('sfContext', Context);


--[=[
ContextSettings(number depthBits = 0, number stencilBits = 0, number antialiasingLevel = 0, number majorVersion = 2, number minorVersion = 0)
number          ContextSettings.depthBits
number          ContextSettings.stencilBits
number          ContextSettings.antialiasingLevel
number          ContextSettings.majorVersion
number          ContextSettings.minorVersion
]=]

setmetatable(ContextSettings, { __call = function(cl, depthBits, stencilBits, antialiasingLevel, majorVersion, minorVersion)
	local obj = ffi.new('sfContextSettings');
	if depthBits == nil         then obj.depthBits = 0;         else obj.depthBits = depthBits; end
	if stencilBits == nil       then obj.stencilBits = 0;       else obj.stencilBits = stencilBits; end
	if antialiasingLevel == nil then obj.antialiasingLevel = 0; else obj.antialiasingLevel = antialiasingLevel; end
	if majorVersion == nil      then obj.majorVersion = 2;      else obj.majorVersion = majorVersion; end
	if minorVersion == nil      then obj.minorVersion = 0;      else obj.minorVersion = minorVersion; end
	return obj;
end });
ffi.metatype('sfContextSettings', ContextSettings);


--[=[
Event()
Event.EventType            type
Event.KeyEvent             key
Event.TextEvent            text
Event.MouseMoveEvent       mouseMove
Event.MouseButtonEvent     mouseButton
Event.MouseWheelEvent      mouseWheel
Event.JoystickMoveEvent    joystickMove
Event.JoystickButtonEvent  joystickButton
Event.JoystickConnectEvent joystickConnect
Event.SizeEvent            size

EventType Event.KeyEvent.type
KeyCode   Event.KeyEvent.code
number    Event.KeyEvent.alt     (Note that these modifiers are not booleans, but numbers [either 0 - false, or 1 - true.])
number    Event.KeyEvent.control
number    Event.KeyEvent.shift
number    Event.KeyEvent.system

EventType Event.TextEvent.type
number    Event.TextEvent.unicode

EventType Event.MouseMoveEvent.type
number    Event.MouseMoveEvent.x
number    Event.MouseMoveEvent.y

EventType   Event.MouseButtonEvent.type
MouseButton Event.MouseButtonEvent.button
number      Event.MouseButtonEvent.x
number      Event.MouseButtonEvent.y

EventType Event.MouseWheelEvent.type
number    Event.MouseWheelEvent.delta
number    Event.MouseWheelEvent.x
number    Event.MouseWheelEvent.y

EventType Event.JoystickMoveEvent.type
number    Event.JoystickMoveEvent.joystickId
Axis      Event.JoystickMoveEvent.axis
number    Event.JoystickMoveEvent.position

EventType Event.JoystickButtonEvent.type
number    Event.JoystickButtonEvent.joystickId
number    Event.JoystickButtonEvent.button

EventType Event.JoystickConnectEvent.type
number    Event.JoystickConnectEvent.joystickId

EventType Event.SizeEvent.type
number    Event.SizeEvent.width
number    Event.SizeEvent.height

Enum 'EventType'
[
Event.Closed
Event.Resized
Event.LostFocus
Event.GainedFocus
Event.TextEntered
Event.KeyPressed
Event.KeyReleased
Event.MouseWheelMoved
Event.MouseButtonPressed
Event.MouseButtonReleased
Event.MouseMoved
Event.MouseEntered
Event.MouseLeft
Event.JoystickButtonPressed
Event.JoystickButtonReleased
Event.JoystickMoved
Event.JoystickConnected
Event.JoystickDisconnected
]
]=]


setmetatable(Event, { __call = function(cl)
	return ffi.new('sfEvent');
end });

Event.Closed = sfWindow.sfEvtClosed;
Event.Resized = sfWindow.sfEvtResized;
Event.LostFocus = sfWindow.sfEvtLostFocus;
Event.GainedFocus = sfWindow.sfEvtGainedFocus;
Event.TextEntered = sfWindow.sfEvtTextEntered;
Event.KeyPressed = sfWindow.sfEvtKeyPressed;
Event.KeyReleased = sfWindow.sfEvtKeyReleased;
Event.MouseWheelMoved = sfWindow.sfEvtMouseWheelMoved;
Event.MouseButtonPressed = sfWindow.sfEvtMouseButtonPressed;
Event.MouseButtonReleased = sfWindow.sfEvtMouseButtonReleased;
Event.MouseMoved = sfWindow.sfEvtMouseMoved;
Event.MouseEntered = sfWindow.sfEvtMouseEntered;
Event.MouseLeft = sfWindow.sfEvtMouseLeft;
Event.JoystickButtonPressed = sfWindow.sfEvtJoystickButtonPressed;
Event.JoystickButtonReleased = sfWindow.sfEvtJoystickButtonReleased;
Event.JoystickMoved = sfWindow.sfEvtJoystickMoved;
Event.JoystickConnected = sfWindow.sfEvtJoystickConnected;
Event.JoystickDisconnected = sfWindow.sfEvtJoystickDisconnected;

ffi.metatype('sfEvent', Event);
ffi.metatype('sfKeyEvent', Event.KeyEvent);
ffi.metatype('sfTextEvent', Event.TextEvent);
ffi.metatype('sfMouseMoveEvent', Event.MouseMoveEvent);
ffi.metatype('sfMouseButtonEvent', Event.MouseButtonEvent);
ffi.metatype('sfMouseWheelEvent', Event.MouseWheelEvent);
ffi.metatype('sfJoystickMoveEvent', Event.JoystickMoveEvent);
ffi.metatype('sfJoystickButtonEvent', Event.JoystickButtonEvent);
ffi.metatype('sfJoystickConnectEvent', Event.JoystickConnectEvent);
ffi.metatype('sfSizeEvent', Event.SizeEvent);


--[=[
bool   Joystick.isConnected(number joystickId)
number Joystick.getButtonCount(number joystickId)
bool   Joystick.hasAxis(number joystickId, Axis sxis)
bool   Joystick.isButtonPressed(number joystickId, number button)
number Joystick.getAxisPosition(number joystickId, Axis axis)
nil    Joystick.update()

Enum 'Axis'
[
Joystick.X
Joystick.Y
Joystick.Z
Joystick.R
Joystick.U
Joystick.V
Joystick.PovX
Joystick.PovY
]

Joystick.Count       = 8
Joystick.ButtonCount = 32
Joystick.AxisCount   = 8
]=]

Joystick.isConnected = function(joystickId)
	return bool(sfWindow.sfJoystick_isConnected(joystickId));
end
Joystick.getButtonCount = function(joystickId)
	return sfWindow.sfJoystick_getButtonCount(joystickId);
end
Joystick.hasAxis = function(joystickId, axis)
	return bool(sfWindow.sfJoystick_hasAxis(joystickId, axis));
end
Joystick.isButtonPressed = function(joystickId, button)
	return bool(sfWindow.sfJoystick_isButtonPressed(joystickId, button));
end
Joystick.getAxisPosition = function(joystickId, axis)
	return newObj(Vector2i, sfWindow.sfJoystick_getAxisPosition(joystickId, axis));
end
Joystick.update = function()
	sfWindow.sfJoystick_update();
end

Joystick.X    = sfWindow.sfJoystickX;
Joystick.Y    = sfWindow.sfJoystickY;
Joystick.Z    = sfWindow.sfJoystickZ;
Joystick.R    = sfWindow.sfJoystickR;
Joystick.U    = sfWindow.sfJoystickU;
Joystick.V    = sfWindow.sfJoystickV;
Joystick.PovX = sfWindow.sfJoystickPovX;
Joystick.PovY = sfWindow.sfJoystickPovY;

Joystick.Count       = sfWindow.sfJoystickCount;
Joystick.ButtonCount = sfWindow.sfJoystickButtonCount;
Joystick.AxisCount   = sfWindow.sfJoystickAxisCount;


--[=[
bool Keyboard.isKeyPressed(KeyCode key)

Enum 'KeyCode'
[
Keyboard.Unknown
Keyboard.A
Keyboard.B
Keyboard.C
Keyboard.D
Keyboard.E
Keyboard.F
Keyboard.G
Keyboard.H
Keyboard.I
Keyboard.J
Keyboard.K
Keyboard.L
Keyboard.M
Keyboard.N
Keyboard.O
Keyboard.P
Keyboard.Q
Keyboard.R
Keyboard.S
Keyboard.T
Keyboard.U
Keyboard.V
Keyboard.W
Keyboard.X
Keyboard.Y
Keyboard.Z
Keyboard.Num0
Keyboard.Num1
Keyboard.Num2
Keyboard.Num3
Keyboard.Num4
Keyboard.Num5
Keyboard.Num6
Keyboard.Num7
Keyboard.Num8
Keyboard.Num9
Keyboard.Escape
Keyboard.LControl
Keyboard.LShift
Keyboard.LAlt
Keyboard.LSystem
Keyboard.RControl
Keyboard.RShift
Keyboard.RAlt
Keyboard.RSystem
Keyboard.Menu
Keyboard.LBracket
Keyboard.RBracket
Keyboard.SemiColon
Keyboard.Comma
Keyboard.Period
Keyboard.Quote
Keyboard.Slash
Keyboard.BackSlash
Keyboard.Tilde
Keyboard.Equal
Keyboard.Dash
Keyboard.Space
Keyboard.Return
Keyboard.Back
Keyboard.Tab
Keyboard.PageUp
Keyboard.PageDown
Keyboard.End
Keyboard.Home
Keyboard.Insert
Keyboard.Delete
Keyboard.Add
Keyboard.Subtract
Keyboard.Multiply
Keyboard.Divide
Keyboard.Left
Keyboard.Right
Keyboard.Up
Keyboard.Down
Keyboard.Numpad0
Keyboard.Numpad1
Keyboard.Numpad2
Keyboard.Numpad3
Keyboard.Numpad4
Keyboard.Numpad5
Keyboard.Numpad6
Keyboard.Numpad7
Keyboard.Numpad8
Keyboard.Numpad9
Keyboard.F1
Keyboard.F2
Keyboard.F3
Keyboard.F4
Keyboard.F5
Keyboard.F6
Keyboard.F7
Keyboard.F8
Keyboard.F9
Keyboard.F10
Keyboard.F11
Keyboard.F12
Keyboard.F13
Keyboard.F14
Keyboard.F15
Keyboard.Pause

Keyboard.Count -- the total number of keyboard keys
]
]=]

Keyboard.isKeyPressed = function(key)
	return bool(sfWindow.sfKeyboard_isKeyPressed(key));
end

Keyboard.Unknown   = sfSystem.sfKeyUnknown
Keyboard.A         = sfSystem.sfKeyA
Keyboard.B         = sfSystem.sfKeyB
Keyboard.C         = sfSystem.sfKeyC
Keyboard.D         = sfSystem.sfKeyD
Keyboard.E         = sfSystem.sfKeyE
Keyboard.F         = sfSystem.sfKeyF
Keyboard.G         = sfSystem.sfKeyG
Keyboard.H         = sfSystem.sfKeyH
Keyboard.I         = sfSystem.sfKeyI
Keyboard.J         = sfSystem.sfKeyJ
Keyboard.K         = sfSystem.sfKeyK
Keyboard.L         = sfSystem.sfKeyL
Keyboard.M         = sfSystem.sfKeyM
Keyboard.N         = sfSystem.sfKeyN
Keyboard.O         = sfSystem.sfKeyO
Keyboard.P         = sfSystem.sfKeyP
Keyboard.Q         = sfSystem.sfKeyQ
Keyboard.R         = sfSystem.sfKeyR
Keyboard.S         = sfSystem.sfKeyS
Keyboard.T         = sfSystem.sfKeyT
Keyboard.U         = sfSystem.sfKeyU
Keyboard.V         = sfSystem.sfKeyV
Keyboard.W         = sfSystem.sfKeyW
Keyboard.X         = sfSystem.sfKeyX
Keyboard.Y         = sfSystem.sfKeyY
Keyboard.Z         = sfSystem.sfKeyZ
Keyboard.Num0      = sfSystem.sfKeyNum0
Keyboard.Num1      = sfSystem.sfKeyNum1
Keyboard.Num2      = sfSystem.sfKeyNum2
Keyboard.Num3      = sfSystem.sfKeyNum3
Keyboard.Num4      = sfSystem.sfKeyNum4
Keyboard.Num5      = sfSystem.sfKeyNum5
Keyboard.Num6      = sfSystem.sfKeyNum6
Keyboard.Num7      = sfSystem.sfKeyNum7
Keyboard.Num8      = sfSystem.sfKeyNum8
Keyboard.Num9      = sfSystem.sfKeyNum9
Keyboard.Escape    = sfSystem.sfKeyEscape
Keyboard.LControl  = sfSystem.sfKeyLControl
Keyboard.LShift    = sfSystem.sfKeyLShift
Keyboard.LAlt      = sfSystem.sfKeyLAlt
Keyboard.LSystem   = sfSystem.sfKeyLSystem
Keyboard.RControl  = sfSystem.sfKeyRControl
Keyboard.RShift    = sfSystem.sfKeyRShift
Keyboard.RAlt      = sfSystem.sfKeyRAlt
Keyboard.RSystem   = sfSystem.sfKeyRSystem
Keyboard.Menu      = sfSystem.sfKeyMenu
Keyboard.LBracket  = sfSystem.sfKeyLBracket
Keyboard.RBracket  = sfSystem.sfKeyRBracket
Keyboard.SemiColon = sfSystem.sfKeySemiColon
Keyboard.Comma     = sfSystem.sfKeyComma
Keyboard.Period    = sfSystem.sfKeyPeriod
Keyboard.Quote     = sfSystem.sfKeyQuote
Keyboard.Slash     = sfSystem.sfKeySlash
Keyboard.BackSlash = sfSystem.sfKeyBackSlash
Keyboard.Tilde     = sfSystem.sfKeyTilde
Keyboard.Equal     = sfSystem.sfKeyEqual
Keyboard.Dash      = sfSystem.sfKeyDash
Keyboard.Space     = sfSystem.sfKeySpace
Keyboard.Return    = sfSystem.sfKeyReturn
Keyboard.Back      = sfSystem.sfKeyBack
Keyboard.Tab       = sfSystem.sfKeyTab
Keyboard.PageUp    = sfSystem.sfKeyPageUp
Keyboard.PageDown  = sfSystem.sfKeyPageDown
Keyboard.End       = sfSystem.sfKeyEnd
Keyboard.Home      = sfSystem.sfKeyHome
Keyboard.Insert    = sfSystem.sfKeyInsert
Keyboard.Delete    = sfSystem.sfKeyDelete
Keyboard.Add       = sfSystem.sfKeyAdd
Keyboard.Subtract  = sfSystem.sfKeySubtract
Keyboard.Multiply  = sfSystem.sfKeyMultiply
Keyboard.Divide    = sfSystem.sfKeyDivide
Keyboard.Left      = sfSystem.sfKeyLeft
Keyboard.Right     = sfSystem.sfKeyRight
Keyboard.Up        = sfSystem.sfKeyUp
Keyboard.Down      = sfSystem.sfKeyDown
Keyboard.Numpad0   = sfSystem.sfKeyNumpad0
Keyboard.Numpad1   = sfSystem.sfKeyNumpad1
Keyboard.Numpad2   = sfSystem.sfKeyNumpad2
Keyboard.Numpad3   = sfSystem.sfKeyNumpad3
Keyboard.Numpad4   = sfSystem.sfKeyNumpad4
Keyboard.Numpad5   = sfSystem.sfKeyNumpad5
Keyboard.Numpad6   = sfSystem.sfKeyNumpad6
Keyboard.Numpad7   = sfSystem.sfKeyNumpad7
Keyboard.Numpad8   = sfSystem.sfKeyNumpad8
Keyboard.Numpad9   = sfSystem.sfKeyNumpad9
Keyboard.F1        = sfSystem.sfKeyF1
Keyboard.F2        = sfSystem.sfKeyF2
Keyboard.F3        = sfSystem.sfKeyF3
Keyboard.F4        = sfSystem.sfKeyF4
Keyboard.F5        = sfSystem.sfKeyF5
Keyboard.F6        = sfSystem.sfKeyF6
Keyboard.F7        = sfSystem.sfKeyF7
Keyboard.F8        = sfSystem.sfKeyF8
Keyboard.F9        = sfSystem.sfKeyF9
Keyboard.F10       = sfSystem.sfKeyF10
Keyboard.F11       = sfSystem.sfKeyF11
Keyboard.F12       = sfSystem.sfKeyF12
Keyboard.F13       = sfSystem.sfKeyF13
Keyboard.F14       = sfSystem.sfKeyF14
Keyboard.F15       = sfSystem.sfKeyF15
Keyboard.Pause     = sfSystem.sfKeyPause
Keyboard.Count     = sfSystem.sfKeyCount

--[=[
bool     Mouse.isButtonPressed(MouseButton button)
Vector2i Mouse.getPosition(Window relativeTo = nil)
nil      Mouse.setPosition(Vector2i position, Window relativeTo = nil)

Enum 'MouseButton'
[
Mouse.Left
Mouse.Right
Mouse.Middle
Mouse.XButton1
Mouse.XButton2

Mouse.Count -- the total number of mouse buttons
]
]=]

Mouse.isButtonPressed = function(button)
	return bool(sfWindow.sfMouse_isButtonPressed(button));
end
Mouse.getPosition = function(relativeTo)
	return newObj(Vector2i, sfWindow.sfMouse_getPosition(relativeTo));
end
Mouse.setPosition = function(position, relativeTo)
	sfWindow.sfMouse_setPosition(position, relativeTo);
end

Mouse.Left     = sfWindow.sfMouseLeft;
Mouse.Right    = sfWindow.sfMouseRight;
Mouse.Middle   = sfWindow.sfMouseMiddle;
Mouse.XButton1 = sfWindow.sfMouseXButton1;
Mouse.XButton2 = sfWindow.sfMouseXButton2;
Mouse.Count    = sfWindow.sfMouseButtonCount;


--[=[
Enum 'Style' [
Style.None
Style.Titlebar
Style.Resize
Style.Close
Style.Fullscreen
Style.Default    = Style.Titlebar + Style.Resize + Style.Close
]
]=]

Style.None       = sfWindow.sfNone;
Style.Titlebar   = sfWindow.sfTitlebar;
Style.Resize     = sfWindow.sfResize;
Style.Close      = sfWindow.sfClose;
Style.Fullscreen = sfWindow.sfFullscreen;
Style.Default    = sfWindow.sfDefaultStyle;


--[=[
VideoMode(number width = 0, number height = 0, number bitsPerPixel = 32)
number    VideoMode.width
number    VideoMode.height
number    VideoMode.bitsPerPixel
]=]

setmetatable(VideoMode, { __call = function(cl, width, height, bitsPerPixel)
	local obj = ffi.new('sfVideoMode');
	if width == nil        then obj.width = 0;         else obj.width = width; end
	if height == nil       then obj.height = 0;        else obj.height = height; end
	if bitsPerPixel == nil then obj.bitsPerPixel = 32; else obj.bitsPerPixel = bitsPerPixel; end
	return obj;
end });
ffi.metatype('sfVideoMode', VideoMode);


--[=[
Window(WindowHandle handle, ContextSettings settings)
Window          Window(VideoMode mode, string title, Style style = Style.Default, ContextSettings settings = ContextSettings())
nil             Window:close()
bool            Window:isOpen()
ContextSettings Window:getSettings()
bool            Window:pollEvent(Event event)
bool            Window:waitEvent(Event event)
Vector2i        Window:getPosition()
nil             Window:setPosition(Vector2i position)
Vector2i        Window:getSize()
nil             Window:setSize(Vector2u size)
void            Window:setTitle(string title)
void            Window:setIcon(number width, number height, table pixels)
void            Window:setVisible(bool visible = true)
void            Window:setMouseCursorVisible(bool visible = true)
void            Window:setVerticalSyncEnabled(bool enabled = true)
void            Window:setKeyRepeatEnabled(bool enabled = true)
bool            Window:setActive(bool active = true)
void            Window:display()
void            Window:setFramerateLimit(number limit)
void            Window:setJoystickThreshold(number threshold)
WindowHandle    Window:getSystemHandle()
]=]

setmetatable(Window, { __call = function(cl, mode_handle, title_settings, style, settings)
	if ffi.istype('sfWindowHandle', mode_handle) then
		return newObj(Window, sfWindow.sfWindow_createFromHandle(mode_handle, title_settings));
	end
	return newObj(Window, sfWindow.sfWindow_create(mode_handle, title_settings, style or Style.Default, settings or ContextSettings()));
end });
function Window:__gc()
	sfWindow.sfWindow_destroy(self);
end
function Window:close()
	sfWindow.sfWindow_close(self);
end
function Window:isOpen()
	return bool(sfWindow.sfWindow_isOpen(self));
end
function Window:getSettings()
	return sfWindow.sfWindow_getSettings(self);
end
function Window:pollEvent(event)
	return bool(sfWindow.sfWindow_pollEvent(self, event));
end
function Window:waitEvent(event)
	return bool(sfWindow.sfWindow_waitEvent(self, event));
end
function Window:getPosition()
	return sfWindow.sfWindow_getPosition(self);
end
function Window:setPosition(position)
	sfWindow.sfWindow_getPosition(self, position);
end
function Window:getSize()
	return sfWindow.sfWindow_getSize(self);
end
function Window:setSize(size)
	sfWindow.sfWindow_setSize(self, position);
end
function Window:setTitle(title)
	sfWindow.sfWindow_setTitle(self, title);
end
function Window:setIcon(width, height, pixels)
	sfWindow.sfWindow_setIcon(self, width, height, pixels);
end
function Window:setVisible(visible)
	if visible == nil then
		visible = true;
	end
	sfWindow.sfWindow_setVisible(self, visible);
end
function Window:setMouseCursorVisible(visible)
	if visible == nil then
		visible = true;
	end
	sfWindow.sfWindow_setMouseCursorVisible(self, visible);
end
function Window:setVerticalSyncEnabled(enabled)
	if enabled == nil then
		enabled = true;
	end
	sfWindow.sfWindow_setVerticalSyncEnabled(self, enabled);
end
function Window:setKeyRepeatEnabled(enabled)
	if enabled == nil then
		enabled = true;
	end
	sfWindow.sfWindow_setKeyRepeatEnabled(self, enabled);
end
function Window:setActive(active)
	if active == nil then
		active = true;
	end
	return bool(sfWindow.sfWindow_setActive(self, active));
end
function Window:display()
	sfWindow.sfWindow_display(self);
end
function Window:setFramerateLimit(limit)
	sfWindow.sfWindow_setFramerateLimit(self, limit);
end
function Window:setJoystickThreshold(threshold)
	sfWindow.sfWindow_setJoystickThreshold(self, threshold);
end
function Window:getSystemHandle()
	return sfWindow.sfWindow_getSystemHandle(self);
end
ffi.metatype('sfWindow', Window);

end -- sfWindow



local sfAudio = ffi.load('csfml-audio-2');
if sfAudio then



end -- sfAudio



local sfNetwork = ffi.load('csfml-network-2');
if sfNetwork then



end -- sfNetwork



local sfGraphics = ffi.load('csfml-graphics-2');
if sfGraphics then



end -- sfGraphics