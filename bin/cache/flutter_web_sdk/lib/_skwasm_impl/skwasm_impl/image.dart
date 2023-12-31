part of dart._skwasm_impl;
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.



class SkwasmImage extends SkwasmObjectWrapper<RawImage> implements ui.Image {
  SkwasmImage(ImageHandle handle) : super(handle, _registry)
  {
    ui.Image.onCreate?.call(this);
  }

  factory SkwasmImage.fromPixels(
    Uint8List pixels,
    int width,
    int height,
    ui.PixelFormat format, {
    int? rowBytes,
  }) {
    final SkDataHandle dataHandle = skDataCreate(pixels.length);
    final Pointer<Uint8> dataPointer = skDataGetPointer(dataHandle).cast<Uint8>();
    for (int i = 0; i < pixels.length; i++) {
      dataPointer[i] = pixels[i];
    }
    final ImageHandle imageHandle = imageCreateFromPixels(
      dataHandle,
      width,
      height,
      format.index,
      rowBytes ?? 4 * width,
    );
    skDataDispose(dataHandle);
    return SkwasmImage(imageHandle);
  }

  static final SkwasmFinalizationRegistry<RawImage> _registry =
    SkwasmFinalizationRegistry<RawImage>(imageDispose);

  @override
  void dispose() {
    super.dispose();
    ui.Image.onDispose?.call(this);
  }

  @override
  int get width => imageGetWidth(handle);

  @override
  int get height => imageGetHeight(handle);

  @override
  Future<ByteData?> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba}) {
    return (renderer as SkwasmRenderer).surface.rasterizeImage(this, format);
  }

  @override
  ui.ColorSpace get colorSpace => ui.ColorSpace.sRGB;

  @override
  SkwasmImage clone() {
    imageRef(handle);
    return SkwasmImage(handle);
  }

  @override
  bool isCloneOf(ui.Image other) => other is SkwasmImage && handle == other.handle;

  @override
  List<StackTrace>? debugGetOpenHandleStackTraces() => null;

  @override
  String toString() => '[$width\u00D7$height]';
}
