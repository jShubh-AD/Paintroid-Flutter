import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paintroid/core/localization/app_localizations.dart';
import 'package:paintroid/core/providers/state/workspace_state.dart';
import 'package:paintroid/core/providers/state/workspace_state_notifier.dart';
import 'package:paintroid/ui/pages/workspace_page/components/top_bar/overflow_menu.dart';
import 'package:paintroid/ui/pages/workspace_page/components/top_bar/top_app_bar.dart';
import 'package:paintroid/ui/pages/workspace_page/workspace_page.dart';
import 'package:paintroid/ui/theme/theme.dart';

class MockWorkspaceStateProvider extends WorkspaceStateProvider {
  @override
  WorkspaceState build() {
    return const WorkspaceState(
      isFullscreen: true,
      isPerformingIOTask: false,
      hasUnsavedChanges: false,
      commandCountWhenLastSaved: 0,
    );
  }
}

void main() {
  late Widget sut;

  setUp(() {
    final lightTheme = LightPaintroidThemeData();
    final darkTheme = DarkPaintroidThemeData();

    sut = ProviderScope(
      child: PaintroidTheme(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        child: MaterialApp(
          theme: lightTheme.materialThemeData,
          darkTheme: darkTheme.materialThemeData,
          home: const WorkspacePage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
        ),
      ),
    );
  });

  testWidgets('Should have a top and bottom app bar', (tester) async {
    await tester.pumpWidget(sut);
    expect(find.byType(TopAppBar), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'Should have the title "Pocket Paint" in app bar',
    (tester) async {
      await tester.pumpWidget(sut);
      final titleFinder = find.widgetWithText(TopAppBar, 'Pocket Paint');
      expect(titleFinder, findsOneWidget);
    },
  );

  testWidgets('Should an overflow menu button in app bar', (tester) async {
    await tester.pumpWidget(sut);
    final overflowMenuButtonFinder = find.widgetWithIcon(
      PopupMenuButton<OverflowMenuOption>,
      Icons.more_vert,
    );
    expect(overflowMenuButtonFinder, findsOneWidget);
  });

  testWidgets('Advanced Options dialog flow', (tester) async {
    await tester.pumpWidget(sut);
    await tester.pumpAndSettle();

    final overflowMenuButtonFinder = find.byIcon(Icons.more_vert);
    expect(overflowMenuButtonFinder, findsOneWidget);

    await tester.tap(overflowMenuButtonFinder);
    await tester.pumpAndSettle();

    final advancedOptionsFinder = find.text('Advanced Options');
    expect(advancedOptionsFinder, findsOneWidget);

    await tester.tap(advancedOptionsFinder);
    await tester.pumpAndSettle();

    expect(find.text('Advanced Options'), findsOneWidget);

    expect(find.text('Antialiasing'), findsOneWidget);
    expect(find.text('Smoothing'), findsOneWidget);

    final switches = tester.widgetList<Switch>(find.byType(Switch));
    for (final s in switches) {
      expect(s.value, false);
    }

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Advanced Options'), findsNothing);
  });

  group('Fullscreen functionality', () {
    setUp(() {
      final lightTheme = LightPaintroidThemeData();
      final darkTheme = DarkPaintroidThemeData();

      sut = ProviderScope(
        overrides: [
          workspaceStateProvider.overrideWith(MockWorkspaceStateProvider.new),
        ],
        child: PaintroidTheme(
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          child: MaterialApp(
            theme: lightTheme.materialThemeData,
            darkTheme: darkTheme.materialThemeData,
            home: const WorkspacePage(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
          ),
        ),
      );
    });

    final exitFullscreenButtonFinder =
        find.widgetWithIcon(IconButton, Icons.fullscreen_exit);

    group('After going fullscreen', () {
      testWidgets(
        'Should hide top and bottom bar',
        (tester) async {
          await tester.pumpWidget(sut);
          expect(find.byType(TopAppBar), findsNothing);
          expect(find.byType(NavigationBar), findsNothing);
        },
      );

      testWidgets(
        'Should have an exit fullscreen button',
        (tester) async {
          await tester.pumpWidget(sut);
          expect(exitFullscreenButtonFinder, findsOneWidget);
        },
      );
    });

    group('After exiting fullscreen', () {
      testWidgets(
        'Should show top and bottom bar',
        (tester) async {
          await tester.pumpWidget(sut);
          await tester.tap(exitFullscreenButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byType(TopAppBar), findsOneWidget);
          expect(find.byType(NavigationBar), findsOneWidget);
        },
      );
    });
  });
}
