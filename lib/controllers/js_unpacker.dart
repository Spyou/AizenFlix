import 'dart:math';

/// A class that detects and unpacks P.A.C.K.E.R.-encoded JavaScript.
class JsUnpacker {
  final String? _packedJS;

  /// Construct with the packed JS code.
  JsUnpacker(this._packedJS);

  /// Detects whether the provided JavaScript is P.A.C.K.E.R. encoded.
  bool detect() {
    if (_packedJS == null) return false;
    // Remove spaces and check for the typical eval(function(p,a,c,k,e,...) pattern.
    String js = _packedJS.replaceAll(" ", "");
    RegExp pattern = RegExp(r"eval\(function\(p,a,c,k,e,[rd]");
    return pattern.hasMatch(js);
  }

  /// Unpacks the JavaScript if it is P.A.C.K.E.R. encoded.
  ///
  /// Returns the decoded JavaScript string or null if unpacking failed.
  String? unpack() {
    if (_packedJS == null) return null;
    try {
      // This regular expression captures the payload, radix, count and symbol table.
      RegExp regExp = RegExp(
        r"\}\s*\('(.*)',\s*(.*?),\s*(\d+),\s*'(.*?)'\.split\('\|'\)",
        dotAll: true,
      );
      RegExpMatch? match = regExp.firstMatch(_packedJS);
      if (match != null && match.groupCount == 4) {
        // Get the payload and do a simple replacement for escaped single quotes.
        String payload = match.group(1)!.replaceAll(r"\'", "'");
        String radixStr = match.group(2)!;
        String countStr = match.group(3)!;
        List<String> symtab = match.group(4)!.split('|');

        int radix = 36;
        int count = 0;
        try {
          radix = int.parse(radixStr);
        } catch (e) {
          // Fallback to default if parsing fails.
        }
        try {
          count = int.parse(countStr);
        } catch (e) {
          // Fallback to default if parsing fails.
        }
        if (symtab.length != count) {
          throw Exception("Unknown p.a.c.k.e.r. encoding");
        }

        // Create an instance of the _Unbase helper for converting tokens.
        var unbase = _Unbase(radix);

        // Pattern to match words (tokens) within the payload.
        RegExp wordPattern = RegExp(r'\b[a-zA-Z0-9_]+\b');

        StringBuffer decoded = StringBuffer();
        int lastIndex = 0;

        // Process each token match and replace it with the corresponding symbol table value.
        for (final m in wordPattern.allMatches(payload)) {
          decoded.write(payload.substring(lastIndex, m.start));
          String word = m.group(0)!;
          int x = unbase.unbase(word);
          if (x >= 0 && x < symtab.length && symtab[x].isNotEmpty) {
            decoded.write(symtab[x]);
          } else {
            decoded.write(word);
          }
          lastIndex = m.end;
        }
        // Append any remaining part of the payload after the last match.
        decoded.write(payload.substring(lastIndex));
        return decoded.toString();
      }
    } catch (e) {
      // Replace with your own error logging if needed.
      print("Error during unpacking: $e");
    }
    return null;
  }
}

/// A private helper class that converts a given string from a specified radix into an integer.
class _Unbase {
  final int radix;
  String? _alphabet;
  Map<String, int>? _dictionary;

  // Constant alphabets for radixes larger than 36.
  static const String ALPHABET_62 =
      "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  static const String ALPHABET_95 =
      " !\"#\$%&\\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

  _Unbase(this.radix) {
    // If radix is greater than 36, build a custom alphabet and a dictionary for conversion.
    if (radix > 36) {
      if (radix < 62) {
        _alphabet = ALPHABET_62.substring(0, radix);
      } else if (radix >= 63 && radix <= 94) {
        _alphabet = ALPHABET_95.substring(0, radix);
      } else if (radix == 62) {
        _alphabet = ALPHABET_62;
      } else if (radix == 95) {
        _alphabet = ALPHABET_95;
      }
      _dictionary = {};
      if (_alphabet != null) {
        for (int i = 0; i < _alphabet!.length; i++) {
          _dictionary![_alphabet!.substring(i, i + 1)] = i;
        }
      }
    }
  }

  /// Converts the given string token into an integer.
  ///
  /// If [radix] is 36 or less, uses Dart’s built-in parsing;
  /// otherwise, it reverses the string and computes the value using the custom dictionary.
  int unbase(String str) {
    if (_alphabet == null) {
      return int.parse(str, radix: radix);
    } else {
      int ret = 0;
      // Reverse the string.
      String reversed = str.split('').reversed.join();
      for (int i = 0; i < reversed.length; i++) {
        String char = reversed[i];
        int digit = _dictionary![char] ?? 0;
        ret += (pow(radix, i) as int) * digit;
      }
      return ret;
    }
  }
}
