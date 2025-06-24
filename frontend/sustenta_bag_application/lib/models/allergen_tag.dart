import 'package:flutter/material.dart';

enum AllergenTag {
  podeConterGluten,
  podeConterLactose,
  podeConterLeite,
  podeConterOvos,
  podeConterAmendoim,
  podeConterCastanhas,
  podeConterNozes,
  podeConterSoja,
  podeConterPeixe,
  podeConterFrutosDoMar,
  podeConterCrustaceos,
  podeConterGergelim,
  podeConterSulfitos,
  podeConterCarne,
  unknown,
}

extension AllergenTagExtension on AllergenTag {

  static AllergenTag fromString(String apiTag) {
    switch (apiTag) {
      case "PODE_CONTER_GLUTEN":
        return AllergenTag.podeConterGluten;
      case "PODE_CONTER_LACTOSE":
        return AllergenTag.podeConterLactose;
      case "PODE_CONTER_LEITE":
        return AllergenTag.podeConterLeite;
      case "PODE_CONTER_OVOS":
        return AllergenTag.podeConterOvos;
      case "PODE_CONTER_AMENDOIM":
        return AllergenTag.podeConterAmendoim;
      case "PODE_CONTER_CASTANHAS":
        return AllergenTag.podeConterCastanhas;
      case "PODE_CONTER_NOZES":
        return AllergenTag.podeConterNozes;
      case "PODE_CONTER_SOJA":
        return AllergenTag.podeConterSoja;
      case "PODE_CONTER_PEIXE":
        return AllergenTag.podeConterPeixe;
      case "PODE_CONTER_FRUTOS_DO_MAR":
        return AllergenTag.podeConterFrutosDoMar;
      case "PODE_CONTER_CRUSTACEOS":
        return AllergenTag.podeConterCrustaceos;
      case "PODE_CONTER_GERGELIM":
        return AllergenTag.podeConterGergelim;
      case "PODE_CONTER_SULFITOS":
        return AllergenTag.podeConterSulfitos;
      case "PODE_CONTER_CARNE":
        return AllergenTag.podeConterCarne;
      default:
        return AllergenTag.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case AllergenTag.podeConterGluten:
        return "Contém Glúten";
      case AllergenTag.podeConterLactose:
        return "Contém Lactose";
      case AllergenTag.podeConterLeite:
        return "Contém Leite";
      case AllergenTag.podeConterOvos:
        return "Contém Ovos";
      case AllergenTag.podeConterAmendoim:
        return "Contém Amendoim";
      case AllergenTag.podeConterCastanhas:
        return "Contém Castanhas";
      case AllergenTag.podeConterNozes:
        return "Contém Nozes";
      case AllergenTag.podeConterSoja:
        return "Contém Soja";
      case AllergenTag.podeConterPeixe:
        return "Contém Peixe";
      case AllergenTag.podeConterFrutosDoMar:
        return "Contém Frutos do Mar";
      case AllergenTag.podeConterCrustaceos:
        return "Contém Crustáceos";
      case AllergenTag.podeConterGergelim:
        return "Contém Gergelim";
      case AllergenTag.podeConterSulfitos:
        return "Contém Sulfitos";
      case AllergenTag.podeConterCarne:
        return "Contém Carne";
      case AllergenTag.unknown:
        return "Outros";
    }
  }

  IconData get icon {
    return Icons.warning_amber_rounded;
  }
}