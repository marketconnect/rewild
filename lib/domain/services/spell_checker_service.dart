import 'package:fpdart/fpdart.dart';
import 'package:rewild/core/utils/rewild_error.dart';
import 'package:rewild/domain/entities/spell_result.dart';
import 'package:rewild/presentation/single_question_screen/single_question_view_model.dart';
import 'package:rewild/presentation/single_review_screen/single_review_view_model.dart';

abstract class SpellCheckerServiceSpellCheckerApiClient {
  Future<Either<RewildError, List<SpellResult>>> checkText(
      {required String text});
}

class SpellCheckerService
    implements
        SingleQuestionViewModelSpellChecker,
        SingleReviewViewModelSpellChecker {
  final SpellCheckerServiceSpellCheckerApiClient spellCheckerApiClient;

  SpellCheckerService({required this.spellCheckerApiClient});

  @override
  Future<Either<RewildError, List<SpellResult>>> checkText(
      {required String text}) async {
    return await spellCheckerApiClient.checkText(text: text);
  }
}
