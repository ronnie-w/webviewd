module webview;

/*
 * MIT License
 *
 * Copyright (c) 2017 Serge Zaitsev
 * Copyright (c) 2022 Steffen André Langnes
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

extern (C):

/// @file webview.h

/**
 * Used to specify function linkage such as extern, inline, etc.
 *
 * When @c WEBVIEW_API is not already defined, the defaults are as follows:
 *
 * - @c inline when compiling C++ code.
 * - @c extern when compiling C code.
 *
 * The following macros can be used to automatically set an appropriate
 * value for @c WEBVIEW_API:
 *
 * - Define @c WEBVIEW_BUILD_SHARED when building a shared library.
 * - Define @c WEBVIEW_SHARED when using a shared library.
 * - Define @c WEBVIEW_STATIC when building or using a static library.
 */

/// @name Version
/// @{

/// The current library major version.
enum WEBVIEW_VERSION_MAJOR = 0;

/// The current library minor version.
enum WEBVIEW_VERSION_MINOR = 11;

/// The current library patch version.
enum WEBVIEW_VERSION_PATCH = 0;

/// SemVer 2.0.0 pre-release labels prefixed with "-".
enum WEBVIEW_VERSION_PRE_RELEASE = "";

/// SemVer 2.0.0 build metadata prefixed with "+".
enum WEBVIEW_VERSION_BUILD_METADATA = "";

/// @}

/// @name Used internally
/// @{

/// Utility macro for stringifying a macro argument.
extern (D) string WEBVIEW_STRINGIFY(T)(auto ref T x)
{
    import std.conv : to;

    return to!string(x);
}

/// Utility macro for stringifying the result of a macro argument expansion.
alias WEBVIEW_EXPAND_AND_STRINGIFY = WEBVIEW_STRINGIFY;

/// @}

/// @name Version
/// @{

/// SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.

/// @}

/// Holds the elements of a MAJOR.MINOR.PATCH version number.
struct webview_version_t
{
    /// Major version.
    uint major;
    /// Minor version.
    uint minor;
    /// Patch version.
    uint patch;
}

/// Holds the library's version information.
struct webview_version_info_t
{
    /// The elements of the version number.
    webview_version_t version_;
    /// SemVer 2.0.0 version number in MAJOR.MINOR.PATCH format.
    char[32] version_number;
    /// SemVer 2.0.0 pre-release labels prefixed with "-" if specified, otherwise
    /// an empty string.
    char[48] pre_release;
    /// SemVer 2.0.0 build metadata prefixed with "+", otherwise an empty string.
    char[48] build_metadata;
}

/// Pointer to a webview instance.
alias webview_t = void*;

/// Native handle kind. The actual type depends on the backend.
enum webview_native_handle_kind_t
{
    /// Top-level window. @c GtkWindow pointer (GTK), @c NSWindow pointer (Cocoa)
    /// or @c HWND (Win32).
    WEBVIEW_NATIVE_HANDLE_KIND_UI_WINDOW = 0,
    /// Browser widget. @c GtkWidget pointer (GTK), @c NSView pointer (Cocoa) or
    /// @c HWND (Win32).
    WEBVIEW_NATIVE_HANDLE_KIND_UI_WIDGET = 1,
    /// Browser controller. @c WebKitWebView pointer (WebKitGTK), @c WKWebView
    /// pointer (Cocoa/WebKit) or @c ICoreWebView2Controller pointer
    /// (Win32/WebView2).
    WEBVIEW_NATIVE_HANDLE_KIND_BROWSER_CONTROLLER = 2
}

/// Window size hints
enum webview_hint_t
{
    /// Width and height are default size.
    WEBVIEW_HINT_NONE = 0,
    /// Width and height are minimum bounds.
    WEBVIEW_HINT_MIN = 1,
    /// Width and height are maximum bounds.
    WEBVIEW_HINT_MAX = 2,
    /// Window size can not be changed by a user.
    WEBVIEW_HINT_FIXED = 3
}

/// @name Errors
/// @{

/**
 * @brief Error codes returned to callers of the API.
 *
 * The following codes are commonly used in the library:
 * - @c WEBVIEW_ERROR_OK
 * - @c WEBVIEW_ERROR_UNSPECIFIED
 * - @c WEBVIEW_ERROR_INVALID_ARGUMENT
 * - @c WEBVIEW_ERROR_INVALID_STATE
 *
 * With the exception of @c WEBVIEW_ERROR_OK which is normally expected,
 * the other common codes do not normally need to be handled specifically.
 * Refer to specific functions regarding handling of other codes.
 */
enum webview_error_t
{
    /// Missing dependency.
    WEBVIEW_ERROR_MISSING_DEPENDENCY = -5,
    /// Operation canceled.
    WEBVIEW_ERROR_CANCELED = -4,
    /// Invalid state detected.
    WEBVIEW_ERROR_INVALID_STATE = -3,
    /// One or more invalid arguments have been specified e.g. in a function call.
    WEBVIEW_ERROR_INVALID_ARGUMENT = -2,
    /// An unspecified error occurred. A more specific error code may be needed.
    WEBVIEW_ERROR_UNSPECIFIED = -1,
    /// OK/Success. Functions that return error codes will typically return this
    /// to signify successful operations.
    WEBVIEW_ERROR_OK = 0,
    /// Signifies that something already exists.
    WEBVIEW_ERROR_DUPLICATE = 1,
    /// Signifies that something does not exist.
    WEBVIEW_ERROR_NOT_FOUND = 2
}

/// @brief Evaluates to @c TRUE for error codes indicating success or
///        additional information.
extern (D) auto WEBVIEW_SUCCEEDED(T)(auto ref T error)
{
    return cast(int)error >= 0;
}

/// Evaluates to @c TRUE if the given error code indicates failure.
extern (D) auto WEBVIEW_FAILED(T)(auto ref T error)
{
    return cast(int)error < 0;
}

/// @}

/**
 * Creates a new webview instance.
 *
 * @param debug Enable developer tools if supported by the backend.
 * @param window Optional native window handle, i.e. @c GtkWindow pointer
 *        @c NSWindow pointer (Cocoa) or @c HWND (Win32). If non-null,
 *        the webview widget is embedded into the given window, and the
 *        caller is expected to assume responsibility for the window as
 *        well as application lifecycle. If the window handle is null,
 *        a new window is created and both the window and application
 *        lifecycle are managed by the webview instance.
 * @remark Win32: The function also accepts a pointer to @c HWND (Win32) in the
 *         window parameter for backward compatibility.
 * @remark Win32/WebView2: @c CoInitializeEx should be called with
 *         @c COINIT_APARTMENTTHREADED before attempting to call this function
 *         with an existing window. Omitting this step may cause WebView2
 *         initialization to fail.
 * @return @c NULL on failure. Creation can fail for various reasons such
 *         as when required runtime dependencies are missing or when window
 *         creation fails.
 * @retval WEBVIEW_ERROR_MISSING_DEPENDENCY
 *         May be returned if WebView2 is unavailable on Windows.
 */
webview_t webview_create(int debug_, void* window);

/**
 * Destroys a webview instance and closes the native window.
 *
 * @param w The webview instance.
 */
webview_error_t webview_destroy(webview_t w);

/**
 * Runs the main loop until it's terminated.
 *
 * @param w The webview instance.
 */
webview_error_t webview_run(webview_t w);

/**
 * Stops the main loop. It is safe to call this function from another other
 * background thread.
 *
 * @param w The webview instance.
 */
webview_error_t webview_terminate(webview_t w);

/**
 * Schedules a function to be invoked on the thread with the run/event loop.
 * Use this function e.g. to interact with the library or native handles.
 *
 * @param w The webview instance.
 * @param fn The function to be invoked.
 * @param arg An optional argument passed along to the callback function.
 */
webview_error_t webview_dispatch(webview_t w, void function(webview_t w, void* arg) fn,
        void* arg);

/**
 * Returns the native handle of the window associated with the webview instance.
 * The handle can be a @c GtkWindow pointer (GTK), @c NSWindow pointer (Cocoa)
 * or @c HWND (Win32).
 *
 * @param w The webview instance.
 * @return The handle of the native window.
 */
void* webview_get_window(webview_t w);

/**
 * Get a native handle of choice.
 *
 * @param w The webview instance.
 * @param kind The kind of handle to retrieve.
 * @return The native handle or @c NULL.
 * @since 0.11
 */
void* webview_get_native_handle(webview_t w, webview_native_handle_kind_t kind);

/**
 * Updates the title of the native window.
 *
 * @param w The webview instance.
 * @param title The new title.
 */
webview_error_t webview_set_title(webview_t w, const(char)* title);

/**
 * Updates the size of the native window.
 *
 * @param w The webview instance.
 * @param width New width.
 * @param height New height.
 * @param hints Size hints.
 */
webview_error_t webview_set_size(webview_t w, int width, int height, webview_hint_t hints);

/**
 * Navigates webview to the given URL. URL may be a properly encoded data URI.
 *
 * Example:
 * @code{.c}
 * webview_navigate(w, "https://github.com/webview/webview");
 * webview_navigate(w, "data:text/html,%3Ch1%3EHello%3C%2Fh1%3E");
 * webview_navigate(w, "data:text/html;base64,PGgxPkhlbGxvPC9oMT4=");
 * @endcode
 *
 * @param w The webview instance.
 * @param url URL.
 */
webview_error_t webview_navigate(webview_t w, const(char)* url);

/**
 * Load HTML content into the webview.
 *
 * Example:
 * @code{.c}
 * webview_set_html(w, "<h1>Hello</h1>");
 * @endcode
 *
 * @param w The webview instance.
 * @param html HTML content.
 */
webview_error_t webview_set_html(webview_t w, const(char)* html);

/**
 * Injects JavaScript code to be executed immediately upon loading a page.
 * The code will be executed before @c window.onload.
 *
 * @param w The webview instance.
 * @param js JS content.
 */
webview_error_t webview_init(webview_t w, const(char)* js);

/**
 * Evaluates arbitrary JavaScript code.
 *
 * Use bindings if you need to communicate the result of the evaluation.
 *
 * @param w The webview instance.
 * @param js JS content.
 */
webview_error_t webview_eval(webview_t w, const(char)* js);

/**
 * Binds a function pointer to a new global JavaScript function.
 *
 * Internally, JS glue code is injected to create the JS function by the
 * given name. The callback function is passed a request identifier,
 * a request string and a user-provided argument. The request string is
 * a JSON array of the arguments passed to the JS function.
 *
 * @param w The webview instance.
 * @param name Name of the JS function.
 * @param fn Callback function.
 * @param arg User argument.
 * @retval WEBVIEW_ERROR_DUPLICATE
 *         A binding already exists with the specified name.
 */
webview_error_t webview_bind(webview_t w, const(char)* name,
        void function(const(char)* id, const(char)* req, void* arg) fn, void* arg);

/**
 * Removes a binding created with webview_bind().
 *
 * @param w The webview instance.
 * @param name Name of the binding.
 * @retval WEBVIEW_ERROR_NOT_FOUND No binding exists with the specified name.
 */
webview_error_t webview_unbind(webview_t w, const(char)* name);

/**
 * Responds to a binding call from the JS side.
 *
 * @param w The webview instance.
 * @param id The identifier of the binding call. Pass along the value received
 *           in the binding handler (see webview_bind()).
 * @param status A status of zero tells the JS side that the binding call was
 *               succesful; any other value indicates an error.
 * @param result The result of the binding call to be returned to the JS side.
 *               This must either be a valid JSON value or an empty string for
 *               the primitive JS value @c undefined.
 */
webview_error_t webview_return(webview_t w, const(char)* id, int status, const(char)* result);

/**
 * Get the library's version information.
 *
 * @since 0.10
 */
const(webview_version_info_t)* webview_version();

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-member-init, hicpp-member-init)

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTNEXTLINE(bugprone-sizeof-expression): pointer to aggregate is OK

// namespace detail

// NOLINTNEXTLINE(bugprone-throw-keyword-missing)

// The library's version information.

// Converts a narrow (UTF-8-encoded) string into a wide (UTF-16-encoded) string.

// Failed to convert string from UTF-8 to UTF-16

// Converts a wide (UTF-16-encoded) string into a narrow (UTF-8-encoded) string.

// WC_ERR_INVALID_CHARS

// Failed to convert string from UTF-16 to UTF-8

// fallthrough

// Calculate the size of the resulting string.
// Add space for the double quotes.

// '\' and a single following character

// '\', 'u', 4 digits

// Allocate memory for resulting string only once.

// Copy string while escaping characters.

// NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)

// Escape as \u00xx

// NOLINTBEGIN(cppcoreguidelines-pro-bounds-constant-array-index)

// NOLINTEND(cppcoreguidelines-pro-bounds-constant-array-index)

// Should have calculated the exact amount of memory needed

// TODO: support unicode decoding

// Holds a symbol name and associated type for code clarity.

// Loads a native shared library and allows one to get addresses for those
// symbols.

// Returns true if the library is currently loaded; otherwise false.

// Get the address for the specified symbol or nullptr if not found.

// NOLINTBEGIN(cppcoreguidelines-pro-type-reinterpret-cast)

// NOLINTEND(cppcoreguidelines-pro-type-reinterpret-cast)

// Returns true if the library is currently loaded; otherwise false.

// Returns true if the library by the given name is currently loaded; otherwise false.

// This function is called upon execution of the bound JS function

// This user-supplied argument is passed to the callback

// Synchronous bind

/*arg*/

// Asynchronous bind

// NOLINTNEXTLINE(readability-container-contains): contains() requires C++20

// Notify that a binding was created if the init script has already
// set things up.

// Notify that a binding was created if the init script has already
// set things up.

// NOLINTNEXTLINE(modernize-avoid-bind): Lambda with move requires C++14

// namespace detail

// namespace webview

//
// ====================================================================
//
// This implementation uses webkit2gtk backend. It requires gtk+3.0 and
// webkit2gtk-4.0 libraries. Proper compiler flags can be retrieved via:
//
//   pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0
//
// ====================================================================
//

// Namespace containing workaround for WebKit 2.42 when using NVIDIA GPU
// driver.
// See WebKit bug: https://bugs.webkit.org/show_bug.cgi?id=261874
// Please remove all of the code in this namespace when it's no longer needed.

// Get environment variable. Not thread-safe.

// Set environment variable. Not thread-safe.

// Checks whether the NVIDIA GPU driver is used based on whether the kernel
// module is loaded.

// Checks whether the windowing system is Wayland.

// Checks whether the GDK X11 backend is used.
// See: https://docs.gtk.org/gdk3/class.DisplayManager.html

// NOLINT(misc-const-correctness)

// Checks whether WebKit is affected by bug when using DMA-BUF renderer.
// Returns true if all of the following conditions are met:
//  - WebKit version is >= 2.42 (please narrow this down when there's a fix).
//  - Environment variables are empty or not set:
//    - WEBKIT_DISABLE_DMABUF_RENDERER
//  - Windowing system is not Wayland.
//  - GDK backend is X11.
//  - NVIDIA GPU driver is used.

// TODO: Narrow down affected WebKit version when there's a fixed version

// Applies workaround for WebKit DMA-BUF bug if needed.
// See WebKit bug: https://bugs.webkit.org/show_bug.cgi?id=261874

// namespace webkit_dmabuf

// namespace webkit_symbols

// Widget destroyed along with window.

// Initialize webview widget

// Disconnect handlers to avoid callbacks invoked during destruction.

// Needed for the window to close immediately.

// This defines either MIN_SIZE, or MAX_SIZE, but not both:

// URI is null before content has begun loading.

/*scripts*/

// Blocks while depleting the run loop of events.

// namespace detail

// namespace webview

//
// ====================================================================
//
// This implementation uses Cocoa WKWebView backend on macOS. It is
// written using ObjC runtime and uses WKWebView class as a browser runtime.
// You should pass "-framework Webkit" flag to the compiler.
//
// ====================================================================
//

// A convenient template function for unconditionally casting the specified
// C-like function into a function that can be called with the given return
// type and arguments. Caller takes full responsibility for ensuring that
// the function call is valid. It is assumed that the function will not
// throw exceptions.

// Calls objc_msgSend.

// Wrapper around NSAutoreleasePool that drains the pool on destruction.

// namespace objc

// Convenient conversion of string literals.

// See comments related to application lifecycle in create_app_delegate().

// Only set the app delegate if it hasn't already been set.

// Start the main run loop so that the app delegate gets the
// NSApplicationDidFinishLaunchingNotification notification after the run
// loop has started in order to perform further initialization.
// We need to return from this constructor so this run loop is only
// temporary.
// Skip the main loop if this isn't the first instance of this class
// because the launch event is only sent once. Instead, proceed to
// create a window.

// Replace delegate to avoid callbacks and other bad things during
// destruction.

// Make sure to release the delegate we created.

// Needed for the window to close immediately.

// TODO: Figure out why m_manager is still alive after the autoreleasepool
// has been drained.

// URI is null before content has begun loading.

// Script is retained when added.

/*scripts*/

// Removing scripts decreases the retain count of each script.

// Avoid crash due to registering same class twice

// Note: Avoid registering the class name "AppDelegate" as it is the
// default name in projects created with Xcode, and using the same name
// causes objc_registerClassPair to crash.

// Avoid crash due to registering same class twice

// Avoid crash due to registering same class twice

// Show a panel for selecting files.

// Get the URLs for the selected files. If the modal was canceled
// then we pass null to the completion handler to signify
// cancellation.

// Invoke the completion handler block.

// Avoid crash due to registering same class twice

/*delegate*/
// See comments related to application lifecycle in create_app_delegate().

// Stop the main run loop so that we can return
// from the constructor.

// Activate the app if it is not bundled.
// Bundled apps launched from Finder are activated automatically but
// otherwise not. Activating the app even when it has been launched from
// Finder does not seem to be harmful but calling this function is rarely
// needed as proper activation is normally taken care of for us.
// Bundled apps have a default activation policy of
// NSApplicationActivationPolicyRegular while non-bundled apps have a
// default activation policy of NSApplicationActivationPolicyProhibited.

// "setActivationPolicy:" must be invoked before
// "activateIgnoringOtherApps:" for activation to work.

// Activate the app regardless of other active apps.
// This can be obtrusive so we only do it when necessary.

/*delegate*/ /*window*/
// Widget destroyed along with window.

// Main window

// Equivalent Obj-C:
// [[config preferences] setValue:@YES forKey:@"developerExtrasEnabled"];

// Equivalent Obj-C:
// [[config preferences] setValue:@YES forKey:@"fullScreenEnabled"];

// Equivalent Obj-C:
// [[config preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];

// Equivalent Obj-C:
// [[config preferences] setValue:@YES forKey:@"DOMPasteAllowed"];

// Explicitly make WKWebView inspectable via Safari on OS versions that
// disable the feature by default (macOS 13.3 and later) and support
// enabling it. According to Apple, the behavior on older OS versions is
// for content to always be inspectable in "debug builds".
// Testing shows that this is true for macOS 12.6 but somehow not 10.15.
// https://webkit.org/blog/13936/enabling-the-inspection-of-web-content-in-apps/

// Request the run loop to stop. This doesn't immediately stop the loop.

// The run loop will stop after processing an NSEvent.
// Event type: NSEventTypeApplicationDefined (macOS 10.12+),
//             NSApplicationDefined (macOS 10.0–10.12)

// Blocks while depleting the run loop of events.

// NSEventMaskAny
// NSDefaultRunLoopMode

// namespace detail

// namespace webview

//
// ====================================================================
//
// This implementation uses Win32 API to create a native window. It
// uses Edge/Chromium webview2 backend as a browser engine.
//
// ====================================================================
//

// Parses a version string with 1-4 integral components, e.g. "1.2.3.4".
// Missing or invalid components default to 0, and excess components are ignored.

// subrange begin
// subrange end
// component index

// Unused

/**
 * A wrapper around COM library initialization. Calls CoInitializeEx in the
 * constructor and CoUninitialize in the destructor.
 *
 * @exception exception Thrown if CoInitializeEx has already been called with a
 * different concurrency model.
 */

// We can safely continue as long as COM was either successfully
// initialized or already initialized.
// RPC_E_CHANGED_MODE means that CoInitializeEx was already called with
// a different concurrency model.

/*NTSTATUS*/

// namespace ntdll_symbols

// Use intptr_t as the underlying type because we need to
// reinterpret_cast<DPI_AWARENESS_CONTEXT> which is a pointer.
// Available since Windows 10, version 1607

// Available since Windows 10, version 1703

// namespace user32_symbols

// This undocumented value is used instead of DWMWA_USE_IMMERSIVE_DARK_MODE
// on Windows 10 older than build 19041 (2004/20H1).

// Documented as being supported since Windows 11 build 22000 (21H2) but it
// works since Windows 10 build 19041 (2004/20H1).

// namespace dwmapi_symbols

// namespace shcore_symbols

// Get the size of the data in bytes.

// Read the data.

// Remove trailing null-characters.

// Compare the specified version against the OS version.
// Returns less than 0 if the OS version is less.
// Returns 0 if the versions are equal.
// Returns greater than 0 if the specified version is greater.

// Use RtlGetVersion both to bypass potential issues related to
// VerifyVersionInfo and manifests, and because both GetVersion and
// GetVersionEx are deprecated.

// Windows 10, version 1703

// EnableNonClientDpiScaling is only needed with per monitor v1 awareness.

// USER_DEFAULT_SCREEN_DPI

// Default is light theme

// Use "immersive dark mode" on systems that support it.
// Changes the color of the window's title bar (light or dark).

// Try the modern, documented attribute before the older, undocumented one.

// Enable built-in WebView2Loader implementation by default.

// Link WebView2Loader.dll explicitly by default only if the built-in
// implementation is enabled.

// Explicit linking of WebView2Loader.dll should be used along with
// the built-in implementation.

// Gets the last component of a Windows native file path.
// For example, if the path is "C:\a\b" then the result is "b".

/* WEBVIEW_MSWEBVIEW2_BUILTIN_IMPL */

// namespace webview2_symbols
/* WEBVIEW_MSWEBVIEW2_BUILTIN_IMPL */

// namespace webview2_symbols
/* WEBVIEW_MSWEBVIEW2_EXPLICIT_LINK */

/* WEBVIEW_MSWEBVIEW2_EXPLICIT_LINK */

/* WEBVIEW_MSWEBVIEW2_EXPLICIT_LINK */

// Our API version is greater than the runtime API version.

// Our API version is greater than the runtime API version.

// The minimum WebView2 API version we need regardless of the SDK release
// actually used. The number comes from the SDK release version,
// e.g. 1.0.1150.38. To be safe the SDK should have a number that is greater
// than or equal to this number. The Edge browser webview client must
// have a number greater than or equal to this number.

// GUID for the stable release channel.

/* WEBVIEW_MSWEBVIEW2_BUILTIN_IMPL */

// namespace cast_info
// namespace mswebview2

// Checks whether the specified IID equals the IID of the specified type and
// if so casts the "this" pointer to T and returns it. Returns nullptr on
// mismatching IIDs.
// If ppv is specified then the pointer will also be assigned to *ppv.

// All of the COM interfaces we implement should be added here regardless
// of whether they are required.
// This is just to be on the safe side in case the WebView2 Runtime ever
// requests a pointer to an interface we implement.
// The WebView2 Runtime must at the very least be able to get a pointer to
// ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler when we use
// our custom WebView2 loader implementation, and observations have shown
// that it is the only interface requested in this case. None have been
// observed to be requested when using the official WebView2 loader.

// See try_create_environment() regarding
// HRESULT_FROM_WIN32(ERROR_INVALID_STATE).
// The result is E_ABORT if the parent window has been destroyed already.

/*sender*/

/*sender*/

// Set the function that will perform the initiating logic for creating
// the WebView2 environment.

// Retry creating a WebView2 environment.
// The initiating logic for creating the environment is defined by the
// caller of set_attempt_handler().

// WebView creation fails with HRESULT_FROM_WIN32(ERROR_INVALID_STATE) if
// a running instance using the same user data folder exists, and the
// Environment objects have different EnvironmentOptions.
// Source: https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment?view=webview2-1.0.1150.38

// Not entirely sure if this error code only applies to
// CreateCoreWebView2Controller so we check here as well.

// Give up.

// Create a top-level window.

/*WM_GETDPISCALEDSIZE*/

/*WM_DPICHANGED*/
// Windows 10: The size we get here is exactly what we supplied to WM_GETDPISCALEDSIZE.
// Windows 11: The size we get here is NOT what we supplied to WM_GETDPISCALEDSIZE.
// Due to this difference, don't use the suggested bounds.

// Create a window that WebView2 will be embedded into.

// Create a message-only window for internal messaging.

// Replace wndproc to avoid callbacks and other bad things during
// destruction.

// Not strictly needed for windows to close immediately but aligns
// behavior across backends.

// We need the message window in order to deplete the event queue.

// TODO: Skip if no content has begun loading yet. Can't check with
//       ICoreWebView2::get_Source because it returns "about:blank".

// Sadly we need to pump the even loop in order to get the script ID.

// TODO: There's a non-zero chance that we didn't get the script ID.
//       We need to convey the error somehow.

// Pump the message loop until WebView2 has finished initialization.

// The result will be equal to HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)
// if the WebView2 runtime is not installed.

// Detect light/dark mode change in system.

// Blocks while depleting the run loop of events.

// The app is expected to call CoInitializeEx before
// CreateCoreWebView2EnvironmentWithOptions.
// Source: https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl#createcorewebview2environmentwithoptions

// namespace detail

// namespace webview

/* WEBVIEW_GTK, WEBVIEW_COCOA, WEBVIEW_EDGE */

// namespace detail
// namespace webview

/* WEBVIEW_HEADER */
/* __cplusplus */
/* WEBVIEW_H */
