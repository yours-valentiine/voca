import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fsrs/fsrs.dart' show Card, Rating, Scheduler, State;
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/data/repository/fsrs_repository.dart';
import 'package:voca/shared/model/repeat_word_model.dart';

part 'spaced_repetition_notifier.freezed.dart';

class SpacedRepetitionNotifier extends AsyncNotifier<SpacedRepetitionData> {
  final Random _rnd = Random();
  late final _currentDictionary = ref.watch(currentDictionaryNotifierProvider);
  late final FsrsRepository _fsrsRepository = ref.watch(fsrsRepositoryProvider);
  late final Scheduler _scheduler = Scheduler();

  @override
  Future<SpacedRepetitionData> build() async {
    return _currentDictionary.when(
      data: (data) async {
        final cards = await _fsrsRepository.getToday(data.dictionaryId);

        return SpacedRepetitionData(
          allCards: cards,
          repeatedCards: {},
          currentId: _pickRandomCard(cards),
        );
      },
      error: (error, stackTrace) => throw error,
      loading: () => SpacedRepetitionData(
        allCards: [],
        repeatedCards: {},
        currentId: UuidValue.fromNamespace(.nil),
      ),
    );
  }

  UuidValue _pickRandomCard(List<RepeatWordModel> cards) {
    final pickIndex = _rnd.nextInt(cards.length);
    return cards[pickIndex].wordId;
  }

  Future<void> _calculateAndSave({
    required RepeatWordModel card,
    required Rating rating,
  }) async {
    final fsrsCard = Card(
      cardId: card.createdAt.millisecondsSinceEpoch,
      state: card.state ?? State.learning,
      step: card.step,
      stability: card.stability,
      difficulty: card.difficulty,
      due: card.due,
      lastReview: card.lastReview,
    );

    final result = _scheduler.reviewCard(fsrsCard, rating);

    await _fsrsRepository.addSingle(
      wordId: card.wordId,
      card: result.card,
      rating: rating,
    );
  }

  void hiddenWarning(bool hidden) => state.whenData(
    (data) => state = AsyncValue.data(data.copyWith(hiddenWarningSkip: hidden)),
  );

  void setRating(double value) => state.whenData(
    (data) => state = AsyncValue.data(
      data.copyWith(rating: ExerciseRating.fromValue(value)),
    ),
  );

  Future<void> checkCard(String translate) async {
    try {
      state = AsyncValue.data(
        state.requireValue.copyWith(currectCardState: .checking()),
      );
      translate = translate.trim().toLowerCase();

      state.whenData((data) async {
        final currentCard = state.requireValue.currentCard;

        if (currentCard.translates.any(
          (c) => c.translate.toLowerCase() == translate,
        )) {
          state = AsyncValue.data(
            state.requireValue.copyWith(currectCardState: .checked(true)),
          );
        } else {
          state = AsyncValue.data(
            state.requireValue.copyWith(currectCardState: .checked(false)),
          );
        }
        calculateCard();
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> calculateCard() async {
    final currentState = state.requireValue;
    await _calculateAndSave(
      card: currentState.currentCard,
      rating: currentState.rating.toFsrsRating(),
    );
  }

  void skipCard() {
    try {
      state = AsyncValue.data(
        state.requireValue.copyWith(
          currectCardState: .checked(false),
          rating: ExerciseRating.again,
        ),
      );
      calculateCard();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void nextCard() {
    try {
      final currentState = state.requireValue;

      if (currentState.isLastCard) {
        state = AsyncValue.data(
          currentState.copyWith(
            repeatedCards: {
              ...currentState.repeatedCards,
              currentState.currentId,
            },
          ),
        );
        return;
      }

      final prevId = currentState.currentId;
      final nextId = _pickRandomCard(currentState.nonRepeatedCards);

      state = AsyncValue.data(
        state.requireValue.nextCard(prevId: prevId, nextId: nextId),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

@freezed
class SpacedRepetitionData with _$SpacedRepetitionData {
  const SpacedRepetitionData({
    required this.allCards,
    required this.repeatedCards,
    required this.currentId,
    this.currectCardState = const CardState.showing(),
    this.rating = .easy,
    this.hiddenWarningSkip = false,
  });

  final List<RepeatWordModel> allCards;
  final Set<UuidValue> repeatedCards;
  final UuidValue currentId;
  final CardState currectCardState;
  final ExerciseRating rating;
  final bool hiddenWarningSkip;

  int get allCount => allCards.length;
  int get repeatedCount => repeatedCards.length;
  int get positionCard => repeatedCount + 1;

  double get percentRepeated => repeatedCount / allCount;

  bool get isLastCard => allCount - repeatedCount == 1;
  bool get isFinished => repeatedCards.length == allCards.length;

  String get tooltipRating => rating.name;

  List<RepeatWordModel> get nonRepeatedCards => allCards
      .where((w) => !repeatedCards.contains(w.wordId) && w.wordId != currentId)
      .toList();
  RepeatWordModel get currentCard =>
      allCards.firstWhere((w) => w.wordId == currentId);

  SpacedRepetitionData nextCard({
    required UuidValue prevId,
    required UuidValue nextId,
  }) => copyWith(
    currentId: nextId,
    currectCardState: CardState.showing(),
    rating: .easy,
    repeatedCards: {...repeatedCards, prevId},
  );
}

@freezed
class CardState with _$CardState {
  const factory CardState.showing() = _Showing;
  const factory CardState.checking() = _Checking;
  const factory CardState.checked(bool isCorrect) = _Checked;
}

enum ExerciseRating {
  easy(1),
  good(2),
  hard(3),
  again(4);

  final int value;

  const ExerciseRating(this.value);

  Rating toFsrsRating() => switch (this) {
    .easy => Rating.easy,
    .good => Rating.good,
    .hard => Rating.hard,
    .again => Rating.again,
  };

  static ExerciseRating fromValue(num value) => switch (value.ceil()) {
    1 => .easy,
    2 => .good,
    3 => .hard,
    4 => .again,
    _ => throw Exception("Undefinied enum value"),
  };
}
