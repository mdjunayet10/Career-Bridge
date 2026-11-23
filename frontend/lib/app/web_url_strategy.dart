import 'web_url_strategy_stub.dart'
    if (dart.library.html) 'web_url_strategy_web.dart' as implementation;

void configureWebUrlStrategy() => implementation.configureWebUrlStrategy();
