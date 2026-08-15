import 'package:equatable/equatable.dart';

/// Time rounding mode, mirroring the server's `RoundingMode` enum.
enum RoundingMode {
  none,
  nearest,
  up;

  static RoundingMode fromName(String name) {
    return RoundingMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => RoundingMode.none,
    );
  }
}

/// Invoicing and time settings of a business.
class BusinessSettings extends Equatable {
  const BusinessSettings({
    this.paymentTermsDays = 14,
    this.invoiceNumberPrefix,
    this.invoiceNumberIncludeYear = true,
    this.invoiceNumberMinDigits = 4,
    this.roundingMode = RoundingMode.none,
    this.roundingGranularityMinutes = 1,
  });

  final int paymentTermsDays;
  final String? invoiceNumberPrefix;
  final bool invoiceNumberIncludeYear;
  final int invoiceNumberMinDigits;
  final RoundingMode roundingMode;
  final int roundingGranularityMinutes;

  BusinessSettings copyWith({
    int? paymentTermsDays,
    String? invoiceNumberPrefix,
    bool clearInvoiceNumberPrefix = false,
    bool? invoiceNumberIncludeYear,
    int? invoiceNumberMinDigits,
    RoundingMode? roundingMode,
    int? roundingGranularityMinutes,
  }) {
    return BusinessSettings(
      paymentTermsDays: paymentTermsDays ?? this.paymentTermsDays,
      invoiceNumberPrefix: clearInvoiceNumberPrefix
          ? null
          : (invoiceNumberPrefix ?? this.invoiceNumberPrefix),
      invoiceNumberIncludeYear:
          invoiceNumberIncludeYear ?? this.invoiceNumberIncludeYear,
      invoiceNumberMinDigits:
          invoiceNumberMinDigits ?? this.invoiceNumberMinDigits,
      roundingMode: roundingMode ?? this.roundingMode,
      roundingGranularityMinutes:
          roundingGranularityMinutes ?? this.roundingGranularityMinutes,
    );
  }

  @override
  List<Object?> get props => [
    paymentTermsDays,
    invoiceNumberPrefix,
    invoiceNumberIncludeYear,
    invoiceNumberMinDigits,
    roundingMode,
    roundingGranularityMinutes,
  ];
}
