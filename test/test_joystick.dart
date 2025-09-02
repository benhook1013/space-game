import 'package:flame/components.dart';

/// Minimal joystick for tests that avoids late initialization of
/// internal base knob position by skipping [JoystickComponent.update].
class TestJoystick extends JoystickComponent {
  TestJoystick()
      : super(
          knob: CircleComponent(radius: 1),
          background: CircleComponent(radius: 2),
        );

  @override
  void update(double dt) {}
}
