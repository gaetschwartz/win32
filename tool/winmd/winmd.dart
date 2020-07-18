// winmd.dart

// Parse the WinMD file and interpret its metadata

// Sources of inspiration:
// https://stackoverflow.com/questions/54375771/how-to-read-a-winmd-winrt-metadata-file
// https://docs.microsoft.com/en-us/windows/win32/api/rometadataresolution/nf-rometadataresolution-rogetmetadatafile

import 'package:win32/src/extensions/intToHexString.dart';

import 'mdFile.dart';
import 'mdMethod.dart';
import 'utils.dart';

void listTokens() {
  final file = metadataFileContainingType('Windows.Globalization.Calendar');
  final winmdFile = WinmdFile(file);

  for (var type in winmdFile.typeDefs) {
    print(
        '[${toHex(type.token)}] ${type.typeName} (baseType: ${toHex(type.baseTypeToken)})');
  }
}

void listMethods([String type = 'Windows.Globalization.Calendar']) {
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);
  final methods = winTypeDef.methods;

  for (var method in methods) {
    printMethod(method);
  }
}

void listParameters([String type = 'Windows.Globalization.Calendar']) {
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);
  final method = winTypeDef.findMethod('HourAsPaddedString');

  print('${method.methodName} has '
      '${method.parameters.length - 1} parameter(s).');

  // the zeroth parameter is the return type
  for (var i = 1; i < method.parameters.length; i++) {
    print('[${method.parameters[i].sequence}] ${method.parameters[i].name}');
  }

  final returnType = method.returnType;
  print('\nreturns: ${returnType.name}');
}

void listInterfaces([String type = 'Windows.Globalization.Calendar']) {
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);

  final interfaces = winTypeDef.interfaces;

  print('$type implements:');
  for (var interface in interfaces) {
    print('  ${interface.typeName}');
    listMethods(interface.typeName);
  }
}

// [uuid(CA30221D-86D9-40FB-A26B-D44EB7CF08EA)]
void listGUID([String type = 'Windows.Globalization.ICalendar']) {
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);
  print(winTypeDef.guid);
}

void printInterface() {
  final type = 'Windows.Globalization.ICalendar';
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);
  print(winTypeDef.typeName);
  print(winTypeDef.guid);
  print('inherits ${winTypeDef.parent.typeName}');

  for (var method in winTypeDef.methods) {
    printMethod(method);
  }
}

void printMethod(WinmdMethod method) {
  final buffer = StringBuffer();
  buffer.write('${method.isPublic ? 'public ' : ''}'
      '${method.isPrivate ? 'private ' : ''}'
      '${method.isStatic ? 'static ' : ''}'
      '${method.isFinal ? 'final ' : ''}'
      '${method.isVirtual ? 'virtual ' : ''}'
      '${method.isSpecialName ? 'special ' : ''}'
      '${method.isRTSpecialName ? 'rt_special ' : ''}'
      '${method.callingConvention}'
      '${method.returnType.typeFlag.nativeType} '
      '${method.methodName} (');

  // if (method.parameters.length != method.parameterNames.length - 1) {
  //   print('failed trying to print method ${method.methodName}');
  //   print(
  //       'signparams: ${method.parameters.length} / methparams: ${method.parameterNames.length}');
  //   return;
  // } else {
  //   for (var idx = 0; idx < method.parameters.length; idx++) {
  //     buffer.write('${method.parameters[idx].toNativeType} ');
  //     buffer.write('${method.parameterNames[idx + 1].name}, ');
  //   }
  //   print('${buffer.toString().substring(0, buffer.length - 2)});');
  // }
}

void printTypeParams() {
  final type = 'Windows.Foundation.IAsyncInfo';
  final file = metadataFileContainingType(type);
  final winmdFile = WinmdFile(file);

  final winTypeDef = winmdFile.findTypeDef(type);
  print(winTypeDef.typeName);
  final mapns = winTypeDef.findMethod('get_ErrorCode');
  print(mapns.methodName);
  print(mapns.parameters.length);
  print(mapns.signature.map((entry) => entry.toHexString(8)));
  print('returns ${mapns.returnType.typeFlag.nativeType}');
  for (var param in mapns.parameters) {
    print('${param.typeFlag.nativeType} ${param.name}');
  }
}

void getAsyncStatusToken() {
  final file = metadataFileContainingType('Windows.Foundation.AsyncStatus');
  final winmdFile = WinmdFile(file);

  final type = winmdFile.findTypeDef('Windows.Foundation.AsyncStatus');
  print(type.token.toHexString(32));
}

void main() {
  printTypeParams();
}
