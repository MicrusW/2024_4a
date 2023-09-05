part of dart._skwasm_impl;
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.



class SkwasmObjectWrapper<T extends NativeType> {
  SkwasmObjectWrapper(this.handle, this.registry) {
    registry.register(this);
  }
  final SkwasmFinalizationRegistry<T> registry;
  final Pointer<T> handle;
  bool _isDisposed = false;

  void dispose() {
    assert(!_isDisposed);
    registry.evict(this);
    _isDisposed = true;
  }

  bool get debugDisposed => _isDisposed;
}

typedef DisposeFunction<T extends NativeType> = void Function(Pointer<T>);

class SkwasmFinalizationRegistry<T extends NativeType> {
  SkwasmFinalizationRegistry(this.dispose)
    : registry = createDomFinalizationRegistry(((JSNumber address) =>
      dispose(Pointer<T>.fromAddress(address.toDart.toInt()))
    ).toJS);

  final DomFinalizationRegistry registry;
  final DisposeFunction<T> dispose;

  void register(SkwasmObjectWrapper<T> wrapper) {
    registry.register(wrapper, wrapper.handle.address, wrapper);
  }

  void evict(SkwasmObjectWrapper<T> wrapper) {
    registry.unregister(wrapper);
    dispose(wrapper.handle);
  }
}
