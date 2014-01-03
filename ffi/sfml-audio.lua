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
local type = type;

module 'sf';
require 'sfml-system';


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


local function tbl2cdata(ct, tbl)
	ffi.new(ct .. '[' .. #tbl .. ']', tbl);
end


ffi.cdef [[
typedef struct sfMusic sfMusic;
typedef struct sfSound sfSound;
typedef struct sfSoundBuffer sfSoundBuffer;
typedef struct sfSoundBufferRecorder sfSoundBufferRecorder;
typedef struct sfSoundRecorder sfSoundRecorder;
typedef struct sfSoundStream sfSoundStream;

typedef struct
{
    sfInt16*     samples;     ///< Pointer to the audio samples
    unsigned int sampleCount; ///< Number of samples pointed by Samples
} sfSoundStreamChunk;

typedef enum
{
    sfStopped, ///< Sound / music is not playing
    sfPaused,  ///< Sound / music is paused
    sfPlaying  ///< Sound / music is playing
} sfSoundStatus;

void       sfListener_setGlobalVolume(float volume);
float      sfListener_getGlobalVolume(void);
void       sfListener_setPosition(sfVector3f position);
sfVector3f sfListener_getPosition();
void       sfListener_setDirection(sfVector3f orientation);
sfVector3f sfListener_getDirection();

sfMusic*      sfMusic_createFromFile(const char* filename);
sfMusic*      sfMusic_createFromMemory(const void* data, size_t sizeInBytes);
sfMusic*      sfMusic_createFromStream(sfInputStream* stream);
void          sfMusic_destroy(sfMusic* music);
void          sfMusic_setLoop(sfMusic* music, sfBool loop);
sfBool        sfMusic_getLoop(const sfMusic* music);
sfTime        sfMusic_getDuration(const sfMusic* music);
void          sfMusic_play(sfMusic* music);
void          sfMusic_pause(sfMusic* music);
void          sfMusic_stop(sfMusic* music);
unsigned int  sfMusic_getChannelCount(const sfMusic* music);
unsigned int  sfMusic_getSampleRate(const sfMusic* music);
sfSoundStatus sfMusic_getStatus(const sfMusic* music);
sfTime        sfMusic_getPlayingOffset(const sfMusic* music);
void          sfMusic_setPitch(sfMusic* music, float pitch);
void          sfMusic_setVolume(sfMusic* music, float volume);
void          sfMusic_setPosition(sfMusic* music, sfVector3f position);
void          sfMusic_setRelativeToListener(sfMusic* music, sfBool relative);
void          sfMusic_setMinDistance(sfMusic* music, float distance);
void          sfMusic_setAttenuation(sfMusic* music, float attenuation);
void          sfMusic_setPlayingOffset(sfMusic* music, sfTime timeOffset);
float         sfMusic_getPitch(const sfMusic* music);
float         sfMusic_getVolume(const sfMusic* music);
sfVector3f    sfMusic_getPosition(const sfMusic* music);
sfBool        sfMusic_isRelativeToListener(const sfMusic* music);
float         sfMusic_getMinDistance(const sfMusic* music);
float         sfMusic_getAttenuation(const sfMusic* music);

sfSound*             sfSound_create(void);
sfSound*             sfSound_copy(const sfSound* sound);
void                 sfSound_destroy(sfSound* sound);
void                 sfSound_play(sfSound* sound);
void                 sfSound_pause(sfSound* sound);
void                 sfSound_stop(sfSound* sound);
void                 sfSound_setBuffer(sfSound* sound, const sfSoundBuffer* buffer);
const sfSoundBuffer* sfSound_getBuffer(const sfSound* sound);
void                 sfSound_setLoop(sfSound* sound, sfBool loop);
sfBool               sfSound_getLoop(const sfSound* sound);
sfSoundStatus        sfSound_getStatus(const sfSound* sound);
void                 sfSound_setPitch(sfSound* sound, float pitch);
void                 sfSound_setVolume(sfSound* sound, float volume);
void                 sfSound_setPosition(sfSound* sound, sfVector3f position);
void                 sfSound_setRelativeToListener(sfSound* sound, sfBool relative);
void                 sfSound_setMinDistance(sfSound* sound, float distance);
void                 sfSound_setAttenuation(sfSound* sound, float attenuation);
void                 sfSound_setPlayingOffset(sfSound* sound, sfTime timeOffset);
float                sfSound_getPitch(const sfSound* sound);
float                sfSound_getVolume(const sfSound* sound);
sfVector3f           sfSound_getPosition(const sfSound* sound);
sfBool               sfSound_isRelativeToListener(const sfSound* sound);
float                sfSound_getMinDistance(const sfSound* sound);
float                sfSound_getAttenuation(const sfSound* sound);
sfTime               sfSound_getPlayingOffset(const sfSound* sound);

sfSoundBuffer* sfSoundBuffer_createFromFile(const char* filename);
sfSoundBuffer* sfSoundBuffer_createFromMemory(const void* data, size_t sizeInBytes);
sfSoundBuffer* sfSoundBuffer_createFromStream(sfInputStream* stream);
sfSoundBuffer* sfSoundBuffer_createFromSamples(const sfInt16* samples, size_t sampleCount, unsigned int channelCount, unsigned int sampleRate);
sfSoundBuffer* sfSoundBuffer_copy(const sfSoundBuffer* soundBuffer);
void           sfSoundBuffer_destroy(sfSoundBuffer* soundBuffer);
sfBool         sfSoundBuffer_saveToFile(const sfSoundBuffer* soundBuffer, const char* filename);
const sfInt16* sfSoundBuffer_getSamples(const sfSoundBuffer* soundBuffer);
size_t         sfSoundBuffer_getSampleCount(const sfSoundBuffer* soundBuffer);
unsigned int   sfSoundBuffer_getSampleRate(const sfSoundBuffer* soundBuffer);
unsigned int   sfSoundBuffer_getChannelCount(const sfSoundBuffer* soundBuffer);
sfTime         sfSoundBuffer_getDuration(const sfSoundBuffer* soundBuffer);

sfSoundBufferRecorder* sfSoundBufferRecorder_create(void);
void                   sfSoundBufferRecorder_destroy(sfSoundBufferRecorder* soundBufferRecorder);
void                   sfSoundBufferRecorder_start(sfSoundBufferRecorder* soundBufferRecorder, unsigned int sampleRate);
void                   sfSoundBufferRecorder_stop(sfSoundBufferRecorder* soundBufferRecorder);
unsigned int           sfSoundBufferRecorder_getSampleRate(const sfSoundBufferRecorder* soundBufferRecorder);
const sfSoundBuffer*   sfSoundBufferRecorder_getBuffer(const sfSoundBufferRecorder* soundBufferRecorder);

typedef sfBool (*sfSoundRecorderStartCallback)(void*);                           ///< Type of the callback used when starting a capture
typedef sfBool (*sfSoundRecorderProcessCallback)(const sfInt16*, size_t, void*); ///< Type of the callback used to process audio data
typedef void   (*sfSoundRecorderStopCallback)(void*);                            ///< Type of the callback used when stopping a capture

sfSoundRecorder* sfSoundRecorder_create(sfSoundRecorderStartCallback onStart, sfSoundRecorderProcessCallback onProcess, sfSoundRecorderStopCallback onStop, void* userData);
void sfSoundRecorder_destroy(sfSoundRecorder* soundRecorder);
void sfSoundRecorder_start(sfSoundRecorder* soundRecorder, unsigned int sampleRate);
void sfSoundRecorder_stop(sfSoundRecorder* soundRecorder);
unsigned int sfSoundRecorder_getSampleRate(const sfSoundRecorder* soundRecorder);
sfBool sfSoundRecorder_isAvailable(void);

typedef sfBool (*sfSoundStreamGetDataCallback)(sfSoundStreamChunk*, void*); ///< Type of the callback used to get a sound stream data
typedef void   (*sfSoundStreamSeekCallback)(sfTime, void*);                 ///< Type of the callback used to seek in a sound stream

sfSoundStream* sfSoundStream_create(sfSoundStreamGetDataCallback onGetData, sfSoundStreamSeekCallback onSeek, unsigned int channelCount, unsigned int sampleRate, void* userData);
void           sfSoundStream_destroy(sfSoundStream* soundStream);
void           sfSoundStream_play(sfSoundStream* soundStream);
void           sfSoundStream_pause(sfSoundStream* soundStream);
void           sfSoundStream_stop(sfSoundStream* soundStream);
sfSoundStatus  sfSoundStream_getStatus(const sfSoundStream* soundStream);
unsigned int   sfSoundStream_getChannelCount(const sfSoundStream* soundStream);
unsigned int   sfSoundStream_getSampleRate(const sfSoundStream* soundStream);
void           sfSoundStream_setPitch(sfSoundStream* soundStream, float pitch);
void           sfSoundStream_setVolume(sfSoundStream* soundStream, float volume);
void           sfSoundStream_setPosition(sfSoundStream* soundStream, sfVector3f position);
void           sfSoundStream_setRelativeToListener(sfSoundStream* soundStream, sfBool relative);
void           sfSoundStream_setMinDistance(sfSoundStream* soundStream, float distance);
void           sfSoundStream_setAttenuation(sfSoundStream* soundStream, float attenuation);
void           sfSoundStream_setPlayingOffset(sfSoundStream* soundStream, sfTime timeOffset);
void           sfSoundStream_setLoop(sfSoundStream* soundStream, sfBool loop);
float          sfSoundStream_getPitch(const sfSoundStream* soundStream);
float          sfSoundStream_getVolume(const sfSoundStream* soundStream);
sfVector3f     sfSoundStream_getPosition(const sfSoundStream* soundStream);
sfBool         sfSoundStream_isRelativeToListener(const sfSoundStream* soundStream);
float          sfSoundStream_getMinDistance(const sfSoundStream* soundStream);
float          sfSoundStream_getAttenuation(const sfSoundStream* soundStream);
sfBool         sfSoundStream_getLoop(const sfSoundStream* soundStream);
sfTime         sfSoundStream_getPlayingOffset(const sfSoundStream* soundStream);
]];


local sfAudio = ffi.load('csfml-audio-2');
if sfAudio then

Listener = {};            Listener.__index = Listener;
Music = {};               Music.__index = Music;
Sound = {};               Sound.__index = Sound;
SoundBuffer = {};         SoundBuffer.__index = SoundBuffer;
SoundBufferRecorder = {}; SoundBufferRecorder.__index = SoundBufferRecorder;
SoundRecorder = {};       SoundRecorder.__index = SoundRecorder;
SoundStream = {};         SoundStream.__index = SoundStream;
SoundStream.Chunk = {};   SoundStream.Chunk.__index = SoundStream.Chunk;
SoundStatus = {};         SoundStatus.__index = SoundStatus;


--[=[
nil      Listener.setGlobalVolume(number volume)
number   Listener.getGlobalVolume()
nil      Listener.setPosition(Vector3f position)
Vector3f Listener.getPosition()
nil      Listener.setDirection(Vector3f orientation)
Vector3f Listener.getDirection()
]=]

Listener.setGlobalVolume = function(volume)
	sfAudio.sfListener_setGlobalVolume(volume);
end
Listener.getGlobalVolume = function()
	return sfAudio.sfListener_getGlobalVolume();
end
Listener.setPosition = function(position)
	sfAudio.sfListener_setPosition(position);
end
Listener.getPosition = function()
	return sfAudio.sfListener_getPosition();
end
Listener.setDirection = function(orientation)
	return sfAudio.sfListener_setDirection(orientation);
end
Listener.getDirection = function()
	return sfAudio.sfListener_getDirection();
end


--[=[
Music(string filename)
Music(cdata data, number sizeInBytes)
Music(InputStream stream)
nil         Music:setLoop(bool loop = true)
bool        Music:getLoop()
Time        Music:getDuration()
nil         Music:play()
nil         Music:pause()
nil         Music:stop()
number      Music:getChannelCount()
number      Music:getSampleRate()
SoundStatus Music:getStatus()
Time        Music:getPlayingOffset()
nil         Music:setPitch(float pitch)
nil         Music:setVolume(float volume)
nil         Music:setPosition(sfVector3f position)
nil         Music:setRelativeToListener(sfBool relative)
nil         Music:setMinDistance(float distance)
nil         Music:setAttenuation(float attenuation)
nil         Music:setPlayingOffset(sfTime timeOffset)
number      Music:getPitch()
number      Music:getVolume()
Vector3f    Music:getPosition()
bool        Music:isRelativeToListener()
number      Music:getMinDistance()
number      Music:getAttenuation()
]=]

setmetatable(Music, { __call = function(cl, filename_data_stream, sizeInBytes)
	if type(filename_data_stream) == 'cdata' then
		if ffi.istype('sfInputStream', filename_data_stream) then
			return newObj(Music, sfAudio.sfMusic_createFromStream(filename_data_stream));
		else
			return newObj(Music, sfAudio.sfMusic_createFromMemory(filename_data_stream, sizeInBytes));
		end
	else
		return newObj(Music, sfAudio.sfMusic_createFromFile(filename_data_stream));
	end
end });
function Music:__gc()
	sfAudio.sfMusic_destroy(self);
end
function Music:setLoop(loop)
	if loop == nil then
		loop = true;
	end
	sfAudio.sfMusic_setLoop(self, loop);
end
function Music:getLoop()
	return bool(sfAudio.sfMusic_getLoop(self));
end
function Music:getDuration()
	return sfAudio.sfMusic_getDuration(self);
end
function Music:play()
	sfAudio.sfMusic_play(self);
end
function Music:pause()
	sfAudio.sfMusic_pause(self);
end
function Music:stop()
	sfAudio.sfMusic_stop(self);
end
function Music:getChannelCount()
	return sfAudio.sfMusic_getChannelCount(self);
end
function Music:getSampleRate()
	return sfAudio.sfMusic_getSampleRate(self);
end
function Music:getStatus()
	return sfAudio.sfMusic_getStatus(self);
end
function Music:getPlayingOffset()
	return sfAudio.sfMusic_getPlayingOffset(self);
end
function Music:setPitch(pitch)
	sfAudio.sfMusic_setPitch(self, pitch);
end
function Music:setVolume(volume)
	sfAudio.sfMusic_setVolume(self, volume);
end
function Music:setPosition(position)
	sfAudio.sfMusic_setPosition(self, position);
end
function Music:setRelativeToListener(relative)
	sfAudio.sfMusic_setRelativeToListener(self, relative);
end
function Music:setMinDistance(distance)
	sfAudio.sfMusic_setMinDistance(self, distance);
end
function Music:setAttenuation(attenuation)
	sfAudio.sfMusic_setAttenuation(self, attenuation);
end
function Music:setPlayingOffset(timeOffset)
	sfAudio.sfMusic_setPlayingOffset(self, timeOffset);
end
function Music:getPitch()
	return sfAudio.sfMusic_getPitch(self);
end
function Music:getVolume()
	return sfAudio.sfMusic_getVolume(self);
end
function Music:getPosition()
	return sfAudio.sfMusic_getPosition(self);
end
function Music:isRelativeToListener()
	return bool(Vector3f, sfAudio.sfMusic_isRelativeToListener(self));
end
function Music:getMinDistance()
	return sfAudio.sfMusic_getMinDistance(self);
end
function Music:getAttenuation()
	return sfAudio.sfMusic_getAttenuation(self);
end
ffi.metatype('sfMusic', Music);


--[=[
Sound(SoundBuffer buffer = nil)
Sound       Sound:copy()
nil         Sound:play()
nil         Sound:pause()
nil         Sound:stop()
nil         Sound:setBuffer(SoundBuffer buffer)
SoundBuffer Sound:getBuffer()
nil         Sound:setLoop(bool loop = true)
bool        Sound:getLoop()
SoundStatus Sound:getStatus()
nil         Sound:setPitch(float pitch)
nil         Sound:setVolume(float volume)
nil         Sound:setPosition(sfVector3f position)
nil         Sound:setRelativeToListener(sfBool relative)
nil         Sound:setMinDistance(float distance)
nil         Sound:setAttenuation(float attenuation)
nil         Sound:setPlayingOffset(sfTime timeOffset)
number      Sound:getPitch()
number      Sound:getVolume()
Vector3f    Sound:getPosition()
bool        Sound:isRelativeToListener()
number      Sound:getMinDistance()
number      Sound:getAttenuation()
Time        Sound:getPlayingOffset()
]=]

setmetatable(Sound, { __call = function(cl, buffer)
	local obj = newObj(Sound, sfAudio.sfSound_create());
	if buffer ~= nil then
		sfAudio.sfSound_setBuffer(obj, buffer);
	end
	return obj;
end });
function Sound:__gc()
	sfAudio.sfSound_destroy(self);
end
function Sound:copy()
	return newObj(Sound, sfAudio.sfSound_copy(self));
end
function Sound:play()
	sfAudio.sfSound_play(self);
end
function Sound:pause()
	sfAudio.sfSound_pause(self);
end
function Sound:stop()
	sfAudio.sfSound_stop(self);
end
function Sound:setLoop(loop)
	if loop == nil then
		loop = true;
	end
	sfAudio.sfSound_setLoop(self, loop);
end
function Sound:getLoop()
	return bool(sfAudio.sfSound_getLoop(self));
end
function Sound:getStatus()
	return sfAudio.sfSound_getStatus(self);
end
function Sound:setPitch(pitch)
	sfAudio.sfSound_setPitch(self, pitch);
end
function Sound:setVolume(volume)
	sfAudio.sfSound_setVolume(self, volume);
end
function Sound:setPosition(position)
	sfAudio.sfSound_setPosition(self, position);
end
function Sound:setRelativeToListener(relative)
	sfAudio.sfSound_setRelativeToListener(self, relative);
end
function Sound:setMinDistance(distance)
	sfAudio.sfSound_setMinDistance(self, distance);
end
function Sound:setAttenuation(attenuation)
	sfAudio.sfSound_setAttenuation(self, attenuation);
end
function Sound:setPlayingOffset(timeOffset)
	sfAudio.sfSound_setPlayingOffset(self, timeOffset);
end
function Sound:getPitch()
	return sfAudio.sfSound_getPitch(self);
end
function Sound:getVolume()
	return sfAudio.sfSound_getVolume(self);
end
function Sound:getPosition()
	return sfAudio.sfSound_getPosition(self);
end
function Sound:isRelativeToListener()
	return bool(Vector3f, sfAudio.sfSound_isRelativeToListener(self));
end
function Sound:getMinDistance()
	return sfAudio.sfSound_getMinDistance(self);
end
function Sound:getAttenuation()
	return sfAudio.sfSound_getAttenuation(self);
end
function Sound:getPlayingOffset()
	return sfAudio.sfSound_getPlayingOffset(self);
end
ffi.metatype('sfSound', Sound);


--[=[
SoundBuffer(string filename)
SoundBuffer(cdata data, number sizeInBytes)
SoundBuffer(InputStream stream)
SoundBuffer(table samples, number sampleCount, number channelCount, number sampleRate)
SoundBuffer SoundBuffer:copy()
bool        SoundBuffer:saveToFile(string filename)
cdata       SoundBuffer:getSamples()
number      SoundBuffer:getSampleCount()
number      SoundBuffer:getSampleRate()
number      SoundBuffer:getChannelCount()
Time        SoundBuffer:getDuration()
]=]


setmetatable(SoundBuffer, { __call = function(cl, filename_data_stream_samples, sizeInBytes_sampleCount, channelCount, sampleRate)
	local t = type(filename_data_stream_samples);
	if t == 'cdata' then
		if ffi.istype('sfInputStream', filename_data_stream_samples) then
			return newObj(SoundBuffer, sfAudio.sfSoundBuffer_createFromStream(filename_data_stream_samples));
		else
			return newObj(SoundBuffer, sfAudio.sfSoundBuffer_createFromMemory(filename_data_stream_samples, sizeInBytes_sampleCount));
		end
	elseif t == 'string' then
		return newObj(SoundBuffer, sfAudio.sfSoundBuffer_createFromFile(filename_data_stream_samples));
	else
		-- TODO table samples
		return newObj(SoundBuffer, sfAudio.sfSoundBuffer_createFromSamples(filename_data_stream_samples, sizeInBytes_sampleCount, channelCount, sampleRate));
	end
end });
function SoundBuffer:__gc()
	sfAudio.sfSoundBuffer_destroy(self);
end
function SoundBuffer:copy()
	return newObj(SoundBuffer, sfAudio.sfSoundBuffer_copy(self));
end
function SoundBuffer:saveToFile(filename)
	return bool(sfAudio.sfSoundBuffer_saveToFile(self, filename));
end
function SoundBuffer:getSamples() -- TODO don't use cdata
	return sfAudio.sfSoundBuffer_getSamples(self);
end
function SoundBuffer:getSampleCount()
	return sfAudio.sfSoundBuffer_getSampleCount(self);
end
function SoundBuffer:getSampleRate()
	return sfAudio.sfSoundBuffer_getSampleRate(self);
end
function SoundBuffer:getChannelCount()
	return sfAudio.sfSoundBuffer_getChannelCount(self);
end
function SoundBuffer:getDuration()
	return sfAudio.sfSoundBuffer_getDuration(self);
end
ffi.metatype('sfSoundBuffer', SoundBuffer);


--[=[
SoundBufferRecorder()
nil         SoundBufferRecorder:start(number sampleRate)
nil         SoundBufferRecorder:stop()
number      SoundBufferRecorder:getSampleRate()
SoundBuffer SoundBufferRecorder:getBuffer()
]=]

setmetatable(SoundBufferRecorder, { __call = function(cl)
	return newObj(SoundBuffer, sfAudio.sfSoundBufferRecorder_create());
end });
function SoundBufferRecorder:__gc()
	sfAudio.sfSoundBufferRecorder_destroy(self);
end
function SoundBufferRecorder:start(sampleRate)
	sfAudio.sfSoundBufferRecorder_start(self, sampleRate);
end
function SoundBufferRecorder:stop()
	sfAudio.sfSoundBufferRecorder_stop(self);
end
function SoundBufferRecorder:getSampleRate()
	return sfAudio.sfSoundBufferRecorder_getSampleRate(self);
end
function SoundBufferRecorder:getBuffer()
	return sfAudio.sfSoundBufferRecorder_getBuffer(self);
end
ffi.metatype('sfSoundBufferRecorder', SoundBufferRecorder);


--[=[
SoundStream(function onGetData => function(SoundStream.Chunk chunk, cdata userData), function onSeek => function(Time offset, cdata userData), number channelCount, number sampleRate, cdata userData)
nil         SoundStream:play()
nil         SoundStream:pause()
nil         SoundStream:stop()
SoundStatus SoundStream:getStatus()
number      SoundStream:getChannelCount()
number      SoundStream:getSampleRate()
nil         SoundStream:setPitch(number pitch)
nil         SoundStream:setVolume(number volume)
nil         SoundStream:setPosition(Vector3f position)
nil         SoundStream:setRelativeToListener(bool relative)
nil         SoundStream:setMinDistance(number distance)
nil         SoundStream:setAttenuation(number attenuation)
nil         SoundStream:setPlayingOffset(Time timeOffset)
nil         SoundStream:setLoop(bool loop = true)
number      SoundStream:getPitch()
number      SoundStream:getVolume()
Vector3f    SoundStream:getPosition()
bool        SoundStream:getRelativeToListener()
number      SoundStream:getMinDistance()
number      SoundStream:getAttenuation()
bool        SoundStream:getLoop()
Time        SoundStream:getPlayingOffset()
]=]

setmetatable(SoundStream, { __call = function(cl, onGetData, onSeek, channelCount, sampleRate, userData)
	return newObj(SoundStream, sfAudio.sfSoundStream_create(onGetData, onSeek, channelCount, sampleRate, userData));
end });
function SoundStream:__gc()
	sfAudio.sfSoundStream_destroy(self);
end
function SoundStream:play()
	sfAudio.sfSound_play(self);
end
function SoundStream:pause()
	sfAudio.sfSound_pause(self);
end
function SoundStream:stop()
	sfAudio.sfSound_stop(self);
end
function SoundStream:getStatus()
	return sfAudio.sfSound_getStatus(self);
end
function SoundStream:getChannelCount()
	return sfAudio.sfMusic_getChannelCount(self);
end
function SoundStream:getSampleRate()
	return sfAudio.sfMusic_getSampleRate(self);
end
function SoundStream:setPitch(pitch)
	sfAudio.sfSound_setPitch(self, pitch);
end
function SoundStream:setVolume(volume)
	sfAudio.sfSound_setVolume(self, volume);
end
function SoundStream:setPosition(position)
	sfAudio.sfSound_setPosition(self, position);
end
function SoundStream:setRelativeToListener(relative)
	sfAudio.sfSound_setRelativeToListener(self, relative);
end
function SoundStream:setMinDistance(distance)
	sfAudio.sfSound_setMinDistance(self, distance);
end
function SoundStream:setAttenuation(attenuation)
	sfAudio.sfSound_setAttenuation(self, attenuation);
end
function SoundStream:setPlayingOffset(timeOffset)
	sfAudio.sfSound_setPlayingOffset(self, timeOffset);
end
function SoundStream:setLoop(loop)
	if loop == nil then
		loop = true;
	end
	sfAudio.sfSound_setLoop(self, loop);
end
function SoundStream:getPitch()
	return sfAudio.sfSound_getPitch(self);
end
function SoundStream:getVolume()
	return sfAudio.sfSound_getVolume(self);
end
function SoundStream:getPosition()
	return sfAudio.sfSound_getPosition(self);
end
function SoundStream:isRelativeToListener()
	return bool(Vector3f, sfAudio.sfSound_isRelativeToListener(self));
end
function SoundStream:getMinDistance()
	return sfAudio.sfSound_getMinDistance(self);
end
function SoundStream:getAttenuation()
	return sfAudio.sfSound_getAttenuation(self);
end
function SoundStream:getLoop()
	return bool(sfAudio.sfSound_getLoop(self));
end
function SoundStream:getPlayingOffset()
	return sfAudio.sfSound_getPlayingOffset(self);
end
ffi.metatype('sfSoundStream', SoundStream);


--[=[
Enum 'SoundStatus'
[
SoundStatus.Stopped
SoundStatus.Paused
SoundStatus.Playing
]
]=]

SoundStatus.Stopped = sfAudio.sfStopped;
SoundStatus.Paused = sfAudio.sfPaused;
SoundStatus.Playing = sfAudio.sfPlaying;

end -- sfAudio