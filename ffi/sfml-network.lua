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
typedef struct sfFtpDirectoryResponse sfFtpDirectoryResponse;
typedef struct sfFtpListingResponse sfFtpListingResponse;
typedef struct sfFtpResponse sfFtpResponse;
typedef struct sfFtp sfFtp;
typedef struct sfHttpRequest sfHttpRequest;
typedef struct sfHttpResponse sfHttpResponse;
typedef struct sfHttp sfHttp;
typedef struct sfPacket sfPacket;
typedef struct sfSocketSelector sfSocketSelector;
typedef struct sfTcpListener sfTcpListener;
typedef struct sfTcpSocket sfTcpSocket;
typedef struct sfUdpSocket sfUdpSocket;

typedef enum
{
    sfSocketDone,         ///< The socket has sent / received the data
    sfSocketNotReady,     ///< The socket is not ready to send / receive data yet
    sfSocketDisconnected, ///< The TCP socket has been disconnected
    sfSocketError         ///< An unexpected error happened

} sfSocketStatus;

typedef struct
{
    char address[16];
} sfIpAddress;

const sfIpAddress sfIpAddress_None;
const sfIpAddress sfIpAddress_LocalHost;
const sfIpAddress sfIpAddress_Broadcast;

typedef enum
{
    sfFtpBinary, ///< Binary mode (file is transfered as a sequence of bytes)
    sfFtpAscii,  ///< Text mode using ASCII encoding
    sfFtpEbcdic  ///< Text mode using EBCDIC encoding
} sfFtpTransferMode;

typedef enum
{
    // 1xx: the requested action is being initiated,
    // expect another reply before proceeding with a new command
    sfFtpRestartMarkerReply          = 110, ///< Restart marker reply
    sfFtpServiceReadySoon            = 120, ///< Service ready in N minutes
    sfFtpDataConnectionAlreadyOpened = 125, ///< Data connection already opened, transfer starting
    sfFtpOpeningDataConnection       = 150, ///< File status ok, about to open data connection

    // 2xx: the requested action has been successfully completed
    sfFtpOk                    = 200, ///< Command ok
    sfFtpPointlessCommand      = 202, ///< Command not implemented
    sfFtpSystemStatus          = 211, ///< System status, or system help reply
    sfFtpDirectoryStatus       = 212, ///< Directory status
    sfFtpFileStatus            = 213, ///< File status
    sfFtpHelpMessage           = 214, ///< Help message
    sfFtpSystemType            = 215, ///< NAME system type, where NAME is an official system name from the list in the Assigned Numbers document
    sfFtpServiceReady          = 220, ///< Service ready for new user
    sfFtpClosingConnection     = 221, ///< Service closing control connection
    sfFtpDataConnectionOpened  = 225, ///< Data connection open, no transfer in progress
    sfFtpClosingDataConnection = 226, ///< Closing data connection, requested file action successful
    sfFtpEnteringPassiveMode   = 227, ///< Entering passive mode
    sfFtpLoggedIn              = 230, ///< User logged in, proceed. Logged out if appropriate
    sfFtpFileActionOk          = 250, ///< Requested file action ok
    sfFtpDirectoryOk           = 257, ///< PATHNAME created

    // 3xx: the command has been accepted, but the requested action
    // is dormant, pending receipt of further information
    sfFtpNeedPassword       = 331, ///< User name ok, need password
    sfFtpNeedAccountToLogIn = 332, ///< Need account for login
    sfFtpNeedInformation    = 350, ///< Requested file action pending further information

    // 4xx: the command was not accepted and the requested action did not take place,
    // but the error condition is temporary and the action may be requested again
    sfFtpServiceUnavailable        = 421, ///< Service not available, closing control connection
    sfFtpDataConnectionUnavailable = 425, ///< Can't open data connection
    sfFtpTransferAborted           = 426, ///< Connection closed, transfer aborted
    sfFtpFileActionAborted         = 450, ///< Requested file action not taken
    sfFtpLocalError                = 451, ///< Requested action aborted, local error in processing
    sfFtpInsufficientStorageSpace  = 452, ///< Requested action not taken; insufficient storage space in system, file unavailable

    // 5xx: the command was not accepted and
    // the requested action did not take place
    sfFtpCommandUnknown          = 500, ///< Syntax error, command unrecognized
    sfFtpParametersUnknown       = 501, ///< Syntax error in parameters or arguments
    sfFtpCommandNotImplemented   = 502, ///< Command not implemented
    sfFtpBadCommandSequence      = 503, ///< Bad sequence of commands
    sfFtpParameterNotImplemented = 504, ///< Command not implemented for that parameter
    sfFtpNotLoggedIn             = 530, ///< Not logged in
    sfFtpNeedAccountToStore      = 532, ///< Need account for storing files
    sfFtpFileUnavailable         = 550, ///< Requested action not taken, file unavailable
    sfFtpPageTypeUnknown         = 551, ///< Requested action aborted, page type unknown
    sfFtpNotEnoughMemory         = 552, ///< Requested file action aborted, exceeded storage allocation
    sfFtpFilenameNotAllowed      = 553, ///< Requested action not taken, file name not allowed

    // 10xx: SFML custom codes
    sfFtpInvalidResponse  = 1000, ///< Response is not a valid FTP one
    sfFtpConnectionFailed = 1001, ///< Connection with server failed
    sfFtpConnectionClosed = 1002, ///< Connection with server closed
    sfFtpInvalidFile      = 1003  ///< Invalid file to upload / download
} sfFtpStatus;

typedef enum
{
    sfHttpGet,  ///< Request in get mode, standard method to retrieve a page
    sfHttpPost, ///< Request in post mode, usually to send data to a page
    sfHttpHead  ///< Request a page's header only
} sfHttpMethod;

typedef enum
{
    // 2xx: success
    sfHttpOk             = 200, ///< Most common code returned when operation was successful
    sfHttpCreated        = 201, ///< The resource has successfully been created
    sfHttpAccepted       = 202, ///< The request has been accepted, but will be processed later by the server
    sfHttpNoContent      = 204, ///< Sent when the server didn't send any data in return
    sfHttpResetContent   = 205, ///< The server informs the client that it should clear the view (form) that caused the request to be sent
    sfHttpPartialContent = 206, ///< The server has sent a part of the resource, as a response to a partial GET request

    // 3xx: redirection
    sfHttpMultipleChoices  = 300, ///< The requested page can be accessed from several locations
    sfHttpMovedPermanently = 301, ///< The requested page has permanently moved to a new location
    sfHttpMovedTemporarily = 302, ///< The requested page has temporarily moved to a new location
    sfHttpNotModified      = 304, ///< For conditionnal requests, means the requested page hasn't changed and doesn't need to be refreshed

    // 4xx: client error
    sfHttpBadRequest          = 400, ///< The server couldn't understand the request (syntax error)
    sfHttpUnauthorized        = 401, ///< The requested page needs an authentification to be accessed
    sfHttpForbidden           = 403, ///< The requested page cannot be accessed at all, even with authentification
    sfHttpNotFound            = 404, ///< The requested page doesn't exist
    sfHttpRangeNotSatisfiable = 407, ///< The server can't satisfy the partial GET request (with a "Range" header field)

    // 5xx: server error
    sfHttpInternalServerError = 500, ///< The server encountered an unexpected error
    sfHttpNotImplemented      = 501, ///< The server doesn't implement a requested feature
    sfHttpBadGateway          = 502, ///< The gateway server has received an error from the source server
    sfHttpServiceNotAvailable = 503, ///< The server is temporarily unavailable (overloaded, in maintenance, ...)
    sfHttpGatewayTimeout      = 504, ///< The gateway server couldn't receive a response from the source server
    sfHttpVersionNotSupported = 505, ///< The server doesn't support the requested HTTP version

    // 10xx: SFML custom codes
    sfHttpInvalidResponse  = 1000, ///< Response is not a valid HTTP one
    sfHttpConnectionFailed = 1001  ///< Connection with server failed
} sfHttpStatus;

void        sfFtpListingResponse_destroy(sfFtpListingResponse* ftpListingResponse);
sfBool      sfFtpListingResponse_isOk(const sfFtpListingResponse* ftpListingResponse);
sfFtpStatus sfFtpListingResponse_getStatus(const sfFtpListingResponse* ftpListingResponse);
const char* sfFtpListingResponse_getMessage(const sfFtpListingResponse* ftpListingResponse);
size_t      sfFtpListingResponse_getCount(const sfFtpListingResponse* ftpListingResponse);
const char* sfFtpListingResponse_getName(const sfFtpListingResponse* ftpListingResponse, size_t index);

void        sfFtpDirectoryResponse_destroy(sfFtpDirectoryResponse* ftpDirectoryResponse);
sfBool      sfFtpDirectoryResponse_isOk(const sfFtpDirectoryResponse* ftpDirectoryResponse);
sfFtpStatus sfFtpDirectoryResponse_getStatus(const sfFtpDirectoryResponse* ftpDirectoryResponse);
const char* sfFtpDirectoryResponse_getMessage(const sfFtpDirectoryResponse* ftpDirectoryResponse);
const char* sfFtpDirectoryResponse_getDirectory(const sfFtpDirectoryResponse* ftpDirectoryResponse);

void        sfFtpResponse_destroy(sfFtpResponse* ftpResponse);
sfBool      sfFtpResponse_isOk(const sfFtpResponse* ftpResponse);
sfFtpStatus sfFtpResponse_getStatus(const sfFtpResponse* ftpResponse);
const char* sfFtpResponse_getMessage(const sfFtpResponse* ftpResponse);

sfFtp*                  sfFtp_create(void);
void                    sfFtp_destroy(sfFtp* ftp);
sfFtpResponse*          sfFtp_connect(sfFtp* ftp, sfIpAddress server, unsigned short port, sfTime timeout);
sfFtpResponse*          sfFtp_loginAnonymous(sfFtp* ftp);
sfFtpResponse*          sfFtp_login(sfFtp* ftp, const char* userName, const char* password);
sfFtpResponse*          sfFtp_disconnect(sfFtp* ftp);
sfFtpResponse*          sfFtp_keepAlive(sfFtp* ftp);
sfFtpDirectoryResponse* sfFtp_getWorkingDirectory(sfFtp* ftp);
sfFtpListingResponse*   sfFtp_getDirectoryListing(sfFtp* ftp, const char* directory);
sfFtpResponse*          sfFtp_changeDirectory(sfFtp* ftp, const char* directory);
sfFtpResponse*          sfFtp_parentDirectory(sfFtp* ftp);
sfFtpResponse*          sfFtp_createDirectory(sfFtp* ftp, const char* name);
sfFtpResponse*          sfFtp_deleteDirectory(sfFtp* ftp, const char* name);
sfFtpResponse*          sfFtp_renameFile(sfFtp* ftp, const char* file, const char* newName);
sfFtpResponse*          sfFtp_deleteFile(sfFtp* ftp, const char* name);
sfFtpResponse*          sfFtp_download(sfFtp* ftp, const char* distantFile, const char* destPath, sfFtpTransferMode mode);
sfFtpResponse*          sfFtp_upload(sfFtp* ftp, const char* localFile, const char* destPath, sfFtpTransferMode mode);

sfHttpRequest* sfHttpRequest_create(void);
void           sfHttpRequest_destroy(sfHttpRequest* httpRequest);
void           sfHttpRequest_setField(sfHttpRequest* httpRequest, const char* field, const char* value);
void           sfHttpRequest_setMethod(sfHttpRequest* httpRequest, sfHttpMethod method);
void           sfHttpRequest_setUri(sfHttpRequest* httpRequest, const char* uri);
void           sfHttpRequest_setHttpVersion(sfHttpRequest* httpRequest, unsigned int major, unsigned int minor);
void           sfHttpRequest_setBody(sfHttpRequest* httpRequest, const char* body);
void           sfHttpResponse_destroy(sfHttpResponse* httpResponse);
const char*    sfHttpResponse_getField(const sfHttpResponse* httpResponse, const char* field);
sfHttpStatus   sfHttpResponse_getStatus(const sfHttpResponse* httpResponse);
unsigned int   sfHttpResponse_getMajorVersion(const sfHttpResponse* httpResponse);
unsigned int   sfHttpResponse_getMinorVersion(const sfHttpResponse* httpResponse);
const char*    sfHttpResponse_getBody(const sfHttpResponse* httpResponse);

sfHttp*         sfHttp_create(void);
void            sfHttp_destroy(sfHttp* http);
void            sfHttp_setHost(sfHttp* http, const char* host, unsigned short port);
sfHttpResponse* sfHttp_sendRequest(sfHttp* http, const sfHttpRequest* request, sfTime timeout);

sfIpAddress sfIpAddress_fromString(const char* address);
sfIpAddress sfIpAddress_fromBytes(sfUint8 byte0, sfUint8 byte1, sfUint8 byte2, sfUint8 byte3);
sfIpAddress sfIpAddress_fromInteger(sfUint32 address);
void        sfIpAddress_toString(sfIpAddress address, char* string);
sfUint32    sfIpAddress_toInteger(sfIpAddress address);
sfIpAddress sfIpAddress_getLocalAddress(void);
sfIpAddress sfIpAddress_getPublicAddress(sfTime timeout);

sfPacket*   sfPacket_create(void);
sfPacket*   sfPacket_copy(const sfPacket* packet);
void        sfPacket_destroy(sfPacket* packet);
void        sfPacket_append(sfPacket* packet, const void* data, size_t sizeInBytes);
void        sfPacket_clear(sfPacket* packet);
const void* sfPacket_getData(const sfPacket* packet);
size_t      sfPacket_getDataSize(const sfPacket* packet);
sfBool      sfPacket_endOfPacket(const sfPacket* packet);
sfBool      sfPacket_canRead(const sfPacket* packet);
sfBool      sfPacket_readBool(sfPacket* packet);
sfInt8      sfPacket_readInt8(sfPacket* packet);
sfUint8     sfPacket_readUint8(sfPacket* packet);
sfInt16     sfPacket_readInt16(sfPacket* packet);
sfUint16    sfPacket_readUint16(sfPacket* packet);
sfInt32     sfPacket_readInt32(sfPacket* packet);
sfUint32    sfPacket_readUint32(sfPacket* packet);
float       sfPacket_readFloat(sfPacket* packet);
double      sfPacket_readDouble(sfPacket* packet);
void        sfPacket_readString(sfPacket* packet, char* string);
void        sfPacket_readWideString(sfPacket* packet, wchar_t* string);
void        sfPacket_writeBool(sfPacket* packet, sfBool);
void        sfPacket_writeInt8(sfPacket* packet, sfInt8);
void        sfPacket_writeUint8(sfPacket* packet, sfUint8);
void        sfPacket_writeInt16(sfPacket* packet, sfInt16);
void        sfPacket_writeUint16(sfPacket* packet, sfUint16);
void        sfPacket_writeInt32(sfPacket* packet, sfInt32);
void        sfPacket_writeUint32(sfPacket* packet, sfUint32);
void        sfPacket_writeFloat(sfPacket* packet, float);
void        sfPacket_writeDouble(sfPacket* packet, double);
void        sfPacket_writeString(sfPacket* packet, const char* string);
void        sfPacket_writeWideString(sfPacket* packet, const wchar_t* string);

sfSocketSelector* sfSocketSelector_create(void);
sfSocketSelector* sfSocketSelector_copy(const sfSocketSelector* selector);
void              sfSocketSelector_destroy(sfSocketSelector* selector);
void              sfSocketSelector_addTcpListener(sfSocketSelector* selector, sfTcpListener* socket);
void              sfSocketSelector_addTcpSocket(sfSocketSelector* selector, sfTcpSocket* socket);
void              sfSocketSelector_addUdpSocket(sfSocketSelector* selector, sfUdpSocket* socket);
void              sfSocketSelector_removeTcpListener(sfSocketSelector* selector, sfTcpListener* socket);
void              sfSocketSelector_removeTcpSocket(sfSocketSelector* selector, sfTcpSocket* socket);
void              sfSocketSelector_removeUdpSocket(sfSocketSelector* selector, sfUdpSocket* socket);
void              sfSocketSelector_clear(sfSocketSelector* selector);
sfBool            sfSocketSelector_wait(sfSocketSelector* selector, sfTime timeout);
sfBool            sfSocketSelector_isTcpListenerReady(const sfSocketSelector* selector, sfTcpListener* socket);
sfBool            sfSocketSelector_isTcpSocketReady(const sfSocketSelector* selector, sfTcpSocket* socket);
sfBool            sfSocketSelector_isUdpSocketReady(const sfSocketSelector* selector, sfUdpSocket* socket);

sfTcpListener* sfTcpListener_create(void);
void           sfTcpListener_destroy(sfTcpListener* listener);
void           sfTcpListener_setBlocking(sfTcpListener* listener, sfBool blocking);
sfBool         sfTcpListener_isBlocking(const sfTcpListener* listener);
unsigned short sfTcpListener_getLocalPort(const sfTcpListener* listener);
sfSocketStatus sfTcpListener_listen(sfTcpListener* listener, unsigned short port);
sfSocketStatus sfTcpListener_accept(sfTcpListener* listener, sfTcpSocket** connected);

sfTcpSocket*   sfTcpSocket_create(void);
void           sfTcpSocket_destroy(sfTcpSocket* socket);
void           sfTcpSocket_setBlocking(sfTcpSocket* socket, sfBool blocking);
sfBool         sfTcpSocket_isBlocking(const sfTcpSocket* socket);
unsigned short sfTcpSocket_getLocalPort(const sfTcpSocket* socket);
sfIpAddress    sfTcpSocket_getRemoteAddress(const sfTcpSocket* socket);
unsigned short sfTcpSocket_getRemotePort(const sfTcpSocket* socket);
sfSocketStatus sfTcpSocket_connect(sfTcpSocket* socket, sfIpAddress host, unsigned short port, sfTime timeout);
void           sfTcpSocket_disconnect(sfTcpSocket* socket);
sfSocketStatus sfTcpSocket_send(sfTcpSocket* socket, const void* data, size_t size);
sfSocketStatus sfTcpSocket_receive(sfTcpSocket* socket, void* data, size_t maxSize, size_t* sizeReceived);
sfSocketStatus sfTcpSocket_sendPacket(sfTcpSocket* socket, sfPacket* packet);
sfSocketStatus sfTcpSocket_receivePacket(sfTcpSocket* socket, sfPacket* packet);

sfUdpSocket*   sfUdpSocket_create(void);
void           sfUdpSocket_destroy(sfUdpSocket* socket);
void           sfUdpSocket_setBlocking(sfUdpSocket* socket, sfBool blocking);
sfBool         sfUdpSocket_isBlocking(const sfUdpSocket* socket);
unsigned short sfUdpSocket_getLocalPort(const sfUdpSocket* socket);
sfSocketStatus sfUdpSocket_bind(sfUdpSocket* socket, unsigned short port);
void           sfUdpSocket_unbind(sfUdpSocket* socket);
sfSocketStatus sfUdpSocket_send(sfUdpSocket* socket, const void* data, size_t size, sfIpAddress address, unsigned short port);
sfSocketStatus sfUdpSocket_receive(sfUdpSocket* socket, void* data, size_t maxSize, size_t* sizeReceived, sfIpAddress* address, unsigned short* port);
sfSocketStatus sfUdpSocket_sendPacket(sfUdpSocket* socket, sfPacket* packet, sfIpAddress address, unsigned short port);
sfSocketStatus sfUdpSocket_receivePacket(sfUdpSocket* socket, sfPacket* packet, sfIpAddress* address, unsigned short* port);
unsigned int   sfUdpSocket_maxDatagramSize();
]];


local sfNetwork = ffi.load('csfml-network-2');
if sfNetwork then



end -- sfNetwork