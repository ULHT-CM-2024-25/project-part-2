import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:prjectcm/main.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:provider/provider.dart';
import 'package:testable_form_field/testable_form_field.dart';

void main() {
  runWidgetTests();
}

void runWidgetTests() {
  final testHospitals = [
    Hospital(
      id: 3,
      name: 'hospital 1',
      latitude: 40.7128,
      longitude: -74.0060,
      address: 'Em cima do monte',
      phoneNumber: 1234567,
      email: 'noreply@hospital1.pt',
      district: 'Lisbon',
      hasEmergency: true,
    ),
    Hospital(
      id: 4,
      name: 'hospital 2',
      latitude: 43.7128,
      longitude: -71.0060,
      address: 'Junto à praia',
      phoneNumber: 23445456,
      email: 'noreply@hospital2.pt',
      district: 'Porto',
      hasEmergency: false,
    ),
  ];

  testWidgets('Has navigation bar with 4 options', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: SnsRepository()),
      ],
      child: const MyApp(),
    ));

    // have to wait for async initializations
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    expect(find.byType(NavigationBar), findsOneWidget,
        reason: "Deveria existir uma NavigationBar (atenção que a BottomNavigationBar deve deixar de ser usada)");
    expect(find.byType(NavigationDestination), findsNWidgets(4),
        reason: "Deveriam existir 4 NavigationDestination dentro da NavigationBar");

    for (String key in [
      'dashboard-bottom-bar-item',
      'lista-bottom-bar-item',
      'mapa-bottom-bar-item',
      'avaliacoes-bottom-bar-item'
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: "Deveria existir um NavigationDestination com a key '$key'");
    }
  });

  testWidgets('Show hospitals list', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));

    // have to wait for async initializations
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    var listBottomBarItemFinder = find.byKey(Key('lista-bottom-bar-item'));
    expect(listBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'lista-bottom-bar-item'");
    await tester.tap(listBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget,
        reason: "Depois de saltar para o ecrã com a lista, deveria existir um ListView com a key 'list-view'");
    expect(tester.widget(listViewFinder), isA<ListView>(),
        reason: "O widget com a key 'list-view' deveria ser um ListView");

    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2, reason: "Deveriam existir 2 ListTiles dentro do ListView dos hospitais");

    // Ensure the first ListTile contains a Text widget with "Hospital 1"
    final Finder firstTileTextFinder = find.descendant(of: listTilesFinder.first, matching: find.text("hospital 1"));
    expect(firstTileTextFinder, findsOneWidget,
        reason: "O primeiro ListTile deveria conter um Text com o texto 'hospital 1'");

    // Ensure the second ListTile contains a Text widget with "Hospital 2"
    final Finder secondTileTextFinder = find.descendant(of: listTilesFinder.last, matching: find.text("hospital 2"));
    expect(secondTileTextFinder, findsOneWidget,
        reason: "O segundo ListTile deveria conter um Text com o texto 'hospital 2'");
  });

  testWidgets('Show hospitals list and detail', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));

    // have to wait for async initializations
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    var listBottomBarItemFinder = find.byKey(Key('lista-bottom-bar-item'));
    expect(listBottomBarItemFinder, findsOneWidget);
    await tester.tap(listBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget);
    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2);

    // tap the first tile
    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    // find if the text 'hospital1' is present
    final Finder hospital1Finder = find.text('hospital 1');
    expect(hospital1Finder, findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'hospital 1' (primeiro elemento da lista)");
    expect(find.text('Em cima do monte'), findsOneWidget,
        reason: "Deveria existir pelo menos um Text com o texto 'Em cima do monte' (morada do primeiro elemento da lista)");

    // go back
    await tester.pageBack();
    await tester.pumpAndSettle();

    // tap the second tile
    final Finder listTilesFinder2 = find.descendant(of: find.byKey(Key('list-view')), matching: find.byType(ListTile));
    await tester.tap(listTilesFinder2.at(1));
    await tester.pumpAndSettle();

    // find if the text 'hospital2' is present
    final Finder hospital2Finder = find.text('hospital 2');
    expect(hospital2Finder, findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'hospital 2' (segundo elemento da lista)");
    expect(find.text('Junto à praia'), findsOneWidget,
        reason: "Deveria existir pelo menos um Text com o texto 'Junto à praia' (morada do segundo elemento da lista)");
  });

  testWidgets('Insert evaluation and show detail', (WidgetTester tester) async {
    final snsRepository = SnsRepository();

    for (var hospital in testHospitals) {
      snsRepository.insertHospital(hospital);
    }

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<SnsRepository>.value(value: snsRepository),
      ],
      child: const MyApp(),
    ));


    // have to wait for async initializations
    await tester.pumpAndSettle(Duration(milliseconds: 200));

    var avaliacoesBottomBarItemFinder = find.byKey(Key('avaliacoes-bottom-bar-item'));
    expect(avaliacoesBottomBarItemFinder, findsOneWidget,
        reason: "Deveria existir um NavigationDestination com a key 'avaliacoes-bottom-bar-item'");
    await tester.tap(avaliacoesBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder hospitalSelectionViewFinder = find.byKey(Key('evaluation-hospital-selection-field'));
    expect(hospitalSelectionViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-hospital-selection-field'");
    expect(tester.widget(hospitalSelectionViewFinder), isA<TestableFormField<Hospital>>(),
        reason: "O widget com a key 'evaluation-hospital-selection-field' deveria ser um TestableFormField<Hospital>");
    TestableFormField<Hospital> hospitalSelectionFormField = tester.widget(hospitalSelectionViewFinder);

    final Finder ratingViewFinder = find.byKey(Key('evaluation-rating-field'));
    expect(ratingViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-rating-field'");
    expect(tester.widget(ratingViewFinder), isA<TestableFormField<int>>(),
        reason: "O widget com a key 'evaluation-rating-field' deveria ser um TestableFormField<int>");
    TestableFormField<int> ratingFormField = tester.widget(ratingViewFinder);

    final Finder dateTimeViewFinder = find.byKey(Key('evaluation-datetime-field'));
    expect(dateTimeViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-datetime-field'");
    expect(tester.widget(dateTimeViewFinder), isA<TestableFormField<DateTime>>(),
        reason: "O widget com a key 'evaluation-datetime-field' deveria ser um TestableFormField<DateTime>");
    TestableFormField<DateTime> dateTimeFormField = tester.widget(dateTimeViewFinder);

    final Finder commentViewFinder = find.byKey(Key('evaluation-comment-field'));
    expect(commentViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-comment-field'");
    expect(tester.widget(commentViewFinder), isA<TestableFormField<String>>(),
        reason: "O widget com a key 'evaluation-comment-field' deveria ser um TestableFormField<String>");
    TestableFormField<String> commentFormField = tester.widget(commentViewFinder);

    // using "an hour ago" instead of current time since probably the form field will have its default value set to now
    final aHourAgo = DateTime.now().subtract(Duration(hours: 1));
    hospitalSelectionFormField.setValue(testHospitals[0]);
    // ratingFormField.setValue(4);  // don't set the value for now
    dateTimeFormField.setValue(aHourAgo);
    commentFormField.setValue("No comments");

    final Finder submitButtonViewFinder = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder);
    await tester.pumpAndSettle();

    // it should show a text near the field explaining the error
    expect(find.textContaining('Preencha a avaliação'), findsOneWidget);

    // it should show a snackbar telling a field is missing
    expect(find.byType(SnackBar), findsOneWidget);

    ratingFormField.setValue(5); // set the missing value now

    final Finder submitButtonViewFinder2 = find.byKey(Key('evaluation-form-submit-button'));
    expect(submitButtonViewFinder2, findsOneWidget,
        reason: "No ecrã do formulário, deveria existir um Widget com a key 'evaluation-form-submit-button'");
    await tester.tap(submitButtonViewFinder2);
    await tester.pumpAndSettle();

    // go to list
    var listBottomBarItemFinder = find.byKey(Key('lista-bottom-bar-item'));
    expect(listBottomBarItemFinder, findsOneWidget);
    await tester.tap(listBottomBarItemFinder);
    await tester.pumpAndSettle();

    final Finder listViewFinder = find.byKey(Key('list-view'));
    expect(listViewFinder, findsOneWidget);
    final Finder listTilesFinder = find.descendant(of: listViewFinder, matching: find.byType(ListTile));
    final tiles = List.from(tester.widgetList<ListTile>(listTilesFinder));
    expect(tiles.length, 2);

    await tester.tap(listTilesFinder.first);
    await tester.pumpAndSettle();

    // find if the text 'hospital1' is present
    expect(find.text('hospital 1'), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'hospital 1' (primeiro elemento da lista)");

    // find if the text with the current date is present
    final nowStr = DateFormat("dd/MM/yyyy HH:mm").format(aHourAgo);
    expect(find.text(nowStr), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto '$nowStr' (data de uma das avaliações)");

    // find if the text 'No comments' is present
    expect(find.text('No comments'), findsAtLeastNWidgets(1),
        reason: "Deveria existir pelo menos um Text com o texto 'No comments' (texto de uma das avaliações)");
  });
}
