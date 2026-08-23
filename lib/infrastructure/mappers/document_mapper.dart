import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/document.dart';

/// Maps between the domain [BusinessDocument] and the protocol model.
@Injectable()
class DocumentMapper {
  const DocumentMapper();

  BusinessDocument fromModel(sdk.Document model) {
    return BusinessDocument(
      id: model.id ?? -1,
      businessId: model.businessId,
      fileName: model.fileName,
      kind: DocumentKind.fromName(model.kind.name),
      mimeType: model.mimeType,
      sizeBytes: model.sizeBytes,
      storagePath: model.storagePath,
      relatedEntityType: model.relatedEntityType,
      relatedEntityId: model.relatedEntityId,
      createdAt: model.createdAt,
    );
  }

  sdk.DocumentKind toProtocolKind(DocumentKind kind) =>
      sdk.DocumentKind.values.byName(kind.name);
}
