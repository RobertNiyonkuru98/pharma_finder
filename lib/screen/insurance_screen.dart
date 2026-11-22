// Compatibility export.
//
// The login and signup screens import `screen/insurance_screen.dart`. The real
// implementation now lives under `features/insurance/` so it follows the
// Clean Architecture layering; this file keeps the existing imports working
// without editing Igihozo's screens.
export 'package:pharma_finder/features/insurance/presentation/screens/insurance_screen.dart';
