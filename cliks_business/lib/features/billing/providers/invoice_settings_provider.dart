import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvoiceSettingsState {
  final List<String> invoiceTypes;
  final List<String> invoiceStatuses;
  final List<String> paymentModes;
  final List<String> termsList;
  final List<String> unitsList;
  final List<String> gstRates;
  final List<String> discountTypes;

  InvoiceSettingsState({
    required this.invoiceTypes,
    required this.invoiceStatuses,
    required this.paymentModes,
    required this.termsList,
    required this.unitsList,
    required this.gstRates,
    required this.discountTypes,
  });

  InvoiceSettingsState copyWith({
    List<String>? invoiceTypes,
    List<String>? invoiceStatuses,
    List<String>? paymentModes,
    List<String>? termsList,
    List<String>? unitsList,
    List<String>? gstRates,
    List<String>? discountTypes,
  }) {
    return InvoiceSettingsState(
      invoiceTypes: invoiceTypes ?? List.from(this.invoiceTypes),
      invoiceStatuses: invoiceStatuses ?? List.from(this.invoiceStatuses),
      paymentModes: paymentModes ?? List.from(this.paymentModes),
      termsList: termsList ?? List.from(this.termsList),
      unitsList: unitsList ?? List.from(this.unitsList),
      gstRates: gstRates ?? List.from(this.gstRates),
      discountTypes: discountTypes ?? List.from(this.discountTypes),
    );
  }
}

class InvoiceSettingsNotifier extends StateNotifier<InvoiceSettingsState> {
  InvoiceSettingsNotifier()
      : super(InvoiceSettingsState(
          invoiceTypes: ['GST', 'Non-GST', 'Quotation', 'Proforma Invoice'],
          invoiceStatuses: ['Draft', 'Unpaid', 'Paid', 'Overdue'],
          paymentModes: ['Cash', 'UPI', 'Bank', 'Credit'],
          termsList: ['Due on Receipt', 'Net 15 Days', 'Net 30 Days', 'Net 60 Days'],
          unitsList: ['Pcs', 'Kg', 'Mtr', 'Box', 'Nos'],
          gstRates: ['0%', '5%', '12%', '18%', '28%'],
          discountTypes: ['Percentage', 'Flat Amount'],
        ));

  void updateSettings(InvoiceSettingsState newState) {
    state = newState;
  }
}

final invoiceSettingsProvider =
    StateNotifierProvider<InvoiceSettingsNotifier, InvoiceSettingsState>((ref) {
  return InvoiceSettingsNotifier();
});
