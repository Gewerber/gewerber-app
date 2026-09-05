import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business/business_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/repositories/business_repository.dart';

class _FakeBusinessRepository implements BusinessRepository {
  _FakeBusinessRepository({List<Business>? businesses, this.failLoad = false})
    : _businesses = List.of(businesses ?? const []);

  final List<Business> _businesses;
  bool failLoad;

  @override
  Future<List<Business>> listMine() async {
    if (failLoad) throw const NetworkException();
    return List.unmodifiable(_businesses);
  }

  @override
  Future<Business> create({
    required String name,
    LegalForm legalForm = LegalForm.einzelunternehmen,
    bool isKleinunternehmer = false,
    String? vatId,
    String? taxNumber,
    String? email,
    String? phone,
    Address? address,
    BusinessLocale locale = BusinessLocale.de,
    BusinessCurrency currency = BusinessCurrency.eur,
  }) async {
    final business = Business(
      id: _businesses.length + 1,
      name: name,
      legalForm: legalForm,
      isKleinunternehmer: isKleinunternehmer,
      vatId: vatId,
      taxNumber: taxNumber,
    );
    _businesses.add(business);
    return business;
  }

  @override
  Future<Business> update(Business business) async {
    final index = _businesses.indexWhere((value) => value.id == business.id);
    if (index < 0) throw Exception('Unknown business ${business.id}');
    _businesses[index] = business;
    return business;
  }

  @override
  Future<Business> getBusiness(int businessId) => throw UnimplementedError();
}

void main() {
  const business = Business(id: 1, name: 'Demo GmbH');

  test('starts in the initial state', () {
    final cubit = BusinessCubit(_FakeBusinessRepository());

    expect(cubit.state.status, BusinessStatus.initial);
    expect(cubit.state.businesses, isEmpty);
    expect(cubit.state.activeBusiness, isNull);
  });

  test('load emits loading then loaded with the businesses', () async {
    final cubit = BusinessCubit(
      _FakeBusinessRepository(businesses: [business]),
    );
    final states = <BusinessStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states, [BusinessStatus.loading, BusinessStatus.loaded]);
    expect(cubit.state.businesses, [business]);
    expect(cubit.state.activeBusiness, business);
    expect(cubit.state.hasBusiness, isTrue);
  });

  test('load failure maps to a failure state', () async {
    final cubit = BusinessCubit(_FakeBusinessRepository(failLoad: true));

    await cubit.load();

    expect(cubit.state.status, BusinessStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('create appends the business and makes it active', () async {
    final cubit = BusinessCubit(_FakeBusinessRepository());

    final created = await cubit.create(name: 'Neue Firma');

    expect(created, isTrue);
    expect(cubit.state.businesses, hasLength(1));
    expect(cubit.state.activeBusiness?.name, 'Neue Firma');
  });

  test('update replaces the matching business in the list', () async {
    final cubit = BusinessCubit(
      _FakeBusinessRepository(businesses: [business]),
    );
    await cubit.load();

    final updated = await cubit.update(
      const Business(id: 1, name: 'Demo GmbH 2'),
    );

    expect(updated, isTrue);
    expect(cubit.state.businesses.single.name, 'Demo GmbH 2');
  });

  test('update of an unknown business returns false', () async {
    final cubit = BusinessCubit(
      _FakeBusinessRepository(businesses: [business]),
    );
    await cubit.load();

    final updated = await cubit.update(const Business(id: 999, name: 'X'));

    expect(updated, isFalse);
    expect(cubit.state.businesses, [business]);
  });
}
