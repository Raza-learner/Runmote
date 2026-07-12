import 'package:flutter_test/flutter_test.dart';
import 'package:acp_remote/features/chat/viewmodel/chat_provider.dart';

void main() {
  group('ConfigOption', () {
    test('fromJson parses with all fields', () {
      final json = {
        'id': 'model',
        'name': 'Model',
        'description': 'AI model to use',
        'category': 'model',
        'currentValue': 'gpt-4',
        'options': [
          {'value': 'gpt-4', 'name': 'GPT-4'},
          {'value': 'gpt-3.5', 'name': 'GPT-3.5'},
        ],
      };
      final opt = ConfigOption.fromJson(json);
      expect(opt.id, 'model');
      expect(opt.name, 'Model');
      expect(opt.description, 'AI model to use');
      expect(opt.category, 'model');
      expect(opt.currentValue, 'gpt-4');
      expect(opt.options.length, 2);
      expect(opt.options[0].value, 'gpt-4');
      expect(opt.options[0].name, 'GPT-4');
      expect(opt.options[1].value, 'gpt-3.5');
      expect(opt.options[1].name, 'GPT-3.5');
    });

    test('fromJson falls back id as name when name missing', () {
      final json = {
        'id': 'model',
        'category': 'model',
        'currentValue': 'gpt-4',
        'options': [],
      };
      final opt = ConfigOption.fromJson(json);
      expect(opt.name, 'model');
    });

    test('ConfigOptionValue falls back value as name', () {
      final json = {'value': 'gpt-4'};
      final v = ConfigOptionValue.fromJson(json);
      expect(v.value, 'gpt-4');
      expect(v.name, 'gpt-4');
    });

    test('toJson/fromJson roundtrip', () {
      final opt = ConfigOption(
        id: 'model',
        name: 'Model Name',
        description: 'A model option',
        category: 'model',
        currentValue: 'gpt-4',
        options: [
          ConfigOptionValue(value: 'gpt-4', name: 'GPT-4', description: 'Best'),
          ConfigOptionValue(value: 'gpt-3.5', name: 'GPT-3.5'),
        ],
      );
      final json = opt.toJson();
      final restored = ConfigOption.fromJson(json);
      expect(restored.id, opt.id);
      expect(restored.name, opt.name);
      expect(restored.description, opt.description);
      expect(restored.category, opt.category);
      expect(restored.currentValue, opt.currentValue);
      expect(restored.options.length, 2);
      expect(restored.options[0].value, 'gpt-4');
      expect(restored.options[0].name, 'GPT-4');
      expect(restored.options[0].description, 'Best');
      expect(restored.options[1].value, 'gpt-3.5');
    });

    test('ConfigOptionValue toJson/fromJson roundtrip', () {
      final v = ConfigOptionValue(value: 'gpt-4', name: 'GPT-4', description: 'Best model');
      final json = v.toJson();
      final restored = ConfigOptionValue.fromJson(json);
      expect(restored.value, v.value);
      expect(restored.name, v.name);
      expect(restored.description, v.description);
    });

    test('ConfigOptionValue toJson omits null description', () {
      final v = ConfigOptionValue(value: 'gpt-4', name: 'GPT-4');
      final json = v.toJson();
      expect(json, containsPair('value', 'gpt-4'));
      expect(json, containsPair('name', 'GPT-4'));
      expect(json.containsKey('description'), isFalse);
    });
  });

  group('SlashCommand', () {
    test('fromJson parses command', () {
      final json = {
        'name': 'help',
        'description': 'Show help',
        'input': {'hint': 'topic'},
      };
      final cmd = SlashCommand.fromJson(json);
      expect(cmd.name, 'help');
      expect(cmd.description, 'Show help');
      expect(cmd.inputHint, 'topic');
    });

    test('fromJson parses command without input', () {
      final json = {
        'name': 'summarize',
        'description': 'Summarize the conversation',
      };
      final cmd = SlashCommand.fromJson(json);
      expect(cmd.name, 'summarize');
      expect(cmd.inputHint, isNull);
    });

    test('toJson/fromJson roundtrip with input', () {
      final cmd = SlashCommand(name: 'help', description: 'Show help', inputHint: 'topic');
      final json = cmd.toJson();
      final restored = SlashCommand.fromJson(json);
      expect(restored.name, cmd.name);
      expect(restored.description, cmd.description);
      expect(restored.inputHint, cmd.inputHint);
    });

    test('toJson/fromJson roundtrip without input', () {
      final cmd = SlashCommand(name: 'summarize', description: 'Summarize');
      final json = cmd.toJson();
      final restored = SlashCommand.fromJson(json);
      expect(restored.name, cmd.name);
      expect(restored.inputHint, isNull);
    });
  });

  group('PermissionOption', () {
    test('fromJson parses with kind', () {
      final json = {
        'optionId': 'opt-1',
        'name': 'Allow once',
        'kind': 'allow_once',
      };
      final opt = PermissionOption.fromJson(json);
      expect(opt.optionId, 'opt-1');
      expect(opt.name, 'Allow once');
      expect(opt.kind, 'allow_once');
    });

    test('fromJson defaults name to optionId and kind to allow_once', () {
      final json = {'optionId': 'opt-2'};
      final opt = PermissionOption.fromJson(json);
      expect(opt.optionId, 'opt-2');
      expect(opt.name, 'opt-2');
      expect(opt.kind, 'allow_once');
    });

    test('toJson/fromJson roundtrip', () {
      final opt = PermissionOption(optionId: 'opt-3', name: 'Allow once', kind: 'allow_once');
      final json = opt.toJson();
      final restored = PermissionOption.fromJson(json);
      expect(restored.optionId, opt.optionId);
      expect(restored.name, opt.name);
      expect(restored.kind, opt.kind);
    });
  });
}
