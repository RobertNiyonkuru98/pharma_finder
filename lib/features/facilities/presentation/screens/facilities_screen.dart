import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/facility.dart';
import '../cubit/facilities_cubit.dart';
import '../cubit/facilities_state.dart';

/// Template screen — the pattern every other feature copies.
///
/// Note the three branches: loading, empty/error, and loaded. A screen that
/// only renders the happy path loses marks, and looks broken on a real device.
class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find care')),
      body: BlocBuilder<FacilitiesCubit, FacilitiesState>(
        builder: (context, state) {
          if (state is FacilitiesLoading || state is FacilitiesInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FacilitiesError) {
            return Center(child: Text(state.message));
          }
          if (state is FacilitiesLoaded) {
            if (state.isEmpty) {
              return const Center(child: Text('No facilities match.'));
            }
            return ListView.separated(
              itemCount: state.facilities.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => FacilityTile(state.facilities[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class FacilityTile extends StatelessWidget {
  final Facility facility;

  const FacilityTile(this.facility, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        facility.type == 'pharmacy'
            ? Icons.local_pharmacy_outlined
            : Icons.local_hospital_outlined,
      ),
      title: Text(facility.name),
      subtitle: Text('${facility.area} · ${facility.openingHours}'),
      trailing: facility.hasStock
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : const Icon(Icons.error_outline, color: Colors.orange),
    );
  }
}
