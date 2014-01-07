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
local rawget = rawget;
local require = require;

module 'sf';
require 'ffi/sfml-system';
require 'ffi/sfml-window';


local function newObj(cl, obj)
	local gc = rawget(cl, '__gc');
	if gc ~= nil then
		ffi.gc(obj, gc);
	end
	return obj;
end


local function bool(b)
	-- Convert sfBool to Lua boolean.
	return b ~= ffi.C.sfFalse;
end


ffi.cdef [[
typedef struct sfCircleShape sfCircleShape;
typedef struct sfConvexShape sfConvexShape;
typedef struct sfFont sfFont;
typedef struct sfImage sfImage;
typedef struct sfShader sfShader;
typedef struct sfRectangleShape sfRectangleShape;
typedef struct sfRenderTexture sfRenderTexture;
typedef struct sfRenderWindow sfRenderWindow;
typedef struct sfShape sfShape;
typedef struct sfSprite sfSprite;
typedef struct sfText sfText;
typedef struct sfTexture sfTexture;
typedef struct sfTransformable sfTransformable;
typedef struct sfVertexArray sfVertexArray;
typedef struct sfView sfView;

typedef enum 
{
    sfBlendAlpha,    ///< Pixel = Src * a + Dest * (1 - a)
    sfBlendAdd,      ///< Pixel = Src + Dest
    sfBlendMultiply, ///< Pixel = Src * Dest
    sfBlendNone      ///< No blending
} sfBlendMode;

typedef enum 
{
    sfPoints,         ///< List of individual points
    sfLines,          ///< List of individual lines
    sfLinesStrip,     ///< List of connected lines, a point uses the previous point to form a line
    sfTriangles,      ///< List of individual triangles
    sfTrianglesStrip, ///< List of connected triangles, a point uses the two previous points to form a triangle
    sfTrianglesFan,   ///< List of connected triangles, a point uses the common center and the previous point to form a triangle
    sfQuads           ///< List of individual quads
} sfPrimitiveType;

typedef enum
{
    sfTextRegular    = 0,      ///< Regular characters, no style
    sfTextBold       = 1 << 0, ///< Characters are bold
    sfTextItalic     = 1 << 1, ///< Characters are in italic
    sfTextUnderlined = 1 << 2  ///< Characters are underlined
} sfTextStyle;

typedef struct
{
    sfUint8 r;
    sfUint8 g;
    sfUint8 b;
    sfUint8 a;
} sfColor;

sfColor sfBlack;       ///< Black predefined color
sfColor sfWhite;       ///< White predefined color
sfColor sfRed;         ///< Red predefined color
sfColor sfGreen;       ///< Green predefined color
sfColor sfBlue;        ///< Blue predefined color
sfColor sfYellow;      ///< Yellow predefined color
sfColor sfMagenta;     ///< Magenta predefined color
sfColor sfCyan;        ///< Cyan predefined color
sfColor sfTransparent; ///< Transparent (black) predefined color

typedef struct
{
    float left;
    float top;
    float width;
    float height;
} sfFloatRect;

typedef struct
{
    int left;
    int top;
    int width;
    int height;
} sfIntRect;

typedef struct
{
    sfVector2f position;  ///< Position of the vertex
    sfColor    color;     ///< Color of the vertex
    sfVector2f texCoords; ///< Coordinates of the texture's pixel to map to the vertex
} sfVertex;

typedef struct
{
    float matrix[9];
} sfTransform;

const sfTransform sfTransform_Identity;

typedef struct
{
    int       advance;     ///< Offset to move horizontically to the next character
    sfIntRect bounds;      ///< Bounding rectangle of the glyph, in coordinates relative to the baseline
    sfIntRect textureRect; ///< Texture coordinates of the glyph inside the font's image
} sfGlyph;

typedef struct
{
    sfBlendMode      blendMode; ///< Blending mode
    sfTransform      transform; ///< Transform
    const sfTexture* texture;   ///< Texture
    const sfShader*  shader;    ///< Shader
} sfRenderStates;

sfColor sfColor_fromRGB(sfUint8 red, sfUint8 green, sfUint8 blue);
sfColor sfColor_fromRGBA(sfUint8 red, sfUint8 green, sfUint8 blue, sfUint8 alpha);
sfColor sfColor_add(sfColor color1, sfColor color2);
sfColor sfColor_modulate(sfColor color1, sfColor color2);

sfBool sfFloatRect_contains(const sfFloatRect* rect, float x, float y);
sfBool sfFloatRect_intersects(const sfFloatRect* rect1, const sfFloatRect* rect2, sfFloatRect* intersection);
sfBool sfIntRect_contains(const sfIntRect* rect, int x, int y);
sfBool sfIntRect_intersects(const sfIntRect* rect1, const sfIntRect* rect2, sfIntRect* intersection);

sfTransform sfTransform_fromMatrix(float a00, float a01, float a02, float a10, float a11, float a12, float a20, float a21, float a22);
void        sfTransform_getMatrix(const sfTransform* transform, float* matrix);
sfTransform sfTransform_getInverse(const sfTransform* transform);
sfVector2f  sfTransform_transformPoint(const sfTransform* transform, sfVector2f point);
sfFloatRect sfTransform_transformRect(const sfTransform* transform, sfFloatRect rectangle);
void        sfTransform_combine(sfTransform* transform, const sfTransform* other);
void        sfTransform_translate(sfTransform* transform, float x, float y);
void        sfTransform_rotate(sfTransform* transform, float angle);
void        sfTransform_rotateWithCenter(sfTransform* transform, float angle, float centerX, float centerY);
void        sfTransform_scale(sfTransform* transform, float scaleX, float scaleY);
void        sfTransform_scaleWithCenter(sfTransform* transform, float scaleX, float scaleY, float centerX, float centerY);

sfCircleShape*   sfCircleShape_create(void);
sfCircleShape*   sfCircleShape_copy(const sfCircleShape* shape);
void             sfCircleShape_destroy(sfCircleShape* shape);
void             sfCircleShape_setPosition(sfCircleShape* shape, sfVector2f position);
void             sfCircleShape_setRotation(sfCircleShape* shape, float angle);
void             sfCircleShape_setScale(sfCircleShape* shape, sfVector2f scale);
void             sfCircleShape_setOrigin(sfCircleShape* shape, sfVector2f origin);
sfVector2f       sfCircleShape_getPosition(const sfCircleShape* shape);
float            sfCircleShape_getRotation(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getScale(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getOrigin(const sfCircleShape* shape);
void             sfCircleShape_move(sfCircleShape* shape, sfVector2f offset);
void             sfCircleShape_rotate(sfCircleShape* shape, float angle);
void             sfCircleShape_scale(sfCircleShape* shape, sfVector2f factors);
sfTransform      sfCircleShape_getTransform(const sfCircleShape* shape);
sfTransform      sfCircleShape_getInverseTransform(const sfCircleShape* shape);
void             sfCircleShape_setTexture(sfCircleShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfCircleShape_setTextureRect(sfCircleShape* shape, sfIntRect rect);
void             sfCircleShape_setFillColor(sfCircleShape* shape, sfColor color);
void             sfCircleShape_setOutlineColor(sfCircleShape* shape, sfColor color);
void             sfCircleShape_setOutlineThickness(sfCircleShape* shape, float thickness);
const sfTexture* sfCircleShape_getTexture(const sfCircleShape* shape);
sfIntRect        sfCircleShape_getTextureRect(const sfCircleShape* shape);
sfColor          sfCircleShape_getFillColor(const sfCircleShape* shape);
sfColor          sfCircleShape_getOutlineColor(const sfCircleShape* shape);
float            sfCircleShape_getOutlineThickness(const sfCircleShape* shape);
unsigned int     sfCircleShape_getPointCount(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getPoint(const sfCircleShape* shape, unsigned int index);
void             sfCircleShape_setRadius(sfCircleShape* shape, float radius);
float            sfCircleShape_getRadius(const sfCircleShape* shape);
void             sfCircleShape_setPointCount(sfCircleShape* shape, unsigned int count);
sfFloatRect      sfCircleShape_getLocalBounds(const sfCircleShape* shape);
sfFloatRect      sfCircleShape_getGlobalBounds(const sfCircleShape* shape);

sfConvexShape*   sfConvexShape_create(void);
sfConvexShape*   sfConvexShape_copy(const sfConvexShape* shape);
void             sfConvexShape_destroy(sfConvexShape* shape);
void             sfConvexShape_setPosition(sfConvexShape* shape, sfVector2f position);
void             sfConvexShape_setRotation(sfConvexShape* shape, float angle);
void             sfConvexShape_setScale(sfConvexShape* shape, sfVector2f scale);
void             sfConvexShape_setOrigin(sfConvexShape* shape, sfVector2f origin);
sfVector2f       sfConvexShape_getPosition(const sfConvexShape* shape);
float            sfConvexShape_getRotation(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getScale(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getOrigin(const sfConvexShape* shape);
void             sfConvexShape_move(sfConvexShape* shape, sfVector2f offset);
void             sfConvexShape_rotate(sfConvexShape* shape, float angle);
void             sfConvexShape_scale(sfConvexShape* shape, sfVector2f factors);
sfTransform      sfConvexShape_getTransform(const sfConvexShape* shape);
sfTransform      sfConvexShape_getInverseTransform(const sfConvexShape* shape);
void             sfConvexShape_setTexture(sfConvexShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfConvexShape_setTextureRect(sfConvexShape* shape, sfIntRect rect);
void             sfConvexShape_setFillColor(sfConvexShape* shape, sfColor color);
void             sfConvexShape_setOutlineColor(sfConvexShape* shape, sfColor color);
void             sfConvexShape_setOutlineThickness(sfConvexShape* shape, float thickness);
const sfTexture* sfConvexShape_getTexture(const sfConvexShape* shape);
sfIntRect        sfConvexShape_getTextureRect(const sfConvexShape* shape);
sfColor          sfConvexShape_getFillColor(const sfConvexShape* shape);
sfColor          sfConvexShape_getOutlineColor(const sfConvexShape* shape);
float            sfConvexShape_getOutlineThickness(const sfConvexShape* shape);
unsigned int     sfConvexShape_getPointCount(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getPoint(const sfConvexShape* shape, unsigned int index);
void             sfConvexShape_setPointCount(sfConvexShape* shape, unsigned int count);
void             sfConvexShape_setPoint(sfConvexShape* shape, unsigned int index, sfVector2f point);
sfFloatRect      sfConvexShape_getLocalBounds(const sfConvexShape* shape);
sfFloatRect      sfConvexShape_getGlobalBounds(const sfConvexShape* shape);

sfFont* sfFont_createFromFile(const char* filename);
sfFont* sfFont_createFromMemory(const void* data, size_t sizeInBytes);
sfFont* sfFont_createFromStream(sfInputStream* stream);
sfFont* sfFont_copy(const sfFont* font);
void    sfFont_destroy(sfFont* font);
sfGlyph sfFont_getGlyph(sfFont* font, sfUint32 codePoint, unsigned int characterSize, sfBool bold);
int     sfFont_getKerning(sfFont* font, sfUint32 first, sfUint32 second, unsigned int characterSize);
int     sfFont_getLineSpacing(sfFont* font, unsigned int characterSize);
const   sfTexture* sfFont_getTexture(sfFont* font, unsigned int characterSize);

sfImage*       sfImage_create(unsigned int width, unsigned int height);
sfImage*       sfImage_createFromColor(unsigned int width, unsigned int height, sfColor color);
sfImage*       sfImage_createFromPixels(unsigned int width, unsigned int height, const sfUint8* pixels);
sfImage*       sfImage_createFromFile(const char* filename);
sfImage*       sfImage_createFromMemory(const void* data, size_t size);
sfImage*       sfImage_createFromStream(sfInputStream* stream);
sfImage*       sfImage_copy(const sfImage* image);
void           sfImage_destroy(sfImage* image);
sfBool         sfImage_saveToFile(const sfImage* image, const char* filename);
sfVector2u     sfImage_getSize(const sfImage* image);
void           sfImage_createMaskFromColor(sfImage* image, sfColor color, sfUint8 alpha);
void           sfImage_copyImage(sfImage* image, const sfImage* source, unsigned int destX, unsigned int destY, sfIntRect sourceRect, sfBool applyAlpha);
void           sfImage_setPixel(sfImage* image, unsigned int x, unsigned int y, sfColor color);
sfColor        sfImage_getPixel(const sfImage* image, unsigned int x, unsigned int y);
const sfUint8* sfImage_getPixelsPtr(const sfImage* image);
void           sfImage_flipHorizontally(sfImage* image);
void           sfImage_flipVertically(sfImage* image);

sfRectangleShape* sfRectangleShape_create(void);
sfRectangleShape* sfRectangleShape_copy(const sfRectangleShape* shape);
void              sfRectangleShape_destroy(sfRectangleShape* shape);
void              sfRectangleShape_setPosition(sfRectangleShape* shape, sfVector2f position);
void              sfRectangleShape_setRotation(sfRectangleShape* shape, float angle);
void              sfRectangleShape_setScale(sfRectangleShape* shape, sfVector2f scale);
void              sfRectangleShape_setOrigin(sfRectangleShape* shape, sfVector2f origin);
sfVector2f        sfRectangleShape_getPosition(const sfRectangleShape* shape);
float             sfRectangleShape_getRotation(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getScale(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getOrigin(const sfRectangleShape* shape);
void              sfRectangleShape_move(sfRectangleShape* shape, sfVector2f offset);
void              sfRectangleShape_rotate(sfRectangleShape* shape, float angle);
void              sfRectangleShape_scale(sfRectangleShape* shape, sfVector2f factors);
sfTransform       sfRectangleShape_getTransform(const sfRectangleShape* shape);
sfTransform       sfRectangleShape_getInverseTransform(const sfRectangleShape* shape);
void              sfRectangleShape_setTexture(sfRectangleShape* shape, const sfTexture* texture, sfBool resetRect);
void              sfRectangleShape_setTextureRect(sfRectangleShape* shape, sfIntRect rect);
void              sfRectangleShape_setFillColor(sfRectangleShape* shape, sfColor color);
void              sfRectangleShape_setOutlineColor(sfRectangleShape* shape, sfColor color);
void              sfRectangleShape_setOutlineThickness(sfRectangleShape* shape, float thickness);
const sfTexture*  sfRectangleShape_getTexture(const sfRectangleShape* shape);
sfIntRect         sfRectangleShape_getTextureRect(const sfRectangleShape* shape);
sfColor           sfRectangleShape_getFillColor(const sfRectangleShape* shape);
sfColor           sfRectangleShape_getOutlineColor(const sfRectangleShape* shape);
float             sfRectangleShape_getOutlineThickness(const sfRectangleShape* shape);
unsigned int      sfRectangleShape_getPointCount(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getPoint(const sfRectangleShape* shape, unsigned int index);
void              sfRectangleShape_setSize(sfRectangleShape* shape, sfVector2f size);
sfVector2f        sfRectangleShape_getSize(const sfRectangleShape* shape);
sfFloatRect       sfRectangleShape_getLocalBounds(const sfRectangleShape* shape);
sfFloatRect       sfRectangleShape_getGlobalBounds(const sfRectangleShape* shape);

sfRenderTexture* sfRenderTexture_create(unsigned int width, unsigned int height, sfBool depthBuffer);
void             sfRenderTexture_destroy(sfRenderTexture* renderTexture);
sfVector2u       sfRenderTexture_getSize(const sfRenderTexture* renderTexture);
sfBool           sfRenderTexture_setActive(sfRenderTexture* renderTexture, sfBool active);
void             sfRenderTexture_display(sfRenderTexture* renderTexture);
void             sfRenderTexture_clear(sfRenderTexture* renderTexture, sfColor color);
void             sfRenderTexture_setView(sfRenderTexture* renderTexture, const sfView* view);
const sfView*    sfRenderTexture_getView(const sfRenderTexture* renderTexture);
const sfView*    sfRenderTexture_getDefaultView(const sfRenderTexture* renderTexture);
sfIntRect        sfRenderTexture_getViewport(const sfRenderTexture* renderTexture, const sfView* view);
sfVector2f       sfRenderTexture_mapPixelToCoords(const sfRenderTexture* renderTexture, sfVector2i point, const sfView* view);
sfVector2i       sfRenderTexture_mapCoordsToPixel(const sfRenderTexture* renderTexture, sfVector2f point, const sfView* view);
void             sfRenderTexture_drawSprite(sfRenderTexture* renderTexture, const sfSprite* object, const sfRenderStates* states);
void             sfRenderTexture_drawText(sfRenderTexture* renderTexture, const sfText* object, const sfRenderStates* states);
void             sfRenderTexture_drawShape(sfRenderTexture* renderTexture, const sfShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawCircleShape(sfRenderTexture* renderTexture, const sfCircleShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawConvexShape(sfRenderTexture* renderTexture, const sfConvexShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawRectangleShape(sfRenderTexture* renderTexture, const sfRectangleShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawVertexArray(sfRenderTexture* renderTexture, const sfVertexArray* object, const sfRenderStates* states);
void             sfRenderTexture_drawPrimitives(sfRenderTexture* renderTexture, const sfVertex* vertices, unsigned int vertexCount, sfPrimitiveType type, const sfRenderStates* states);
void             sfRenderTexture_pushGLStates(sfRenderTexture* renderTexture);
void             sfRenderTexture_popGLStates(sfRenderTexture* renderTexture);
void             sfRenderTexture_resetGLStates(sfRenderTexture* renderTexture);
const sfTexture* sfRenderTexture_getTexture(const sfRenderTexture* renderTexture);
void             sfRenderTexture_setSmooth(sfRenderTexture* renderTexture, sfBool smooth);
sfBool           sfRenderTexture_isSmooth(const sfRenderTexture* renderTexture);
void             sfRenderTexture_setRepeated(sfRenderTexture* renderTexture, sfBool repeated);
sfBool           sfRenderTexture_isRepeated(const sfRenderTexture* renderTexture);

sfRenderWindow*   sfRenderWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
sfRenderWindow*   sfRenderWindow_createUnicode(sfVideoMode mode, const sfUint32* title, sfUint32 style, const sfContextSettings* settings);
sfRenderWindow*   sfRenderWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
void              sfRenderWindow_destroy(sfRenderWindow* renderWindow);
void              sfRenderWindow_close(sfRenderWindow* renderWindow);
sfBool            sfRenderWindow_isOpen(const sfRenderWindow* renderWindow);
sfContextSettings sfRenderWindow_getSettings(const sfRenderWindow* renderWindow);
sfBool            sfRenderWindow_pollEvent(sfRenderWindow* renderWindow, sfEvent* event);
sfBool            sfRenderWindow_waitEvent(sfRenderWindow* renderWindow, sfEvent* event);
sfVector2i        sfRenderWindow_getPosition(const sfRenderWindow* renderWindow);
void              sfRenderWindow_setPosition(sfRenderWindow* renderWindow, sfVector2i position);
sfVector2u        sfRenderWindow_getSize(const sfRenderWindow* renderWindow);
void              sfRenderWindow_setSize(sfRenderWindow* renderWindow, sfVector2u size);
void              sfRenderWindow_setTitle(sfRenderWindow* renderWindow, const char* title);
void              sfRenderWindow_setUnicodeTitle(sfRenderWindow* renderWindow, const sfUint32* title);
void              sfRenderWindow_setIcon(sfRenderWindow* renderWindow, unsigned int width, unsigned int height, const sfUint8* pixels);
void              sfRenderWindow_setVisible(sfRenderWindow* renderWindow, sfBool visible);
void              sfRenderWindow_setMouseCursorVisible(sfRenderWindow* renderWindow, sfBool show);
void              sfRenderWindow_setVerticalSyncEnabled(sfRenderWindow* renderWindow, sfBool enabled);
void              sfRenderWindow_setKeyRepeatEnabled(sfRenderWindow* renderWindow, sfBool enabled);
sfBool            sfRenderWindow_setActive(sfRenderWindow* renderWindow, sfBool active);
void              sfRenderWindow_display(sfRenderWindow* renderWindow);
void              sfRenderWindow_setFramerateLimit(sfRenderWindow* renderWindow, unsigned int limit);
void              sfRenderWindow_setJoystickThreshold(sfRenderWindow* renderWindow, float threshold);
sfWindowHandle    sfRenderWindow_getSystemHandle(const sfRenderWindow* renderWindow);
void              sfRenderWindow_clear(sfRenderWindow* renderWindow, sfColor color);
void              sfRenderWindow_setView(sfRenderWindow* renderWindow, const sfView* view);
const sfView*     sfRenderWindow_getView(const sfRenderWindow* renderWindow);
const sfView*     sfRenderWindow_getDefaultView(const sfRenderWindow* renderWindow);
sfIntRect         sfRenderWindow_getViewport(const sfRenderWindow* renderWindow, const sfView* view);
sfVector2f        sfRenderWindow_mapPixelToCoords(const sfRenderWindow* renderWindow, sfVector2i point, const sfView* view);
sfVector2i        sfRenderWindow_mapCoordsToPixel(const sfRenderWindow* renderWindow, sfVector2f point, const sfView* view);
void             sfRenderWindow_drawSprite(sfRenderWindow* renderWindow, const sfSprite* object, const sfRenderStates* states);
void             sfRenderWindow_drawText(sfRenderWindow* renderWindow, const sfText* object, const sfRenderStates* states);
void             sfRenderWindow_drawShape(sfRenderWindow* renderWindow, const sfShape* object, const sfRenderStates* states);
void             sfRenderWindow_drawCircleShape(sfRenderWindow* renderWindow, const sfCircleShape* object, const sfRenderStates* states);
void             sfRenderWindow_drawConvexShape(sfRenderWindow* renderWindow, const sfConvexShape* object, const sfRenderStates* states);
void             sfRenderWindow_drawRectangleShape(sfRenderWindow* renderWindow, const sfRectangleShape* object, const sfRenderStates* states);
void             sfRenderWindow_drawVertexArray(sfRenderWindow* renderWindow, const sfVertexArray* object, const sfRenderStates* states);
void             sfRenderWindow_drawPrimitives(sfRenderWindow* renderWindow, const sfVertex* vertices, unsigned int vertexCount, sfPrimitiveType type, const sfRenderStates* states);
void             sfRenderWindow_pushGLStates(sfRenderWindow* renderWindow);
void             sfRenderWindow_popGLStates(sfRenderWindow* renderWindow);
void             sfRenderWindow_resetGLStates(sfRenderWindow* renderWindow);
sfImage*         sfRenderWindow_capture(const sfRenderWindow* renderWindow);
sfVector2i       sfMouse_getPositionRenderWindow(const sfRenderWindow* relativeTo);
void             sfMouse_setPositionRenderWindow(sfVector2i position, const sfRenderWindow* relativeTo);

sfShader* sfShader_createFromFile(const char* vertexShaderFilename, const char* fragmentShaderFilename);
sfShader* sfShader_createFromMemory(const char* vertexShader, const char* fragmentShader);
sfShader* sfShader_createFromStream(sfInputStream* vertexShaderStream, sfInputStream* fragmentShaderStream);
void      sfShader_destroy(sfShader* shader);
void      sfShader_setFloatParameter(sfShader* shader, const char* name, float x);
void      sfShader_setFloat2Parameter(sfShader* shader, const char* name, float x, float y);
void      sfShader_setFloat3Parameter(sfShader* shader, const char* name, float x, float y, float z);
void      sfShader_setFloat4Parameter(sfShader* shader, const char* name, float x, float y, float z, float w);
void      sfShader_setVector2Parameter(sfShader* shader, const char* name, sfVector2f vector);
void      sfShader_setVector3Parameter(sfShader* shader, const char* name, sfVector3f vector);
void      sfShader_setColorParameter(sfShader* shader, const char* name, sfColor color);
void      sfShader_setTransformParameter(sfShader* shader, const char* name, sfTransform transform);
void      sfShader_setTextureParameter(sfShader* shader, const char* name, const sfTexture* texture);
void      sfShader_setCurrentTextureParameter(sfShader* shader, const char* name);
void      sfShader_bind(const sfShader* shader);
sfBool    sfShader_isAvailable(void);

typedef unsigned int (*sfShapeGetPointCountCallback)(void*);        ///< Type of the callback used to get the number of points in a shape
typedef sfVector2f (*sfShapeGetPointCallback)(unsigned int, void*); ///< Type of the callback used to get a point of a shape

sfShape*         sfShape_create(sfShapeGetPointCountCallback getPointCount, sfShapeGetPointCallback getPoint, void* userData);
void             sfShape_destroy(sfShape* shape);
void             sfShape_setPosition(sfShape* shape, sfVector2f position);
void             sfShape_setRotation(sfShape* shape, float angle);
void             sfShape_setScale(sfShape* shape, sfVector2f scale);
void             sfShape_setOrigin(sfShape* shape, sfVector2f origin);
sfVector2f       sfShape_getPosition(const sfShape* shape);
float            sfShape_getRotation(const sfShape* shape);
sfVector2f       sfShape_getScale(const sfShape* shape);
sfVector2f       sfShape_getOrigin(const sfShape* shape);
void             sfShape_move(sfShape* shape, sfVector2f offset);
void             sfShape_rotate(sfShape* shape, float angle);
void             sfShape_scale(sfShape* shape, sfVector2f factors);
sfTransform      sfShape_getTransform(const sfShape* shape);
sfTransform      sfShape_getInverseTransform(const sfShape* shape);
void             sfShape_setTexture(sfShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfShape_setTextureRect(sfShape* shape, sfIntRect rect);
void             sfShape_setFillColor(sfShape* shape, sfColor color);
void             sfShape_setOutlineColor(sfShape* shape, sfColor color);
void             sfShape_setOutlineThickness(sfShape* shape, float thickness);
const sfTexture* sfShape_getTexture(const sfShape* shape);
sfIntRect        sfShape_getTextureRect(const sfShape* shape);
sfColor          sfShape_getFillColor(const sfShape* shape);
sfColor          sfShape_getOutlineColor(const sfShape* shape);
float            sfShape_getOutlineThickness(const sfShape* shape);
unsigned int     sfShape_getPointCount(const sfShape* shape);
sfVector2f       sfShape_getPoint(const sfShape* shape, unsigned int index);
sfFloatRect      sfShape_getLocalBounds(const sfShape* shape);
sfFloatRect      sfShape_getGlobalBounds(const sfShape* shape);
void             sfShape_update(sfShape* shape);

sfSprite*        sfSprite_create(void);
sfSprite*        sfSprite_copy(const sfSprite* sprite);
void             sfSprite_destroy(sfSprite* sprite);
void             sfSprite_setPosition(sfSprite* sprite, sfVector2f position);
void             sfSprite_setRotation(sfSprite* sprite, float angle);
void             sfSprite_setScale(sfSprite* sprite, sfVector2f scale);
void             sfSprite_setOrigin(sfSprite* sprite, sfVector2f origin);
sfVector2f       sfSprite_getPosition(const sfSprite* sprite);
float            sfSprite_getRotation(const sfSprite* sprite);
sfVector2f       sfSprite_getScale(const sfSprite* sprite);
sfVector2f       sfSprite_getOrigin(const sfSprite* sprite);
void             sfSprite_move(sfSprite* sprite, sfVector2f offset);
void             sfSprite_rotate(sfSprite* sprite, float angle);
void             sfSprite_scale(sfSprite* sprite, sfVector2f factors);
sfTransform      sfSprite_getTransform(const sfSprite* sprite);
sfTransform      sfSprite_getInverseTransform(const sfSprite* sprite);
void             sfSprite_setTexture(sfSprite* sprite, const sfTexture* texture, sfBool resetRect);
void             sfSprite_setTextureRect(sfSprite* sprite, sfIntRect rectangle);
void             sfSprite_setColor(sfSprite* sprite, sfColor color);
const sfTexture* sfSprite_getTexture(const sfSprite* sprite);
sfIntRect        sfSprite_getTextureRect(const sfSprite* sprite);
sfColor          sfSprite_getColor(const sfSprite* sprite);
sfFloatRect      sfSprite_getLocalBounds(const sfSprite* sprite);
sfFloatRect      sfSprite_getGlobalBounds(const sfSprite* sprite);

sfText*         sfText_create(void);
sfText*         sfText_copy(const sfText* text);
void            sfText_destroy(sfText* text);
void            sfText_setPosition(sfText* text, sfVector2f position);
void            sfText_setRotation(sfText* text, float angle);
void            sfText_setScale(sfText* text, sfVector2f scale);
void            sfText_setOrigin(sfText* text, sfVector2f origin);
sfVector2f      sfText_getPosition(const sfText* text);
float           sfText_getRotation(const sfText* text);
sfVector2f      sfText_getScale(const sfText* text);
sfVector2f      sfText_getOrigin(const sfText* text);
void            sfText_move(sfText* text, sfVector2f offset);
void            sfText_rotate(sfText* text, float angle);
void            sfText_scale(sfText* text, sfVector2f factors);
sfTransform     sfText_getTransform(const sfText* text);
sfTransform     sfText_getInverseTransform(const sfText* text);
void            sfText_setString(sfText* text, const char* string);
void            sfText_setUnicodeString(sfText* text, const sfUint32* string);
void            sfText_setFont(sfText* text, const sfFont* font);
void            sfText_setCharacterSize(sfText* text, unsigned int size);
void            sfText_setStyle(sfText* text, sfUint32 style);
void            sfText_setColor(sfText* text, sfColor color);
const char*     sfText_getString(const sfText* text);
const sfUint32* sfText_getUnicodeString(const sfText* text);
const sfFont*   sfText_getFont(const sfText* text);
unsigned int    sfText_getCharacterSize(const sfText* text);
sfUint32        sfText_getStyle(const sfText* text);
sfColor         sfText_getColor(const sfText* text);
sfVector2f      sfText_findCharacterPos(const sfText* text, size_t index);
sfFloatRect     sfText_getLocalBounds(const sfText* text);
sfFloatRect     sfText_getGlobalBounds(const sfText* text);

sfTexture*   sfTexture_create(unsigned int width, unsigned int height);
sfTexture*   sfTexture_createFromFile(const char* filename, const sfIntRect* area);
sfTexture*   sfTexture_createFromMemory(const void* data, size_t sizeInBytes, const sfIntRect* area);
sfTexture*   sfTexture_createFromStream(sfInputStream* stream, const sfIntRect* area);
sfTexture*   sfTexture_createFromImage(const sfImage* image, const sfIntRect* area);
sfTexture*   sfTexture_copy(const sfTexture* texture);
void         sfTexture_destroy(sfTexture* texture);
sfVector2u   sfTexture_getSize(const sfTexture* texture);
sfImage*     sfTexture_copyToImage(const sfTexture* texture);
void         sfTexture_updateFromPixels(sfTexture* texture, const sfUint8* pixels, unsigned int width, unsigned int height, unsigned int x, unsigned int y);
void         sfTexture_updateFromImage(sfTexture* texture, const sfImage* image, unsigned int x, unsigned int y);
void         sfTexture_updateFromWindow(sfTexture* texture, const sfWindow* window, unsigned int x, unsigned int y);
void         sfTexture_updateFromRenderWindow(sfTexture* texture, const sfRenderWindow* renderWindow, unsigned int x, unsigned int y);
void         sfTexture_setSmooth(sfTexture* texture, sfBool smooth);
sfBool       sfTexture_isSmooth(const sfTexture* texture);
void         sfTexture_setRepeated(sfTexture* texture, sfBool repeated);
sfBool       sfTexture_isRepeated(const sfTexture* texture);
void         sfTexture_bind(const sfTexture* texture);
unsigned int sfTexture_getMaximumSize();

sfTransformable* sfTransformable_create(void);
sfTransformable* sfTransformable_copy(const sfTransformable* transformable);
void             sfTransformable_destroy(sfTransformable* transformable);
void             sfTransformable_setPosition(sfTransformable* transformable, sfVector2f position);
void             sfTransformable_setRotation(sfTransformable* transformable, float angle);
void             sfTransformable_setScale(sfTransformable* transformable, sfVector2f scale);
void             sfTransformable_setOrigin(sfTransformable* transformable, sfVector2f origin);
sfVector2f       sfTransformable_getPosition(const sfTransformable* transformable);
float            sfTransformable_getRotation(const sfTransformable* transformable);
sfVector2f       sfTransformable_getScale(const sfTransformable* transformable);
sfVector2f       sfTransformable_getOrigin(const sfTransformable* transformable);
void             sfTransformable_move(sfTransformable* transformable, sfVector2f offset);
void             sfTransformable_rotate(sfTransformable* transformable, float angle);
void             sfTransformable_scale(sfTransformable* transformable, sfVector2f factors);
sfTransform      sfTransformable_getTransform(const sfTransformable* transformable);
sfTransform      sfTransformable_getInverseTransform(const sfTransformable* transformable);

sfVertexArray*  sfVertexArray_create(void);
sfVertexArray*  sfVertexArray_copy(const sfVertexArray* vertexArray);
void            sfVertexArray_destroy(sfVertexArray* vertexArray);
unsigned int    sfVertexArray_getVertexCount(const sfVertexArray* vertexArray);
sfVertex*       sfVertexArray_getVertex(sfVertexArray* vertexArray, unsigned int index);
void            sfVertexArray_clear(sfVertexArray* vertexArray);
void            sfVertexArray_resize(sfVertexArray* vertexArray, unsigned int vertexCount);
void            sfVertexArray_append(sfVertexArray* vertexArray, sfVertex vertex);
void            sfVertexArray_setPrimitiveType(sfVertexArray* vertexArray, sfPrimitiveType type);
sfPrimitiveType sfVertexArray_getPrimitiveType(sfVertexArray* vertexArray);
sfFloatRect     sfVertexArray_getBounds(sfVertexArray* vertexArray);

sfView*     sfView_create(void);
sfView*     sfView_createFromRect(sfFloatRect rectangle);
sfView*     sfView_copy(const sfView* view);
void        sfView_destroy(sfView* view);
void        sfView_setCenter(sfView* view, sfVector2f center);
void        sfView_setSize(sfView* view, sfVector2f size);
void        sfView_setRotation(sfView* view, float angle);
void        sfView_setViewport(sfView* view, sfFloatRect viewport);
void        sfView_reset(sfView* view, sfFloatRect rectangle);
sfVector2f  sfView_getCenter(const sfView* view);
sfVector2f  sfView_getSize(const sfView* view);
float       sfView_getRotation(const sfView* view);
sfFloatRect sfView_getViewport(const sfView* view);
void        sfView_move(sfView* view, sfVector2f offset);
void        sfView_rotate(sfView* view, float angle);
void        sfView_zoom(sfView* view, float factor);
]];


local sfGraphics = ffi.load('csfml-graphics-2');
if sfGraphics then



end -- sfGraphics