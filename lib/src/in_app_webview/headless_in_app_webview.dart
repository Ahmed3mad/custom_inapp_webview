import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../context_menu.dart';
import '../types.dart';
import '../_uuid_generator.dart';
import 'webview.dart';
import 'in_app_webview_controller.dart';
import 'in_app_webview_options.dart';

///Class that represents a WebView in headless mode.
///It can be used to run a WebView in background without attaching an `InAppWebView` to the widget tree.
///
///Remember to dispose it when you don't need it anymore.
class HeadlessInAppWebView implements WebView {
  String uuid;
  bool _isDisposed = true;
  static const MethodChannel _sharedChannel =
      const MethodChannel('com.pichillilorenzo/flutter_headless_inappwebview');

  ///WebView Controller that can be used to access the [InAppWebViewController] API.
  InAppWebViewController webViewController;

  ///The window id of a [CreateWindowAction.windowId].
  final int windowId;

  HeadlessInAppWebView(
      {this.windowId,
      this.onWebViewCreated,
      this.onLoadStart,
      this.onLoadStop,
      this.onLoadError,
      this.onLoadHttpError,
      this.onProgressChanged,
      this.onConsoleMessage,
      this.shouldOverrideUrlLoading,
      this.onLoadResource,
      this.onScrollChanged,
      this.onDownloadStart,
      this.onLoadResourceCustomScheme,
      this.onCreateWindow,
      this.onCloseWindow,
      this.onJsAlert,
      this.onJsConfirm,
      this.onJsPrompt,
      this.onReceivedHttpAuthRequest,
      this.onReceivedServerTrustAuthRequest,
      this.onReceivedClientCertRequest,
      this.onFindResultReceived,
      this.shouldInterceptAjaxRequest,
      this.onAjaxReadyStateChange,
      this.onAjaxProgress,
      this.shouldInterceptFetchRequest,
      this.onUpdateVisitedHistory,
      this.onPrint,
      this.onLongPressHitTestResult,
      this.onEnterFullscreen,
      this.onExitFullscreen,
      this.onPageCommitVisible,
      this.onTitleChanged,
      this.onWindowFocus,
      this.onWindowBlur,
      this.androidOnSafeBrowsingHit,
      this.androidOnPermissionRequest,
      this.androidOnGeolocationPermissionsShowPrompt,
      this.androidOnGeolocationPermissionsHidePrompt,
      this.androidShouldInterceptRequest,
      this.androidOnRenderProcessGone,
      this.androidOnRenderProcessResponsive,
      this.androidOnRenderProcessUnresponsive,
      this.androidOnFormResubmission,
      this.androidOnScaleChanged,
      this.androidOnReceivedIcon,
      this.androidOnReceivedTouchIconUrl,
      this.androidOnJsBeforeUnload,
      this.androidOnReceivedLoginRequest,
      this.iosOnWebContentProcessDidTerminate,
      this.iosOnDidReceiveServerRedirectForProvisionalNavigation,
      this.iosOnNavigationResponse,
      this.iosShouldAllowDeprecatedTLS,
      this.initialUrlRequest,
      this.initialFile,
      this.initialData,
      this.initialOptions,
      this.contextMenu,
      this.initialUserScripts}) {
    uuid = UUID_GENERATOR.v4();
    webViewController = new InAppWebViewController(uuid, this);
  }

  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onHeadlessWebViewCreated":
        if (onWebViewCreated != null) {
          onWebViewCreated(webViewController);
        }
        break;
      default:
        return webViewController.handleMethod(call);
    }
  }

  ///Runs the headless WebView.
  Future<void> run() async {
    if (!_isDisposed) {
      return;
    }
    _isDisposed = false;
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    args.putIfAbsent(
        'params',
        () => <String, dynamic>{
              'initialUrlRequest': (this.initialUrlRequest ??
                      URLRequest(url: Uri.parse("about:blank")))
                  .toMap(),
              'initialFile': this.initialFile,
              'initialData': this.initialData?.toMap(),
              'initialOptions': this.initialOptions?.toMap() ?? {},
              'contextMenu': this.contextMenu?.toMap() ?? {},
              'windowId': this.windowId,
              'initialUserScripts':
                  this.initialUserScripts?.map((e) => e.toMap())?.toList() ?? [],
            });
    await _sharedChannel.invokeMethod('createHeadlessWebView', args);
  }

  ///Disposes the headless WebView.
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('uuid', () => uuid);
    await _sharedChannel.invokeMethod('disposeHeadlessWebView', args);
    _isDisposed = true;
  }

  @override
  final void Function(InAppWebViewController controller)
      androidOnGeolocationPermissionsHidePrompt;

  @override
  final Future<GeolocationPermissionShowPromptResponse> Function(
          InAppWebViewController controller, String origin)
      androidOnGeolocationPermissionsShowPrompt;

  @override
  final Future<PermissionRequestResponse> Function(
      InAppWebViewController controller,
      String origin,
      List<String> resources) androidOnPermissionRequest;

  @override
  final Future<SafeBrowsingResponse> Function(
      InAppWebViewController controller,
      Uri url,
      SafeBrowsingThreat threatType) androidOnSafeBrowsingHit;

  @override
  final InAppWebViewInitialData initialData;

  @override
  final String initialFile;

  @override
  final InAppWebViewGroupOptions initialOptions;

  @override
  final ContextMenu contextMenu;

  @override
  final URLRequest initialUrlRequest;

  @override
  final UnmodifiableListView<UserScript> initialUserScripts;

  @override
  final void Function(InAppWebViewController controller, Uri url)
      onPageCommitVisible;

  @override
  final void Function(InAppWebViewController controller, String title)
      onTitleChanged;

  @override
  final void Function(InAppWebViewController controller)
      iosOnDidReceiveServerRedirectForProvisionalNavigation;

  @override
  final void Function(InAppWebViewController controller)
      iosOnWebContentProcessDidTerminate;

  @override
  final Future<IOSNavigationResponseAction> Function(
      InAppWebViewController controller,
      IOSWKNavigationResponse navigationResponse) iosOnNavigationResponse;

  @override
  final Future<IOSShouldAllowDeprecatedTLSAction> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) iosShouldAllowDeprecatedTLS;

  @override
  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)
      onAjaxProgress;

  @override
  final Future<AjaxRequestAction> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)
      onAjaxReadyStateChange;

  @override
  final void Function(
          InAppWebViewController controller, ConsoleMessage consoleMessage)
      onConsoleMessage;

  @override
  final Future<bool> Function(InAppWebViewController controller,
      CreateWindowAction createWindowAction) onCreateWindow;

  @override
  final void Function(InAppWebViewController controller) onCloseWindow;

  @override
  final void Function(InAppWebViewController controller) onWindowFocus;

  @override
  final void Function(InAppWebViewController controller) onWindowBlur;

  @override
  final void Function(InAppWebViewController controller, Uri url)
      onDownloadStart;

  @override
  final void Function(InAppWebViewController controller, int activeMatchOrdinal,
      int numberOfMatches, bool isDoneCounting) onFindResultReceived;

  @override
  final Future<JsAlertResponse> Function(
          InAppWebViewController controller, JsAlertRequest jsAlertRequest)
      onJsAlert;

  @override
  final Future<JsConfirmResponse> Function(
          InAppWebViewController controller, JsConfirmRequest jsConfirmRequest)
      onJsConfirm;

  @override
  final Future<JsPromptResponse> Function(
          InAppWebViewController controller, JsPromptRequest jsPromptRequest)
      onJsPrompt;

  @override
  final void Function(InAppWebViewController controller, Uri url, int code,
      String message) onLoadError;

  @override
  final void Function(InAppWebViewController controller, Uri url,
      int statusCode, String description) onLoadHttpError;

  @override
  final void Function(
          InAppWebViewController controller, LoadedResource resource)
      onLoadResource;

  @override
  final Future<CustomSchemeResponse> Function(
      InAppWebViewController controller, Uri url) onLoadResourceCustomScheme;

  @override
  final void Function(InAppWebViewController controller, Uri url) onLoadStart;

  @override
  final void Function(InAppWebViewController controller, Uri url) onLoadStop;

  @override
  final void Function(InAppWebViewController controller,
      InAppWebViewHitTestResult hitTestResult) onLongPressHitTestResult;

  @override
  final void Function(InAppWebViewController controller, Uri url) onPrint;

  @override
  final void Function(InAppWebViewController controller, int progress)
      onProgressChanged;

  @override
  final Future<ClientCertResponse> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge) onReceivedClientCertRequest;

  @override
  final Future<HttpAuthResponse> Function(InAppWebViewController controller,
      URLAuthenticationChallenge challenge) onReceivedHttpAuthRequest;

  @override
  final Future<ServerTrustAuthResponse> Function(
      InAppWebViewController controller,
      URLAuthenticationChallenge challenge) onReceivedServerTrustAuthRequest;

  @override
  final void Function(InAppWebViewController controller, int x, int y)
      onScrollChanged;

  @override
  final void Function(
          InAppWebViewController controller, Uri url, bool androidIsReload)
      onUpdateVisitedHistory;

  @override
  final void Function(InAppWebViewController controller) onWebViewCreated;

  @override
  final Future<AjaxRequest> Function(
          InAppWebViewController controller, AjaxRequest ajaxRequest)
      shouldInterceptAjaxRequest;

  @override
  final Future<FetchRequest> Function(
          InAppWebViewController controller, FetchRequest fetchRequest)
      shouldInterceptFetchRequest;

  @override
  final Future<NavigationActionPolicy> Function(
          InAppWebViewController controller, NavigationAction navigationAction)
      shouldOverrideUrlLoading;

  @override
  final void Function(InAppWebViewController controller) onEnterFullscreen;

  @override
  final void Function(InAppWebViewController controller) onExitFullscreen;

  @override
  final Future<WebResourceResponse> Function(
          InAppWebViewController controller, WebResourceRequest request)
      androidShouldInterceptRequest;

  @override
  final Future<WebViewRenderProcessAction> Function(
          InAppWebViewController controller, Uri url)
      androidOnRenderProcessUnresponsive;

  @override
  final Future<WebViewRenderProcessAction> Function(
          InAppWebViewController controller, Uri url)
      androidOnRenderProcessResponsive;

  @override
  final void Function(
          InAppWebViewController controller, RenderProcessGoneDetail detail)
      androidOnRenderProcessGone;

  @override
  final Future<FormResubmissionAction> Function(
      InAppWebViewController controller, Uri url) androidOnFormResubmission;

  @override
  final void Function(
          InAppWebViewController controller, double oldScale, double newScale)
      androidOnScaleChanged;

  @override
  final void Function(InAppWebViewController controller, Uint8List icon)
      androidOnReceivedIcon;

  @override
  final void Function(
          InAppWebViewController controller, Uri url, bool precomposed)
      androidOnReceivedTouchIconUrl;

  @override
  final Future<JsBeforeUnloadResponse> Function(
      InAppWebViewController controller,
      JsBeforeUnloadRequest jsBeforeUnloadRequest) androidOnJsBeforeUnload;

  @override
  final void Function(
          InAppWebViewController controller, LoginRequest loginRequest)
      androidOnReceivedLoginRequest;
}
