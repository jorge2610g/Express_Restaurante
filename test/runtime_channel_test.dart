import 'package:flutter_test/flutter_test.dart';
import 'package:express_restaurante/core/runtime_channel.dart';

void main() {
  test('restaurant runtime accepts only Preview and Production', () {
    ExpressRuntimeChannel.applyResolvedEnvironment('preview');
    expect(ExpressRuntimeChannel.name, 'preview');

    ExpressRuntimeChannel.applyResolvedEnvironment('production');
    expect(ExpressRuntimeChannel.name, 'production');

    expect(
      () => ExpressRuntimeChannel.applyResolvedEnvironment('unknown'),
      throwsArgumentError,
    );
  });
}
