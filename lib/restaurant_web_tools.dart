import 'package:flutter/services.dart';

// Herramientas del portal adaptadas al teléfono: aviso sonoro del sistema, copiar el reporte al
// portapapeles. La impresión automática de comandas y la vuelta al panel de administración solo
// existen en la web.

/// Aviso sonoro corto para pedidos nuevos.
void restaurantBeep() {
  try {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
  } catch (_) {}
}

/// En el teléfono el reporte se copia al portapapeles (para pegarlo en una hoja de cálculo).
void restaurantDownloadText(String filename, String text,
    {String mime = 'text/csv;charset=utf-8'}) {
  Clipboard.setData(ClipboardData(text: text));
}

/// Sin impresión desde el teléfono.
void restaurantPrintHtml(String html) {}

/// Quita parámetros de la dirección (solo aplica en la web).
void restaurantCleanUrl() {}

/// Solo aplica a la web.
void restaurantReturnToAdmin(String adminUrl) {}
