// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_list_items_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeListItemsNotifierHash() =>
    r'acb35be51bdfb330625f4410d6f8fe1048c42aab';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ActiveListItemsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<ShoppingItem>> {
  late final int listId;

  FutureOr<List<ShoppingItem>> build(
    int listId,
  );
}

/// Família de providers indexada por listId.
///
/// Copied from [ActiveListItemsNotifier].
@ProviderFor(ActiveListItemsNotifier)
const activeListItemsNotifierProvider = ActiveListItemsNotifierFamily();

/// Família de providers indexada por listId.
///
/// Copied from [ActiveListItemsNotifier].
class ActiveListItemsNotifierFamily
    extends Family<AsyncValue<List<ShoppingItem>>> {
  /// Família de providers indexada por listId.
  ///
  /// Copied from [ActiveListItemsNotifier].
  const ActiveListItemsNotifierFamily();

  /// Família de providers indexada por listId.
  ///
  /// Copied from [ActiveListItemsNotifier].
  ActiveListItemsNotifierProvider call(
    int listId,
  ) {
    return ActiveListItemsNotifierProvider(
      listId,
    );
  }

  @override
  ActiveListItemsNotifierProvider getProviderOverride(
    covariant ActiveListItemsNotifierProvider provider,
  ) {
    return call(
      provider.listId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activeListItemsNotifierProvider';
}

/// Família de providers indexada por listId.
///
/// Copied from [ActiveListItemsNotifier].
class ActiveListItemsNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ActiveListItemsNotifier,
        List<ShoppingItem>> {
  /// Família de providers indexada por listId.
  ///
  /// Copied from [ActiveListItemsNotifier].
  ActiveListItemsNotifierProvider(
    int listId,
  ) : this._internal(
          () => ActiveListItemsNotifier()..listId = listId,
          from: activeListItemsNotifierProvider,
          name: r'activeListItemsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activeListItemsNotifierHash,
          dependencies: ActiveListItemsNotifierFamily._dependencies,
          allTransitiveDependencies:
              ActiveListItemsNotifierFamily._allTransitiveDependencies,
          listId: listId,
        );

  ActiveListItemsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listId,
  }) : super.internal();

  final int listId;

  @override
  FutureOr<List<ShoppingItem>> runNotifierBuild(
    covariant ActiveListItemsNotifier notifier,
  ) {
    return notifier.build(
      listId,
    );
  }

  @override
  Override overrideWith(ActiveListItemsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActiveListItemsNotifierProvider._internal(
        () => create()..listId = listId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listId: listId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ActiveListItemsNotifier,
      List<ShoppingItem>> createElement() {
    return _ActiveListItemsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveListItemsNotifierProvider && other.listId == listId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ActiveListItemsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<ShoppingItem>> {
  /// The parameter `listId` of this provider.
  int get listId;
}

class _ActiveListItemsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ActiveListItemsNotifier,
        List<ShoppingItem>> with ActiveListItemsNotifierRef {
  _ActiveListItemsNotifierProviderElement(super.provider);

  @override
  int get listId => (origin as ActiveListItemsNotifierProvider).listId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
