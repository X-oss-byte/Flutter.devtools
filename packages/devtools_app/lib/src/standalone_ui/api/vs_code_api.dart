// Copyright 2023 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This class defines the API exposed by the Dart/Flutter extensions in VS
/// Code (and must match the implementation there).
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeApi {
  /// The capabilities of the instance of VS Code / Dart VS Code extension that
  /// we are connected to.
  ///
  /// All API calls should be guarded by checks of capabilities because the API
  /// may change over time.
  VsCodeCapabilities get capabilities;

  /// Informs the VS Code extension we are initialized, allowing it to send
  /// initial events to all streams with an initial set of data.
  Future<void> initialize();

  /// A stream of events for whenever the set of devices (or selected device)
  /// change in VS Code.
  ///
  /// An event with initial devices is sent after [initialize] is called.
  Stream<VsCodeDevicesEvent> get devicesChanged;

  /// A stream of events for whenever the set of debug sessions change or are
  /// updated in VS Code.
  ///
  /// An event with initial sessions is sent after [initialize] is called.
  Stream<VsCodeDebugSessionsEvent> get debugSessionsChanged;

  /// Executes a VS Code command.
  ///
  /// Commands can be native VS Code commands or commands registered by the
  /// Dart/Flutter extensions.
  ///
  /// Which commands are available is not part of the API contract so callers
  /// should take care when calling APIs that might evolve over time.
  Future<Object?> executeCommand(String command, [List<Object?>? arguments]);

  /// Changes the current Flutter device.
  ///
  /// The selected device is the same one shown in the status bar in VS Code.
  /// Calling this API will update the device for the whole VS Code extension.
  Future<bool> selectDevice(String id);

  /// Opens a specific DevTools [page] for the debug session with ID
  /// [debugSessionId].
  ///
  /// Depending on user settings, this may open embedded (the default) or in an
  /// external browser window.
  Future<void> openDevToolsPage(String debugSessionId, String page);

  static const jsonApiName = 'vsCode';

  static const jsonInitializeMethod = 'initialize';

  static const jsonExecuteCommandMethod = 'executeCommand';
  static const jsonExecuteCommandCommandParameter = 'command';
  static const jsonExecuteCommandArgumentsParameter = 'arguments';

  static const jsonDevicesChangedEvent = 'devicesChanged';

  static const jsonSelectDeviceMethod = 'selectDevice';
  static const jsonSelectDeviceIdParameter = 'id';

  static const openDevToolsPageMethod = 'openDevToolsPage';
  static const openDevToolsPageDebugSessionIdParameter = 'debugSessionId';
  static const openDevToolsPagePageParameter = 'page';

  static const jsonDebugSessionsChangedEvent = 'debugSessionsChanged';
}

/// This class defines a device exposed by the Dart/Flutter extensions in VS
/// Code (and must match the implementation there).
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeDevice {
  String get id;
  String get name;
  String? get category;
  bool get emulator;
  String? get emulatorId;
  bool get ephemeral;
  String get platform;
  String? get platformType;

  static const jsonIdField = 'id';
  static const jsonNameField = 'name';
  static const jsonCategoryField = 'category';
  static const jsonEmulatorField = 'emulator';
  static const jsonEmulatorIdField = 'emulatorId';
  static const jsonEphemeralField = 'ephemeral';
  static const jsonPlatformField = 'platform';
  static const jsonPlatformTypeField = 'platformType';
}

/// This class defines a debug session exposed by the Dart/Flutter extensions in
/// VS Code (and must match the implementation there).
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeDebugSession {
  String get id;
  String get name;
  String? get vmServiceUri;

  /// The mode the app is running in.
  ///
  /// These values are defined by Flutter and at the time of writing can include
  /// 'debug', 'profile', 'release' and 'jit_release'.
  ///
  /// This value may be unavailable (`null`) for Dart/Test sessions or those
  /// that have not fully started yet.
  String? get flutterMode;

  /// The ID of the device the Flutter app is running on, if available.
  String? get flutterDeviceId;

  /// The type of debugger session. If available, this is usually one of:
  ///
  /// - Dart        (dart run)
  /// - DartTest    (dart test)
  /// - Flutter     (flutter run)
  /// - FlutterTest (flutter test)
  /// - Web         (webdev serve)
  /// - WebTest     (webdev test)
  String? get debuggerType;

  static const jsonIdField = 'id';
  static const jsonNameField = 'name';
  static const jsonVmServiceUriField = 'vmServiceUri';
  static const jsonFlutterModeField = 'flutterMode';
  static const jsonFlutterDeviceIdField = 'flutterDeviceId';
  static const jsonDebuggerTypeField = 'debuggerType';
}

/// This class defines a device event sent by the Dart/Flutter extensions in VS
/// Code (and must match the implementation there).
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeDevicesEvent {
  /// The ID of the selected Flutter device in VS Code.
  ///
  /// This device can be changed with the `selectDevice` method but can also
  /// be changed by the VS Code extension (which will emit a new event).
  String? get selectedDeviceId;

  /// A list of the devices that are available to select.
  List<VsCodeDevice> get devices;

  static const jsonSelectedDeviceIdField = 'selectedDeviceId';
  static const jsonDevicesField = 'devices';
}

/// This class defines a debug session event sent by the Dart/Flutter extensions
/// in VS Code (and must match the implementation there).
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeDebugSessionsEvent {
  /// A list of debug sessions that are currently active in VS Code.
  List<VsCodeDebugSession> get sessions;

  static const jsonSessionsField = 'sessions';
}

/// This class defines the capabilities provided by the current version of the
/// Dart/Flutter extensions in VS Code.
///
/// All changes to this file should be backwards-compatible and use
/// [VsCodeCapabilities] to advertise which capabilities are available and
/// handle any changes in behaviour.
abstract interface class VsCodeCapabilities {
  /// Whether the `executeCommand` method is available to call to execute VS
  /// Code commands.
  bool get executeCommand;

  /// Whether the `selectDevice` method is available to call to change the
  /// selected Flutter device.
  bool get selectDevice;

  /// Whether the `openDevToolsPage` method is available call to open a specific
  /// DevTools page.
  bool get openDevToolsPage;

  static const jsonExecuteCommandField = 'executeCommand';
  static const jsonSelectDeviceField = 'selectDevice';
  static const openDevToolsPageField = 'openDevToolsPage';
}
