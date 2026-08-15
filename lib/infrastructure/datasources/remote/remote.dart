/// Remote data sources — all transport-level calls (Serverpod, social SDKs)
/// are isolated here; nothing above this layer may perform network access.
library;

export 'auth_remote_data_source.dart';
export 'social_auth_remote_data_source.dart';
export 'dtos/dtos.dart';
