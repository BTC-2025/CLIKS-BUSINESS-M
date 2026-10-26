// Customizable Subscription & Instant Add-Ons Builder View
// Exported and organized for flexible consumption across the app.

export '../../billing/widgets/customizable_plan_builder_section.dart';

import 'package:flutter/material.dart';
import '../../billing/widgets/customizable_plan_builder_section.dart';

class CustomizablePlanView extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onScrollToActivePlan;
  final VoidCallback? onScrollToBillingHistory;

  const CustomizablePlanView({
    super.key,
    this.isMobile = false,
    this.onScrollToActivePlan,
    this.onScrollToBillingHistory,
  });

  @override
  Widget build(BuildContext context) {
    return CustomizablePlanBuilderSection(
      isMobile: isMobile,
      onScrollToActivePlan: onScrollToActivePlan,
      onScrollToBillingHistory: onScrollToBillingHistory,
    );
  }
}
