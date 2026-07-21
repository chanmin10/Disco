import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('DiscoApp shows the default chat room and input field', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiscoApp()));

    expect(find.text('프로그래밍'), findsWidgets);
    expect(find.text('아직 저장된 단어가 없어요'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
