import 'dart:io';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

// usage: ev <ws-uri> <lib-suffix> <expr>   (expr '-' = read stdin)
Future<void> main(List<String> a) async {
  final svc = await vmServiceConnectUri(a[0]);
  try {
    var expr = a[2];
    if (expr == '-') expr = await stdin.transform(const SystemEncoding().decoder).join(); expr = expr.replaceAll('\n', ' ').trim();
    final vm = await svc.getVM();
    for (final iso in vm.isolates!) {
      final i = await svc.getIsolate(iso.id!);
      final lib = i.libraries!.where((l) => l.uri!.endsWith(a[1])).firstOrNull;
      if (lib == null) continue;
      final r = await svc.evaluate(iso.id!, lib.id!, expr);
      if (r is InstanceRef) {
        if (r.kind == 'String') {
          final full = await svc.getObject(iso.id!, r.id!) as Instance;
          print(full.valueAsString);
        } else {
          print('${r.kind}: ${r.valueAsString}');
        }
      } else if (r is ErrorRef) {
        print('ERROR: ${r.message}');
        exitCode = 1;
      } else {
        print(r);
      }
      break;
    }
  } finally {
    await svc.dispose();
  }
}
