# webviewd - D bindings for webview

## Usage
```dlang
import webview;

void main()
{
    auto window = webview_create(1, null);
    webview_set_title(window, cast(char*)"Webview test");
    webview_set_size(window, 1024, 720, webview_hint_t.WEBVIEW_HINT_NONE);
    webview_navigate(window, cast(char*)"https://wikipedia.com/");
    webview_run(window);
}
```

#### MingW is required for Windows

## Reference
[webview](https://github.com/webview/webview) - A tiny cross-platform webview library for C/C++ to build modern cross-platform GUIs.

## License
Licensed under the MIT License.
