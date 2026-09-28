import 'package:flutter_test/flutter_test.dart';

// Copy of calculation algorithms for isolated unit testing
Map<String, double> calculateBalances(Map<String, dynamic> ticket) {
  final participants = List<String>.from(ticket['participants'] as List);
  final balances = <String, double>{for (var p in participants) p: 0.0};

  final expenses = List<Map<String, dynamic>>.from(ticket['expenses'] as List);
  for (var exp in expenses) {
    final paidBy = exp['paidBy'] as String;
    final amount = (exp['amount'] as num).toDouble();
    final shares = Map<String, dynamic>.from(exp['shares'] as Map? ?? {});

    balances.putIfAbsent(paidBy, () => 0.0);
    balances[paidBy] = balances[paidBy]! + amount;

    for (var p in participants) {
      final shareVal = shares.containsKey(p)
          ? (shares[p] as num).toDouble()
          : (amount / participants.length);
      balances.putIfAbsent(p, () => 0.0);
      balances[p] = balances[p]! - shareVal;
    }
  }

  // Adjust settlements
  final settlements = List<Map<String, dynamic>>.from(ticket['settlements'] as List? ?? []);
  for (var st in settlements) {
    final debtor = st['debtor'] as String;
    final creditor = st['creditor'] as String;
    final amt = (st['amount'] as num).toDouble();

    balances.putIfAbsent(debtor, () => 0.0);
    balances.putIfAbsent(creditor, () => 0.0);
    balances[debtor] = balances[debtor]! + amt;
    balances[creditor] = balances[creditor]! - amt;
  }

  return balances;
}

List<Map<String, dynamic>> calculateSimplifiedDebts(Map<String, double> balances) {
  final debtors = <String, double>{};
  final creditors = <String, double>{};

  balances.forEach((person, bal) {
    final roundedBal = (bal * 100).roundToDouble() / 100.0;
    if (roundedBal < -0.005) {
      debtors[person] = -roundedBal;
    } else if (roundedBal > 0.005) {
      creditors[person] = roundedBal;
    }
  });

  final debts = <Map<String, dynamic>>[];

  while (debtors.isNotEmpty && creditors.isNotEmpty) {
    String? bestDebtor;
    String? bestCreditor;
    double matchAmount = 0.0;

    // 1. Exact match priority
    for (final d in debtors.entries) {
      for (final c in creditors.entries) {
        if ((d.value - c.value).abs() < 0.005) {
          bestDebtor = d.key;
          bestCreditor = c.key;
          matchAmount = d.value;
          break;
        }
      }
      if (bestDebtor != null) break;
    }

    // 2. Greedy match
    if (bestDebtor == null || bestCreditor == null) {
      bestDebtor = debtors.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      bestCreditor = creditors.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final dVal = debtors[bestDebtor]!;
      final cVal = creditors[bestCreditor]!;
      matchAmount = dVal < cVal ? dVal : cVal;
    }

    if (matchAmount > 0.005) {
      debts.add({
        'from': bestDebtor,
        'to': bestCreditor,
        'amount': matchAmount,
      });

      debtors[bestDebtor] = debtors[bestDebtor]! - matchAmount;
      creditors[bestCreditor] = creditors[bestCreditor]! - matchAmount;
    }

    if (debtors[bestDebtor]! < 0.005) {
      debtors.remove(bestDebtor);
    }
    if (creditors[bestCreditor]! < 0.005) {
      creditors.remove(bestCreditor);
    }
  }

  debts.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

  return debts;
}

void main() {
  group('Simplified Debts Algorithm Tests', () {
    test('User Marina Trip Scenario with 5 participants and settlements', () {
      final ticket = {
        'participants': ['You', 'sri', 'monica', 'vincent', 'ashwin'],
        'expenses': [
          {
            'paidBy': 'You',
            'amount': 100000.0,
            'shares': <String, double>{}, // equal split
          }
        ],
        'settlements': [
          {'debtor': 'ashwin', 'creditor': 'You', 'amount': 600.0},
          {'debtor': 'ashwin', 'creditor': 'You', 'amount': 1400.0},
          {'debtor': 'vincent', 'creditor': 'You', 'amount': 2000.0},
          {'debtor': 'monica', 'creditor': 'You', 'amount': 2000.0},
          {'debtor': 'sri', 'creditor': 'You', 'amount': 2000.0},
        ],
      };

      final balances = calculateBalances(ticket);

      expect(balances['You'], equals(72000.0));
      expect(balances['sri'], equals(-18000.0));
      expect(balances['monica'], equals(-18000.0));
      expect(balances['vincent'], equals(-18000.0));
      expect(balances['ashwin'], equals(-18000.0));

      final debts = calculateSimplifiedDebts(balances);

      // Must have EXACTLY 4 simplified transactions - one for each debtor!
      expect(debts.length, equals(4));

      // Each debt must be for 18000 from debtor to You
      for (final debt in debts) {
        expect(debt['to'], equals('You'));
        expect(debt['amount'], equals(18000.0));
      }

      final fromPersons = debts.map((d) => d['from']).toSet();
      expect(fromPersons, containsAll(['sri', 'monica', 'vincent', 'ashwin']));
    });

    test('Exact match priority reduces transaction count', () {
      final balances = {
        'Alice': -500.0,
        'Bob': -1000.0,
        'Charlie': 500.0,
        'David': 1000.0,
      };

      final debts = calculateSimplifiedDebts(balances);

      expect(debts.length, equals(2));
      expect(debts.any((d) => d['from'] == 'Alice' && d['to'] == 'Charlie' && d['amount'] == 500.0), isTrue);
      expect(debts.any((d) => d['from'] == 'Bob' && d['to'] == 'David' && d['amount'] == 1000.0), isTrue);
    });

    test('Circular debt resolves to zero transactions', () {
      final balances = {
        'A': 0.0,
        'B': 0.0,
        'C': 0.0,
      };

      final debts = calculateSimplifiedDebts(balances);
      expect(debts.isEmpty, isTrue);
    });

    test('Fully settled ticket after custom pay and settle', () {
      final ticket = {
        'participants': ['You', 'ashwin'],
        'expenses': [
          {
            'paidBy': 'You',
            'amount': 2000.0,
            'shares': {'You': 1000.0, 'ashwin': 1000.0},
          }
        ],
        'settlements': [
          {'debtor': 'ashwin', 'creditor': 'You', 'amount': 1000.0},
        ],
      };

      final balances = calculateBalances(ticket);
      expect(balances['You'], equals(0.0));
      expect(balances['ashwin'], equals(0.0));

      final debts = calculateSimplifiedDebts(balances);
      expect(debts.isEmpty, isTrue);
    });
  });
}
